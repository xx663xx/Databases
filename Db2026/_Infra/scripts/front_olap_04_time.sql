-- PostgreSQL, база front_olap_resources. В журнале Front есть события с января 2012 по декабрь 2023 года.
DO $$
DECLARE
    month_names text[] := ARRAY[
        'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
        'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    quarter_names text[] := ARRAY['I квартал', 'II квартал', 'III квартал', 'IV квартал'];
    first_day date;
    next_month date;
    quarter_number integer;
    month_code integer;
BEGIN
    BEGIN
        CREATE TABLE IF NOT EXISTS public.dim_time (
            time_id bigint PRIMARY KEY,
            month_start date NOT NULL,
            month_end date NOT NULL,
            month_name text NOT NULL,
            year_no integer NOT NULL,
            quarter_no integer NOT NULL,
            quarter_name text NOT NULL
        );

        COMMENT ON TABLE public.dim_time IS 'Календарь по месяцам';
        COMMENT ON COLUMN public.dim_time.time_id IS 'Код месяца в формате ГГГГММ';
        COMMENT ON COLUMN public.dim_time.month_start IS 'Первый день месяца';
        COMMENT ON COLUMN public.dim_time.month_end IS 'Последний день месяца';
        COMMENT ON COLUMN public.dim_time.month_name IS 'Название месяца';
        COMMENT ON COLUMN public.dim_time.year_no IS 'Год';
        COMMENT ON COLUMN public.dim_time.quarter_no IS 'Номер квартала';
        COMMENT ON COLUMN public.dim_time.quarter_name IS 'Название квартала';
    END;

    BEGIN
        FOR y IN 2012..2023 LOOP
            first_day := (y::text || '-01-01')::date;
            FOR m IN 1..12 LOOP
                IF m = 12 THEN
                    next_month := ((y + 1)::text || '-01-01')::date;
                ELSE
                    next_month := (y::text || '-' || (m + 1)::text || '-01')::date;
                END IF;

                month_code := y * 100 + m;
                quarter_number := (m - 1) / 3 + 1;
                IF NOT EXISTS (SELECT 1 FROM public.dim_time WHERE time_id = month_code) THEN
                    INSERT INTO public.dim_time
                        (time_id, month_start, month_end, month_name, year_no, quarter_no, quarter_name)
                    VALUES
                        (month_code, first_day, next_month - 1, month_names[m], y,
                         quarter_number, quarter_names[quarter_number]);
                END IF;
                first_day := next_month;
            END LOOP;
        END LOOP;
    END;
END;
$$;
