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



------------------------------------------------------------------------------------------------------------------------