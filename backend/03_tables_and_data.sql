

drop table if exists tricount;

create table tricount
(
    id  serial primary key,
    title  varchar(256) not null,
    description  varchar(512),
    creator int not null,
    participant  integer[],
    date_hour timestamp default current_timestamp 
);

drop table if exists operateur;
drop table if exists depense;
create table depense(
    id serial primary key,
    tricount_id int,
    title varchar(256) not null ,
    amount double precision not null,
    operation_date timestamp default null,
    initiator int not null,
    repartition jsonb not null
);


