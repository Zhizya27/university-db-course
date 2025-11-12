USE master;
GO

IF EXISTS (
	SELECT name 
	FROM sys.databases 
	WHERE name = N'KN301_Zhiznevskiy'
)
ALTER DATABASE [KN301_Zhiznevskiy] SET single_user WITH ROLLBACK IMMEDIATE;
GO

IF EXISTS (
	SELECT name 
	FROM sys.databases 
	WHERE name = N'KN301_Zhiznevskiy'
)
DROP DATABASE [KN301_Zhiznevskiy];
GO

CREATE DATABASE [KN301_Zhiznevskiy];
GO

USE [KN301_Zhiznevskiy];
GO

IF EXISTS (
  SELECT * 
  FROM sys.schemas 
  WHERE name = N'Zhiznevskiy'
)
DROP SCHEMA Zhiznevskiy;
GO

CREATE SCHEMA Zhiznevskiy;
GO
-- =========================================

-- Таблица справочника регионов
CREATE TABLE Zhiznevskiy.Region (
    id INT IDENTITY(1,1) PRIMARY KEY,            -- Уникальный идентификатор региона сделать Constraint
    region_code NVARCHAR(10) NOT NULL,    -- Код региона (например, '74', '174')
    region_name NVARCHAR(50) NOT NULL           -- Название региона
);
GO

-- Таблица постов
CREATE TABLE Zhiznevskiy.Posts (
    id INT IDENTITY(1,1) PRIMARY KEY,            -- Уникальный идентификатор поста
    post_name NVARCHAR(100) NOT NULL UNIQUE      -- Название поста
);
GO

-- Таблица регистрации движения автомобилей
CREATE TABLE Zhiznevskiy.VehicleLog (
    id INT IDENTITY(1,1) PRIMARY KEY,              -- Уникальный идентификатор записи
    vehicle_number NVARCHAR(10) NOT NULL,          -- Госномер автомобиля
    times DATETIME NOT NULL,                   -- Время регистрации
    direction BIT, -- Направление --хранить в буле (тут только 0 или 1)
    post_id INT NOT NULL,                          -- Пост регистрации (внешний ключ к таблице постов)
    region_id INT,                                 -- Регион автомобиля (внешний ключ к таблице регионов) 
    CONSTRAINT CK_VehicleNumberFormat CHECK (
        -- Формат номера: CNNNCCNN или CNNNCCNNN
        vehicle_number LIKE '[A-ZА-Я][0-9][0-9][0-9][A-ZА-Я][A-ZА-Я][0-9][0-9]' OR
        vehicle_number LIKE '[A-ZА-Я][0-9][0-9][0-9][A-ZА-Я][A-ZА-Я][0-9][0-9][0-9]'
    ),
    CONSTRAINT FK_Post FOREIGN KEY (post_id) REFERENCES Zhiznevskiy.Posts (id),
    CONSTRAINT FK_Region FOREIGN KEY (region_id) REFERENCES Zhiznevskiy.Region (id)  
);
GO
-- =========================================
-- Вставка данных в таблицы
-- =========================================


INSERT INTO Zhiznevskiy.Region (region_code, region_name)
VALUES
('01', 'Республика Адыгея'),
('02', 'Республика Башкортостан'),
('102', 'Республика Башкортостан'),
('03', 'Республика Бурятия'),
('04', 'Республика Алтай'),
('05', 'Республика Дагестан'),
('06', 'Республика Ингушетия'),
('07', 'Кабардино-Балкарская Республика'),
('08', 'Республика Калмыкия'),
('09', 'Карачаево-Черкесская Республика'),
('10', 'Республика Карелия'),
('11', 'Республика Коми'),
('12', 'Республика Марий Эл'),
('13', 'Республика Мордовия'),
('113', 'Республика Мордовия'),
('14', 'Республика Саха (Якутия)'),
('15', 'Республика Северная Осетия-Алания'),
('16', 'Республика Татарстан'),
('17', 'Республика Тыва'),
('18', 'Удмуртская Республика'),
('19', 'Республика Хакасия'),
('20', 'Чеченская Республика'),
('21', 'Чувашская Республика'),
('121', 'Чувашская Республика'),
('22', 'Алтайский край'),
('23', 'Краснодарский край'),
('93', 'Краснодарский край'),
('123', 'Краснодарский край'),
('24', 'Красноярский край'),
('84', 'Красноярский край'),
('88', 'Красноярский край'),
('124', 'Красноярский край'),
('25', 'Приморский край'),
('125', 'Приморский край'),
('26', 'Ставропольский край'),
('27', 'Хабаровский край'),
('28', 'Амурская область'),
('29', 'Архангельская область'),
('30', 'Астраханская область'),
('31', 'Белгородская область'),
('32', 'Брянская область'),
('33', 'Владимирская область'),
('34', 'Волгоградская область'),
('134', 'Волгоградская область'),
('35', 'Вологодская область'),
('36', 'Воронежская область'),
('37', 'Ивановская область'),
('38', 'Иркутская область'),
('85', 'Иркутская область'),
('39', 'Калининградская область'),
('85', 'Калининградская область'),
('40', 'Калужская область'),
('41', 'Камчатский край'),
('42', 'Кемеровская область'),
('43', 'Кировская область'),
('44', 'Костромская область'),
('45', 'Курганская область'),
('46', 'Курская область'),
('47', 'Ленинградская область'),
('48', 'Липецкая область'),
('49', 'Магаданская область'),
('50', 'Московская область'),
('90', 'Московская область'),
('150', 'Московская область'),
('190', 'Московская область'),
('750', 'Московская область'),
('790', 'Московская область'),
('51', 'Мурманская область'),
('52', 'Нижегородская область'),
('152', 'Нижегородская область'),
('53', 'Новгородская область'),
('54', 'Новосибирская область'),
('55', 'Омская область'),
('56', 'Оренбургская область'),
('57', 'Орловская область'),
('58', 'Пензенская область'),
('59', 'Пермский край'),
('81', 'Пермский край'),
('159', 'Пермский край'),
('60', 'Псковская область'),
('61', 'Ростовская область'),
('161', 'Ростовская область'),
('62', 'Рязанская область'),
('63', 'Самарская область'),
('163', 'Самарская область'),
('64', 'Саратовская область'),
('65', 'Сахалинская область'),
('66', 'Свердловская область'),
('96', 'Свердловская область'),
('196', 'Свердловская область'),
('67', 'Смоленская область'),
('68', 'Тамбовская область'),
('69', 'Тверская область'),
('70', 'Томская область'),
('71', 'Тульская область'),
('72', 'Тюменская область'),
('73', 'Ульяновская область'),
('173', 'Ульяновская область'),
('74', 'Челябинская область'),
('174', 'Челябинская область'),
('75', 'Забайкальский край'),
('80', 'Забайкальский край'),
('76', 'Ярославская область'),
('77', 'Москва'),
('97', 'Москва'),
('99', 'Москва'),
('177', 'Москва'),
('197', 'Москва'),
('199', 'Москва'),
('199', 'Москва'),
('777', 'Москва'),
('779', 'Москва'),
('78', 'Санкт-Петербург'),
('88', 'Санкт-Петербург'),
('178', 'Санкт-Петербург'),
('79', 'Еврейская автономная область'),
('83', 'Ненецкий автономный округ'),
('86', 'Ханты-Мансийский автономный округ'),
('87', 'Чукотский автономный округ'),
('89', 'Ямало-Ненецкий автономный округ'),
('92', 'Севастополь'),
('94', 'Байконур'),
('95', 'Чечня');

INSERT INTO Zhiznevskiy.Posts (post_name) VALUES
('Пост №1'),
('Пост №2'),
('Пост №3'),
('Пост №4');


-- Создание триггеров
-- =========================================

-- Триггер: Запрет на двойной въезд или выезд и минимальное время между проездами
CREATE TRIGGER Zhiznevskiy.trg_PreventDoubleEntryExit
ON Zhiznevskiy.VehicleLog
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        CROSS APPLY (
            SELECT TOP 1 v.direction, v.times
            FROM Zhiznevskiy.VehicleLog v
            WHERE v.vehicle_number = i.vehicle_number AND v.times < i.times
            ORDER BY v.times DESC
        ) v
        WHERE v.direction = i.direction OR DATEDIFF(MINUTE, v.times, i.times) < 5
    )
    BEGIN
        RAISERROR('Нарушение правил въезда/выезда: двойной въезд/выезд или менее 5 минут между проездами', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
GO

-- Триггер: Проверка корректности госномера автомобиля
CREATE TRIGGER Zhiznevskiy.trg_CheckVehicleNumber
ON Zhiznevskiy.VehicleLog
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE
            NOT (
                -- Формат CNNNCCNN
                (
                    LEN(i.vehicle_number) = 8 AND
                    SUBSTRING(i.vehicle_number,1,1) LIKE '[АВЕКМНОРСТУХ]' AND  -- Кириллические буквы
                    SUBSTRING(i.vehicle_number,2,3) NOT LIKE '000' AND
                    SUBSTRING(i.vehicle_number,2,3) LIKE '[0-9][0-9][0-9]' AND
                    SUBSTRING(i.vehicle_number,5,2) LIKE '[АВЕКМНОРСТУХ][АВЕКМНОРСТУХ]' AND  -- Кириллические буквы
                    SUBSTRING(i.vehicle_number,7,2) LIKE '[0-9][0-9]'
                )
                OR
                -- Формат CNNNCCNNN
                (
                    LEN(i.vehicle_number) = 9 AND
                    SUBSTRING(i.vehicle_number,1,1) LIKE '[АВЕКМНОРСТУХ]' AND  -- Кириллические буквы
                    SUBSTRING(i.vehicle_number,2,3) NOT LIKE '000' AND
                    SUBSTRING(i.vehicle_number,2,3) LIKE '[0-9][0-9][0-9]' AND
                    SUBSTRING(i.vehicle_number,5,2) LIKE '[АВЕКМНОРСТУХ][АВЕКМНОРСТУХ]' AND  -- Кириллические буквы
                    SUBSTRING(i.vehicle_number,7,3) LIKE '[1,2,7][0-9][0-9]'
                )
            )
    )
    BEGIN
        RAISERROR('Неверный формат госномера автомобиля', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
GO
-- =========================================
-- Пример проверки данных
-- =========================================

-- Пример ошибки: Двойной въезд
INSERT INTO Zhiznevskiy.VehicleLog (vehicle_number, times, direction, post_id, region_id)
VALUES ('А123ВС74', '2023-09-25T09:00:00', 1, 2, 5);
-- Ошибка

-- Пример ошибки: Менее 5 минут между въездом и выездом
INSERT INTO Zhiznevskiy.VehicleLog (vehicle_number, times, direction, post_id, region_id)
VALUES ('А123ВС74', '2023-09-25T09:03:00', 0, 2, 5);
-- Ошибка

-- Пример ошибки: Неверный формат номера
INSERT INTO Zhiznevskiy.VehicleLog (vehicle_number, times, direction, post_id)
VALUES ('Z123ВС74', '2023-09-25T10:00:00', 1, 1);
-- Ошибка

-- Транзитные автомобили (въезд на одном посту, выезд на другом)
INSERT INTO Zhiznevskiy.VehicleLog (vehicle_number, times, direction, post_id, region_id)
VALUES ('А111АС07', '2023-09-25T10:10:00', 1, 2, 8), -- Въезд через пост 2
 ('А111АС07', '2023-09-25T12:30:00', 0, 3, 8), -- Выезд через пост 3
 ('В222АВ11', '2023-09-25T11:15:00', 1, 1, 12), -- Въезд через пост 1
 ('В222АВ11', '2023-09-25T13:20:00', 0, 4, 12), -- Выезд через пост 4
 ('О333ХХ113', '2023-09-25T09:40:00', 1, 3, 15), -- Въезд через пост 3
 ('О333ХХ113', '2023-09-25T11:50:00', 0, 1, 15), -- Выезд через пост 1
 ('А444РР16', '2023-09-25T08:25:00', 1, 4, 18), -- Въезд через пост 4
 ('А444РР16', '2023-09-25T10:45:00', 0, 2, 18), -- Выезд через пост 2
 ('А555ХХ19', '2023-09-25T07:30:00', 1, 2, 21), -- Въезд через пост 2
 ('А555ХХ19', '2023-09-25T09:50:00', 0, 3, 21); -- Выезд через пост 3

 -- Местные автомобили (въезд и выезд через один пост, регион 74 или 174)
INSERT INTO Zhiznevskiy.VehicleLog (vehicle_number, times, direction, post_id, region_id)
VALUES ('А666АА74', '2023-09-25T10:00:00', 1, 1, 99), -- Въезд
 ('А666АА74', '2023-09-25T12:00:00', 0, 1, 99), -- Выезд
 ('К777КА74', '2023-09-25T11:00:00', 1, 2, 99), -- Въезд
 ('К777КА74', '2023-09-25T13:30:00', 0, 2, 99), -- Выезд
 ('В888ВК174', '2023-09-25T09:15:00', 1, 3, 100), -- Въезд
 ('В888ВК174', '2023-09-25T11:45:00', 0, 3, 100), -- Выезд
 ('К999КК74', '2023-09-25T08:20:00', 1, 4, 99), -- Въезд
 ('К999КК74', '2023-09-25T10:40:00', 0, 4, 99), -- Выезд
 ('Х001ОО174', '2023-09-25T10:10:00', 1, 1, 100), -- Въезд
 ('Х001ОО174', '2023-09-25T12:20:00', 0, 1, 100); -- Выезд



-- Вывести Все транзитные автомобили:
CREATE VIEW Zhiznevskiy.TransitVehicles AS
WITH VehicleData AS (
    SELECT
        vehicle_number,
        direction,
        times,
        post_id,
        -- Предполагаем, что код региона - это последние 2 или 3 символа номера
        CASE
            WHEN LEN(vehicle_number) = 8 THEN SUBSTRING(vehicle_number, 7, 2)
            WHEN LEN(vehicle_number) = 9 THEN SUBSTRING(vehicle_number, 7, 3)
            ELSE NULL
        END AS region_code
    FROM Zhiznevskiy.VehicleLog
    WHERE CAST(times AS DATE) = '2023-09-25'
),
Entries AS (
    SELECT vehicle_number, MIN(times) AS entry_time, post_id AS entry_post, region_code
    FROM VehicleData
    WHERE direction = 1
    GROUP BY vehicle_number, post_id, region_code
),
Exits AS (
    SELECT vehicle_number, MAX(times) AS exit_time, post_id AS exit_post, region_code
    FROM VehicleData
    WHERE direction = 0
    GROUP BY vehicle_number, post_id, region_code
)
SELECT DISTINCT
    e.vehicle_number as [Номер автомобиля], 
    FORMAT(e.entry_time, 'HH:mm') AS [Время въезда], 
    ep.post_name AS [Пост въезда], 
    FORMAT(x.exit_time, 'HH:mm') AS [Время выезда], 
    xp.post_name AS [Пост выезда],
    r.region_name as [Название региона]  -- Название региона
FROM Entries e
INNER JOIN Exits x ON e.vehicle_number = x.vehicle_number AND e.entry_post <> x.exit_post
INNER JOIN Zhiznevskiy.Posts ep ON e.entry_post = ep.id
INNER JOIN Zhiznevskiy.Posts xp ON x.exit_post = xp.id
-- Здесь добавляем присоединение к таблице Region по region_code
INNER JOIN Zhiznevskiy.Region r 
    ON r.region_code = TRY_CAST(e.region_code AS INT);  -- Используем TRY_CAST, чтобы избежать ошибок преобразования
GO


-- Вывести Все местные автомобили:
CREATE VIEW Zhiznevskiy.LocalVehicles AS
WITH VehicleData AS (
    SELECT
        vehicle_number,
        direction,
        times,
        post_id,
        CASE
            WHEN LEN(vehicle_number) = 8 THEN SUBSTRING(vehicle_number, 7, 2)
            WHEN LEN(vehicle_number) = 9 THEN SUBSTRING(vehicle_number, 7, 3)
            ELSE NULL
        END AS region_code
    FROM Zhiznevskiy.VehicleLog
    WHERE CAST(times AS DATE) = '2023-09-25'
),
Entries AS (
    SELECT vehicle_number, MIN(times) AS entry_time, post_id
    FROM VehicleData
    WHERE direction = 1
    GROUP BY vehicle_number, post_id
),
Exits AS (
    SELECT vehicle_number, MAX(times) AS exit_time, post_id
    FROM VehicleData
    WHERE direction = 0
    GROUP BY vehicle_number, post_id
)
SELECT DISTINCT 
    v.vehicle_number as [Номер автомобиля], 
    r.region_name as [Название региона], 
    FORMAT(e.entry_time, 'HH:mm') AS [Время въезда] , 
    FORMAT(x.exit_time, 'HH:mm') AS [Время выезда]
FROM VehicleData v
INNER JOIN Entries e ON v.vehicle_number = e.vehicle_number
INNER JOIN Exits x ON v.vehicle_number = x.vehicle_number
INNER JOIN Zhiznevskiy.Region r ON v.region_code = r.region_code
WHERE v.region_code IN ('74', '174') 
  AND e.post_id = x.post_id;
GO


	
-- Вывести Выборку для определенного поста:
CREATE VIEW Zhiznevskiy.Post1Vehicles AS
SELECT 
    vehicle_number  as [Номер автомобиля], 
    FORMAT(times, 'HH:mm') AS [Время проезда], 
    direction as [Направление], 
    p.post_name as [Название поста]
FROM Zhiznevskiy.VehicleLog v
INNER JOIN Zhiznevskiy.Posts p ON v.post_id = p.id
WHERE v.post_id = 1;
GO

	
-- Вывести Последнее время въезда:
CREATE VIEW Zhiznevskiy.LastEntries AS
WITH LastEntry AS (
    SELECT vehicle_number, MAX(times) AS last_entry_time, post_id
    FROM Zhiznevskiy.VehicleLog
    WHERE direction = 1
    GROUP BY vehicle_number, post_id
)
SELECT 
    le.vehicle_number AS [Номер автомобиля], 
    FORMAT(le.last_entry_time, 'HH:mm') AS [Последнее время въезда],
    p.post_name AS [Название поста]
FROM LastEntry le
JOIN Zhiznevskiy.Posts p ON le.post_id = p.id;
GO

SELECT * FROM Zhiznevskiy.TransitVehicles; -- Выводит транзитные автомобили
SELECT * FROM Zhiznevskiy.Post1Vehicles; -- выводит все автомобили, проехавшие через пост #1
SELECT * FROM Zhiznevskiy.LastEntries; --
SELECT * FROM Zhiznevskiy.LocalVehicles; -- Выводит местные автомобили (Яелябинская область)
SELECT * FROM Zhiznevskiy.Region;