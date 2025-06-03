alter table users
    add constraint unique_email unique (email);

ALTER TABLE users
    ADD CONSTRAINT user_email_format
        CHECK (
            email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            );


alter table users
    add constraint check_full_name_length check (length(users.full_name) >= 3);


ALTER TABLE users
    ADD CONSTRAINT user_iban_format
        CHECK (
            iban IS NULL
                OR iban ~ '^BE[0-9]{2}( [0-9]{4}){3}$'
            );




-----------------------------------------------Tricount-----------------------------------------------------------------
    
-- longeur d'un titre
alter table tricount
    add constraint title_length check (length(title) >= 3);


-- un creator ne peux creer que un meme titre
alter table tricount
    add constraint unique_title_for_a_creator unique (creator,title );

-- longeur d'une descpition
alter table tricount
    add constraint desctiption_length check (length(description) >= 3 or length(description) = 0);


create or replace function block_username_update()
    returns trigger as $$
begin
    if New.creator is distinct from OLD.creator then
        Raise exception 'creator information cannot be changed';
    end if;
end;
$$ language plpgsql;


--Exception lors du changement du nom de l'utilisateurs
create or replace function block_username_update()
    returns trigger as $$
begin
    if New.creator is distinct from OLD.creator then
        Raise exception 'creator information cannot be changed';
    end if;
    return New;
end;
$$ language plpgsql;

create trigger prevent_username_change
    before update on tricount
    for each row
execute function block_username_update();



------------------------------------------------------------------------------------------------------------------------

alter table depense
    add constraint title_length check ( length(title) >=3 );

alter table depense
    add constraint montant_check check ( amount >= 0.01 );

DROP TRIGGER IF EXISTS correcte_operation_date ON tricount;
-- Ajouter la contrainte à la table depense
ALTER TABLE depense
    ADD CONSTRAINT operation_date_not_future
        CHECK (operation_date::date <= CURRENT_DATE);

CREATE OR REPLACE FUNCTION check_inserted_date() RETURNS TRIGGER as
$$
DECLARE
    tricount_date date;
BEGIN

    SELECT date(date_hour) INTO tricount_date
    FROM tricount
    WHERE id = NEW.tricount_id;

    /* Si la dépense est antérieure : exception */
    IF NEW.operation_date::date < tricount_date THEN
        RAISE EXCEPTION
            'La date de l''opération (%) précède la date de création du tricount (%)',
            NEW.operation_date::date, tricount_date;
    END IF;
    RETURN NEW;       
END;
$$ language plpgsql;

CREATE TRIGGER correcte_operation_date
    BEFORE INSERT OR UPDATE ON depense
    FOR EACH ROW
EXECUTE FUNCTION check_inserted_date();


create or replace function check_participation_deletion()
returns trigger as
$$
    declare 
        v_creator_id integer;
        v_user_in_depense boolean;
        
begin
    -- ne pas supprimer le créateur du tricount
    select creator into v_creator_id
    from tricount
    where id = old.tricount_id;
    
    if v_creator_id = old.user_id then
        raise exception 'Impossible de supprimer le créateur du tricount';
    end if;
    
    --ne pas supprimer un participant impliqué dans une dépense
    select exists (
        select 1
        from depense d 
        where d.tricount_id = old.tricount_id
            and d.initiator = old.user_id
    ) into v_user_in_depense;
    
    if v_user_in_depense then
        raise exception 'Impossible de supprimer un participant qui est initiateur d''une dépense.';
    end if;

    -- Vérifie si l'utilisateur apparaît dans une répartition (jsonb)
    select exists(
        select 1
        from depense d
        where d.tricount_id = old.tricount_id
            and d.repartition @> format('[{"user": %s}]', old.user_id)::jsonb
    ) into v_user_in_depense;
    
    if v_user_in_depense then
        raise exception 'Impossible de supprimer un participant impliqué dans une répartition.';
    end if;
    
    return old;
end; 
$$ language plpgsql;

create trigger before_delete_participation
before delete on participation
for each row 
execute procedure check_participation_deletion();
CREATE OR REPLACE FUNCTION check_repartition_participants()
    RETURNS TRIGGER set search_path from current as $$
DECLARE
    v_user_id integer;
BEGIN
    -- Vérifie qu'il y a au moins une répartition
    IF jsonb_array_length(NEW.repartition) = 0 THEN
        RAISE EXCEPTION 'An operation must have at least one repartition';
    END IF;
    -- Pour chaque utilisateur dans la répartition
    FOR v_user_id IN (
        SELECT (jsonb_array_elements(NEW.repartition)->>'user')::integer
    )
        LOOP
            -- Vérifie que l'utilisateur est participant du tricount
            IF NOT EXISTS (
                SELECT 1
                FROM participation p
                WHERE p.tricount_id = NEW.tricount_id
                  AND p.user_id = v_user_id
            ) THEN
                RAISE EXCEPTION 'L''utilisateur % n''est pas participant du tricount', v_user_id;
            END IF;
        END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql security definer;

CREATE constraint TRIGGER check_repartition_participants_trigger
    after insert or update
    on depense
    deferrable initially deferred
    for each row
EXECUTE FUNCTION check_repartition_participants();

