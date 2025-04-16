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


