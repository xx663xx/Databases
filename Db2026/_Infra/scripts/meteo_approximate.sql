DO $$
BEGIN
    CREATE TABLE public.meteo_constants (
        code VARCHAR(50) PRIMARY KEY,
        constant_value NUMERIC NOT NULL,
        description TEXT NOT NULL
    );

    COMMENT ON TABLE public.meteo_constants IS 'Константы заголовка метеобюллетеня';
    COMMENT ON COLUMN public.meteo_constants.code IS 'Код константы';
    COMMENT ON COLUMN public.meteo_constants.constant_value IS 'Значение константы';
    COMMENT ON COLUMN public.meteo_constants.description IS 'Описание константы';

    INSERT INTO public.meteo_constants (code, constant_value, description)
    VALUES
        ('base_pressure', 750, 'Табличное давление, мм рт. ст.'),
        ('base_virtual_temperature', 15.9, 'Табличная виртуальная температура, °C'),
        ('negative_pressure_code', 500, 'Добавка для отрицательного отклонения давления'),
        ('negative_temperature_code', 50, 'Добавка для отрицательного отклонения температуры');

    CREATE FUNCTION public.get_meteo_constant(p_code VARCHAR)
    RETURNS NUMERIC
    LANGUAGE plpgsql
    AS $function$
    DECLARE
        value NUMERIC;
    BEGIN
        SELECT constant_value INTO value
        FROM public.meteo_constants
        WHERE code = p_code;

        IF value IS NULL THEN
            RAISE EXCEPTION 'Не найдена константа %', p_code;
        END IF;

        RETURN value;
    END;
    $function$;

    COMMENT ON FUNCTION public.get_meteo_constant(VARCHAR)
    IS 'Получение расчетной константы по коду';

    CREATE FUNCTION public.format_meteo_datetime(p_measured_at TIMESTAMP)
    RETURNS TEXT
    LANGUAGE plpgsql
    AS $function$
    BEGIN
        RETURN LPAD(EXTRACT(DAY FROM p_measured_at)::TEXT, 2, '0')
            || LPAD(EXTRACT(HOUR FROM p_measured_at)::TEXT, 2, '0')
            || TRUNC(EXTRACT(MINUTE FROM p_measured_at) / 10)::TEXT;
    END;
    $function$;

    COMMENT ON FUNCTION public.format_meteo_datetime(TIMESTAMP)
    IS 'Дата измерения в формате ДДЧЧМ';

    CREATE FUNCTION public.format_meteo_height(p_height INTEGER)
    RETURNS TEXT
    LANGUAGE plpgsql
    AS $function$
    BEGIN
        IF LENGTH(p_height::TEXT) > 4 THEN
            RAISE EXCEPTION 'Высота % не помещается в поле ВВВВ', p_height;
        END IF;

        IF p_height < 0 THEN
            RETURN '-' || LPAD(ABS(p_height)::TEXT, 3, '0');
        END IF;

        RETURN LPAD(p_height::TEXT, 4, '0');
    END;
    $function$;

    COMMENT ON FUNCTION public.format_meteo_height(INTEGER)
    IS 'Высота метеопоста в формате ВВВВ';

    CREATE FUNCTION public.calculate_meteo_pressure(p_pressure NUMERIC)
    RETURNS NUMERIC
    LANGUAGE plpgsql
    AS $function$
    BEGIN
        RETURN p_pressure - public.get_meteo_constant('base_pressure');
    END;
    $function$;

    COMMENT ON FUNCTION public.calculate_meteo_pressure(NUMERIC)
    IS 'Отклонение наземного давления от табличного';

    CREATE FUNCTION public.calculate_meteo_temperature(p_temperature NUMERIC)
    RETURNS NUMERIC
    LANGUAGE plpgsql
    AS $function$
    DECLARE
        correction_temperature NUMERIC;
        correction NUMERIC;
    BEGIN
        -- Выше последней точки используем последнюю табличную поправку.
        SELECT LEAST(p_temperature, MAX(temperature)) INTO correction_temperature
        FROM public.temperature_corrections;

        correction := public.calculate_interpolation(
            correction_temperature,
            public.get_temperature_interpolation_params(correction_temperature)
        );

        RETURN ROUND(p_temperature + correction
            - public.get_meteo_constant('base_virtual_temperature'));
    END;
    $function$;

    COMMENT ON FUNCTION public.calculate_meteo_temperature(NUMERIC)
    IS 'Округленное отклонение виртуальной температуры от табличного';

    CREATE FUNCTION public.format_meteo_pressure_temperature(
        p_pressure NUMERIC,
        p_temperature NUMERIC
    )
    RETURNS TEXT
    LANGUAGE plpgsql
    AS $function$
    DECLARE
        pressure_code NUMERIC;
        temperature_code NUMERIC;
    BEGIN
        pressure_code := public.calculate_meteo_pressure(p_pressure);
        temperature_code := public.calculate_meteo_temperature(p_temperature);

        IF pressure_code < 0 THEN
            pressure_code := public.get_meteo_constant('negative_pressure_code')
                + ABS(pressure_code);
        END IF;

        IF temperature_code < 0 THEN
            temperature_code := public.get_meteo_constant('negative_temperature_code')
                + ABS(temperature_code);
        END IF;

        IF LENGTH(pressure_code::INTEGER::TEXT) > 3
            OR LENGTH(temperature_code::INTEGER::TEXT) > 2 THEN
            RAISE EXCEPTION 'Отклонения давления % и температуры % не помещаются в поле БББТТ',
                pressure_code, temperature_code;
        END IF;

        RETURN LPAD(pressure_code::INTEGER::TEXT, 3, '0')
            || LPAD(temperature_code::INTEGER::TEXT, 2, '0');
    END;
    $function$;

    COMMENT ON FUNCTION public.format_meteo_pressure_temperature(NUMERIC, NUMERIC)
    IS 'Отклонения давления и температуры в формате БББТТ';

    CREATE FUNCTION public.calculate_meteo_header(
        p_parameters public.measurement_parameters,
        p_measured_at TIMESTAMP DEFAULT LOCALTIMESTAMP
    )
    RETURNS TEXT
    LANGUAGE plpgsql
    AS $function$
    DECLARE
        errors TEXT;
    BEGIN
        errors := public.validate_measurement_parameters(p_parameters);

        IF errors <> '' THEN
            RAISE EXCEPTION '%', errors;
        END IF;

        RETURN public.format_meteo_datetime(p_measured_at) || ' '
            || public.format_meteo_height(p_parameters.height::INTEGER) || ' '
            || public.format_meteo_pressure_temperature(
                p_parameters.pressure, p_parameters.temperature
            );
    END;
    $function$;

    COMMENT ON FUNCTION public.calculate_meteo_header(public.measurement_parameters, TIMESTAMP)
    IS 'Заголовок ДДЧЧМ ВВВВ БББТТ; по умолчанию текущее время сеанса';
END $$;
