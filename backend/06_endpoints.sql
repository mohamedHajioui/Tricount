create or replace function save_tricount(
    id integer,                   
    title text,                   
    description text default null, --  et valeur par défaut
    participants integer[] default null --  valeur par défaut
)
    returns json as
$$
declare
    current_user_id integer;
    new_tricount_id integer;
    tricount_creator_id integer;
    final_participants integer[];
begin
    -- Obtenir l'ID de l'utilisateur connecté
    perform auth.check_logged();
    current_user_id := auth.id();

    -- S'assurer que l'utilisateur connecté est toujours inclus comme participant
    if participants is null then
        final_participants := array[current_user_id];
    else
        -- Vérifier si l'utilisateur connecté est déjà dans les participants
        if not (current_user_id = any(participants)) then
            final_participants := array_append(participants, current_user_id);
        else
            final_participants := participants;
        end if;
    end if;

    -- Cas création (id = 0)
    if id = 0 then
        -- Insérer dans tricount (l'utilisateur connecté est le créateur)
        insert into tricount(title, description, participant, creator)
        values (
                   title,
                   description,
                   final_participants,
                   current_user_id
               )
        returning tricount.id into new_tricount_id;

        -- Ajouter tous les participants dans la table participation
        insert into participation(user_id, tricount_id)
        select unnest(final_participants), new_tricount_id
        on conflict do nothing;

        -- Retourner le tricount complet au format JSON
        return (
            select json_build_object(
                           'id', t.id,
                           'title', t.title,
                           'description', t.description,
                           'created_at', t.date_hour,
                           'creator', t.creator,
                           'participants', (
                               select json_agg(
                                              json_build_object(
                                                      'id', u.id,
                                                      'email', u.email,
                                                      'full_name', u.full_name,
                                                      'iban', u.iban,
                                                      'role', u.role
                                              )
                                      )
                               from users u
                               where u.id = any(t.participant)
                           ),
                           'operations', (
                               select coalesce(
                                              json_agg(
                                                      json_build_object(
                                                              'id', d.id,
                                                              'title', d.title,
                                                              'amount', d.amount,
                                                              'operation_date', d.operation_date,
                                                              'initiator', d.initiator,
                                                              'created_at', d.created_at,
                                                              'repartitions', d.repartition
                                                      )
                                              ),
                                              '[]'::json
                                      )
                               from depense d
                               where d.tricount_id = t.id
                           )
                   )
            from tricount t
            where t.id = new_tricount_id
        );
    else
        -- Cas modification (id > 0)

        -- Vérifier que l'utilisateur a le droit de modifier ce tricount
        if not exists (
            select 1 from tricount
            where tricount.id = save_tricount.id
              and (creator = current_user_id or current_user_id = any(participant))
        ) then
            raise exception 'Accès non autorisé à ce tricount';
        end if;

        -- Récupérer le créateur du tricount
        select creator into tricount_creator_id
        from tricount
        where tricount.id = save_tricount.id;

        -- S'assurer que le créateur reste dans les participants
        if not (tricount_creator_id = any(final_participants)) then
            final_participants := array_append(final_participants, tricount_creator_id);
        end if;

        -- Mettre à jour le tricount
        update tricount
        set title = save_tricount.title,
            description = save_tricount.description,
            participant = final_participants
        where tricount.id = save_tricount.id;

        -- Supprimer les participations qui ne sont plus dans le tableau
        -- SAUF le créateur et ceux impliqués dans des opérations
        delete from participation p
        where p.tricount_id = save_tricount.id
          and not (p.user_id = any(final_participants))
          and p.user_id != tricount_creator_id
          and not exists (
            select 1 from depense d
                              join jsonb_array_elements(d.repartition) as rep on (rep->>'user')::integer = p.user_id
            where d.tricount_id = save_tricount.id
        );

        -- Ajouter les nouvelles participations
        insert into participation(user_id, tricount_id)
        select unnest(final_participants), save_tricount.id
        on conflict do nothing;

        -- Retourner le tricount complet au format JSON
        return (
            select json_build_object(
                           'id', t.id,
                           'title', t.title,
                           'description', t.description,
                           'created_at', t.date_hour,
                           'creator', t.creator,
                           'participants', (
                               select json_agg(
                                              json_build_object(
                                                      'id', u.id,
                                                      'email', u.email,
                                                      'full_name', u.full_name,
                                                      'iban', u.iban,
                                                      'role', u.role
                                              )
                                      )
                               from users u
                               where u.id = any(t.participant)
                           ),
                           'operations', (
                               select coalesce(
                                              json_agg(
                                                      json_build_object(
                                                              'id', d.id,
                                                              'title', d.title,
                                                              'amount', d.amount,
                                                              'operation_date', d.operation_date,
                                                              'initiator', d.initiator,
                                                              'created_at', d.created_at,
                                                              'repartitions', d.repartition
                                                      )
                                              ),
                                              '[]'::json
                                      )
                               from depense d
                               where d.tricount_id = t.id
                           )
                   )
            from tricount t
            where t.id = save_tricount.id
        );
    end if;
end;
$$ language plpgsql security definer;

grant execute on function save_tricount(integer, text, text, integer[]) to authenticated;
/*DROP FUNCTION save_tricount(integer,text,text,integer,integer[]);*/

create or replace function get_user_data()
    returns setof users as
$$
begin
    perform auth.check_logged();
    return query select *
                 from users
                 where users.email = auth.email();
end;
$$ language plpgsql security definer;
grant execute on function get_user_data() to authenticated;

create or replace function check_email_available(email text, user_id integer default 0)
returns boolean as
$$
    begin 
        if user_id = 0 then 
            return not exists(
                select 1 from users where users.email = check_email_available.email
                
            );
        else 
            return not exists(
                select 1 from users
                where users.email = check_email_available.email
                and users.id <> check_email_available.user_id
            );
        end if;
    end;
$$ language plpgsql security definer;
grant execute on function check_email_available(text, integer) to anon;

DROP FUNCTION check_full_name_available(text,integer);
create or replace function check_full_name_available(fullName text, user_id integer default 0)
    returns boolean as
$$
begin
    if user_id = 0 then
        return not exists(
            select 1 from users where users.full_name = check_full_name_available.fullName

        );
    else
        return not exists(
            select 1 from users
            where users.full_name = check_full_name_available.fullName
              and users.id <> check_full_name_available.user_id
        );
    end if;
end;
$$ language plpgsql security definer;
grant execute on function check_full_name_available(text,integer) to anon;



create or replace function get_all_users()
returns setof users as
$$
  begin 
      return query
        select *
        from users
        order by full_name;
      
end;
$$ language plpgsql security definer;
grant execute on function get_all_users() to anon;

create or replace function check_tricount_title_available(title text, tricount_id integer default 0)
    returns boolean as
$$
declare
    current_user_id integer;
begin
    
    current_user_id := auth.id();

   
    title := lower(trim(title));

    if tricount_id = 0 then
        -- Cas création : vérifie que le titre n'existe pas déjà pour cet utilisateur
        return not exists(
            select 1
            from tricount
            where lower(trim(tricount.title)) = check_tricount_title_available.title
              and creator = current_user_id
        );
    else
        -- Cas modification : vérifie que le titre n'existe pas déjà pour cet utilisateur
        -- en excluant le tricount en cours de modification
        return not exists(
            select 1
            from tricount
            where lower(trim(tricount.title)) = check_tricount_title_available.title
              and creator = current_user_id
              and id != tricount_id
        );
    end if;
end;
$$ language plpgsql security definer;

grant execute on function check_tricount_title_available(text,integer) to authenticated;






create or replace function delete_tricount(tricount_id integer)
    returns void as $$
declare
    current_user_id integer;
    is_admin boolean;
    tricount_creator_id integer;
begin
    
    current_user_id := auth.id();

    
    if not exists(select 1 from tricount where id = tricount_id) then
        raise exception 'Tricount non trouvé';
    end if;

    
    select creator into tricount_creator_id
    from tricount
    where id = tricount_id;

   
    select role = 'admin' into is_admin
    from users
    where id = current_user_id;

    -- Vérifie les permissions
    if not (current_user_id = tricount_creator_id or is_admin) then
        raise exception 'Permission refusée';
    end if;

    -- Tente de supprimer (le trigger vérifiera les règles métier)
    delete from tricount where id = tricount_id;
end;
$$ language plpgsql security definer;
grant execute on function delete_tricount(integer) to authenticated;



create or replace function save_operation(
    id integer,
    tricount_id integer,
    title text,
    amount double precision,
    initiator integer,
    repartitions jsonb,
    operation_date timestamp default null
)
    returns json as
$$
declare
    current_user_id integer;
    new_operation_id integer;
    participant_ids integer[];
    current_tricount_id integer;
    depense_id integer; -- Variable locale pour éviter l'ambiguïté
begin
    perform auth.check_logged();
    current_user_id := auth.id();

    -- Assignez la valeur du paramètre id à la variable locale
    depense_id := id;

    -- Extraire les IDs des utilisateurs de la répartition
    with users_in_repartition as (
        select ((rep->>'user')::integer) as user_id
        from jsonb_array_elements(repartitions) rep
    )
    select array_agg(user_id) into participant_ids
    from users_in_repartition;


    if depense_id = 0 then
        -- Ajouter l'initiateur à la liste des participants s'il n'y est pas déjà
        if not (initiator = any(participant_ids)) then
            participant_ids := array_append(participant_ids, initiator);
        end if;

        -- Ajouter les participants à la table participation
        insert into participation(user_id, tricount_id)
        select unnest(participant_ids), save_operation.tricount_id
        on conflict do nothing;

        -- Mettre à jour le tableau participant de la table tricount
        update tricount
        set participant = array(
                select distinct unnest(array_cat(participant, participant_ids))
                from tricount
                where tricount.id = save_operation.tricount_id
                          )
        where tricount.id = save_operation.tricount_id;

        insert into depense (
            tricount_id,
            title,
            amount,
            operation_date,
            initiator,
            repartition
        ) values (
                     tricount_id,
                     trim(title),
                     amount,
                     coalesce(operation_date, current_timestamp),
                     initiator,
                     repartitions
                 ) returning depense.id into new_operation_id;

        return (
            select json_build_object(
                           'id', d.id,
                           'title', d.title,
                           'amount', d.amount,
                           'operation_date', to_char(d.operation_date::date, 'YYYY-MM-DD'),
                           'initiator', d.initiator,
                           'created_at', d.created_at,
                           'repartitions', d.repartition
                   )
            from depense d
            where d.id = new_operation_id
        );
    else
        -- Ajouter l'initiateur à la liste des participants s'il n'y est pas déjà
        if not (initiator = any(participant_ids)) then
            participant_ids := array_append(participant_ids, initiator);
        end if;

        -- Récupérer le tricount_id associé à cette dépense
        select d.tricount_id into current_tricount_id
        from depense d
        where d.id = depense_id;

        -- Ajouter les participants à la table participation
        insert into participation(user_id, tricount_id)
        select unnest(participant_ids), current_tricount_id
        on conflict do nothing;

        -- Mettre à jour le tableau participant de la table tricount
        update tricount
        set participant = array(
                select distinct unnest(array_cat(participant, participant_ids))
                from tricount
                where tricount.id = current_tricount_id
                          )
        where tricount.id = current_tricount_id;

        update depense set
                           title = trim(save_operation.title),
                           amount = save_operation.amount,
                           operation_date = coalesce(save_operation.operation_date, current_timestamp),
                           initiator = save_operation.initiator,
                           repartition = save_operation.repartitions
        where depense.id = depense_id;

        return (
            select json_build_object(
                           'id', d.id,
                           'title', d.title,
                           'amount', d.amount,
                           'operation_date', to_char(d.operation_date::date, 'YYYY-MM-DD'),
                           'initiator', d.initiator,
                           'created_at', d.created_at,
                           'repartitions', d.repartition
                   )
            from depense d
            where d.id = depense_id
        );
    end if;
end;
$$ language plpgsql security definer;

grant execute on function save_operation(
    integer,    -- id
    integer,    -- tricount_id
    text,       -- title
    double precision, -- amount
    integer,    -- initiator
    jsonb,      -- repartitions
    timestamp   -- operation_date
    ) to authenticated;
create or replace function delete_operation(operation_id integer)
    returns void as $$
declare
    current_user_id integer;
    is_admin boolean;
begin
    -- Vérifie que l'utilisateur est connecté
    perform auth.check_logged();
    current_user_id := auth.id();

    -- Vérifie que la dépense existe
    if not exists(select 1 from depense where id = operation_id) then
        raise exception 'Dépense non trouvée';
    end if;

    -- Vérifie si l'utilisateur est admin
    select role = 'admin' into is_admin
    from users
    where id = current_user_id;

    -- Si pas admin, vérifie que l'utilisateur est participant du tricount
    if not is_admin then
        if not exists (
            select 1
            from depense d
                     join participation p on d.tricount_id = p.tricount_id
            where d.id = operation_id
              and p.user_id = current_user_id
        ) then
            raise exception 'Accès non autorisé à cette dépense';
        end if;
    end if;

    -- Supprime la dépense
    delete from depense where id = operation_id;
end;
$$ language plpgsql security definer;

grant execute on function delete_operation(integer) to authenticated;
DROP FUNCTION get_tricount_balance(integer);
create or replace function get_tricount_balance(tricount_id integer)
    returns table (
                      "user" integer,
                      paid numeric,
                      due numeric,
                      balance numeric
                  ) as $$
declare
    current_user_id integer;
    is_admin boolean;
begin
    -- Vérifie que l'utilisateur est connecté
    perform auth.check_logged();
    current_user_id := auth.id();

    -- Vérifie si admin
    select role = 'admin' into is_admin
    from users u
    where u.id = current_user_id;

    -- Vérifie les droits d'accès (si pas admin)
    if not is_admin then
        if not exists (
            select 1
            from participation p
            where p.tricount_id = get_tricount_balance.tricount_id
              and p.user_id = current_user_id
        ) then
            raise exception 'Accès non autorisé à ce tricount';
        end if;
    end if;

    return query
        WITH
            paid_amounts AS (
                SELECT
                    p.user_id,
                    COALESCE(SUM(d.amount::numeric), 0)::numeric(10,2) as amount
                FROM participation p
                         LEFT JOIN depense d ON d.tricount_id = p.tricount_id AND d.initiator = p.user_id
                WHERE p.tricount_id = get_tricount_balance.tricount_id
                GROUP BY p.user_id
            ),
            due_amounts AS (
                SELECT
                    p.user_id,
                    COALESCE(SUM(
                                     d.amount * (CAST((rep->>'weight') AS numeric) /
                                                 (SELECT SUM(CAST((r->>'weight') AS numeric))
                                                  FROM jsonb_array_elements(d.repartition) r))
                             ), 0)::numeric(10,2) as amount
                FROM participation p
                         CROSS JOIN depense d
                         CROSS JOIN jsonb_array_elements(d.repartition) rep
                WHERE d.tricount_id = get_tricount_balance.tricount_id
                  AND p.tricount_id = d.tricount_id
                  AND rep->>'user' = CAST(p.user_id AS text)
                GROUP BY p.user_id
            ),
            base_results AS (
                SELECT
                    p.user_id,
                    COALESCE(paid.amount, 0)::numeric(10,2) as paid,
                    COALESCE(due.amount, 0)::numeric(10,2) as due,
                    (COALESCE(paid.amount, 0) - COALESCE(due.amount, 0))::numeric(10,2) as balance
                FROM participation p
                         LEFT JOIN paid_amounts paid ON paid.user_id = p.user_id
                         LEFT JOIN due_amounts due ON due.user_id = p.user_id
                WHERE p.tricount_id = get_tricount_balance.tricount_id
            )
        SELECT
            base_results.user_id,
            -- Convertir en texte, supprimer les zéros à la fin et reconvertir en numeric
            trim(trailing '0' from trim(trailing '.' from base_results.paid::text))::numeric as paid,
            trim(trailing '0' from trim(trailing '.' from base_results.due::text))::numeric as due,
            trim(trailing '0' from trim(trailing '.' from base_results.balance::text))::numeric as balance
        FROM base_results;

end;
$$ language plpgsql security definer;
grant execute on function get_tricount_balance(integer) to authenticated;


create or replace function get_my_tricounts()
    returns json as $$
declare
    current_user_id integer;
begin
    -- Vérifie que l'utilisateur est connecté
    perform auth.check_logged();
    current_user_id := auth.id();

    return (
        select json_agg(
                       json_build_object(
                               'id', tricount_data.id,
                               'title', tricount_data.title,
                               'description', tricount_data.description,
                               'created_at', tricount_data.created_at,
                               'creator', tricount_data.creator,
                               'participants', tricount_data.participants,
                               'operations', tricount_data.operations
                       )
                       order by tricount_data.last_operation_date desc nulls last, tricount_data.created_at desc
               )
        from (
                 select
                     t.id,
                     t.title,
                     t.description,
                     t.date_hour as created_at,
                     t.creator,
                     COALESCE(
                             (select max(d.operation_date)
                              from depense d
                              where d.tricount_id = t.id),
                             t.date_hour
                     ) as last_operation_date,
                     (
                         -- Get participants details
                         select json_agg(user_details)
                         from (
                                  select
                                      u.id,
                                      u.email,
                                      u.full_name,
                                      u.iban,
                                      u.role
                                  from users u
                                           join participation p on u.id = p.user_id
                                  where p.tricount_id = t.id
                                  order by u.id
                              ) user_details
                     ) as participants,
                     (
                         -- Get operations details
                         select COALESCE(json_agg(operation_details order by operation_date desc,id desc ),'[]'::json)
                         from (
                                  select
                                      d.id,
                                      d.title,
                                      d.amount,
                                      to_char(d.operation_date, 'YYYY-MM-DD') as operation_date,
                                      d.initiator,
                                      to_char(d.created_at, 'YYYY-MM-DD"T"HH24:MI:SS') as created_at,
                                      (
                                          -- Transform repartition format
                                          select json_agg(
                                                         json_build_object(
                                                                 'user', (rep->>'user')::integer,
                                                                 'weight', (rep->>'weight')::integer
                                                         )
                                                 )
                                          from jsonb_array_elements(d.repartition) rep
                                      ) as repartitions
                                  from depense d
                                  where d.tricount_id = t.id
                              ) operation_details
                     ) as operations
                 from tricount t
                          join participation p on t.id = p.tricount_id
                 where p.user_id = current_user_id
             ) tricount_data
    );
end;
$$ language plpgsql security definer;
grant execute on function get_my_tricounts() to authenticated;

CREATE OR REPLACE FUNCTION reset_database()
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = public
AS $$
BEGIN
    -- On remet TOUT à zéro
    TRUNCATE TABLE depense, participation, tricount, users RESTART IDENTITY CASCADE;

    -- USERS
    INSERT INTO users (id, email, password, full_name, role, iban)
    VALUES
        (1, 'boverhaegen@epfc.eu', 'Password1,', 'Boris',    'basic_user', NULL),
        (2, 'bepenelle@epfc.eu',   'Password1,', 'Benoît',   'basic_user', NULL),
        (3, 'xapigeolet@epfc.eu',  'Password1,', 'Xavier',   'basic_user', NULL),
        (4, 'mamichel@epfc.eu',    'Password1,', 'Marc',     'basic_user', 'BE12 1234 1234 1234'),
        (5, 'gedielman@epfc.eu',   'Password1,', 'Geoffrey', 'basic_user', 'BE45 4567 4567 4567'),
        (9, 'admin@epfc.eu',       'Password1,', 'Admin',    'admin',      NULL);

    PERFORM setval('users_id_seq', (SELECT MAX(id) FROM users));

    -- TRICOUNT
    INSERT INTO tricount(id, title, description, creator, participant, date_hour)
    VALUES
        (4, 'Vacances', 'A la mer du nord', 1, ARRAY[2, 1, 4, 3], '2024-10-10T19:31:09'),
        (2, 'Resto badminton', NULL, 1, ARRAY[2, 1], '2024-10-10T19:25:10'),
        (1, 'Gers 2022', NULL, 1, ARRAY[1], '2024-10-10T18:42:24'); 

    PERFORM setval(pg_get_serial_sequence('tricount', 'id'), (SELECT MAX(id) FROM tricount));

    -- PARTICIPATIONS
    INSERT INTO participation(user_id, tricount_id)
    VALUES
        -- Vacances
        (2, 4), (1, 4), (4, 4), (3, 4),
        -- Resto badminton
        (2, 2), (1, 2),
        -- Gers 2022 (juste Boris)
        (1, 1);

    INSERT INTO depense(id, tricount_id, title, amount, operation_date, created_at, initiator, repartition)
    VALUES
        (6, 4, 'Loterie', 35.0, '2024-10-26', '2024-10-26T10:02:24', 1,
         '[{"user": 1, "weight": 1}, {"user": 3, "weight": 1}]'),
        (5, 4, 'Boucherie', 25.5, '2024-10-26', '2024-10-26T09:59:56', 2,
         '[{"user": 1, "weight": 2}, {"user": 2, "weight": 1}, {"user": 3, "weight": 1}]'),
        (4, 4, 'Apéros', 31.897456217, '2024-10-13', '2024-10-13T23:51:20', 1,
         '[{"user": 1, "weight": 1}, {"user": 2, "weight": 2}, {"user": 3, "weight": 3}]'),
        (3, 4, 'Grosses courses LIDL', 212.47, '2024-10-13', '2024-10-13T21:23:49', 3,
         '[{"user": 1, "weight": 2}, {"user": 2, "weight": 1}, {"user": 3, "weight": 1}]'),
        (2, 4, 'Plein essence', 75.0, '2024-10-13', '2024-10-13T20:10:41', 1,
         '[{"user": 1, "weight": 1}, {"user": 2, "weight": 1}]'),
        (1, 4, 'Colruyt', 100.0, '2024-10-13', '2024-10-13T19:09:18', 2,
         '[{"user": 1, "weight": 1}, {"user": 2, "weight": 1}]');

    PERFORM setval(pg_get_serial_sequence('depense', 'id'), (SELECT MAX(id) FROM depense));
END;
$$;

grant execute on function save_tricount to authenticated;
GRANT EXECUTE ON FUNCTION reset_database() TO anon;

