# Анализ ресурсов Front

## 1. Закупки продукции

**Основные:** `bm_JournalBarnetDocs`, `bm_StorageOperations`

**Связанные:** `bm_JournalTypeDocuments`, `bm_JournalType`, `bm_StorageOperationsType`, `product`, `vendors`, `vendorgroup`, `bm_Contracts`, `storages`, `size`, `bm_Companies`

Закупки выделяются по `DocumentTypeID = 4` и `IsUse = 1`, а товарные строки и дата берутся через `DocumentID` и `bm_JournalBarnetDocs.Period`. Одного `OperationID = 1` недостаточно, поскольку он встречается и в чеках. Запросы **1.1–1.5** подтвердили 3175 документов и 11 358 строк на 19 657 112,54, причем товары, поставщики, склады и размеры нашлись для всех строк, а суммы строк и документов совпали. В `receiving` есть только поступления 2002–2003 годов.

## 2. Продажи товара

**Основные:** `journal`, `bm_Journal_Details`

**Связанные:** `transtype`, `product`, `category`, `size`, `storages`, `personnel`, `pricelist`, `pricegroup`, `bm_JournalBarnetDocs`, `recipe`, `bm_classifierSizes`, `bm_classifierSizesGroup`

Для продаж в `journal` используется тип 101, а оплаты 211/216 и итог 501 считаются отдельно, чтобы суммы не повторялись. Товар находится по `journal.id = product.productid`, детализация – по `SourceID = transnumber`, причем после соединения с ингредиентами сумма продажи может повториться в нескольких строках. Запросы **2.1–2.8** нашли товар для всех 119 367 продаж, детализацию для 103 884 и 44 рецептурные строки без ингредиента. `recipe.sizeid` относится к `bm_classifierSizes`; наличие цены или рецепта не подтверждает продажу, а перед расчетом чистой выручки нужно проверить `status`, `flagrefund` и знаки сумм.

## 3. Взаимоотношения с поставщиками

**Основные:** `vendors`, `bm_StorageOperations`, `bm_PaymentOperations`

**Связанные:** `vendorgroup`, `bm_JournalBarnetDocs`, `bm_Contracts`, `bm_Companies`, `paymenttype`, `product`, `pricelist`, `bm_CashOperations`, `bm_CashOperationsType`

Поставщик поступления определяется через `VendorID = vendors.id`, а платеж – через `ParentID` при `ParentType = 'Vendor'`. Запросы **3.1–3.5** показали 63 карточки поставщиков, из которых 21 связана с закупками, но договоры, платежи и кассовые операции пустые, а `ContractID` в движениях везде равен 0. Поэтому закупки по поставщикам получить можно, а фактический долг без истории оплат определить нельзя.

## 4. Работа персонала

**Основные:** `personnel`, `journal`, `bm_JournalBarnetDocs`

**Связанные:** `transtype`, `securityaccess`, `bm_PersonnelSecurity`, `bm_SecurityObjects`, `bm_JournalSessions`, `bm_ShiftsOperations`, `bm_ShiftsOperations_Values`, `bm_WorkHours`, `bm_BonusHistory`, `bm_CashOperations`

События кассы связаны с сотрудниками через `loginid`, документы – через `PersonID`, а типы 301, 386 и 387 обозначают вход, начало и окончание работы. По запросам **4.1–4.5** найдено 109 учетных записей, 5774 начала и 5758 окончаний работы, но все продажи записаны на техническую учетную запись 906 («Доставка»), поэтому сравнить личную выручку нельзя. `bm_WorkHours` пустая, события требуют проверки пар, а `bm_BonusHistory` хранит клиентские бонусы и не подходит для расчета премий.

## 5. Остатки

**Основные:** `bm_StorageOperations`, `bm_JournalBarnetDocs`

**Связанные:** `product`, `storages`, `size`, `bm_StorageOperationsType`, `bm_ReasonDebit`, `bm_StorageOperations_Table`, `journal`, `bm_Journal_Details`, `recipe`

Запросы **5.1–5.5** показали, что количество движения хранится в `Count` уже со знаком, а `Quantity` и `Rest` везде равны 0. В 5.2 приведены первые десять сочетаний товара, склада и размера с суммой движения; дата берется из `bm_JournalBarnetDocs.Period` при `IsUse = 1`. Готовые остатки в `onhand`, `storagesonhand`, `stock` и `closingcount` отсутствуют, а 56 строк `stockperiod` относятся к февралю 2015 года. Для фактического остатка не хватает начального значения и полной истории, поскольку продажи доходят до 06.12.2023, а складские чеки – до 04.12.2023. Строки `bm_StorageOperations_Table` и детализацию нельзя складывать с основными движениями без сверки, причем ссылки `SourceID` и `BludoID` в дополнительной таблице совпадают лишь частично.

## 6. Колонки таблиц

Общие таблицы описаны один раз; FK означает внешний ключ в базе, а «без FK» – связь при чтении. Для пустых таблиц указано «Нет строк».

| Таблица | Колонка | Назначение | Пример |
|---|---|---|---|
| `bm_JournalBarnetDocs` – документы | `ID` | Ключ | `388235` |
|  | `DocumentTypeID` | Тип документа, bm_JournalTypeDocuments.ID (FK) | `4` |
|  | `JournalID` | Журнал, bm_JournalType.ID (FK) | `1` |
|  | `Period` | Дата документа | `2020-11-11T08:00:00` |
|  | `IsUse` | 1 – документ учитывается | `1` |
|  | `ShiftID` | Кассовая смена, bm_ShiftsOperations.ID (FK) | `65` |
|  | `CompanyID` | Организация, bm_Companies.ID (FK) | `6` |
|  | `TicketNumber` | Номер чека, не ключ journal | `NULL` |
|  | `PersonID` | Автор, personnel.personid; без FK | `897` |
|  | `Amount` | Сумма документа | `892.77` |
| `bm_StorageOperations` – движения товаров | `ID` | Ключ | `4780421` |
|  | `DocumentID` | Документ, bm_JournalBarnetDocs.ID (FK) | `388235` |
|  | `OperationID` | Тип движения, bm_StorageOperationsType.ID (FK) | `1` |
|  | `ProductID` | Товар, product.id (FK) | `4368` |
|  | `VendorID` | Поставщик, vendors.id; без FK | `200` |
|  | `ContractID` | Договор, bm_Contracts.ID; без FK, везде 0 | `0` |
|  | `StorageID` | Склад, storages.id (FK) | `41` |
|  | `RangeID` | Размер, size.ID; без FK | `42` |
|  | `Price` | Цена | `323.0` |
|  | `Count` | Количество со знаком | `2.764` |
|  | `Quantity` | Дополнительное количество, везде 0 | `0.0` |
|  | `Rest` | Поле остатка, везде 0 | `0.0` |
|  | `Amount` | Сумма со знаком | `892.77` |
|  | `ReasonID` | Причина списания, bm_ReasonDebit.ID, без FK | `NULL` |
| `product` – номенклатура | `id` | Внутренний ключ | `4368` |
|  | `productid` | Код для journal.id; без FK | `1137721` |
|  | `description` | Наименование | `Грудинка (Бекон)` |
|  | `flaging` | Тип: 0 блюдо, 1 ингредиент, 2 полуфабрикат, 3 товар, 4 изделие | `1` |
|  | `CategoryID` | Категория, category.id (FK) | `203` |
|  | `SizeID` | Единица или размер, size.ID; без FK | `42` |
|  | `vendorid` | Поставщик по умолчанию, vendors.id; FK нет | `0` |
|  | `IsUse` | Используется ли карточка | `1` |
| `journal` – события кассы | `transnumber` | Ключ события | `1675586` |
|  | `transtype` | Тип события, transtype.transtypeid (FK) | `101` |
|  | `receiptn` | Номер чека, может повторяться | `14740696` |
|  | `dater` | Дата события | `2020-11-11T10:09:39` |
|  | `id` | Код товара, product.productid; без FK | `524058` |
|  | `quantity` | Количество | `1.0` |
|  | `price` | Зафиксированная цена позиции | `450.0` |
|  | `amount` | Сумма строки со знаком | `450.0` |
|  | `status` | Состояние строки | `0` |
|  | `flagrefund` | Флаг строки (0/1) | `0` |
|  | `loginid` | Сотрудник, personnel.personid; без FK | `906` |
| `bm_Journal_Details` – детализация расхода под блюда | `ID` | Ключ | `224218250` |
|  | `SourceID` | Строка журнала, journal.transnumber (FK) | `1677325` |
|  | `ProductID` | Расходуемая номенклатура, product.id (FK) | `4397` |
|  | `BludoID` | Блюдо, product.id (FK) | `4527` |
|  | `Count` | Расход номенклатуры | `0.04` |
|  | `RangeID` | Размер, size.ID (FK) | `42` |
|  | `SizeID` | Код размера; FK на size нет | `163` |
|  | `StorageID` | Склад, storages.id; FK нет | `41` |
| `pricelist` – цены | `id` | Ключ | `113681` |
|  | `DocumentID` | Документ цены, bm_JournalBarnetDocs.ID (FK) | `142417` |
|  | `productid` | Внутренний ключ, product.id (FK) | `4544` |
|  | `groupid` | Группа цены, pricegroup.pricegroupid (FK) | `2` |
|  | `basecost` | Значение цены | `140.0` |
|  | `vendorid` | Поставщик, vendors.id; только 0 или NULL | `NULL` |
| `vendors` – поставщики | `id` | Ключ | `90` |
|  | `clientid` | Краткое название | `Габур` |
|  | `firstname` | Наименование | `ИП Габур` |
|  | `clientgroup` | Группа, vendorgroup.vendorgroupid (FK) | `32` |
|  | `IsUse` | Используется ли карточка | `0` |
| `personnel` – учетные записи сотрудников | `personid` | Ключ | `906` |
|  | `firstname` | Имя учетной записи | `Доставка` |
|  | `securityaccess` | Роль, securityaccess.securityaccessid, без FK | `3` |
|  | `deleteflag` | Признак удаления | `1` |
| `bm_StorageOperationsType` | `ID` | Ключ | `1` |
|  | `Description` | Название движения | `Поступление` |
|  | `Factor` | Знак направления; Count уже хранится со знаком | `1` |
| `bm_JournalTypeDocuments` | `ID` | Ключ | `4` |
|  | `Description` | Название типа | `Поступление продуктов` |
|  | `JournalID` | Журнал учета, bm_JournalType.ID (FK) | `3` |
| `bm_JournalType` | `ID` | Ключ | `3` |
|  | `JournalName` | Название вида учета | `Складской учет` |
| `category` | `id` | Ключ | `203` |
|  | `description` | Название категории | `Мясная продукция` |
|  | `ParentID` | Родительская категория; FK нет | `199` |
| `size` | `ID` | Внутренний ключ | `42` |
|  | `description` | Название | `кг` |
| `storages` | `id` | Ключ | `41` |
|  | `description` | Название склада | `Склад` |
| `bm_Companies` | `ID` | Ключ | `6` |
|  | `ShortName` | Краткое наименование | `Пиzzбург` |
| `pricegroup` | `pricegroupid` | Ключ | `2` |
|  | `description` | Название группы | `Розничная` |
| `transtype` | `transtypeid` | Ключ | `101` |
|  | `description` | Название типа | `PLU Sales` |
| `recipe` | `id` | Ключ | `2806` |
|  | `DocumentID` | Документ рецептуры, bm_JournalBarnetDocs.ID (FK) | `1216` |
|  | `recipeid` | Блюдо, product.id (FK) | `4420` |
|  | `ingredientid` | Ингредиент, product.id; без FK, есть пропуски | `4391` |
|  | `sizeid` | Размер рецептуры, bm_classifierSizes.ID, без FK | `166` |
| `bm_classifierSizes` | `ID` | Ключ | `3` |
|  | `GroupID` | Группа, bm_classifierSizesGroup.ID (FK) | `1` |
|  | `Description` | Название | `Миллиметр` |
| `bm_classifierSizesGroup` | `ID` | Ключ | `1` |
|  | `Description` | Название группы | `Единицы длины` |
| `vendorgroup` | `vendorgroupid` | Ключ | `31` |
|  | `description` | Название группы | `Поставщики` |
| `bm_Contracts` | `ID` | Ключ | Нет строк |
|  | `VendorID` | Поставщик, vendors.id; без FK | Нет строк |
|  | `CompanyID` | Организация, bm_Companies.ID (FK) | Нет строк |
|  | `ContractNumber` | Номер договора | Нет строк |
| `bm_PaymentOperations` | `ID` | Ключ | Нет строк |
|  | `DocumentID` | Документ платежа, bm_JournalBarnetDocs.ID (FK) | Нет строк |
|  | `PaymentTypeID` | Тип платежа, paymenttype.paymenttypeid (FK) | Нет строк |
|  | `ParentID` | Ключ контрагента выбранного типа | Нет строк |
|  | `ParentType` | Тип контрагента; Vendor – поставщик | Нет строк |
|  | `Amount` | Сумма со знаком | Нет строк |
| `paymenttype` | `paymenttypeid` | Ключ | `211` |
|  | `description` | Название способа оплаты | `Наличные` |
| `securityaccess` | `securityaccessid` | Ключ | `2` |
|  | `description` | Название роли | `Clerk` |
| `bm_PersonnelSecurity` | `ID` | Ключ | `1397` |
|  | `PersonID` | Сотрудник, personnel.personid; FK нет | `906` |
|  | `ObjectID` | Объект доступа, bm_SecurityObjects.ID (FK) | `36` |
|  | `IsUse` | Состояние права | `1` |
| `bm_SecurityObjects` | `ID` | Ключ | `28` |
|  | `Description` | Описание права | `Отмена перечека` |
| `bm_JournalSessions` | `ID` | Ключ | `1` |
|  | `PersonID` | Учетная запись, personnel.personid; без FK, есть код 0 | `897` |
|  | `DateAdd` | Дата сообщения | `2019-10-10T10:09:48.707` |
| `bm_ShiftsOperations` | `ID` | Ключ | `65` |
|  | `ShiftNumber` | Номер смены | `1` |
|  | `PersonalID` | Учетная запись смены; без FK | `0` |
| `bm_ShiftsOperations_Values` | `ID` | Ключ | Нет строк |
|  | `ParentID` | Смена, bm_ShiftsOperations.ID (FK) | Нет строк |
|  | `Value` | Значение показателя | Нет строк |
| `bm_WorkHours` | `ID` | Ключ | Нет строк |
|  | `PersonID` | Сотрудник | Нет строк |
|  | `DateR` | Дата | Нет строк |
|  | `SystemPeriod` | Системная длительность | Нет строк |
|  | `ManualPeriod` | Ручная длительность | Нет строк |
| `bm_BonusHistory` | `ID` | Ключ | `1` |
|  | `ClientID` | Клиент | `3352` |
|  | `PersonID` | Сотрудник, personnel.personid (FK) | `897` |
|  | `BonusValue` | Клиентские бонусы, не премия | `0.0` |
|  | `Period` | Дата | `2016-04-05T11:31:10.553` |
| `bm_CashOperations` | `ID` | Ключ | Нет строк |
|  | `DocumentID` | Документ, bm_JournalBarnetDocs.ID (FK) | Нет строк |
|  | `OperationTypeID` | Тип операции, bm_CashOperationsType.ID (FK) | Нет строк |
|  | `VendorID` | Поставщик, vendors.id; без FK | Нет строк |
|  | `PersonID` | Сотрудник | Нет строк |
|  | `Amount` | Сумма | Нет строк |
| `bm_CashOperationsType` | `ID` | Ключ | `1` |
|  | `Description` | Название операции | `Принято по смене` |
| `bm_StorageOperations_Table` | `ID` | Ключ | `134198` |
|  | `DocumentID` | Документ, bm_JournalBarnetDocs.ID (FK) | `388540` |
|  | `OperationID` | Тип операции, bm_StorageOperationsType.ID (FK) | `2` |
|  | `ProductID` | Товар или ингредиент, product.id (FK) | `4345` |
|  | `StorageID` | Склад, storages.id (FK) | `41` |
|  | `SourceID` | Ссылка на journal.transnumber, совпадение неполное | `200634` |
|  | `BludoID` | Блюдо, product.id, совпадение неполное | `4641` |
|  | `Count` | Количество со знаком строки | `0.0` |
|  | `Amount` | Сумма | `0.0` |
|  | `ReasonID` | Причина, bm_ReasonDebit.ID; без FK | `24` |
| `bm_ReasonDebit` | `ID` | Ключ | `1` |
|  | `Description` | Название причины | `Порча продукта` |
| `onhand` | `productid` | Строковый код товара | Нет строк |
|  | `onhand` | Остаток | Нет строк |
| `storagesonhand` | `productid` | Строковый код товара | Нет строк |
|  | `storageid` | Склад | Нет строк |
|  | `onhand` | Остаток | Нет строк |
| `stockperiod` | `id` | Ключ | `1` |
|  | `productid` | Строковый код товара | Пустая строка |
|  | `quantityclose` | Остаток на конец | `0.0` |
|  | `datestart` | Начало периода | `2015-02-17T08:20:36.540` |
|  | `datefinish` | Конец периода | `2015-02-17T08:20:36.540` |
| `receiving` | `transnumber` | Поле номера строки | `5` |
|  | `dater` | Дата события | `2002-10-30T00:00:00` |
|  | `amount` | Сумма | `0.0` |
