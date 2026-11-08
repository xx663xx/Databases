DO $$
BEGIN
    BEGIN
        CREATE SEQUENCE public.seq_temperature_height_corrections START WITH 1;
        CREATE TABLE public.temperature_height_corrections (
            id INTEGER PRIMARY KEY DEFAULT nextval('public.seq_temperature_height_corrections'),
            height INTEGER NOT NULL,
            ground_deviation INTEGER NOT NULL,
            mean_deviation INTEGER NOT NULL,
            UNIQUE (height, ground_deviation)
        );
        COMMENT ON TABLE public.temperature_height_corrections
        IS 'Таблица 2. Средние отклонения температуры для ВР и ДМК';
        COMMENT ON COLUMN public.temperature_height_corrections.id
        IS 'Номер записи температурного справочника';
        COMMENT ON COLUMN public.temperature_height_corrections.height
        IS 'Стандартная высота Y, м';
        COMMENT ON COLUMN public.temperature_height_corrections.ground_deviation
        IS 'Опорное отклонение приземной виртуальной температуры со знаком, °C';
        COMMENT ON COLUMN public.temperature_height_corrections.mean_deviation
        IS 'Среднее отклонение температуры на высоте Y со знаком, °C';
        COMMENT ON SEQUENCE public.seq_temperature_height_corrections
        IS 'Счетчик записей температурного справочника';
    END;
    COMMIT;

    BEGIN
        CREATE SEQUENCE public.seq_wind_speed_corrections START WITH 1;
        CREATE TABLE public.wind_speed_corrections (
            id INTEGER PRIMARY KEY DEFAULT nextval('public.seq_wind_speed_corrections'),
            equipment_type_id INTEGER NOT NULL,
            height INTEGER NOT NULL,
            input_value INTEGER NOT NULL,
            wind_speed INTEGER NOT NULL,
            UNIQUE (equipment_type_id, height, input_value)
        );
        COMMENT ON TABLE public.wind_speed_corrections
        IS 'Таблица 3. Скорости среднего ветра для ВР и ДМК';
        COMMENT ON COLUMN public.wind_speed_corrections.id
        IS 'Номер записи справочника скоростей ветра';
        COMMENT ON COLUMN public.wind_speed_corrections.equipment_type_id
        IS 'Тип оборудования из существующего справочника';
        COMMENT ON COLUMN public.wind_speed_corrections.height
        IS 'Стандартная высота Y, м';
        COMMENT ON COLUMN public.wind_speed_corrections.input_value
        IS 'Опорное значение: скорость V0, м/с для ДМК; дальность Дг, м для ВР';
        COMMENT ON COLUMN public.wind_speed_corrections.wind_speed
        IS 'Скорость среднего ветра Wy, м/с';
        COMMENT ON SEQUENCE public.seq_wind_speed_corrections
        IS 'Счетчик записей справочника скоростей ветра';
    END;
    COMMIT;

    BEGIN
        CREATE SEQUENCE public.seq_wind_direction_corrections START WITH 1;
        CREATE TABLE public.wind_direction_corrections (
            id INTEGER PRIMARY KEY DEFAULT nextval('public.seq_wind_direction_corrections'),
            equipment_type_id INTEGER NOT NULL,
            height INTEGER NOT NULL,
            direction_delta INTEGER NOT NULL,
            UNIQUE (equipment_type_id, height)
        );
        COMMENT ON TABLE public.wind_direction_corrections
        IS 'Таблица 3. Приращения направления среднего ветра для ВР и ДМК';
        COMMENT ON COLUMN public.wind_direction_corrections.id
        IS 'Номер записи справочника приращений направления ветра';
        COMMENT ON COLUMN public.wind_direction_corrections.equipment_type_id
        IS 'Тип оборудования из существующего справочника';
        COMMENT ON COLUMN public.wind_direction_corrections.height
        IS 'Стандартная высота Y, м';
        COMMENT ON COLUMN public.wind_direction_corrections.direction_delta
        IS 'Приращение направления в больших делениях угломера: 1 означает 1-00';
        COMMENT ON SEQUENCE public.seq_wind_direction_corrections
        IS 'Счетчик записей справочника приращений направления ветра';
    END;
    COMMIT;
END $$;