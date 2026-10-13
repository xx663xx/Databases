SELECT
    ROW_NUMBER() OVER (ORDER BY object_type, object_name) AS "№",
    object_name AS "Наименование",
    object_type AS "Тип"
FROM (
    SELECT table_name AS object_name, 'Таблица' AS object_type
    FROM information_schema.tables
    WHERE table_schema = 'public'
        AND table_catalog = 'transactions_db'
        AND table_type = 'BASE TABLE'

    UNION ALL

    SELECT sequence_name AS object_name, 'Последовательность' AS object_type
    FROM information_schema.sequences
    WHERE sequence_schema = 'public'
        AND sequence_catalog = 'transactions_db'
) AS metadata
ORDER BY object_type, object_name;