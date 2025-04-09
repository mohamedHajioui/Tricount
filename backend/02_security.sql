set search_path to public, auth;

/**************************************************************
  Role basic_user
 **************************************************************/

drop role if exists basic_user, admin;
create role basic_user nologin;
create role admin nologin;
grant basic_user, admin to authenticator;
grant authenticated to basic_user;
grant authenticated to admin;

/**************************************************************
  Table users
 **************************************************************/

drop type if exists role_type;

create type role_type as enum ('basic_user', 'admin');

drop table if exists users;

create table users
(
    id        serial primary key,
    email     varchar(256) not null,
    password  varchar(512) not null,
    full_name varchar(256) not null,
    iban      varchar(256) null,
    role      role_type    not null default 'basic_user'
);

insert into users (id, email, password, full_name, role, iban)
values (1, 'boverhaegen@epfc.eu', '', 'Boris', 'basic_user', null),
       (2, 'bepenelle@epfc.eu', '', 'Benoît', 'basic_user', null),
       (3, 'xapigeolet@epfc.eu', '', 'Xavier', 'basic_user', null),
       (4, 'mamichel@epfc.eu', '', 'Marc', 'basic_user', 'BE12 1234 1234 1234'),
       (5, 'gedielman@epfc.eu', '', 'Geoffrey', 'basic_user', 'BE45 4567 4567 4567'),
       (9, 'admin@epfc.eu', '', 'Admin', 'admin', null);

-- met à jour la séquence pour qu'elle commence à 10
select setval('users_id_seq', (select max(id)
                               from users));

/**************************************************************
 Trigger pour encrypter automatiquement le mot de passe
 **************************************************************/

create or replace function auth.encrypt_pass() returns trigger as
$$
begin
    if tg_op = 'INSERT' or new.password <> old.password then
        new.password = auth.crypt(new.password, auth.gen_salt('bf'));
    end if;
    return new;
end
$$ language plpgsql;

drop trigger if exists encrypt_pass on users;
create trigger encrypt_pass
    before insert or update
    on users
    for each row
execute procedure auth.encrypt_pass();

-- met à jour les mots de passe pour forcer le hashage
-- noinspection SqlWithoutWhere
update users
set password = 'Password1,';

/**************************************************************
 Fonction qui permet de faire le login et retourne un jeton JWT
 **************************************************************/

create or replace function
    login(email text, password text) returns auth.jwt_token as
$$
declare
    role   name;
    result auth.jwt_token;
begin
    -- check email and password
    if not exists(select *
                  from users
                  where users.email = login.email
                    and users.password = auth.crypt(login.password, users.password)) then
        raise invalid_password using message = 'invalid user or password';
    end if;

    select users.role from users where users.email = login.email into role;

    select auth.sign(row_to_json(r), '94VEF6BGSV4MHACYQYWYZZXILQR7412Z') as token
    from (select role                                              as role,
                 email                                             as sub,
                 -- valid for 24 hours
                 extract(epoch from now())::integer + 24 * 60 * 60 as exp) r
    into result;
    return result;
end;
$$ language plpgsql security definer;

grant execute on function login to anon;

/**************************************************************
 Fonction qui permet de vérifier si un email est disponible
 **************************************************************/

create or replace function is_email_available(email text) returns boolean as
$$
begin
    return not exists(select 1 from users where users.email = is_email_available.email);
end
$$ language plpgsql security definer;

grant execute on function is_email_available to anon;

/**************************************************************
 Fonction signup
 **************************************************************/

create or replace function 
    signup(_email text, _name text, _iban text, _password text, _confirm_password text) returns auth.jwt_token as
$$
declare
    result auth.jwt_token;
begin
    if not is_email_available(_email) then
        raise invalid_argument_for_nth_value_function using message = 'This email is already in use';
    end if;
    
    if exists(select 1 from users where users.full_name = _name) then
        raise invalid_name using message = 'This name is already to use';
    elseif length(_name) <= 3 then
        raise invalid_name using message = 'Name lenght must be bigger or equal than 3';
    end if;
    
    if (length(_password) < 8 or _password !~ '[A-Z]' or _password !~ '[0-9]' or _password !~ '[^a-zA-Z0-9]') then
        raise invalid_password using message = 'Password must be at least 8 char, one digit, one uppercase and one special char';
    elsif _password <> _confirm_password then
        raise invalid_password using message = 'Password and confirms password do not match';
    end if;
    
    if _iban is not null and _iban !~ '^BE[0-9]{14}$' then
        raise exception 'Invalid IBAN format';
    end if;
    
    insert into users(email, password, full_name, iban)
    values(_email, _password, _name, _iban);

    select auth.sign(row_to_json(r), '94VEF6BGSV4MHACYQYWYZZXILQR7412Z') as token
    into result
    from (
             select 'basic_user' as role,
                    _email as sub,
                    extract(epoch from now())::int + 86400 as exp
         ) r;
    return result;
end;
$$ language plpgsql security definer;

grant execute on function signup to anon;


/**************************************************************
 Fonctions utilitaires vàv de la sécurité
 **************************************************************/

/*
 Retourne l'email de l'utilisateur connecté via JWT
 */

create or replace function auth.email()
    returns varchar as
$$
begin
    return current_setting('request.jwt.claims', true)::json ->> 'sub';
end;
$$ language plpgsql;

/*
 Retourne le rôle de l'utilisateur connecté via JWT
 */

create or replace function auth.role()
    returns varchar as
$$
begin
    return current_setting('request.jwt.claims', true)::json ->> 'role';
end;
$$ language plpgsql;

/*
 Vérifie si l'utilisateur est connecté
 */

create or replace function auth.check_logged()
    returns void as
$$
begin
    if auth.email() is null then
        raise exception 'You must be logged';
    end if;
end
$$ language plpgsql;

/*
 Vérifie si l'utilisateur connecté est un admin
 */

create or replace function auth.is_admin()
    returns bool as
$$
begin
    return auth.role() is not null and auth.role() = 'admin';
end
$$ language plpgsql;

/*
 Vérifie si un admin est connecté
 */

create or replace function auth.check_admin_logged()
    returns void as
$$
begin
    if not auth.is_admin() then
        raise exception 'You must be logged with an admin role';
    end if;
end
$$ language plpgsql;

/*
 Lors des tests, permet de simuler une connexion anonyme
 */

create or replace function auth.login_anonymously_for_test() returns void as
$$
begin
    execute 'set session role to anon';
    -- true = pour la transaction, false = pour la session
    perform set_config('request.jwt.claims', '{"role":"anon"}', false);
end
$$ language plpgsql;

/*
 Lors des tests, permet de simuler une connexion avec un utilisateur donné
 */

create or replace function auth.login_for_test(email text) returns void as
$$
declare
    role text;
begin
    if not exists(select 1 from users u where u.email = login_for_test.email) then
        raise exception 'User ''%'' does not exist', email;
    end if;
    select m.role from users m where m.email = login_for_test.email into role;
    execute 'set session role to ' || role;
    -- true = pour la transaction, false = pour la session
    perform set_config('request.jwt.claims', concat('{"role": "', role, '", "sub": "', email, '"}'), false);
end
$$ language plpgsql;

/*
 Permet de revenir à son rôle normal (après un login_for_test)
 */

create or replace function auth.logout_for_test() returns void as
$$
begin
    perform set_config('request.jwt.claims', '{}', false);
    reset role;
end;
$$ language plpgsql;


grant execute on function auth.login_anonymously_for_test() to anon;
grant execute on function auth.login_for_test(text) to anon;
grant execute on function auth.logout_for_test() to anon;
grant execute on function auth.email() to anon;
grant execute on function auth.role() to anon;

/**************************************************************
  Fonction de test pour un utilisateur connecté
 **************************************************************/

create or replace function get_email() returns varchar as
$$
begin
    return auth.email();
end
$$ language plpgsql security definer;

grant execute on function get_email to authenticated;

/**************************************************************
  TESTS
 **************************************************************/

select login('bepenelle@epfc.eu', 'Password1,'); -- OK
-- select login('xxx', 'xxx'); -- KO: user n'existe pas
-- select login('bepenelle@epfc.eu', 'xxx'); -- KO: mauvais mot de passe

select auth.login_anonymously_for_test();
select current_user, auth.email(), auth.role();
select auth.logout_for_test();

select auth.login_for_test('bepenelle@epfc.eu');
select current_user, auth.email(), auth.role();
select auth.logout_for_test();

select auth.login_for_test('admin@epfc.eu');
select current_user, auth.email(), auth.role();
select auth.logout_for_test();
