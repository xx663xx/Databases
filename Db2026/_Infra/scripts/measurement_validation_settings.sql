DO $$
BEGIN
    CREATE TABLE public.measurement_validation_settings (
        parameter_type_id INTEGER PRIMARY KEY REFERENCES public.parameter_types (id),
        minimum_value NUMERIC,
        maximum_value NUMERIC,
        decimal_places INTEGER NOT NULL
    );

    COMMENT ON TABLE public.measurement_validation_settings
    IS 'Ограничения входных параметров';
    COMMENT ON COLUMN public.measurement_validation_settings.parameter_type_id
    IS 'Тип параметра';
    COMMENT ON COLUMN public.measurement_validation_settings.minimum_value
    IS 'Минимальное значение; NULL без ограничения';
    COMMENT ON COLUMN public.measurement_validation_settings.maximum_value
    IS 'Максимальное значение; NULL без ограничения';
    COMMENT ON COLUMN public.measurement_validation_settings.decimal_places
    IS 'Допустимое число знаков после запятой';

    INSERT INTO public.measurement_validation_settings
        (parameter_type_id, minimum_value, maximum_value, decimal_places)
    VALUES
        (1, NULL, NULL, 0),
        (2, -58, 58, 1),
        (3, 500, 900, 0),
        (4, 0, 59, 0),
        (5, 0, 15, 0),
        (6, 0, 150, 0);
END $$;
