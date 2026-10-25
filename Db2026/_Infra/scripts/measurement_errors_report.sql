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
