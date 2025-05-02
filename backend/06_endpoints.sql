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

grant execute on function save_tricount to anon;

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


create or replace function delete_tricount(tricount_id text)
    returns void as
$$
    declare 
        v_tricount_id text := tricount_id;
begin
    --verifie que l'user est connecté
    perform auth.check_logged();

    delete from depense where depense.tricount_id = v_tricount_id;
    --delete from part
end;

$$ language plpgsql;

