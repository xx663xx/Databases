USE Front;

-- 1. Закупки продукции

-- 1.1. Статистика по типам документов и периодам данных
SELECT d.DocumentTypeID, t.Description, d.IsUse,
       COUNT(*) AS documents, MIN(d.Period) AS first_date,
       MAX(d.Period) AS last_date, SUM(d.Amount) AS amount
FROM dbo.bm_JournalBarnetDocs AS d
LEFT JOIN dbo.bm_JournalTypeDocuments AS t ON t.ID = d.DocumentTypeID
GROUP BY d.DocumentTypeID, t.Description, d.IsUse
ORDER BY d.DocumentTypeID, d.IsUse;

-- 1.2. Складские операции в разрезе типов документов
-- (Проверка вхождения операций, например, тип 1 встречается и в чеках)
SELECT d.DocumentTypeID, t.Description, o.OperationID, d.IsUse,
       COUNT(*) AS operation_rows, SUM(o.Amount) AS amount
FROM dbo.bm_StorageOperations AS o
JOIN dbo.bm_JournalBarnetDocs AS d ON d.ID = o.DocumentID
JOIN dbo.bm_JournalTypeDocuments AS t ON t.ID = d.DocumentTypeID
GROUP BY d.DocumentTypeID, t.Description, o.OperationID, d.IsUse
ORDER BY d.DocumentTypeID, o.OperationID;

-- 1.3. Связь закупок со справочниками (товары, поставщики, склады, размеры)
SELECT COUNT(*) AS purchase_rows,
       COUNT(p.id) AS products_found, COUNT(v.id) AS vendors_found,
       COUNT(s.id) AS storages_found, COUNT(z.ID) AS ranges_found
FROM dbo.bm_StorageOperations AS o
JOIN dbo.bm_JournalBarnetDocs AS d ON d.ID = o.DocumentID
LEFT JOIN dbo.product AS p ON p.id = o.ProductID
LEFT JOIN dbo.vendors AS v ON v.id = o.VendorID
LEFT JOIN dbo.storages AS s ON s.id = o.StorageID
LEFT JOIN dbo.size AS z ON z.ID = o.RangeID
WHERE d.DocumentTypeID = 4 AND d.IsUse = 1;

-- 1.4. Сверка сумм документов (шапка) и сумм по их строкам
SELECT COUNT(*) AS documents, SUM(d.Amount) AS header_amount,
       SUM(o.amount) AS rows_amount, COUNT(o.DocumentID) AS documents_with_rows
FROM dbo.bm_JournalBarnetDocs AS d
LEFT JOIN (
    SELECT DocumentID, SUM(Amount) AS amount
    FROM dbo.bm_StorageOperations
    GROUP BY DocumentID
) AS o ON o.DocumentID = d.ID
WHERE d.DocumentTypeID = 4 AND d.IsUse = 1;

-- 1.5. Временной диапазон старых поступлений в таблице receiving
SELECT COUNT(*) AS receiving_rows, MIN(dater) AS first_date,
       MAX(dater) AS last_date
FROM dbo.receiving;


-- 2. Продажи товара

-- 2.1. Анализ кассовых событий по типам
SELECT j.transtype, t.description,
       COUNT(*) AS journal_rows, SUM(j.amount) AS amount
FROM dbo.journal AS j
LEFT JOIN dbo.transtype AS t ON t.transtypeid = j.transtype
GROUP BY j.transtype, t.description
ORDER BY j.transtype;

-- Период продаж смотрим отдельно
SELECT MIN(dater) AS first_sale, MAX(dater) AS last_sale
FROM dbo.journal
WHERE transtype = 101;

-- 2.2. Проверка связи продаж с таблицей товаров (journal.id с product.productid)
SELECT COUNT(*) AS sale_rows, COUNT(p.id) AS products_found,
       SUM(j.amount) AS signed_amount
FROM dbo.journal AS j
LEFT JOIN dbo.product AS p ON p.productid = j.id
WHERE j.transtype = 101;

-- 2.3. Детализация кассовых событий (блюда, ингредиенты, склады)
SELECT j.transtype, COUNT(*) AS detail_rows,
       COUNT(p.id) AS ingredients_found, COUNT(b.id) AS dishes_found,
       COUNT(z.ID) AS ranges_found, COUNT(s.id) AS storages_found
FROM dbo.bm_Journal_Details AS d
LEFT JOIN dbo.journal AS j ON j.transnumber = d.SourceID
LEFT JOIN dbo.product AS p ON p.id = d.ProductID
LEFT JOIN dbo.product AS b ON b.id = d.BludoID
LEFT JOIN dbo.size AS z ON z.ID = d.RangeID
LEFT JOIN dbo.storages AS s ON s.id = d.StorageID
GROUP BY j.transtype
ORDER BY j.transtype;

-- 2.4. Распределение событий на те, что с детализацией, и те, что без нее
SELECT j.transtype, COUNT(*) AS journal_rows,
       COUNT(d.SourceID) AS rows_with_details,
       COUNT(*) - COUNT(d.SourceID) AS rows_without_details
FROM dbo.journal AS j
LEFT JOIN (
    SELECT SourceID
    FROM dbo.bm_Journal_Details
    GROUP BY SourceID
) AS d ON d.SourceID = j.transnumber
GROUP BY j.transtype
ORDER BY j.transtype;

-- 2.5. Связь прайс-листов с группами цен и документами-источниками
SELECT p.groupid, g.description, d.DocumentTypeID,
       COUNT(*) AS price_rows
FROM dbo.pricelist AS p
LEFT JOIN dbo.pricegroup AS g ON g.pricegroupid = p.groupid
LEFT JOIN dbo.bm_JournalBarnetDocs AS d ON d.ID = p.DocumentID
GROUP BY p.groupid, g.description, d.DocumentTypeID
ORDER BY p.groupid, d.DocumentTypeID;

-- 2.6. Классификация товаров (категории, единицы измерения)
SELECT p.flaging, p.IsUse, COUNT(*) AS products,
       COUNT(c.id) AS categories_found, COUNT(z.ID) AS units_found
FROM dbo.product AS p
LEFT JOIN dbo.category AS c ON c.id = p.CategoryID
LEFT JOIN dbo.size AS z ON z.ID = p.SizeID
GROUP BY p.flaging, p.IsUse
ORDER BY p.flaging, p.IsUse;

-- 2.7. Анализ статусов и флагов возврата для операций продаж (transtype = 101)
SELECT status, flagrefund, COUNT(*) AS journal_rows,
       SUM(amount) AS signed_amount
FROM dbo.journal
WHERE transtype = 101
GROUP BY status, flagrefund
ORDER BY status, flagrefund;

-- 2.8. Проверка связей рецептур с блюдами и ингредиентами
SELECT COUNT(*) AS recipe_rows, COUNT(p.id) AS dishes_found,
       COUNT(i.id) AS ingredients_found, COUNT(z.ID) AS recipe_sizes_found
FROM dbo.recipe AS r
LEFT JOIN dbo.product AS p ON p.id = r.recipeid
LEFT JOIN dbo.product AS i ON i.id = r.ingredientid
LEFT JOIN dbo.bm_classifierSizes AS z ON z.ID = r.sizeid;


-- 3. Взаимоотношения с поставщиками

-- 3.1. Распределение поставщиков по группам и признаку использования
SELECT v.clientgroup, g.description, v.IsUse, COUNT(*) AS vendors
FROM dbo.vendors AS v
LEFT JOIN dbo.vendorgroup AS g ON g.vendorgroupid = v.clientgroup
GROUP BY v.clientgroup, g.description, v.IsUse
ORDER BY v.clientgroup, v.IsUse;

-- 3.2. Сколько поставщиков участвовало в закупках
SELECT COUNT(*) AS vendors, COUNT(o.VendorID) AS vendors_with_purchases,
       SUM(o.purchase_rows) AS purchase_rows, SUM(o.amount) AS amount
FROM dbo.vendors AS v
LEFT JOIN (
    SELECT o.VendorID, COUNT(*) AS purchase_rows, SUM(o.Amount) AS amount
    FROM dbo.bm_StorageOperations AS o
    JOIN dbo.bm_JournalBarnetDocs AS d ON d.ID = o.DocumentID
    WHERE d.DocumentTypeID = 4 AND d.IsUse = 1
    GROUP BY o.VendorID
) AS o ON o.VendorID = v.id;

-- 3.3. Проверка наполненности таблиц договоров, платежей и кассы
SELECT COUNT(*) AS contracts FROM dbo.bm_Contracts;
SELECT COUNT(*) AS payment_operations FROM dbo.bm_PaymentOperations;
SELECT COUNT(*) AS cash_operations FROM dbo.bm_CashOperations;
SELECT COUNT(*) AS payment_types FROM dbo.paymenttype;

-- 3.4. Использование договоров в складских операциях
SELECT ContractID, COUNT(*) AS operation_rows
FROM dbo.bm_StorageOperations
GROUP BY ContractID;

-- 3.5. Анализ привязки поставщиков в карточках товаров и прайсах
SELECT COUNT(*) AS products_with_vendor, COUNT(v.id) AS vendors_found
FROM dbo.product AS p
LEFT JOIN dbo.vendors AS v ON v.id = p.vendorid
WHERE p.vendorid <> 0;

SELECT p.vendorid, COUNT(*) AS price_rows, COUNT(v.id) AS vendors_found
FROM dbo.pricelist AS p
LEFT JOIN dbo.vendors AS v ON v.id = p.vendorid
GROUP BY p.vendorid
ORDER BY p.vendorid;


-- 4. Работа персонала

-- 4.1. Сотрудники по ролям и связь с событиями кассы
SELECT p.securityaccess, a.description AS access_name,
       p.deleteflag, COUNT(*) AS employees
FROM dbo.personnel AS p
LEFT JOIN dbo.securityaccess AS a ON a.securityaccessid = p.securityaccess
GROUP BY p.securityaccess, a.description, p.deleteflag
ORDER BY p.securityaccess;

SELECT j.transtype, COUNT(*) AS events, COUNT(p.personid) AS employees_found,
       COUNT(DISTINCT j.loginid) AS accounts,
       MIN(p.personid) AS min_person, MAX(p.personid) AS max_person
FROM dbo.journal AS j
LEFT JOIN dbo.personnel AS p ON p.personid = j.loginid
GROUP BY j.transtype
ORDER BY j.transtype;

-- 4.2. Статистика создания документов сотрудниками
SELECT d.PersonID, p.firstname, d.DocumentTypeID, COUNT(*) AS documents
FROM dbo.bm_JournalBarnetDocs AS d
LEFT JOIN dbo.personnel AS p ON p.personid = d.PersonID
GROUP BY d.PersonID, p.firstname, d.DocumentTypeID
ORDER BY d.PersonID, d.DocumentTypeID;

-- 4.3. Наличие данных по рабочему времени, сменам и бонусам
SELECT COUNT(*) AS work_hours FROM dbo.bm_WorkHours;
SELECT COUNT(*) AS shifts FROM dbo.bm_ShiftsOperations;
SELECT COUNT(*) AS shift_values FROM dbo.bm_ShiftsOperations_Values;
SELECT COUNT(*) AS bonus_events FROM dbo.bm_BonusHistory;

-- 4.4. Логирование сессий пользователей в системном журнале
SELECT l.PersonID, p.firstname, COUNT(*) AS events,
       MIN(l.DateAdd) AS first_date, MAX(l.DateAdd) AS last_date
FROM dbo.bm_JournalSessions AS l
LEFT JOIN dbo.personnel AS p ON p.personid = l.PersonID
GROUP BY l.PersonID, p.firstname
ORDER BY l.PersonID;

-- 4.5. Связи прав доступа персонала с системными объектами
SELECT COUNT(*) AS permission_rows, COUNT(p.personid) AS employees_found,
       COUNT(o.ID) AS security_objects_found
FROM dbo.bm_PersonnelSecurity AS s
LEFT JOIN dbo.personnel AS p ON p.personid = s.PersonID
LEFT JOIN dbo.bm_SecurityObjects AS o ON o.ID = s.ObjectID;

-- Участие сотрудников в истории клиентских бонусов
SELECT COUNT(*) AS bonus_events, COUNT(p.personid) AS employees_found,
       MIN(b.Period) AS first_date, MAX(b.Period) AS last_date
FROM dbo.bm_BonusHistory AS b
LEFT JOIN dbo.personnel AS p ON p.personid = b.PersonID;


-- 5. Остатки

-- 5.1. Знак количества по типам операций и состоянию документа
SELECT o.OperationID, d.IsUse,
       COUNT(*) AS operation_rows,
       MIN(o.[Count]) AS min_count, MAX(o.[Count]) AS max_count
FROM dbo.bm_StorageOperations AS o
JOIN dbo.bm_JournalBarnetDocs AS d ON d.ID = o.DocumentID
GROUP BY o.OperationID, d.IsUse
ORDER BY o.OperationID, d.IsUse;

-- Отдельно проверяем нулевые Quantity и Rest
SELECT MIN(Quantity) AS min_quantity, MAX(Quantity) AS max_quantity,
       MIN(Rest) AS min_rest, MAX(Rest) AS max_rest
FROM dbo.bm_StorageOperations;

-- 5.2. Пример расчета движения по товару, складу и размеру
-- Показываем первые 10 сочетаний по коду товара, это не полный список остатков
SELECT TOP (10) o.ProductID, o.StorageID, o.RangeID,
       SUM(o.[Count]) AS recorded_movement
FROM dbo.bm_StorageOperations AS o
JOIN dbo.bm_JournalBarnetDocs AS d ON d.ID = o.DocumentID
WHERE d.IsUse = 1
GROUP BY o.ProductID, o.StorageID, o.RangeID
ORDER BY o.ProductID, o.StorageID, o.RangeID;

-- 5.3. Документы и источники строк bm_StorageOperations_Table
-- Здесь только проверяем ссылки на журнал, количества из разных таблиц не складываем
SELECT d.DocumentTypeID, o.OperationID, COUNT(*) AS operation_rows,
       COUNT(j.transnumber) AS journal_sources_found
FROM dbo.bm_StorageOperations_Table AS o
LEFT JOIN dbo.bm_JournalBarnetDocs AS d ON d.ID = o.DocumentID
LEFT JOIN dbo.journal AS j ON j.transnumber = o.SourceID
GROUP BY d.DocumentTypeID, o.OperationID
ORDER BY d.DocumentTypeID, o.OperationID;

-- 5.4. Сколько списаний имеет причину из справочника
SELECT COUNT(*) AS writeoffs, COUNT(r.ID) AS reasons_found,
       COUNT(*) - COUNT(r.ID) AS reasons_not_found
FROM dbo.bm_StorageOperations AS o
LEFT JOIN dbo.bm_ReasonDebit AS r ON r.ID = o.ReasonID
WHERE o.OperationID = 2;

-- 5.5. Проверка таблиц остатков, производства и отчетных периодов (stockperiod)
SELECT COUNT(*) AS onhand_rows FROM dbo.onhand;
SELECT COUNT(*) AS storagesonhand_rows FROM dbo.storagesonhand;
SELECT COUNT(*) AS stock_rows FROM dbo.stock;
SELECT COUNT(*) AS closingcount_rows FROM dbo.closingcount;
SELECT COUNT(*) AS manufacture_orders FROM dbo.bm_ManufactureOrders;

SELECT COUNT(*) AS stockperiod_rows, MIN(datestart) AS first_date,
       MAX(datefinish) AS last_date
FROM dbo.stockperiod;
