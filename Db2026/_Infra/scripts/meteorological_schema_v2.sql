CREATE TABLE base_units (
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL UNIQUE,
    symbol VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO base_units (code, name, symbol)
VALUES
    ('BASE-001', 'Метр', 'м'),
    ('BASE-002', 'Градус Цельсия', '°C'),
    ('BASE-003', 'Паскаль', 'Па'),
    ('BASE-004', 'Деление угломера', 'дел. угл.'),
    ('BASE-005', 'Метр в секунду', 'м/с');

CREATE TABLE measurement_units (
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL UNIQUE,
    symbol VARCHAR(30) NOT NULL UNIQUE,
    base_unit_code VARCHAR(20) NOT NULL
);

INSERT INTO measurement_units (
    code,
    name,
    symbol,
    base_unit_code
)
VALUES
    ('UNIT-001', 'Метры', 'м', 'BASE-001'),
    ('UNIT-002', 'Градусы Цельсия', '°C', 'BASE-002'),
    ('UNIT-003', 'Миллиметры ртутного столба', 'мм рт. ст.', 'BASE-003'),
    ('UNIT-004', 'Деления угломера', 'деления угломера', 'BASE-004'),
    ('UNIT-005', 'Метры в секунду', 'м/с', 'BASE-005'),
    ('UNIT-006', 'Километр', 'км', 'BASE-001'),
    ('UNIT-007', 'Международный фут', 'ft', 'BASE-001'),
    ('UNIT-008', 'Узел', 'kn', 'BASE-005');

CREATE TABLE parameter_types (
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL UNIQUE
);

INSERT INTO parameter_types (code, name)
VALUES
    ('TYPE-001', 'Высота метеопоста'),
    ('TYPE-002', 'Температура воздуха'),
    ('TYPE-003', 'Давление атмосферы'),
    ('TYPE-004', 'Направление ветра'),
    ('TYPE-005', 'Скорость ветра'),
    ('TYPE-006', 'Дальность сноса пуль');

ALTER TABLE parameters
ADD COLUMN parameter_type_code VARCHAR(20);

ALTER TABLE parameters
ADD COLUMN measurement_unit_code VARCHAR(20);

ALTER TABLE parameters
ADD COLUMN batch_code VARCHAR(20);

UPDATE parameters
SET parameter_type_code = 'TYPE-001'
WHERE name = 'Высота метеопоста';

UPDATE parameters
SET parameter_type_code = 'TYPE-002'
WHERE name = 'Температура воздуха';

UPDATE parameters
SET parameter_type_code = 'TYPE-003'
WHERE name = 'Давление атмосферы';

UPDATE parameters
SET parameter_type_code = 'TYPE-004'
WHERE name = 'Направление ветра';

UPDATE parameters
SET parameter_type_code = 'TYPE-005'
WHERE name = 'Скорость ветра';

UPDATE parameters
SET parameter_type_code = 'TYPE-006'
WHERE name = 'Дальность сноса пуль';

UPDATE parameters
SET measurement_unit_code = 'UNIT-001'
WHERE unit = 'м';

UPDATE parameters
SET measurement_unit_code = 'UNIT-002'
WHERE unit = '°C';

UPDATE parameters
SET measurement_unit_code = 'UNIT-003'
WHERE unit = 'мм рт. ст.';

UPDATE parameters
SET measurement_unit_code = 'UNIT-004'
WHERE unit = 'деления угломера';

UPDATE parameters
SET measurement_unit_code = 'UNIT-005'
WHERE unit = 'м/с';

UPDATE parameters
SET batch_code = 'BATCH-001'
WHERE code IN (
    'PAR-001', 'PAR-002', 'PAR-003', 'PAR-004', 'PAR-005'
);

UPDATE parameters
SET batch_code = 'BATCH-002'
WHERE code IN (
    'PAR-006', 'PAR-007', 'PAR-008', 'PAR-009', 'PAR-010'
);

UPDATE parameters
SET batch_code = 'BATCH-003'
WHERE code IN (
    'PAR-011', 'PAR-012', 'PAR-013', 'PAR-014', 'PAR-015'
);

UPDATE parameters
SET batch_code = 'BATCH-004'
WHERE code IN (
    'PAR-016', 'PAR-017', 'PAR-018', 'PAR-019', 'PAR-020'
);

ALTER TABLE parameters
DROP COLUMN name;

ALTER TABLE parameters
DROP COLUMN unit;

ALTER TABLE batches
ADD COLUMN user_code VARCHAR(20);

UPDATE batches
SET user_code = 'USR-003'
WHERE code IN ('BATCH-001', 'BATCH-002');

UPDATE batches
SET user_code = 'USR-004'
WHERE code IN ('BATCH-003', 'BATCH-004');

SELECT
    b.measured_at AS "Дата измерения",
    b.code AS "Номер пачки",
    u.full_name AS "ФИО сотрудника",
    pt.name || ', ' || mu.symbol AS "Параметр и ед. измерения",
    par.parameter_value AS "Значение"
FROM parameters AS par
JOIN batches AS b
    ON par.batch_code = b.code
JOIN users AS u
    ON b.user_code = u.code
JOIN parameter_types AS pt
    ON par.parameter_type_code = pt.code
JOIN measurement_units AS mu
    ON par.measurement_unit_code = mu.code
ORDER BY b.code, par.code;