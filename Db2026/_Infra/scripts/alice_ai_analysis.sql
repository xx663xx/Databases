SELECT
    usr.code AS user_code,
    usr.full_name,
    COALESCE(user_counts.measurement_count, 0) AS measurement_count
FROM public.users AS usr
LEFT JOIN
(
    SELECT
        user_code,
        COUNT(*) AS measurement_count
    FROM public.batches
    GROUP BY user_code
) AS user_counts
    ON usr.code = user_counts.user_code
ORDER BY user_code;


SELECT
    batch.code AS batch_code,
    batch.measured_at,
    COALESCE(batch_counts.parameter_count, 0) AS parameter_count
FROM public.batches AS batch
LEFT JOIN
(
    SELECT
        batch_code,
        COUNT(*) AS parameter_count
    FROM public.parameters
    GROUP BY batch_code
) AS batch_counts
    ON batch_counts.batch_code = batch.code
WHERE COALESCE(batch_counts.parameter_count, 0) = 0
ORDER BY batch_code;


SELECT
    batch.code AS batch_code,
    batch.user_code,
    COALESCE(batch_counts.parameter_count, 0) AS parameter_count
FROM public.batches AS batch
LEFT JOIN
(
    SELECT
        batch_code,
        COUNT(*) AS parameter_count
    FROM public.parameters
    GROUP BY batch_code
) AS batch_counts
    ON batch_counts.batch_code = batch.code
WHERE COALESCE(batch_counts.parameter_count, 0) < 5
   OR COALESCE(batch_counts.parameter_count, 0) > 5
ORDER BY batch_code;


SELECT
    param.code AS parameter_code,
    param.batch_code,
    param.parameter_type_code,
    param_type.name AS parameter_name,
    param.parameter_value,
    unit.name AS unit_name
FROM public.parameters AS param
LEFT JOIN public.parameter_types AS param_type
    ON param_type.code = param.parameter_type_code
LEFT JOIN public.measurement_units AS unit
    ON unit.code = param.measurement_unit_code
WHERE param.parameter_value IS NULL
   OR param_type.code IS NULL
   OR (param.parameter_type_code = 'TYPE-002'
       AND (param.parameter_value < -58 OR param.parameter_value > 58))
   OR (param.parameter_type_code = 'TYPE-003'
       AND (param.parameter_value < 500 OR param.parameter_value > 900))
   OR (param.parameter_type_code = 'TYPE-004'
       AND (param.parameter_value < 0 OR param.parameter_value > 59))
   OR (param.parameter_type_code = 'TYPE-005'
       AND (param.parameter_value < 0 OR param.parameter_value > 15))
   OR (param.parameter_type_code = 'TYPE-006'
       AND (param.parameter_value < 0 OR param.parameter_value > 150))
ORDER BY batch_code, parameter_code;


SELECT
    param.code AS parameter_code,
    param.batch_code,
    param.parameter_type_code,
    param_type.name AS parameter_name,
    param.measurement_unit_code AS unit_code,
    unit.name AS unit_name
FROM public.parameters AS param
LEFT JOIN public.parameter_types AS param_type
    ON param_type.code = param.parameter_type_code
LEFT JOIN public.measurement_units AS unit
    ON unit.code = param.measurement_unit_code
WHERE param_type.code IS NULL
   OR unit.code IS NULL
   OR NOT
   (
       (param.parameter_type_code = 'TYPE-001' AND unit.code = 'UNIT-001')
       OR (param.parameter_type_code = 'TYPE-002' AND unit.code = 'UNIT-002')
       OR (param.parameter_type_code = 'TYPE-003' AND unit.code = 'UNIT-003')
       OR (param.parameter_type_code = 'TYPE-004' AND unit.code = 'UNIT-004')
       OR (param.parameter_type_code = 'TYPE-005' AND unit.code = 'UNIT-005')
       OR (param.parameter_type_code = 'TYPE-006' AND unit.code = 'UNIT-001')
   )
ORDER BY batch_code, parameter_code;