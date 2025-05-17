

DROP TABLE IF EXISTS tricount CASCADE;

create table tricount
(
    id  serial primary key,
    title  varchar(256) not null,
    description  varchar(512),
    creator int not null references users(id),
    participant  integer[],
    date_hour timestamp default current_timestamp
);


drop table if exists depense;
drop table if exists participation;
create table depense(
                        id serial primary key,
                        tricount_id int not null references tricount(id) on delete cascade,
                        title varchar(256) not null,
                        amount double precision not null,
                        operation_date timestamp not null default current_DATE,  -- date de la dépense
                        created_at timestamp not null default current_timestamp,      -- date de création
                        initiator int not null,
                        repartition jsonb
);



drop table if exists participation;
create table participation (
                               user_id integer not null references users(id) on delete cascade,
                               tricount_id integer not null references tricount(id) on delete cascade,
                               primary key (user_id, tricount_id)
);




