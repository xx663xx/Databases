-- 1. Количество пачек измерений у каждого пользователя
SELECT
    usr.code AS user_code,
    usr.full_name,
    batch_counts.batch_count
FROM public.users AS usr
LEFT JOIN
(
    SELECT
        user_code,
        COUNT(*) AS batch_count
    FROM public.batches
    GROUP BY user_code
) AS batch_counts
    ON usr.code = batch_counts.user_code
ORDER BY usr.code;

-- 2. Поиск пустых пачек без параметров
SELECT
    batch.code AS batch_code,
    batch.measured_at,
    batch.user_code
FROM public.batches AS batch
LEFT JOIN public.parameters AS param
    ON batch.code = param.batch_code
WHERE param.code IS NULL
ORDER BY batch.code;

-- 3. Поиск пачек, в которых количество параметров отличается от пяти
SELECT
    batch.code AS batch_code,
    param_counts.parameter_count
FROM public.batches AS batch
LEFT JOIN
(
    SELECT
        batch_code,
        COUNT(*) AS parameter_count
    FROM public.parameters
    GROUP BY batch_code
) AS param_counts
    ON batch.code = param_counts.batch_code
WHERE param_counts.parameter_count < 5
   OR param_counts.parameter_count > 5
   OR param_counts.batch_code IS NULL
ORDER BY batch.code;

-- 4.1. Минимум и максимум каждого типа параметра для сверки с диапазонами ТЗ
SELECT
    param_type.name AS parameter_name,
    value_stats.min_value,
    value_stats.max_value
FROM
(
    SELECT
        parameter_type_code,
        MIN(parameter_value) AS min_value,
        MAX(parameter_value) AS max_value
    FROM public.parameters
    GROUP BY parameter_type_code
) AS value_stats
LEFT JOIN public.parameter_types AS param_type
    ON value_stats.parameter_type_code = param_type.code
ORDER BY value_stats.parameter_type_code;

-- 4.2. Поиск дробных значений там, где по ТЗ требуются целые
SELECT
    checked.code AS parameter_code,
    checked.batch_code,
    param_type.name AS parameter_name,
    checked.parameter_value
FROM
(
    SELECT
        code,
        batch_code,
        parameter_type_code,
        parameter_value,
        CAST(parameter_value AS DECIMAL(10, 0)) AS whole_value
    FROM public.parameters
    WHERE parameter_type_code IN (
        'TYPE-001', 'TYPE-003', 'TYPE-004', 'TYPE-005'
    )
) AS checked
LEFT JOIN public.parameter_types AS param_type
    ON checked.parameter_type_code = param_type.code
WHERE checked.parameter_value < checked.whole_value
   OR checked.parameter_value > checked.whole_value
ORDER BY checked.batch_code, checked.parameter_type_code;

-- 5. Единицы измерения каждого типа параметра для сверки с ТЗ
SELECT
    param_type.name AS parameter_name,
    param.measurement_unit_code AS unit_code,
    unit.name AS unit_name,
    COUNT(*) AS record_count
FROM public.parameters AS param
LEFT JOIN public.parameter_types AS param_type
    ON param.parameter_type_code = param_type.code
LEFT JOIN public.measurement_units AS unit
    ON param.measurement_unit_code = unit.code
GROUP BY
    param.parameter_type_code,
    param_type.name,
    param.measurement_unit_code,
    unit.name
ORDER BY param.parameter_type_code, param.measurement_unit_code;