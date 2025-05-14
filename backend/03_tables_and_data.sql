

drop table if exists tricount;

create table tricount
(
    id  serial primary key,
    title  varchar(256) not null,
    description  varchar(512),
    creator int not null references users(id),
    participant  integer[],
    date_hour timestamp default current_timestamp
);

insert into tricount(id, title, description, creator, participant, date_hour)
values (1, 'Colruyt', 'Courses', 2, ARRAY[1, 4, 2, 5], '2025-05-10'),
   (2, 'Voyage Italie', 'Depenses de tout le voyage', 1, ARRAY[1, 2, 3, 4], '2025-05-13'),
       (3, 'Société', 'Materiel pour travailler', 5, ARRAY[5, 2, 3], '2025-05-01');

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

INSERT INTO depense(tricount_id, title, amount, operation_date, initiator, repartition)
VALUES
    (2, 'Location voiture', 200.0, '2025-05-13', 1, '[{"user_id": 1, "weight": 2}, {"user_id": 2, "weight": 1}, {"user_id": 3, "weight": 1}]'),
    (2, 'Location Villa', 1000.0, '2025-05-13', 2, '[{"user_id": 1, "weight": 1}, {"user_id": 2, "weight": 1}, {"user_id": 3, "weight": 1}, {"user_id": 4, "weight": 1}]'),
    (2, 'Essence', 60.0, '2025-05-14', 3, '[{"user_id": 2, "weight": 1}, {"user_id": 3, "weight": 1}]'),
    (2, 'Billets de musée', 80.0, '2025-05-14', 4, '[{"user_id": 1, "weight": 1}, {"user_id": 2, "weight": 1}, {"user_id": 3, "weight": 1}]'),
    (2, 'Repas à Florence', 120.0, '2025-05-14', 1, '[{"user_id": 1, "weight": 1}, {"user_id": 2, "weight": 1}, {"user_id": 3, "weight": 1}, {"user_id": 4, "weight": 1}]'),
    (1, 'Courses Carrefour', 150.0, '2025-05-10', 2, '[{"user_id": 1, "weight": 1}, {"user_id": 2, "weight": 1}, {"user_id": 4, "weight": 1}, {"user_id": 5, "weight": 1}]'),
    (1, 'Pain & Lait', 30.0, '2025-05-11', 1, '[{"user_id": 2, "weight": 1}, {"user_id": 1, "weight": 1}]'),
    (1, 'Fruits & légumes', 45.0, '2025-05-11', 5, '[{"user_id": 4, "weight": 1}, {"user_id": 5, "weight": 1}]'),
    (3, 'Écran 27 pouces', 250.0, '2025-05-01', 5, '[{"user_id": 2, "weight": 1}, {"user_id": 3, "weight": 1}, {"user_id": 5, "weight": 1}]'),
    (3, 'Clavier mécanique', 90.0, '2025-05-02', 2, '[{"user_id": 2, "weight": 1}, {"user_id": 3, "weight": 1}]'),
    (3, 'Licences logicielles', 300.0, '2025-05-03', 3, '[{"user_id": 2, "weight": 2}, {"user_id": 5, "weight": 1}]');



create table participation (
                               user_id integer not null references users(id) on delete cascade,
                               tricount_id integer not null references tricount(id) on delete cascade,
                               primary key (user_id, tricount_id)
);

INSERT INTO participation (user_id, tricount_id)
VALUES
-- Tricount 1 (Colruyt) — participants : 1, 2, 4, 5 (créateur : 2)
(1, 1), (2, 1), (4, 1), (5, 1),

-- Tricount 2 (Voyage Italie) — participants : 1, 2, 3, 4 (créateur : 1)
(1, 2), (2, 2), (3, 2), (4, 2),

-- Tricount 3 (Société) — participants : 2, 3, 5 (créateur : 5)
(2, 3), (3, 3), (5, 3);



