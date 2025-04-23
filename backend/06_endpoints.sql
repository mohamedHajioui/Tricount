create or replace function save_tricount(
    save_id int,
    save_title text,
    save_description text,
    save_participants integer[]) returns void  as 
    $$
    begin
        perform auth.check_logged(); --on check la connection de l'utilisateur
        if save_id = 0 then --create 
            insert into tricount(title, description, participant,creator) values (save_title,save_description,save_participants,auth.id());
        end if;
        if save_id > 0 then --update
            update tricount set title = save_title , description = save_description , participant = save_participants
                            where id = save_id;
        end if;
    end;
    
$$language plpgsql security definer; 

grant execute on function save_tricount to anon;

create or replace function get_my_tricounts() 
    returns setof tricount as
    $$
    begin
        perform auth.check_logged(); --on check la connection de l'utilisateur
        return query select tricount.*
                    from tricount
                    where tricount.creator = auth.id();
    end;
    $$language plpgsql security definer ;

select * from get_my_tricounts();

grant execute on function get_my_tricounts() to anon;

    
    
    
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

