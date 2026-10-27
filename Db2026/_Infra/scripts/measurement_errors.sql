DO $$
BEGIN
    CREATE TABLE public.measurement_validation_settings (
        parameter_type_id INTEGER PRIMARY KEY REFERENCES public.parameter_types (id),
        minimum_value NUMERIC,
        maximum_value NUMERIC,
        decimal_places INTEGER NOT NULL
    );

    COMMENT ON TABLE public.measurement_validation_settings
    IS 'Ограничения входных параметров';
    COMMENT ON COLUMN public.measurement_validation_settings.parameter_type_id
    IS 'Тип параметра';
    COMMENT ON COLUMN public.measurement_validation_settings.minimum_value
    IS 'Минимальное значение; NULL без ограничения';
    COMMENT ON COLUMN public.measurement_validation_settings.maximum_value
    IS 'Максимальное значение; NULL без ограничения';
    COMMENT ON COLUMN public.measurement_validation_settings.decimal_places
    IS 'Допустимое число знаков после запятой';

    INSERT INTO public.measurement_validation_settings
        (parameter_type_id, minimum_value, maximum_value, decimal_places)
    VALUES
        (1, NULL, NULL, 0),
        (2, -58, 58, 1),
        (3, 500, 900, 0),
        (4, 0, 59, 0),
        (5, 0, 15, 0),
        (6, 0, 150, 0);
END $$;

DO $$
BEGIN
    CREATE SEQUENCE public.seq_measurement_error_types START WITH 1;

    CREATE TABLE public.measurement_error_types (
        id INTEGER PRIMARY KEY DEFAULT nextval('public.seq_measurement_error_types'),
        parameter_type_id INTEGER REFERENCES public.parameter_types (id),
        description TEXT NOT NULL
    );

    COMMENT ON TABLE public.measurement_error_types
    IS 'Ошибки проверки входных параметров';
    COMMENT ON COLUMN public.measurement_error_types.id
    IS 'Номер ошибки';
    COMMENT ON COLUMN public.measurement_error_types.parameter_type_id
    IS 'Тип параметра; NULL для ошибки типа оборудования';
    COMMENT ON COLUMN public.measurement_error_types.description
    IS 'Описание ошибки';
    COMMENT ON SEQUENCE public.seq_measurement_error_types
    IS 'Счетчик ошибок проверки параметров';

    INSERT INTO public.measurement_error_types (parameter_type_id, description)
    VALUES
        (NULL, 'Не указан или неизвестен тип оборудования'),
        (1, 'Высота должна быть целым числом'),
        (2, 'Температура должна быть от -58 до 58 с не более чем одним знаком после запятой'),
        (3, 'Давление должно быть целым числом от 500 до 900'),
        (4, 'Направление ветра должно быть целым числом от 0 до 59'),
        (5, 'Скорость ветра должна быть целым числом от 0 до 15'),
        (6, 'Дальность сноса пуль должна быть целым числом от 0 до 150');

    CREATE TYPE public.measurement_parameters AS (
        equipment_type_id INTEGER,
        height NUMERIC,
        temperature NUMERIC,
        pressure NUMERIC,
        direction NUMERIC,
        speed NUMERIC,
        drift NUMERIC
    );

    COMMENT ON TYPE public.measurement_parameters
    IS 'Входные параметры одной пачки измерений';
    COMMENT ON COLUMN public.measurement_parameters.equipment_type_id
    IS 'Тип оборудования';
    COMMENT ON COLUMN public.measurement_parameters.height
    IS 'Высота метеопоста';
    COMMENT ON COLUMN public.measurement_parameters.temperature
    IS 'Температура воздуха';
    COMMENT ON COLUMN public.measurement_parameters.pressure
    IS 'Давление атмосферы';
    COMMENT ON COLUMN public.measurement_parameters.direction
    IS 'Направление ветра';
    COMMENT ON COLUMN public.measurement_parameters.speed
    IS 'Скорость ветра';
    COMMENT ON COLUMN public.measurement_parameters.drift
    IS 'Дальность сноса пуль';

    CREATE FUNCTION public.validate_measurement_parameters(
        p_parameters public.measurement_parameters
    )
    RETURNS TEXT
    LANGUAGE plpgsql
    AS $function$
    DECLARE
        errors TEXT;
    BEGIN
        WITH input_values AS (
            SELECT 1 AS parameter_type_id, p_parameters.height AS parameter_value
            UNION ALL
            SELECT 2, p_parameters.temperature
            UNION ALL
            SELECT 3, p_parameters.pressure
            UNION ALL
            SELECT 4, p_parameters.direction
            UNION ALL
            SELECT 5, p_parameters.speed
            WHERE p_parameters.equipment_type_id = 1
            UNION ALL
            SELECT 6, p_parameters.drift
            WHERE p_parameters.equipment_type_id = 2
        ),
        found_errors AS (
            SELECT e.parameter_type_id, e.description
            FROM input_values AS v
            JOIN public.measurement_validation_settings AS s
                ON s.parameter_type_id = v.parameter_type_id
            JOIN public.measurement_error_types AS e
                ON e.parameter_type_id = v.parameter_type_id
            WHERE v.parameter_value IS NULL
                OR v.parameter_value < s.minimum_value
                OR v.parameter_value > s.maximum_value
                OR v.parameter_value <> TRUNC(v.parameter_value, s.decimal_places)
            UNION ALL
            SELECT e.parameter_type_id, e.description
            FROM public.measurement_error_types AS e
            WHERE e.parameter_type_id IS NULL AND (
                p_parameters.equipment_type_id IS NULL
                OR p_parameters.equipment_type_id NOT IN (1, 2)
            )
        )
        SELECT
            COALESCE(MAX(CASE WHEN e.parameter_type_id IS NULL THEN e.description || '; ' END), '') ||
            COALESCE(MAX(CASE WHEN e.parameter_type_id = 1 THEN e.description || '; ' END), '') ||
            COALESCE(MAX(CASE WHEN e.parameter_type_id = 2 THEN e.description || '; ' END), '') ||
            COALESCE(MAX(CASE WHEN e.parameter_type_id = 3 THEN e.description || '; ' END), '') ||
            COALESCE(MAX(CASE WHEN e.parameter_type_id = 4 THEN e.description || '; ' END), '') ||
            COALESCE(MAX(CASE WHEN e.parameter_type_id = 5 THEN e.description || '; ' END), '') ||
            COALESCE(MAX(CASE WHEN e.parameter_type_id = 6 THEN e.description || '; ' END), '')
        INTO errors
        FROM found_errors AS e;

        RETURN errors;
    END;
    $function$;

    COMMENT ON FUNCTION public.validate_measurement_parameters(public.measurement_parameters)
    IS 'Список ошибок одной пачки; пустая строка при отсутствии ошибок';
END $$;
