

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
VALUES (4, 'Vacances', 'A la mer du nord', 1, ARRAY[2, 1, 4, 3], '2024-10-10T19:31:09');

INSERT INTO tricount(id, title, description, creator, participant, date_hour)
VALUES (2, 'Resto badminton', NULL, 1, ARRAY[2, 1], '2024-10-10T19:25:10');


drop table if exists depense;
CREATE TABLE depense (
                         id serial PRIMARY KEY,
                         tricount_id INT NOT NULL REFERENCES tricount(id) ON DELETE RESTRICT,
                         title VARCHAR(256) NOT NULL,
                         amount DOUBLE PRECISION NOT NULL,
                         operation_date TIMESTAMP NOT NULL DEFAULT current_date,  -- date réelle de la dépense
                         created_at TIMESTAMP NOT NULL DEFAULT current_timestamp, -- date d'encodage
                         initiator INT NOT NULL,
                         repartition JSONB NOT NULL
);

INSERT INTO depense(id, tricount_id, title, amount, operation_date, created_at, initiator, repartition)
VALUES (6, 4, 'Loterie', 35, '2024-10-26', '2024-10-26T10:02:24', 1, '[{"user_id": 1, "weight": 1}, {"user_id": 3, "weight": 1}]');

INSERT INTO depense(id, tricount_id, title, amount, operation_date, created_at, initiator, repartition)
VALUES (5, 4, 'Boucherie', 25.5, '2024-10-26', '2024-10-26T09:59:56', 2, '[{"user_id": 1, "weight": 2}, {"user_id": 2, "weight": 1}, {"user_id": 3, "weight": 1}]');

INSERT INTO depense(id, tricount_id, title, amount, operation_date, created_at, initiator, repartition)
VALUES (4, 4, 'Apéros', 31.897456217, '2024-10-13', '2024-10-13T23:51:20', 1, '[{"user_id": 1, "weight": 1}, {"user_id": 2, "weight": 2}, {"user_id": 3, "weight": 3}]');



drop table if exists participation;
create table participation (
                               user_id integer not null references users(id) on delete cascade,
                               tricount_id integer not null references tricount(id) on delete cascade,
                               primary key (user_id, tricount_id)
);

INSERT INTO participation(user_id, tricount_id) VALUES (2, 4);
INSERT INTO participation(user_id, tricount_id) VALUES (1, 4);
INSERT INTO participation(user_id, tricount_id) VALUES (4, 4);
INSERT INTO participation(user_id, tricount_id) VALUES (3, 4);
INSERT INTO participation(user_id, tricount_id) VALUES (2, 2);
INSERT INTO participation(user_id, tricount_id) VALUES (1, 2);



