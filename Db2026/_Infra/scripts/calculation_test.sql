DO $$
DECLARE
    -- ДМК пример 2 из ТЗ
    dmk_input public.measurement_parameters := ROW(1, 100, 25, 765, 15, 6, NULL);
    -- Для ВР берем снос 45м с иллюстрации в ТЗ, он лежит между столбцами 40 и 50
    vr_input public.measurement_parameters := ROW(2, 100, 25, 765, 15, NULL, 45);
BEGIN
    RAISE NOTICE 'ДМК приземный ветер 6м/с';
    CALL public.calculate_meteo_by_height(dmk_input, dmk_input.equipment_type_id);

    RAISE NOTICE 'ВР дальность сноса 45м';
    CALL public.calculate_meteo_by_height(vr_input, vr_input.equipment_type_id);
END $$;