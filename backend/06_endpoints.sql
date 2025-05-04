create or replace function save_tricount(
    save_id int,
    save_title text,
    save_description text,
    save_creator int,
    save_participants integer[]) returns void  as 
    $$
    begin
        perform auth.check_logged();
        if save_id = 0 then
            
            insert into tricount(title, description, participant,creator) values (save_title,save_description,save_participants,save_creator);
        end if;
        if save_id > 0 then
            update tricount set title = save_title , description = save_description , participant = save_participants
                            where id = save_id;
        end if;
    end;
    
$$language plpgsql security definer; 

grant execute on function save_tricount to authenticated;

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
grant execute on function get_all_users() to authenticated;

create or replace function check_tricount_title_available(title text, tricount_id integer default 0)
    returns boolean as
$$
declare
    current_user_id integer;
begin
    -- Vérifie que l'utilisateur est connecté et récupère son ID
    current_user_id := auth.id();

    -- Normalise le titre (trim et lowercase pour la comparaison)
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
    -- Vérifie que l'utilisateur est connecté
    current_user_id := auth.id();

    -- Vérifie que le tricount existe
    if not exists(select 1 from tricount where id = tricount_id) then
        raise exception 'Tricount non trouvé';
    end if;

    -- Récupère le créateur du tricount
    select creator into tricount_creator_id
    from tricount
    where id = tricount_id;

    -- Vérifie si l'utilisateur est admin
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
    depense_id integer,              -- requis (0 pour création)
    tricount_id integer,     -- requis pour création
    title text,              -- requis
    amount double precision, -- requis
    initiator integer,       -- requis
    repartitions jsonb,      -- requis et non vide
    operation_date timestamp default null  -- seul paramètre optionnel
)
    returns integer as
$$
declare
    current_user_id integer;
    new_operation_id integer;
begin
    -- Vérifie que l'utilisateur est connecté
    perform auth.check_logged();
    current_user_id := auth.id();

    -- Cas création (id = 0)
    if depense_id = 0 then
        -- Vérifie que tricount_id est fourni pour une création
        if tricount_id is null then
            raise exception 'tricount_id est requis pour une création';
        end if;

        -- Vérifie que l'utilisateur a accès au tricount
        if not exists (
            select 1
            from participation
            where participation.tricount_id = save_operation.tricount_id
              and user_id = current_user_id
        ) then
            raise exception 'Accès non autorisé à ce tricount';
        end if;

        -- Insertion nouvelle dépense
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
                 ) returning id into new_operation_id;

        return new_operation_id;

        -- Cas modification (id > 0)
    else
        -- Vérifie que la dépense existe
        if not exists (select 1 from depense where depense.id = save_operation.depense_id) then
            raise exception 'Dépense non trouvée';
        end if;

        -- Vérifie que l'utilisateur a accès à cette dépense
        if not exists (
            select 1
            from depense d
                     join participation p on d.tricount_id = p.tricount_id
            where d.id = save_operation.depense_id
              and p.user_id = current_user_id
        ) then
            raise exception 'Accès non autorisé à cette dépense';
        end if;

        -- Mise à jour de la dépense
        update depense set
                           title = trim(save_operation.title),
                           amount = save_operation.amount,
                           operation_date = coalesce(save_operation.operation_date, current_timestamp),
                           initiator = save_operation.initiator,
                           repartition = save_operation.repartitions
        where id = save_operation.depense_id;

        return save_operation.depense_id;
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
create or replace function get_tricount_balance(tricount_id integer)
    returns table (
                      user_id integer,
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
                    COALESCE(SUM(d.amount::numeric), 0) as amount
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
                             ), 0) as amount
                FROM participation p
                         CROSS JOIN depense d
                         CROSS JOIN jsonb_array_elements(d.repartition) rep
                WHERE d.tricount_id = get_tricount_balance.tricount_id
                  AND p.tricount_id = d.tricount_id
                  AND rep->>'user_id' = CAST(p.user_id AS text)
                GROUP BY p.user_id
            )
        SELECT
            p.user_id,
            COALESCE(paid.amount, 0)::numeric as paid,
            COALESCE(due.amount, 0)::numeric as due,
            COALESCE(paid.amount, 0) - COALESCE(due.amount, 0)::numeric as balance
        FROM participation p
                 LEFT JOIN paid_amounts paid ON paid.user_id = p.user_id
                 LEFT JOIN due_amounts due ON due.user_id = p.user_id
        WHERE p.tricount_id = get_tricount_balance.tricount_id;

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
        select json_agg(tricount_with_details order by last_operation_date desc nulls last, created_at desc)
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
                         select json_agg(operation_details order by operation_date desc)
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
                                                                 'user', (rep->>'user_id')::integer,
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
             ) tricount_with_details
    );
end;
$$ language plpgsql security definer;
grant execute on function get_my_tricounts() to authenticated;

select * from depense;
