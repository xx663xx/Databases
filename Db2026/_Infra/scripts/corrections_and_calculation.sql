DO $$
BEGIN
    BEGIN
        CREATE SEQUENCE public.calc_correction_headers_seq;
        CREATE TABLE public.calc_correction_headers (
            id INTEGER PRIMARY KEY DEFAULT nextval('public.calc_correction_headers_seq'),
            column_values INTEGER[] NOT NULL
        );
        COMMENT ON SEQUENCE public.calc_correction_headers_seq IS 'Счетчик заголовков';
        COMMENT ON TABLE public.calc_correction_headers IS 'Заголовки таблиц корректировок';
        COMMENT ON COLUMN public.calc_correction_headers.id IS 'Код заголовка';
        COMMENT ON COLUMN public.calc_correction_headers.column_values IS 'Входные значения в порядке столбцов';
        UPDATE public.calc_correction_types
        SET header_values = ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,40,50]
        WHERE id = 1;

        ALTER TABLE public.calc_correction_types ADD COLUMN header_id INTEGER;
        COMMENT ON COLUMN public.calc_correction_types.header_id IS 'Код заголовка таблицы';

        INSERT INTO public.calc_correction_headers (column_values)
        SELECT header_values
        FROM public.calc_correction_types
        WHERE id IN (1, 4, 6)
        ORDER BY id;

        UPDATE public.calc_correction_types AS t
        SET header_id = h.id
        FROM public.calc_correction_headers AS h
        WHERE t.id IN (1, 4, 6) AND t.header_values = h.column_values;

        UPDATE public.calc_correction_types
        SET header_id = (SELECT header_id FROM public.calc_correction_types WHERE id = 1)
        WHERE parent_id = 1;

        ALTER TABLE public.calc_correction_types DROP COLUMN header_values;
        ALTER TABLE public.calc_correction_types
            ADD FOREIGN KEY (header_id) REFERENCES public.calc_correction_headers (id),
            ADD FOREIGN KEY (parent_id) REFERENCES public.calc_correction_types (id),
            ADD FOREIGN KEY (measurment_equipment_id) REFERENCES public.equipment_types (id);

        ALTER TABLE public.calc_correction
            ADD FOREIGN KEY (height_id) REFERENCES public.calc_correction_heights (id),
            ADD FOREIGN KEY (type_id) REFERENCES public.calc_correction_types (id);

        COMMENT ON SEQUENCE public.calc_correction_height_seq IS 'Счетчик стандартных высот';
        COMMENT ON SEQUENCE public.calc_correction_types_seq IS 'Счетчик типов таблиц';
        COMMENT ON SEQUENCE public.calc_correction_seq IS 'Счетчик записей корректировок';
        COMMENT ON COLUMN public.calc_correction.row_values IS 'Поправки в порядке столбцов, NULL означает прочерк';

        UPDATE public.calc_correction SET type_id = 9 WHERE type_id = 8;
        UPDATE public.calc_correction
        SET type_id = 8, row_values = ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,NULL,NULL]
        WHERE type_id = 7 AND row_values[2] IS NOT NULL;
        UPDATE public.calc_correction SET row_values[13] = -38 WHERE height_id = 2 AND type_id = 9;
        UPDATE public.calc_correction SET row_values[9] = 22 WHERE height_id = 4 AND type_id = 6;
        INSERT INTO public.calc_correction (height_id, type_id, row_values)
        VALUES
            (5, 9, ARRAY[-1,-2,-3,-3,-4,-4,-5,-6,-7,-7,-17,-25,-34,-42]),
            (6, 9, ARRAY[-1,-2,-3,-3,-4,-4,-5,-6,-6,-7,-16,-24,-32,-40]),
            (7, 9, ARRAY[-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-15,-23,-31,-38]),
            (8, 9, ARRAY[-1,-2,-2,-3,-4,-4,-4,-5,-5,-6,-15,-22,-30,-37]),
            (9, 9, ARRAY[-1,-2,-2,-3,-4,-4,-4,-4,-5,-6,-14,-20,-27,-34]),

            (5, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,NULL,NULL]),
            (6, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,NULL,NULL]),
            (7, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,NULL,NULL]),
            (8, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,NULL,NULL]),
            (9, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,NULL,NULL]),

            (5, 4, ARRAY[4,6,7,8,9,10,11,13,14,15,17,17]),
            (6, 4, ARRAY[4,6,7,8,9,10,11,13,14,16,17,18]),
            (7, 4, ARRAY[4,6,8,9,9,10,12,14,15,16,18,19]),
            (8, 4, ARRAY[5,6,8,9,10,11,12,14,15,17,18,19]),
            (9, 4, ARRAY[5,6,8,9,10,11,12,14,16,18,19,20]),

            (5, 5, ARRAY[3]),
            (6, 5, ARRAY[3]),
            (7, 5, ARRAY[3]),
            (8, 5, ARRAY[4]),
            (9, 5, ARRAY[4]),

            (5, 6, ARRAY[6,8,11,13,14,17,20,21,23,25,27,29,32]),
            (6, 6, ARRAY[6,9,11,13,14,17,20,21,24,26,28,30,32]),
            (7, 6, ARRAY[6,9,12,14,15,18,21,22,25,27,29,32,34]),
            (8, 6, ARRAY[6,9,12,14,15,18,21,23,25,28,30,32,36]),
            (9, 6, ARRAY[6,10,12,14,16,19,22,24,26,29,32,34,36]),

            (5, 7, ARRAY[4]),
            (6, 7, ARRAY[4]),
            (7, 7, ARRAY[4]),
            (8, 7, ARRAY[5]),
            (9, 7, ARRAY[5]);
    END;
    COMMIT;

    BEGIN
        CREATE FUNCTION public.format_meteo_height_row(
            p_height INTEGER, p_temperature INTEGER, p_direction INTEGER, p_speed INTEGER
        )
        RETURNS TEXT
        LANGUAGE plpgsql
        AS $function$
        DECLARE
            metres_per_height_code CONSTANT INTEGER := 100;
            code_width CONSTANT INTEGER := 2;
            temperature_code INTEGER := p_temperature;
            formatted_temperature TEXT;
        BEGIN
            IF p_temperature < 0 THEN
                temperature_code := ABS(p_temperature)
                    + public.get_meteo_constant('negative_temperature_code');
            END IF;

            formatted_temperature := COALESCE(temperature_code::TEXT, 'NULL');
            IF temperature_code BETWEEN 0 AND 9 THEN
                formatted_temperature := LPAD(formatted_temperature, code_width, '0');
            END IF;

            RETURN LPAD((p_height / metres_per_height_code)::TEXT, code_width, '0')
                || ' | ' || formatted_temperature
                || ' | ' || LPAD(p_direction::TEXT, code_width, '0')
                || ' | ' || LPAD(p_speed::TEXT, code_width, '0');
        END;
        $function$;
        COMMENT ON FUNCTION public.format_meteo_height_row(INTEGER, INTEGER, INTEGER, INTEGER)
        IS 'Строка метеобюллетеня в формате H, TT, HH, CC';

        CREATE PROCEDURE public.calculate_meteo_by_height(
            IN p_input public.measurement_parameters, IN p_equipment_id INTEGER
        )
        LANGUAGE plpgsql
        AS $procedure$
        DECLARE
            dmk_equipment_id CONSTANT INTEGER := 1;
            vr_equipment_id CONSTANT INTEGER := 2;
            wind_speed_parent_id CONSTANT INTEGER := 2;
            wind_direction_parent_id CONSTANT INTEGER := 3;
            positive_temperature_type_id CONSTANT INTEGER := 8;
            negative_temperature_type_id CONSTANT INTEGER := 9;
            decimal_base CONSTANT INTEGER := 10;
            full_direction_circle CONSTANT INTEGER := 60;

            temperature_deviation INTEGER;
            temperature_type_id INTEGER;
            temperature_headers INTEGER[];
            temperature_magnitude INTEGER;
            temperature_tens INTEGER;
            temperature_units INTEGER;
            temperature_tens_position INTEGER;
            temperature_units_position INTEGER;
            wind_input NUMERIC;
            wind_type_id INTEGER;
            direction_type_id INTEGER;
            wind_headers INTEGER[];
            wind_left_position INTEGER;
            wind_right_position INTEGER;
            mean_temperature INTEGER;
            mean_speed INTEGER;
            mean_direction INTEGER;
            current_height_id INTEGER;
            current_height INTEGER;
            temperature_values INTEGER[];
            wind_values INTEGER[];
            direction_increment INTEGER;
        BEGIN
            IF p_equipment_id = dmk_equipment_id THEN
                wind_input := p_input.speed;
            ELSIF p_equipment_id = vr_equipment_id THEN
                wind_input := p_input.drift;
            ELSE
                RAISE EXCEPTION 'Неизвестный тип оборудования: %', p_equipment_id;
            END IF;

            temperature_deviation := public.calculate_meteo_temperature(p_input.temperature);
            temperature_type_id := CASE WHEN temperature_deviation < 0
                THEN negative_temperature_type_id ELSE positive_temperature_type_id END;

            SELECT h.column_values INTO temperature_headers
            FROM public.calc_correction_types AS t
            JOIN public.calc_correction_headers AS h ON h.id = t.header_id
            WHERE t.id = temperature_type_id;

            temperature_magnitude := ABS(temperature_deviation);
            temperature_units := temperature_magnitude % decimal_base;
            temperature_tens := temperature_magnitude - temperature_units;

            FOR position IN 1..array_length(temperature_headers, 1) LOOP
                IF temperature_headers[position] = temperature_tens THEN
                    temperature_tens_position := position;
                END IF;
                IF temperature_headers[position] = temperature_units THEN
                    temperature_units_position := position;
                END IF;
            END LOOP;

            SELECT t.id, h.column_values INTO wind_type_id, wind_headers
            FROM public.calc_correction_types AS t
            JOIN public.calc_correction_headers AS h ON h.id = t.header_id
            WHERE t.parent_id = wind_speed_parent_id
              AND t.measurment_equipment_id = p_equipment_id;

            SELECT id INTO direction_type_id
            FROM public.calc_correction_types
            WHERE parent_id = wind_direction_parent_id
              AND measurment_equipment_id = p_equipment_id;

            FOR position IN 1..array_length(wind_headers, 1) LOOP
                IF wind_headers[position] <= wind_input THEN
                    wind_left_position := position;
                END IF;
                IF wind_headers[position] >= wind_input THEN
                    wind_right_position := position;
                    EXIT;
                END IF;
            END LOOP;

            RAISE NOTICE ' H | TT | HH | CC';

            FOR current_height_id, current_height IN
                SELECT id, height FROM public.calc_correction_heights ORDER BY height
            LOOP
                SELECT row_values INTO temperature_values
                FROM public.calc_correction
                WHERE height_id = current_height_id AND type_id = temperature_type_id;

                mean_temperature := 0;
                IF temperature_tens > 0 THEN
                    mean_temperature := temperature_values[temperature_tens_position];
                END IF;
                IF temperature_units > 0 THEN
                    mean_temperature := mean_temperature + temperature_values[temperature_units_position];
                END IF;

                IF wind_input < wind_headers[1] THEN
                    mean_speed := 0;
                    mean_direction := 0;
                ELSE
                    SELECT row_values INTO wind_values
                    FROM public.calc_correction
                    WHERE height_id = current_height_id AND type_id = wind_type_id;

                    SELECT row_values[1] INTO direction_increment
                    FROM public.calc_correction
                    WHERE height_id = current_height_id AND type_id = direction_type_id;

                    mean_speed := ROUND(public.calculate_interpolation(
                        wind_input,
                        ROW(wind_headers[wind_left_position], wind_values[wind_left_position],
                            wind_headers[wind_right_position], wind_values[wind_right_position]
                        )::public.interpolation_bounds
                    ));
                    mean_direction := (p_input.direction::INTEGER + direction_increment)
                        % full_direction_circle;
                END IF;

                RAISE NOTICE '%', public.format_meteo_height_row(
                    current_height, mean_temperature, mean_direction, mean_speed
                );
            END LOOP;
        END;
        $procedure$;
        COMMENT ON PROCEDURE public.calculate_meteo_by_height(public.measurement_parameters, INTEGER)
        IS 'Расчет температуры и ветра по всем стандартным высотам';
    END;
    COMMIT;
END $$;