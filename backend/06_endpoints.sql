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
    
$$ language plpgsql security definer ;
/****************************************************************
  fonction get user data
  ******************************************************************/

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