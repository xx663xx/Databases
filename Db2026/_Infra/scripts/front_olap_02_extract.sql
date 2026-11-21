-- MSSQL, база Front. Запросы возвращают по одной строке PostgreSQL-кода в колонке sql.
-- Сохраните результаты сверху вниз в UTF-8 без заголовков и номеров строк.
-- Получится полный скрипт 03 для первичной загрузки пустых таблиц.
-- В названиях удваиваем апострофы. Знак доллара выводим отдельно, чтобы он
-- не мог закрыть блок DO, если такое название появится в справочнике.
SET NOCOUNT ON;

SELECT N'-- PostgreSQL. Первичная загрузка ресурсов, выбранных из Front.' AS sql;
SELECT N'SET standard_conforming_strings = on;' AS sql;
SELECT N'DO $front$' AS sql;
SELECT N'BEGIN' AS sql;

-- Товары для анализа закупок, продаж и остатков
SELECT N'    -- Товары для анализа закупок, продаж и остатков' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_products (external_id, name, category_code, category_name) VALUES ('
    + CAST(p.id AS nvarchar(30)) + N', ' +
      COALESCE(N'''' + REPLACE(p.description, N'''', N'''''') + N'''', N'NULL') + N', ' +
      COALESCE(CAST(p.CategoryID AS nvarchar(30)), N'NULL') + N', ' +
      COALESCE(N'''' + REPLACE(c.description, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.product AS p
LEFT JOIN dbo.category AS c ON c.id = p.CategoryID
ORDER BY p.id;
SELECT N'    END;' AS sql;

-- Поставщики продукции
SELECT N'    -- Поставщики продукции' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_vendors (external_id, name, group_code, group_name) VALUES ('
    + CAST(v.id AS nvarchar(30)) + N', ' +
      COALESCE(N'''' + REPLACE(v.clientid, N'''', N'''''') + N'''', N'NULL') + N', ' +
      COALESCE(CAST(v.clientgroup AS nvarchar(30)), N'NULL') + N', ' +
      COALESCE(N'''' + REPLACE(g.description, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.vendors AS v
LEFT JOIN dbo.vendorgroup AS g ON g.vendorgroupid = v.clientgroup
ORDER BY v.id;
SELECT N'    END;' AS sql;

-- Базовые единицы измерения
SELECT N'    -- Базовые единицы измерения' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_base_units (external_id, group_code, short_name, name) VALUES ('
    + CAST(ID AS nvarchar(30)) + N', ' +
      COALESCE(CAST(GroupID AS nvarchar(30)), N'NULL') + N', ' +
      COALESCE(N'''' + REPLACE(ShortName, N'''', N'''''') + N'''', N'NULL') + N', ' +
      COALESCE(N'''' + REPLACE(Description, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.bm_classifierSizes
ORDER BY ID;
SELECT N'    END;' AS sql;

-- Группы цен
SELECT N'    -- Группы цен' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_price_groups (external_id, name) VALUES ('
    + CAST(pricegroupid AS nvarchar(30)) + N', ' +
      COALESCE(N'''' + REPLACE(description, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.pricegroup
ORDER BY pricegroupid;
SELECT N'    END;' AS sql;

-- Способы оплаты продаж
SELECT N'    -- Способы оплаты продаж' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_payment_types (external_id, name) VALUES ('
    + CAST(paymenttypeid AS nvarchar(30)) + N', ' +
      COALESCE(N'''' + REPLACE(description, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.paymenttype
ORDER BY paymenttypeid;
SELECT N'    END;' AS sql;

-- Сотрудники
SELECT N'    -- Сотрудники' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_personnel (external_id, name) VALUES ('
    + CAST(personid AS nvarchar(30)) + N', ' +
      COALESCE(N'''' + REPLACE(firstname, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.personnel
ORDER BY personid;
SELECT N'    END;' AS sql;

-- Роли персонала
SELECT N'    -- Роли персонала' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_roles (external_id, name) VALUES ('
    + CAST(securityaccessid AS nvarchar(30)) + N', ' +
      COALESCE(N'''' + REPLACE(description, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.securityaccess
ORDER BY securityaccessid;
SELECT N'    END;' AS sql;

-- Склады
SELECT N'    -- Склады' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_storages (external_id, name) VALUES ('
    + CAST(id AS nvarchar(30)) + N', ' +
      COALESCE(N'''' + REPLACE(description, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.storages
ORDER BY id;
SELECT N'    END;' AS sql;

-- Причины списания запасов
SELECT N'    -- Причины списания запасов' AS sql;
SELECT N'    BEGIN' AS sql;
SELECT REPLACE(
    N'        INSERT INTO public.dim_debit_reasons (external_id, name) VALUES ('
    + CAST(ID AS nvarchar(30)) + N', ' +
      COALESCE(N'''' + REPLACE(Description, N'''', N'''''') + N'''', N'NULL') + N');',
    N'$', N''' || ''$'' || ''') AS sql
FROM dbo.bm_ReasonDebit
ORDER BY ID;
SELECT N'    END;' AS sql;

SELECT N'END;' AS sql;
SELECT N'$front$;' AS sql;
