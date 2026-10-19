DO $$
BEGIN
    ALTER TABLE public.temperature_corrections
    ADD COLUMN temperature NUMERIC(4,1);

    UPDATE public.temperature_corrections
    SET temperature = -58
    WHERE temperature_category = 'Ниже 0';

    UPDATE public.temperature_corrections
    SET temperature = 0
    WHERE temperature_category = '0 - 5';

    UPDATE public.temperature_corrections
    SET temperature = 10
    WHERE temperature_category = '10 - 15';

    UPDATE public.temperature_corrections
    SET temperature = 20
    WHERE temperature_category = '20';

    UPDATE public.temperature_corrections
    SET temperature = 25
    WHERE temperature_category = '25';

    UPDATE public.temperature_corrections
    SET temperature = 30
    WHERE temperature_category = '30';

    UPDATE public.temperature_corrections
    SET temperature = 40
    WHERE temperature_category = '40';

    INSERT INTO public.temperature_corrections (temperature, correction)
    SELECT 5, correction
    FROM public.temperature_corrections
    WHERE temperature = 0;

    INSERT INTO public.temperature_corrections (temperature, correction)
    SELECT 15, correction
    FROM public.temperature_corrections
    WHERE temperature = 10;

    ALTER TABLE public.temperature_corrections
    DROP COLUMN temperature_category;

    COMMENT ON COLUMN public.temperature_corrections.temperature
    IS 'Опорная температура, °C';

    CREATE TYPE public.interpolation_bounds AS (
        x0 NUMERIC,
        y0 NUMERIC,
        x1 NUMERIC,
        y1 NUMERIC
    );
    COMMENT ON TYPE public.interpolation_bounds IS 'Опорные точки для интерполяции';

    CREATE FUNCTION public.get_temperature_interpolation_params(p_temperature NUMERIC)
    RETURNS public.interpolation_bounds
    LANGUAGE plpgsql
    AS $function$
    DECLARE
        temperature_bounds public.interpolation_bounds;
    BEGIN
        IF p_temperature < 0 THEN
            temperature_bounds.x0 := p_temperature;
            temperature_bounds.x1 := p_temperature;

            SELECT correction, correction
            INTO temperature_bounds.y0, temperature_bounds.y1
            FROM public.temperature_corrections
            WHERE temperature < 0
            ORDER BY temperature DESC
            LIMIT 1;

            RETURN temperature_bounds;
        END IF;

        SELECT temperature, correction
        INTO temperature_bounds.x0, temperature_bounds.y0
        FROM public.temperature_corrections
        WHERE temperature <= p_temperature
        ORDER BY temperature DESC
        LIMIT 1;

        SELECT temperature, correction
        INTO temperature_bounds.x1, temperature_bounds.y1
        FROM public.temperature_corrections
        WHERE temperature >= p_temperature
        ORDER BY temperature
        LIMIT 1;

        IF temperature_bounds.x0 IS NULL OR temperature_bounds.x1 IS NULL THEN
            RAISE EXCEPTION 'Для температуры % нет двух опорных точек в таблице поправок',
                p_temperature;
        END IF;

        RETURN temperature_bounds;
    END;
    $function$;

    COMMENT ON FUNCTION public.get_temperature_interpolation_params(NUMERIC)
    IS 'Опорные точки температурной поправки по таблице 1';

    CREATE FUNCTION public.calculate_interpolation(
        p_x NUMERIC,
        p_interpolation public.interpolation_bounds
    )
    RETURNS NUMERIC
    LANGUAGE plpgsql
    AS $function$
    BEGIN
        IF p_interpolation.x0 = p_interpolation.x1 THEN
            RETURN p_interpolation.y0;
        END IF;

        RETURN p_interpolation.y0
            + (p_x - p_interpolation.x0)
            * (p_interpolation.y1 - p_interpolation.y0)
            / (p_interpolation.x1 - p_interpolation.x0);
    END;
    $function$;

    COMMENT ON FUNCTION public.calculate_interpolation(NUMERIC, public.interpolation_bounds)
    IS 'Расчет линейной интерполяции по двум опорным точкам';

END $$;