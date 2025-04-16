create or replace function save_tricount(
    id int,
    save_title text,
    save_description text,
    save_participant integer[]) returns int  as 
    $$
    begin 
        if id = 0 then
            insert into tricount(title, description, participant) values (save_title,save_description,save_participant);
        end if;
        
        
    end;
    
$$