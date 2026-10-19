DO $$
DECLARE
    temperature_bounds public.interpolation_bounds;
    temperature_correction NUMERIC(8,2);
    virtual_temperature NUMERIC(8,2);
    deviation NUMERIC(8,2);
    check_status TEXT;
BEGIN
    DROP TABLE IF EXISTS interpolation_check_results;

    CREATE TEMP TABLE interpolation_check_results (
        test_number INTEGER,
        test_name TEXT,
        expected NUMERIC(8,2),
        actual NUMERIC(8,2),
        result TEXT
    );

    temperature_bounds := public.get_temperature_interpolation_params(23);
    temperature_correction := public.calculate_interpolation(23, temperature_bounds);

    IF temperature_bounds.x0 = 20 AND temperature_bounds.y0 = 1.5
       AND temperature_bounds.x1 = 25 AND temperature_bounds.y1 = 2
       AND temperature_correction = 1.8 THEN
        check_status := 'OK';
    ELSE
        check_status := 'ОШИБКА';
    END IF;

    INSERT INTO interpolation_check_results
    VALUES (1, 'Пример 1, поправка при 23 °C', 1.8, temperature_correction, check_status);

    virtual_temperature := 23 + temperature_correction;
    deviation := ROUND(virtual_temperature - 15.9);

    IF virtual_temperature = 24.8 THEN
        check_status := 'OK';
    ELSE
        check_status := 'ОШИБКА';
    END IF;

    INSERT INTO interpolation_check_results
    VALUES (2, 'Пример 1, виртуальная температура', 24.8, virtual_temperature, check_status);

    IF deviation = 9 THEN
        check_status := 'OK';
    ELSE
        check_status := 'ОШИБКА';
    END IF;

    INSERT INTO interpolation_check_results
    VALUES (3, 'Пример 1, отклонение', 9, deviation, check_status);

    temperature_bounds := public.get_temperature_interpolation_params(25);
    temperature_correction := public.calculate_interpolation(25, temperature_bounds);
    deviation := ROUND(25 + temperature_correction - 15.9);

    IF temperature_correction = 2 THEN
        check_status := 'OK';
    ELSE
        check_status := 'ОШИБКА';
    END IF;

    INSERT INTO interpolation_check_results
    VALUES (4, 'Пример 2, поправка при 25 °C', 2, temperature_correction, check_status);

    IF deviation = 11 THEN
        check_status := 'OK';
    ELSE
        check_status := 'ОШИБКА';
    END IF;

    INSERT INTO interpolation_check_results
    VALUES (5, 'Пример 2, отклонение', 11, deviation, check_status);
END $$;

SELECT
    test_number AS "№",
    test_name AS "Проверка",
    expected AS "Ожидание",
    actual AS "Получено",
    result AS "Результат"
FROM interpolation_check_results
ORDER BY test_number;