alter table users
    add constraint unique_email unique (email);

alter table users
    add constraint chk_full_name_length check (length(users.full_name) >= 3);

alter table users
    add constraint chk_iban_format
        check (
            iban is null or
            replace(iban, ' ', '') ~ '^BE[0-9]{14}$'
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



---------------------------------------------depense--------------------------------------------------------------------

alter table depense
    add constraint title_length check ( length(title) >=3 );

alter table depense
    add constraint montant_check check ( amount >= 0.01 );

create or replace function check_inserted_date() returns trigger as
$$
declare
    tricount_date timestamp;
begin
    select tricount.date_hour into tricount_date
    from tricount
    where id = NEW.tricount_id;

    if NEW.operation_date < tricount_date then
        raise exception 'La date de l operation preccede celle du tricount';
    end if;
end;
$$language plpgsql;

create trigger correcte_operation_date
    before insert or update on tricount
    for each row
execute function check_inserted_date();


-----------------------------------------------------------------------------------------------------------------------

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
            and d.repartition @> format('[{"user_id": %s}]', old.user_id)::jsonb
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
