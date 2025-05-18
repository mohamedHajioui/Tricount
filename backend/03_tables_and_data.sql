

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

INSERT INTO tricount(id, title, description, creator, participant, date_hour)
VALUES
    (4, 'Vacances', 'A la mer du nord', 1, ARRAY[2, 1, 4, 3], '2024-10-10T19:31:09'),
    (2, 'Resto badminton', NULL, 1, ARRAY[2, 1], '2024-10-10T19:25:10');


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

INSERT INTO depense(id, tricount_id, title, amount, operation_date, created_at, initiator, repartition)
VALUES
    (6, 4, 'Loterie',35.0, '2024-10-26', '2024-10-26T10:02:24', 1,
     '[{"user": 1, "weight": 1}, {"user": 3, "weight": 1}]'),
    (5, 4, 'Boucherie',  25.5, '2024-10-26', '2024-10-26T09:59:56', 2,
     '[{"user": 1, "weight": 2}, {"user": 2, "weight": 1}, {"user": 3, "weight": 1}]'),
    (4, 4, 'Apéros',     31.897456217, '2024-10-13', '2024-10-13T23:51:20', 1,
     '[{"user": 1, "weight": 1}, {"user": 2, "weight": 2}, {"user": 3, "weight": 3}]');




drop table if exists participation;
create table participation (
                               user_id integer not null references users(id) on delete cascade,
                               tricount_id integer not null references tricount(id) on delete cascade,
                               primary key (user_id, tricount_id)
);

INSERT INTO participation(user_id, tricount_id)
VALUES
    (2, 4), (1, 4), (4, 4), (3, 4),
    (2, 2), (1, 2);






