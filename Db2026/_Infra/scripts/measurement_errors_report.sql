WITH batch_parameters AS (
    SELECT
        b.id AS batch_id,
        b.equipment_type_id,
        MAX(CASE WHEN p.parameter_type_id = 1 THEN p.parameter_value END) AS height,
        MAX(CASE WHEN p.parameter_type_id = 2 THEN p.parameter_value END) AS temperature,
        MAX(CASE WHEN p.parameter_type_id = 3 THEN p.parameter_value END) AS pressure,
        MAX(CASE WHEN p.parameter_type_id = 4 THEN p.parameter_value END) AS direction,
        MAX(CASE WHEN p.parameter_type_id = 5 THEN p.parameter_value END) AS speed,
        MAX(CASE WHEN p.parameter_type_id = 6 THEN p.parameter_value END) AS drift
    FROM public.batches AS b
    LEFT JOIN public.parameters AS p ON p.batch_id = b.id
    GROUP BY b.id, b.equipment_type_id
),
checked_parameters AS (
    SELECT
        bp.*,
        public.validate_measurement_parameters(
            ROW(bp.equipment_type_id, bp.height, bp.temperature, bp.pressure,
                bp.direction, bp.speed, bp.drift)::public.measurement_parameters
        ) AS errors
    FROM batch_parameters AS bp
)
SELECT
    cp.batch_id AS "№",
    e.name AS "Тип оборудования",
    cp.height AS "Высота метеопоста",
    cp.temperature AS "Температура",
    cp.pressure AS "Давление",
    cp.direction AS "Направление ветра",
    cp.speed AS "Скорость ветра",
    cp.drift AS "Дальность сноса пуль",
    cp.errors <> '' AS "Флаг: Есть ошибка",
    cp.errors AS "Описание ошибки"
FROM checked_parameters AS cp
LEFT JOIN public.equipment_types AS e ON e.id = cp.equipment_type_id
ORDER BY cp.batch_id;

WITH batch_parameters AS (
    SELECT
        b.id AS batch_id,
        b.user_id,
        b.equipment_type_id,
        MAX(CASE WHEN p.parameter_type_id = 1 THEN p.parameter_value END) AS height,
        MAX(CASE WHEN p.parameter_type_id = 2 THEN p.parameter_value END) AS temperature,
        MAX(CASE WHEN p.parameter_type_id = 3 THEN p.parameter_value END) AS pressure,
        MAX(CASE WHEN p.parameter_type_id = 4 THEN p.parameter_value END) AS direction,
        MAX(CASE WHEN p.parameter_type_id = 5 THEN p.parameter_value END) AS speed,
        MAX(CASE WHEN p.parameter_type_id = 6 THEN p.parameter_value END) AS drift
    FROM public.batches AS b
    LEFT JOIN public.parameters AS p ON p.batch_id = b.id
    GROUP BY b.id, b.user_id, b.equipment_type_id
),
checked_parameters AS (
    SELECT
        bp.batch_id,
        bp.user_id,
        bp.equipment_type_id,
        CASE s.parameter_type_id
            WHEN 1 THEN bp.height
            WHEN 2 THEN bp.temperature
            WHEN 3 THEN bp.pressure
            WHEN 4 THEN bp.direction
            WHEN 5 THEN bp.speed
            WHEN 6 THEN bp.drift
        END AS parameter_value,
        s.minimum_value,
        s.maximum_value,
        s.decimal_places
    FROM batch_parameters AS bp
    JOIN public.measurement_validation_settings AS s
        ON s.parameter_type_id IN (1, 2, 3, 4)
        OR (s.parameter_type_id = 5 AND bp.equipment_type_id = 1)
        OR (s.parameter_type_id = 6 AND bp.equipment_type_id = 2)
),
batch_errors AS (
    SELECT
        cp.batch_id,
        cp.user_id,
        SUM(
            CASE
                WHEN cp.parameter_value IS NULL
                    OR cp.parameter_value < cp.minimum_value
                    OR cp.parameter_value > cp.maximum_value
                    OR cp.parameter_value <> TRUNC(cp.parameter_value, cp.decimal_places)
                THEN 1
                ELSE 0
            END
        ) + CASE
                WHEN cp.equipment_type_id IS NULL OR cp.equipment_type_id NOT IN (1, 2)
                THEN 1
                ELSE 0
            END AS errors_count
    FROM checked_parameters AS cp
    GROUP BY cp.batch_id, cp.user_id, cp.equipment_type_id
),
user_errors AS (
    SELECT
        u.id AS user_id,
        u.full_name,
        COALESCE(SUM(be.errors_count), 0) AS errors_count
    FROM public.users AS u
    LEFT JOIN batch_errors AS be ON be.user_id = u.id
    GROUP BY u.id, u.full_name
)
SELECT
    ue.full_name AS "Пользователь",
    ue.errors_count AS "Количество ошибок"
FROM user_errors AS ue
ORDER BY ue.errors_count, ue.user_id;
