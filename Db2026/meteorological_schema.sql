DROP TABLE IF EXISTS parameters;
DROP TABLE IF EXISTS batches;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS equipment_types;
DROP TABLE IF EXISTS positions;

CREATE TABLE positions (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE equipment_types (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(80) NOT NULL,
    position_id INTEGER NOT NULL,
    FOREIGN KEY (position_id) REFERENCES positions(id)
);

CREATE TABLE batches (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    measured_at TIMESTAMP NOT NULL,
    user_id INTEGER NOT NULL,
    equipment_type_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(id)
);

CREATE TABLE parameters (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    parameter_value NUMERIC(10,1) NOT NULL,
    batch_id INTEGER NOT NULL,
    FOREIGN KEY (batch_id) REFERENCES batches(id)
);

INSERT INTO positions (id, code, name)
VALUES
    (1, 'POS-001', 'Начальник метеорологического поста'),
    (2, 'POS-002', 'Метеоролог-наблюдатель'),
    (3, 'POS-003', 'Оператор ДМК'),
    (4, 'POS-004', 'Оператор ветрового ружья'),
    (5, 'POS-005', 'Вычислитель метеоданных');

INSERT INTO equipment_types (id, code, name)
VALUES
    (1, 'EQ-001', 'Десантный метеорологический комплект'),
    (2, 'EQ-002', 'Ветровое ружье');

INSERT INTO users (id, code, full_name, position_id)
VALUES
    (1, 'USR-001', 'Алексей Владимирович Орлов', 1),
    (2, 'USR-002', 'Иван Сергеевич Петров', 2),
    (3, 'USR-003', 'Сергей Юрьевич Волков', 3),
    (4, 'USR-004', 'Дмитрий Анатольевич Кузнецов', 4),
    (5, 'USR-005', 'Максим Владиславович Соколов', 5);

INSERT INTO batches (
    id,
    code,
    measured_at,
    user_id,
    equipment_type_id
)
VALUES
    (1, 'BATCH-001', '2026-09-20 09:30:00', 3, 1),
    (2, 'BATCH-002', '2026-09-20 13:10:00', 3, 1),
    (3, 'BATCH-003', '2026-09-20 10:00:00', 4, 2),
    (4, 'BATCH-004', '2026-09-20 14:20:00', 4, 2);

INSERT INTO parameters (
    id,
    code,
    name,
    unit,
    parameter_value,
    batch_id
)
VALUES
    (1, 'PAR-001', 'Высота метеопоста', 'м', 100, 1),
    (2, 'PAR-002', 'Температура воздуха', '°C', 15.0, 1),
    (3, 'PAR-003', 'Давление атмосферы', 'мм рт. ст.', 750, 1),
    (4, 'PAR-004', 'Направление ветра', 'деления угломера', 12, 1),
    (5, 'PAR-005', 'Скорость ветра', 'м/с', 5, 1),

    (6, 'PAR-006', 'Высота метеопоста', 'м', 120, 2),
    (7, 'PAR-007', 'Температура воздуха', '°C', -3.5, 2),
    (8, 'PAR-008', 'Давление атмосферы', 'мм рт. ст.', 743, 2),
    (9, 'PAR-009', 'Направление ветра', 'деления угломера', 25, 2),
    (10, 'PAR-010', 'Скорость ветра', 'м/с', 7, 2),

    (11, 'PAR-011', 'Высота метеопоста', 'м', 80, 3),
    (12, 'PAR-012', 'Температура воздуха', '°C', 18.0, 3),
    (13, 'PAR-013', 'Давление атмосферы', 'мм рт. ст.', 755, 3),
    (14, 'PAR-014', 'Направление ветра', 'деления угломера', 15, 3),
    (15, 'PAR-015', 'Дальность сноса пуль', 'м', 80, 3),

    (16, 'PAR-016', 'Высота метеопоста', 'м', 150, 4),
    (17, 'PAR-017', 'Температура воздуха', '°C', 6.5, 4),
    (18, 'PAR-018', 'Давление атмосферы', 'мм рт. ст.', 730, 4),
    (19, 'PAR-019', 'Направление ветра', 'деления угломера', 40, 4),
    (20, 'PAR-020', 'Дальность сноса пуль', 'м', 110, 4);

SELECT
    b.code AS "Пачка",
    u.full_name AS "Пользователь",
    p.name AS "Должность",
    et.name AS "Оборудование",
    par.name AS "Параметр",
    par.parameter_value AS "Значение",
    par.unit AS "Ед."
FROM batches AS b
JOIN users AS u ON b.user_id = u.id
JOIN positions AS p ON u.position_id = p.id
JOIN equipment_types AS et ON b.equipment_type_id = et.id
JOIN parameters AS par ON par.batch_id = b.id
ORDER BY b.id, par.id;