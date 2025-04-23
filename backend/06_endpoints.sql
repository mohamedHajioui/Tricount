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
create or replace function check_full_name_available(full_name text,user_id integer default 0)
returns boolean as 
    $$
    begin 
        if user_id =0 then 
            return not exists(
                select 1 from users where users.full_name = check_full_name_available.full_name
                );
        else
            return not exists(
                select 1 from users 
                where users.full_name = check_full_name_available.full_name
                and users.id <> check_full_name_available.user_id
                );
        end if;
    end;
    $$ language plpgsql security definer ;
grant execute on function check_full_name_available(text,integer) to anon;