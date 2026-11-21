-- PostgreSQL. Один раз создайте пустую базу отдельной командой CREATE DATABASE front_olap_resources;
-- Затем подключитесь к ней и выполните этот файл.
DO $$
BEGIN
    BEGIN
        CREATE SEQUENCE public.dim_products_seq;
        CREATE TABLE public.dim_products (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_products_seq'),
            external_id bigint NOT NULL UNIQUE,
            name text,
            category_code bigint,
            category_name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_products IS 'Товары для анализа закупок, продаж и остатков';
        COMMENT ON COLUMN public.dim_products.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_products.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_products.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_products.category_code IS 'Код категории в Front';
        COMMENT ON COLUMN public.dim_products.category_name IS 'Название категории';
        COMMENT ON COLUMN public.dim_products.date_add IS 'Время загрузки в OLAP';
    END;

    BEGIN
        CREATE SEQUENCE public.dim_vendors_seq;
        CREATE TABLE public.dim_vendors (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_vendors_seq'),
            external_id bigint NOT NULL UNIQUE,
            name text,
            group_code bigint,
            group_name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_vendors IS 'Поставщики продукции';
        COMMENT ON COLUMN public.dim_vendors.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_vendors.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_vendors.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_vendors.group_code IS 'Код группы в Front';
        COMMENT ON COLUMN public.dim_vendors.group_name IS 'Название группы';
        COMMENT ON COLUMN public.dim_vendors.date_add IS 'Время загрузки в OLAP';
    END;

    BEGIN
        CREATE SEQUENCE public.dim_base_units_seq;
        CREATE TABLE public.dim_base_units (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_base_units_seq'),
            external_id bigint NOT NULL UNIQUE,
            group_code bigint,
            short_name text,
            name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_base_units IS 'Базовые единицы измерения';
        COMMENT ON COLUMN public.dim_base_units.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_base_units.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_base_units.group_code IS 'Код группы в Front';
        COMMENT ON COLUMN public.dim_base_units.short_name IS 'Сокращенное обозначение';
        COMMENT ON COLUMN public.dim_base_units.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_base_units.date_add IS 'Время загрузки в OLAP';
    END;

    BEGIN
        CREATE SEQUENCE public.dim_price_groups_seq;
        CREATE TABLE public.dim_price_groups (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_price_groups_seq'),
            external_id bigint NOT NULL UNIQUE,
            name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_price_groups IS 'Группы цен';
        COMMENT ON COLUMN public.dim_price_groups.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_price_groups.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_price_groups.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_price_groups.date_add IS 'Время загрузки в OLAP';
    END;

    BEGIN
        CREATE SEQUENCE public.dim_payment_types_seq;
        CREATE TABLE public.dim_payment_types (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_payment_types_seq'),
            external_id bigint NOT NULL UNIQUE,
            name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_payment_types IS 'Способы оплаты продаж';
        COMMENT ON COLUMN public.dim_payment_types.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_payment_types.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_payment_types.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_payment_types.date_add IS 'Время загрузки в OLAP';
    END;

    BEGIN
        CREATE SEQUENCE public.dim_personnel_seq;
        CREATE TABLE public.dim_personnel (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_personnel_seq'),
            external_id bigint NOT NULL UNIQUE,
            name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_personnel IS 'Сотрудники';
        COMMENT ON COLUMN public.dim_personnel.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_personnel.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_personnel.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_personnel.date_add IS 'Время загрузки в OLAP';
    END;

    BEGIN
        CREATE SEQUENCE public.dim_roles_seq;
        CREATE TABLE public.dim_roles (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_roles_seq'),
            external_id bigint NOT NULL UNIQUE,
            name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_roles IS 'Роли персонала';
        COMMENT ON COLUMN public.dim_roles.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_roles.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_roles.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_roles.date_add IS 'Время загрузки в OLAP';
    END;

    BEGIN
        CREATE SEQUENCE public.dim_storages_seq;
        CREATE TABLE public.dim_storages (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_storages_seq'),
            external_id bigint NOT NULL UNIQUE,
            name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_storages IS 'Склады';
        COMMENT ON COLUMN public.dim_storages.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_storages.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_storages.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_storages.date_add IS 'Время загрузки в OLAP';
    END;

    BEGIN
        CREATE SEQUENCE public.dim_debit_reasons_seq;
        CREATE TABLE public.dim_debit_reasons (
            id bigint PRIMARY KEY DEFAULT nextval('public.dim_debit_reasons_seq'),
            external_id bigint NOT NULL UNIQUE,
            name text,
            date_add timestamp NOT NULL DEFAULT now()
        );
        COMMENT ON TABLE public.dim_debit_reasons IS 'Причины списания запасов';
        COMMENT ON COLUMN public.dim_debit_reasons.id IS 'Внутренний код OLAP';
        COMMENT ON COLUMN public.dim_debit_reasons.external_id IS 'Код записи в Front';
        COMMENT ON COLUMN public.dim_debit_reasons.name IS 'Наименование';
        COMMENT ON COLUMN public.dim_debit_reasons.date_add IS 'Время загрузки в OLAP';
    END;

END;
$$;
