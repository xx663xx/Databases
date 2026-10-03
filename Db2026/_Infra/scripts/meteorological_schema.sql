DROP TABLE IF EXISTS parameters;
DROP TABLE IF EXISTS batches;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS equipment_types;
DROP TABLE IF EXISTS positions;

CREATE TABLE positions (
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE equipment_types (
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE users (
    code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(80) NOT NULL
);

CREATE TABLE batches (
    code VARCHAR(20) NOT NULL UNIQUE,
    measured_at TIMESTAMP NOT NULL
);

CREATE TABLE parameters (
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    parameter_value NUMERIC(10,1) NOT NULL
);

COMMENT ON TABLE positions IS 'Таблица должностей сотрудников';
COMMENT ON TABLE equipment_types IS 'Таблица типов метеорологического оборудования';
COMMENT ON TABLE users IS 'Таблица пользователей системы';
COMMENT ON TABLE batches IS 'Таблица пачек измерений';
COMMENT ON TABLE parameters IS 'Таблица измеренных параметров';

INSERT INTO positions (code, name)
VALUES
    ('POS-001', 'Начальник метеорологического поста'),
    ('POS-002', 'Метеоролог-наблюдатель'),
    ('POS-003', 'Оператор ДМК'),
    ('POS-004', 'Оператор ветрового ружья'),
    ('POS-005', 'Вычислитель метеоданных');

INSERT INTO equipment_types (code, name)
VALUES
    ('EQ-001', 'Десантный метеорологический комплект'),
    ('EQ-002', 'Ветровое ружье');

INSERT INTO users (code, full_name)
VALUES
    ('USR-001', 'Алексей Владимирович Орлов'),
    ('USR-002', 'Иван Сергеевич Петров'),
    ('USR-003', 'Сергей Юрьевич Волков'),
    ('USR-004', 'Дмитрий Анатольевич Кузнецов'),
    ('USR-005', 'Максим Владиславович Соколов');

INSERT INTO batches (code, measured_at)
VALUES
    ('BATCH-001', '2026-09-20 09:30:00'),
    ('BATCH-002', '2026-09-20 13:10:00'),
    ('BATCH-003', '2026-09-20 10:00:00'),
    ('BATCH-004', '2026-09-20 14:20:00');

INSERT INTO parameters (code, name, unit, parameter_value)
VALUES
    ('PAR-001', 'Высота метеопоста', 'м', 100),
    ('PAR-002', 'Температура воздуха', '°C', 15.0),
    ('PAR-003', 'Давление атмосферы', 'мм рт. ст.', 750),
    ('PAR-004', 'Направление ветра', 'деления угломера', 12),
    ('PAR-005', 'Скорость ветра', 'м/с', 5),
    ('PAR-006', 'Высота метеопоста', 'м', 120),
    ('PAR-007', 'Температура воздуха', '°C', -3.5),
    ('PAR-008', 'Давление атмосферы', 'мм рт. ст.', 743),
    ('PAR-009', 'Направление ветра', 'деления угломера', 25),
    ('PAR-010', 'Скорость ветра', 'м/с', 7),
    ('PAR-011', 'Высота метеопоста', 'м', 80),
    ('PAR-012', 'Температура воздуха', '°C', 18.0),
    ('PAR-013', 'Давление атмосферы', 'мм рт. ст.', 755),
    ('PAR-014', 'Направление ветра', 'деления угломера', 15),
    ('PAR-015', 'Дальность сноса пуль', 'м', 80),
    ('PAR-016', 'Высота метеопоста', 'м', 150),
    ('PAR-017', 'Температура воздуха', '°C', 6.5),
    ('PAR-018', 'Давление атмосферы', 'мм рт. ст.', 730),
    ('PAR-019', 'Направление ветра', 'деления угломера', 40),
    ('PAR-020', 'Дальность сноса пуль', 'м', 110);

SELECT 'Должности' AS "Таблица", code AS "Код", name AS "Данные"
FROM positions
UNION ALL
SELECT 'Типы оборудования', code, name
FROM equipment_types
UNION ALL
SELECT 'Пользователи', code, full_name
FROM users
UNION ALL
SELECT 'Пачки', code, CAST(measured_at AS VARCHAR(80))
FROM batches
UNION ALL
SELECT 'Параметры', code, name || ': ' || parameter_value || ' ' || unit
FROM parameters
ORDER BY "Таблица", "Код";