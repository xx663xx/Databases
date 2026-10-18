DO $$
BEGIN
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
            WHERE temperature_category = 'Ниже 0';

            RETURN temperature_bounds;
        END IF;

        SELECT points.temperature, corrections.correction
        INTO temperature_bounds.x0, temperature_bounds.y0
        FROM public.temperature_corrections AS corrections
        INNER JOIN (
            SELECT '0 - 5' AS temperature_category, 0 AS temperature
            UNION ALL SELECT '0 - 5', 5
            UNION ALL SELECT '10 - 15', 10
            UNION ALL SELECT '10 - 15', 15
            UNION ALL SELECT '20', 20
            UNION ALL SELECT '25', 25
            UNION ALL SELECT '30', 30
            UNION ALL SELECT '40', 40
        ) AS points ON points.temperature_category = corrections.temperature_category
        WHERE points.temperature <= p_temperature
        ORDER BY points.temperature DESC
        LIMIT 1;

        SELECT points.temperature, corrections.correction
        INTO temperature_bounds.x1, temperature_bounds.y1
        FROM public.temperature_corrections AS corrections
        INNER JOIN (
            SELECT '0 - 5' AS temperature_category, 0 AS temperature
            UNION ALL SELECT '0 - 5', 5
            UNION ALL SELECT '10 - 15', 10
            UNION ALL SELECT '10 - 15', 15
            UNION ALL SELECT '20', 20
            UNION ALL SELECT '25', 25
            UNION ALL SELECT '30', 30
            UNION ALL SELECT '40', 40
        ) AS points ON points.temperature_category = corrections.temperature_category
        WHERE points.temperature >= p_temperature
        ORDER BY points.temperature
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