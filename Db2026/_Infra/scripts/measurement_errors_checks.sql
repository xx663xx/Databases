WITH test_cases (test_name, parameters, expected_errors) AS (
    VALUES
        ('Корректные параметры первого типа', ROW(1, 100, 15, 750, 12, 5, NULL)::public.measurement_parameters, ''),
        ('Корректные параметры второго типа', ROW(2, 80, 18, 755, 15, NULL, 80)::public.measurement_parameters, ''),
        ('Нижние границы и отрицательная высота', ROW(1, -100, -58, 500, 0, 0, NULL)::public.measurement_parameters, ''),
        ('Верхние границы первого типа', ROW(1, 0, 58, 900, 59, 15, NULL)::public.measurement_parameters, ''),
        ('Верхняя граница шестого параметра', ROW(2, 100, 15, 750, 0, NULL, 150)::public.measurement_parameters, ''),
        ('Нулевая дальность', ROW(2, 100, 15, 750, 0, NULL, 0)::public.measurement_parameters, ''),
        ('Один знак после запятой', ROW(1, 100, -3.5, 750, 0, 0, NULL)::public.measurement_parameters, ''),
        ('Неизвестный тип оборудования', ROW(3, 100, 15, 750, 0, NULL, NULL)::public.measurement_parameters, 'Не указан или неизвестен тип оборудования; '),
        ('Не указан тип оборудования', ROW(NULL, 100, 15, 750, 0, NULL, NULL)::public.measurement_parameters, 'Не указан или неизвестен тип оборудования; '),
        ('Отсутствует высота', ROW(1, NULL, 15, 750, 0, 0, NULL)::public.measurement_parameters, 'Высота должна быть целым числом; '),
        ('Дробная высота', ROW(1, 100.5, 15, 750, 0, 0, NULL)::public.measurement_parameters, 'Высота должна быть целым числом; '),
        ('Отсутствует температура', ROW(1, 100, NULL, 750, 0, 0, NULL)::public.measurement_parameters, 'Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; '),
        ('Температура ниже минимума', ROW(1, 100, -58.1, 750, 0, 0, NULL)::public.measurement_parameters, 'Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; '),
        ('Температура выше максимума', ROW(1, 100, 58.1, 750, 0, 0, NULL)::public.measurement_parameters, 'Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; '),
        ('Два знака после запятой', ROW(1, 100, 15.55, 750, 0, 0, NULL)::public.measurement_parameters, 'Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; '),
        ('Отсутствует давление', ROW(1, 100, 15, NULL, 0, 0, NULL)::public.measurement_parameters, 'Давление должно быть целым числом от 500 до 900; '),
        ('Давление ниже минимума', ROW(1, 100, 15, 499, 0, 0, NULL)::public.measurement_parameters, 'Давление должно быть целым числом от 500 до 900; '),
        ('Давление выше максимума', ROW(1, 100, 15, 901, 0, 0, NULL)::public.measurement_parameters, 'Давление должно быть целым числом от 500 до 900; '),
        ('Дробное давление', ROW(1, 100, 15, 750.5, 0, 0, NULL)::public.measurement_parameters, 'Давление должно быть целым числом от 500 до 900; '),
        ('Отсутствует направление', ROW(1, 100, 15, 750, NULL, 0, NULL)::public.measurement_parameters, 'Направление ветра должно быть целым числом от 0 до 59; '),
        ('Направление ниже минимума', ROW(1, 100, 15, 750, -1, 0, NULL)::public.measurement_parameters, 'Направление ветра должно быть целым числом от 0 до 59; '),
        ('Направление выше максимума', ROW(1, 100, 15, 750, 60, 0, NULL)::public.measurement_parameters, 'Направление ветра должно быть целым числом от 0 до 59; '),
        ('Дробное направление', ROW(1, 100, 15, 750, 12.5, 0, NULL)::public.measurement_parameters, 'Направление ветра должно быть целым числом от 0 до 59; '),
        ('Отсутствует скорость', ROW(1, 100, 15, 750, 0, NULL, NULL)::public.measurement_parameters, 'Скорость ветра должна быть целым числом от 0 до 15; '),
        ('Скорость ниже минимума', ROW(1, 100, 15, 750, 0, -1, NULL)::public.measurement_parameters, 'Скорость ветра должна быть целым числом от 0 до 15; '),
        ('Скорость выше максимума', ROW(1, 100, 15, 750, 0, 16, NULL)::public.measurement_parameters, 'Скорость ветра должна быть целым числом от 0 до 15; '),
        ('Дробная скорость', ROW(1, 100, 15, 750, 0, 1.5, NULL)::public.measurement_parameters, 'Скорость ветра должна быть целым числом от 0 до 15; '),
        ('Отсутствует дальность', ROW(2, 100, 15, 750, 0, NULL, NULL)::public.measurement_parameters, 'Дальность сноса пуль должна быть целым числом от 0 до 150; '),
        ('Дальность ниже минимума', ROW(2, 100, 15, 750, 0, NULL, -1)::public.measurement_parameters, 'Дальность сноса пуль должна быть целым числом от 0 до 150; '),
        ('Дальность выше максимума', ROW(2, 100, 15, 750, 0, NULL, 151)::public.measurement_parameters, 'Дальность сноса пуль должна быть целым числом от 0 до 150; '),
        ('Дробная дальность', ROW(2, 100, 15, 750, 0, NULL, 1.5)::public.measurement_parameters, 'Дальность сноса пуль должна быть целым числом от 0 до 150; '),
        ('Пять ошибок в одной пачке', ROW(1, 100.5, 60, 450, 60, 16, NULL)::public.measurement_parameters, 'Высота должна быть целым числом; Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; Давление должно быть целым числом от 500 до 900; Направление ветра должно быть целым числом от 0 до 59; Скорость ветра должна быть целым числом от 0 до 15; '),
        ('Четыре ошибки в одной пачке', ROW(2, 150, -60, 950, -1, NULL, 151)::public.measurement_parameters, 'Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; Давление должно быть целым числом от 500 до 900; Направление ветра должно быть целым числом от 0 до 59; Дальность сноса пуль должна быть целым числом от 0 до 150; '),
        ('Пустая пачка первого типа', ROW(1, NULL, NULL, NULL, NULL, NULL, NULL)::public.measurement_parameters, 'Высота должна быть целым числом; Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; Давление должно быть целым числом от 500 до 900; Направление ветра должно быть целым числом от 0 до 59; Скорость ветра должна быть целым числом от 0 до 15; '),
        ('Пустая пачка второго типа', ROW(2, NULL, NULL, NULL, NULL, NULL, NULL)::public.measurement_parameters, 'Высота должна быть целым числом; Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; Давление должно быть целым числом от 500 до 900; Направление ветра должно быть целым числом от 0 до 59; Дальность сноса пуль должна быть целым числом от 0 до 150; '),
        ('Неиспользуемое поле первого типа', ROW(1, 100, 15, 750, 0, 0, -999)::public.measurement_parameters, ''),
        ('Неиспользуемое поле второго типа', ROW(2, 100, 15, 750, 0, -999, 0)::public.measurement_parameters, ''),
        ('NULL вместо составного значения', NULL::public.measurement_parameters, 'Не указан или неизвестен тип оборудования; Высота должна быть целым числом; Температура должна быть от -58 до 58 с не более чем одним знаком после запятой; Давление должно быть целым числом от 500 до 900; Направление ветра должно быть целым числом от 0 до 59; ')
),
results AS (
    SELECT
        tc.*,
        public.validate_measurement_parameters(tc.parameters) AS errors
    FROM test_cases AS tc
)
SELECT
    r.test_name AS "Проверка",
    CASE
        WHEN r.errors = r.expected_errors THEN 'OK'
        ELSE 'Ошибка'
    END AS "Результат",
    r.expected_errors AS "Ожидаемое описание",
    r.errors AS "Полученное описание"
FROM results AS r
ORDER BY r.test_name;

WITH checks AS (
    SELECT test_name, actual, expected
    FROM (
        VALUES
            ('Дата из ТЗ', public.format_meteo_datetime(TIMESTAMP '2026-10-24 09:30:00'), '24093'),
            ('Первый день и полночь', public.format_meteo_datetime(TIMESTAMP '2026-10-01 00:00:00'), '01000'),
            ('Минуты меньше десяти', public.format_meteo_datetime(TIMESTAMP '2026-10-09 09:09:00'), '09090'),
            ('Последние минуты месяца', public.format_meteo_datetime(TIMESTAMP '2026-10-31 23:59:00'), '31235'),
            ('Нулевая высота', public.format_meteo_height(0), '0000'),
            ('Высота из ТЗ', public.format_meteo_height(60), '0060'),
            ('Отрицательная высота', public.format_meteo_height(-60), '-060'),
            ('Четырехзначная высота', public.format_meteo_height(9999), '9999'),
            ('Давление без отклонения', public.calculate_meteo_pressure(750)::TEXT, '0'),
            ('Положительное отклонение давления', public.calculate_meteo_pressure(757)::TEXT, '7'),
            ('Отрицательное отклонение давления', public.calculate_meteo_pressure(743)::TEXT, '-7'),
            ('Температура 23 из ТЗ', public.calculate_meteo_temperature(23)::TEXT, '9'),
            ('Температура 25 из ТЗ', public.calculate_meteo_temperature(25)::TEXT, '11'),
            ('Нижняя граница температуры', public.calculate_meteo_temperature(-58)::TEXT, '-74'),
            ('Нулевая температура', public.calculate_meteo_temperature(0)::TEXT, '-15'),
            ('Поправка внутри интервала 0-5', public.calculate_meteo_temperature(3)::TEXT, '-12'),
            ('Последняя опорная температура', public.calculate_meteo_temperature(40)::TEXT, '29'),
            ('Температура выше таблицы', public.calculate_meteo_temperature(50)::TEXT, '39'),
            ('Верхняя граница температуры', public.calculate_meteo_temperature(58)::TEXT, '47'),
            ('БББТТ из ТЗ', public.format_meteo_pressure_temperature(765, 25), '01511'),
            ('Положительное давление 7', public.format_meteo_pressure_temperature(757, 23), '00709'),
            ('Положительное давление 13', public.format_meteo_pressure_temperature(763, 23), '01309'),
            ('Отрицательное давление 7', public.format_meteo_pressure_temperature(743, 23), '50709'),
            ('Отрицательное давление 13', public.format_meteo_pressure_temperature(737, 23), '51309'),
            ('Отрицательная температура', public.format_meteo_pressure_temperature(750, 0), '00065'),
            ('Граница двух цифр ТТ', public.format_meteo_pressure_temperature(750, -33), '00099'),
            ('Нижняя граница давления', public.format_meteo_pressure_temperature(500, 23), '75009'),
            ('Верхняя граница давления', public.format_meteo_pressure_temperature(900, 23), '15009'),
            ('БББТТ при температуре 58', public.format_meteo_pressure_temperature(750, 58), '00047')
    ) AS examples(test_name, actual, expected)

    UNION ALL

    SELECT
        'Полный заголовок из ТЗ',
        public.calculate_meteo_header(
            ROW(1, 100, 25, 765, 15, 6, NULL)::public.measurement_parameters,
            TIMESTAMP '2026-10-24 09:30:00'
        ),
        '24093 0100 01511'

    UNION ALL

    SELECT
        'Заголовок для второго типа оборудования',
        public.calculate_meteo_header(
            ROW(2, 60, 23, 743, 15, NULL, 80)::public.measurement_parameters,
            TIMESTAMP '2026-10-24 09:30:00'
        ),
        '24093 0060 50709'

    UNION ALL

    SELECT
        'Текущая дата по умолчанию',
        public.calculate_meteo_header(
            ROW(1, 100, 25, 765, 15, 6, NULL)::public.measurement_parameters
        ),
        public.format_meteo_datetime(LOCALTIMESTAMP) || ' 0100 01511'
)
SELECT
    test_name AS "Проверка",
    CASE WHEN actual = expected THEN 'OK' ELSE 'Ошибка' END AS "Результат",
    expected AS "Ожидание",
    actual AS "Получено"
FROM checks
ORDER BY test_name;
