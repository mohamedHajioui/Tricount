create or replace function save_tricount(
    save_id int,
    save_title text,
    save_description text,
    save_creator int,
    save_participants integer[]) returns void  as 
    $$
    begin 
        if save_id = 0 then
            insert into tricount(title, description, participant,creator) values (save_title,save_description,save_participants,save_creator);
        end if;
        if save_id > 0 then
            update tricount set title = save_title , description = save_description , participant = save_participants
                            where id = save_id;
        end if;
    end;
    
$$language plpgsql security definer; 

grant execute on function save_tricount to anon;


