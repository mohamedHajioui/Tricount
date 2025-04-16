-----------------------------------------------Tricount-----------------------------------------------------------------

--Exception lors du changement du nom de l'utilisateurs
create or replace function block_username_update()
    returns trigger as $$
begin
    if New.creator is distinct from OLD.creator then
        Raise exception 'creator information cannot be changed';
    end if;
end;
$$ language plpgsql;

------------------------------------------------------------------------------------------------------------------------