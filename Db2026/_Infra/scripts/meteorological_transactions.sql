BEGIN;

DO $$
BEGIN
    CREATE TABLE positions (
        id INTEGER,
        name VARCHAR(80)
    );

    CREATE SEQUENCE seq_positions START WITH 1;

    ALTER TABLE positions
    ALTER COLUMN id SET DEFAULT nextval('seq_positions');

    CREATE TABLE equipment_types (
        id INTEGER,
        name VARCHAR(80)
    );

    CREATE SEQUENCE seq_equipment_types START WITH 1;

    ALTER TABLE equipment_types
    ALTER COLUMN id SET DEFAULT nextval('seq_equipment_types');

    CREATE TABLE users (
        id INTEGER,
        full_name VARCHAR(80)
    );

    CREATE SEQUENCE seq_users START WITH 1;

    ALTER TABLE users
    ALTER COLUMN id SET DEFAULT nextval('seq_users');

    CREATE TABLE batches (
        id INTEGER,
        measured_at TIMESTAMP,
        user_id INTEGER
    );

    CREATE SEQUENCE seq_batches START WITH 1;

    ALTER TABLE batches
    ALTER COLUMN id SET DEFAULT nextval('seq_batches');

    CREATE TABLE base_units (
        id INTEGER,
        name VARCHAR(80),
        symbol VARCHAR(30)
    );

    CREATE SEQUENCE seq_base_units START WITH 1;

    ALTER TABLE base_units
    ALTER COLUMN id SET DEFAULT nextval('seq_base_units');

    CREATE TABLE measurement_units (
        id INTEGER,
        name VARCHAR(80),
        symbol VARCHAR(30),
        base_unit_id INTEGER
    );

    CREATE SEQUENCE seq_measurement_units START WITH 1;

    ALTER TABLE measurement_units
    ALTER COLUMN id SET DEFAULT nextval('seq_measurement_units');

    CREATE TABLE parameter_types (
        id INTEGER,
        name VARCHAR(80)
    );

    CREATE SEQUENCE seq_parameter_types START WITH 1;

    ALTER TABLE parameter_types
    ALTER COLUMN id SET DEFAULT nextval('seq_parameter_types');

    CREATE TABLE parameters (
        id INTEGER,
        batch_id INTEGER,
        parameter_type_id INTEGER,
        measurement_unit_id INTEGER,
        parameter_value NUMERIC(10,1)
    );

    CREATE SEQUENCE seq_parameters START WITH 1;

    ALTER TABLE parameters
    ALTER COLUMN id SET DEFAULT nextval('seq_parameters');

    CREATE TABLE temperature_corrections (
        id INTEGER,
        temperature_category VARCHAR(30),
        correction NUMERIC(4,1)
    );

    CREATE SEQUENCE seq_temperature_corrections START WITH 1;

    ALTER TABLE temperature_corrections
    ALTER COLUMN id SET DEFAULT nextval('seq_temperature_corrections');

    COMMENT ON TABLE positions IS 'Таблица должностей';
    COMMENT ON SEQUENCE seq_positions IS 'Счетчик должностей';

    COMMENT ON TABLE equipment_types IS 'Таблица типов оборудования';
    COMMENT ON SEQUENCE seq_equipment_types IS 'Счетчик типов оборудования';

    COMMENT ON TABLE users IS 'Таблица пользователей';
    COMMENT ON SEQUENCE seq_users IS 'Счетчик пользователей';

    COMMENT ON TABLE batches IS 'Таблица пачек';
    COMMENT ON SEQUENCE seq_batches IS 'Счетчик пачек';

    COMMENT ON TABLE base_units IS 'Справочник базовых единиц измерения';
    COMMENT ON SEQUENCE seq_base_units IS 'Счетчик базовых единиц измерения';

    COMMENT ON TABLE measurement_units IS 'Справочник единиц измерения';
    COMMENT ON SEQUENCE seq_measurement_units IS 'Счетчик единиц измерения';

    COMMENT ON TABLE parameter_types IS 'Справочник типов измеряемых параметров';
    COMMENT ON SEQUENCE seq_parameter_types IS 'Счетчик типов параметров';

    COMMENT ON TABLE parameters IS 'Таблица измеренных параметров';
    COMMENT ON SEQUENCE seq_parameters IS 'Счетчик параметров';

    COMMENT ON TABLE temperature_corrections IS 'Поправки к температуре';
    COMMENT ON SEQUENCE seq_temperature_corrections IS 'Счетчик поправок к температуре';
END $$;

COMMIT;

BEGIN;

DO $$
BEGIN
    INSERT INTO positions (name)
    VALUES
        ('Начальник метеорологического поста'),
        ('Метеоролог-наблюдатель'),
        ('Оператор ДМК'),
        ('Оператор ветрового ружья'),
        ('Вычислитель метеоданных');

    INSERT INTO equipment_types (name)
    VALUES
        ('Десантный метеорологический комплект'),
        ('Ветровое ружье');

    INSERT INTO users (full_name)
    VALUES
        ('Алексей Владимирович Орлов'),
        ('Иван Сергеевич Петров'),
        ('Сергей Юрьевич Волков'),
        ('Дмитрий Анатольевич Кузнецов'),
        ('Максим Владиславович Соколов');

    INSERT INTO batches (measured_at, user_id)
    VALUES
        ('2026-09-20 09:30:00', 3),
        ('2026-09-20 13:10:00', 3),
        ('2026-09-20 10:00:00', 4),
        ('2026-09-20 14:20:00', 4);

    INSERT INTO base_units (name, symbol)
    VALUES
        ('Метр', 'м'),
        ('Градус Цельсия', '°C'),
        ('Паскаль', 'Па'),
        ('Деление угломера', 'дел. угл.'),
        ('Метр в секунду', 'м/с');

    INSERT INTO measurement_units (name, symbol, base_unit_id)
    VALUES
        ('Метры', 'м', 1),
        ('Градусы Цельсия', '°C', 2),
        ('Миллиметры ртутного столба', 'мм рт. ст.', 3),
        ('Деления угломера', 'деления угломера', 4),
        ('Метры в секунду', 'м/с', 5),
        ('Километр', 'км', 1),
        ('Международный фут', 'ft', 1),
        ('Узел', 'kn', 5);

    INSERT INTO parameter_types (name)
    VALUES
        ('Высота метеопоста'),
        ('Температура воздуха'),
        ('Давление атмосферы'),
        ('Направление ветра'),
        ('Скорость ветра'),
        ('Дальность сноса пуль');

    INSERT INTO parameters (
        batch_id,
        parameter_type_id,
        measurement_unit_id,
        parameter_value
    )
    VALUES
        (1, 1, 1, 100),
        (1, 2, 2, 15.0),
        (1, 3, 3, 750),
        (1, 4, 4, 12),
        (1, 5, 5, 5),
        (2, 1, 1, 120),
        (2, 2, 2, -3.5),
        (2, 3, 3, 743),
        (2, 4, 4, 25),
        (2, 5, 5, 7),
        (3, 1, 1, 80),
        (3, 2, 2, 18.0),
        (3, 3, 3, 755),
        (3, 4, 4, 15),
        (3, 6, 1, 80),
        (4, 1, 1, 150),
        (4, 2, 2, 6.5),
        (4, 3, 3, 730),
        (4, 4, 4, 40),
        (4, 6, 1, 110);

    INSERT INTO temperature_corrections (temperature_category, correction)
    VALUES
        ('Ниже 0', 0),
        ('0 - 5', 0.5),
        ('10 - 15', 1),
        ('20', 1.5),
        ('25', 2),
        ('30', 3.5),
        ('40', 4.5);
END $$;

COMMIT;

BEGIN;

DO $$
BEGIN
    ALTER TABLE positions
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE positions
    ADD UNIQUE (id);

    ALTER TABLE positions
    ALTER COLUMN name SET NOT NULL;

    ALTER TABLE positions
    ADD UNIQUE (name);

    ALTER TABLE equipment_types
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE equipment_types
    ADD UNIQUE (id);

    ALTER TABLE equipment_types
    ALTER COLUMN name SET NOT NULL;

    ALTER TABLE equipment_types
    ADD UNIQUE (name);

    ALTER TABLE users
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE users
    ADD UNIQUE (id);

    ALTER TABLE users
    ALTER COLUMN full_name SET NOT NULL;

    ALTER TABLE batches
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE batches
    ADD UNIQUE (id);

    ALTER TABLE batches
    ALTER COLUMN measured_at SET NOT NULL;

    ALTER TABLE batches
    ADD FOREIGN KEY (user_id) REFERENCES users (id);

    ALTER TABLE base_units
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE base_units
    ADD UNIQUE (id);

    ALTER TABLE base_units
    ALTER COLUMN name SET NOT NULL;

    ALTER TABLE base_units
    ADD UNIQUE (name);

    ALTER TABLE base_units
    ALTER COLUMN symbol SET NOT NULL;

    ALTER TABLE base_units
    ADD UNIQUE (symbol);

    ALTER TABLE measurement_units
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE measurement_units
    ADD UNIQUE (id);

    ALTER TABLE measurement_units
    ALTER COLUMN name SET NOT NULL;

    ALTER TABLE measurement_units
    ADD UNIQUE (name);

    ALTER TABLE measurement_units
    ALTER COLUMN symbol SET NOT NULL;

    ALTER TABLE measurement_units
    ADD UNIQUE (symbol);

    ALTER TABLE measurement_units
    ALTER COLUMN base_unit_id SET NOT NULL;

    ALTER TABLE measurement_units
    ADD FOREIGN KEY (base_unit_id) REFERENCES base_units (id);

    ALTER TABLE parameter_types
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE parameter_types
    ADD UNIQUE (id);

    ALTER TABLE parameter_types
    ALTER COLUMN name SET NOT NULL;

    ALTER TABLE parameter_types
    ADD UNIQUE (name);

    ALTER TABLE parameters
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE parameters
    ADD UNIQUE (id);

    ALTER TABLE parameters
    ALTER COLUMN parameter_value SET NOT NULL;

    ALTER TABLE parameters
    ADD FOREIGN KEY (batch_id) REFERENCES batches (id);

    ALTER TABLE parameters
    ADD FOREIGN KEY (parameter_type_id) REFERENCES parameter_types (id);

    ALTER TABLE parameters
    ADD FOREIGN KEY (measurement_unit_id) REFERENCES measurement_units (id);

    ALTER TABLE temperature_corrections
    ALTER COLUMN id SET NOT NULL;

    ALTER TABLE temperature_corrections
    ADD UNIQUE (id);
END $$;

COMMIT;