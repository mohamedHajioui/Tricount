

drop table if exists tricount;

create table tricount
(
    id  serial primary key,
    title  varchar(256) not null,
    description  varchar(512),
    creator varchar(256) not null,
    participant  integer[],
    date_hour timestamp default current_timestamp 
);