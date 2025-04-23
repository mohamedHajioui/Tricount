

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


insert into tricount(title, description, creator, participant) values ('japon','voyage epfc informatique',2,'{3,4,9}')

