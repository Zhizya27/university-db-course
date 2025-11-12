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

CREATE TABLE Zhiznevskiy.Shop (
    id INT IDENTITY(1,1) PRIMARY KEY, --добавить время работы магазина и добавить селекты по товарам 
    name NVARCHAR(100),
    address NVARCHAR(255)
);

CREATE TABLE Zhiznevskiy.Product (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    type NVARCHAR(50)  -- тип товара: молочные, алкоголь и т.п.
);

CREATE TABLE Zhiznevskiy.Manufacturer (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100)
);

CREATE TABLE Zhiznevskiy.PriceType (
    id INT IDENTITY(1,1) PRIMARY KEY,
    type NVARCHAR(50)  -- по весу, за штуку, за объем
);

CREATE TABLE Zhiznevskiy.Inventory (
    id INT IDENTITY(1,1) PRIMARY KEY,
    shop_id INT,
    product_id INT,
    manufacturer_id INT,
    price_type_id INT,
    price DECIMAL(10, 2),  -- цена товара
    quantity DECIMAL(10, 2),  -- количество товара (со знаком: + для поступления, - для продажи)
    date DATETIME,  -- дата операции с временем
    CONSTRAINT FK_Shop FOREIGN KEY (shop_id) REFERENCES Zhiznevskiy.Shop(id),
    CONSTRAINT FK_Product FOREIGN KEY (product_id) REFERENCES Zhiznevskiy.Product(id),
    CONSTRAINT FK_Manufacturer FOREIGN KEY (manufacturer_id) REFERENCES Zhiznevskiy.Manufacturer(id),
    CONSTRAINT FK_PriceType FOREIGN KEY (price_type_id) REFERENCES Zhiznevskiy.PriceType(id)
);

INSERT INTO Zhiznevskiy.Shop (name, address) VALUES
('Пятерочка', 'Улица Строителей 4'),
('Магнит', 'Улица Ленина 41'),
('Магнит', 'Улица Просветова 90'),
('Перекресток', 'Улица Ленина 92 корпус 1'),
('Пятерочка', 'Улица Овощная 3'),
('Азбука Вкуса', 'Улица Малышева 43'),
('Чижик', 'Улица Мичурина 55'),
('Магнит', 'Улица Белинского 21'),
('Монетка', 'Улица Гурзуфская 25');

INSERT INTO Zhiznevskiy.Product (name, type) VALUES
('Молоко Ирбитское 3%', 'Молочный'),
('Молоко Полевское Обезжиренное', 'Молочный'),
('Кефир Ирбитский 10%', 'Молочный'),
('Колбаса Докторская Златоустовская', 'Колбасный'),
('Колбаса Докторская Березовская', 'Колбасный'),
('Колбаса Сервелат Башкирская', 'Колбасный'),
('Шоколад Milka Карамель', 'Кондитерский'),
('Шоколад Alpen Gold Фундук', 'Кондитерский'),
('Шоколад Milka Фундук', 'Кондитерский'),
('Kit Kat', 'Кондитерский'),
('Snikers Белый шоколад', 'Кондитерский'),
('Конфеты Ротфронт', 'Кондитерский'), 
('Конфеты Метелица', 'Кондитерский'),
('Пиво Corona Extra', 'Алкогольный'),
('Вино Масандра Крым', 'Алкогольный'),
('Пиво Bud', 'Алкогольный'),
('Вино Shato Tamagne Франция', 'Алкогольный');

INSERT INTO Zhiznevskiy.Manufacturer (name) VALUES
('Ирбитский молочный завод'),
('Полевской молочный завод'),
('Ирбитский молочный завод'),
('Златоустовский колбасный завод'),
('Березовский мясокомбинат'),
('Alpen Gold Company'),
('Крымский винный завод Масандра'),
('Жигулёвский завод');

INSERT INTO Zhiznevskiy.PriceType (type) VALUES
('За штуку'),
('За вес'),
('За объём');

-- Пример поступлений и продаж товара
INSERT INTO Zhiznevskiy.Inventory (shop_id, product_id, manufacturer_id, price_type_id, price, quantity, date) VALUES
(1, 1, 1, 3, 45.50, 10.00, '2024-11-09 08:30:00'),  -- поступление 10 литров молока в магазин Пятерочка Улица Строителей 4
(1, 1, 1, 3, 45.50, -3.00, '2024-08-10 12:45:00'),  -- продажа 3 литров молока в магазине Пятерочка Улица Строителей 4
(2, 1, 1, 3, 50.00, 15.00, '2024-11-09 09:15:00'), 
(5, 3, 2, 3, 50.00, 15.00, '2024-11-09 09:15:00'),  
(3, 1, 3, 3, 48.75, 40.00, '2024-10-09 10:00:00'), 
(1, 2, 1, 3, 40.00, 20.00, '2024-10-09 09:30:00'),  
(1, 1, 1, 3, 42.50, -5.00, '2024-10-10 10:00:00'), 
(2, 4, 4, 3, 150.00, 10.00, '2024-10-09 11:00:00'),
(3, 5, 5, 3, 160.00, -2.00, '2024-10-10 11:30:00'), 
(2, 6, 6, 3, 75.00, 30.00, '2024-10-09 12:00:00'), 
(1, 1, 1, 3, 90.00, 10.00, '2024-10-11 13:30:00'), 
(3, 8, 7, 3, 120.00, 5.00, '2024-10-02 14:15:00'),
(4, 3, 1, 3, 250.00, 26.00, '2024-10-03 18:15:00'),
(3, 4, 4, 1, 170.00, 4.00, '2024-11-08 11:15:00'),
(3, 5, 5, 1, 120.00, -5.00, '2024-12-01 13:25:00'),
(2, 9, 8, 3, 200.00, -1.00, '2024-10-10 15:45:00'), 
(1, 10, 6, 1, 55.00, 25.00, '2024-12-02 08:45:00'), 
(2, 12, 6, 1, 120.00, 30.00, '2024-12-03 10:30:00'),  
(3, 13, 6, 1, 90.00, -10.00, '2024-12-03 11:00:00'),  
(1, 11, 6, 1, 75.00, 50.00, '2024-12-04 08:20:00'),  
(4, 14, 8, 3, 120.00, 40.00, '2024-12-05 09:15:00'),  
(2, 15, 7, 3, 300.00, 20.00, '2024-12-06 16:00:00'),  
(5, 16, 8, 3, 200.00, 15.00, '2024-12-07 14:30:00'), 
(3, 11, 6, 1, 70.00, -5.00, '2024-12-08 10:15:00'),  
(1, 9, 6, 1, 85.00, 20.00, '2024-12-09 13:45:00'),  
(4, 3, 2, 1, 60.00, -5.00, '2024-12-09 15:30:00'),   
(5, 2, 2, 1, 45.00, 10.00, '2024-12-10 09:45:00'),   
(3, 17, 7, 3, 400.00, 5.00, '2024-12-10 17:15:00'),  
(1, 7, 6, 1, 100.00, 30.00, '2024-12-11 08:00:00'),  
(2, 18, 8, 1, 150.00, 20.00, '2024-12-11 14:00:00'), 
(4, 1, 1, 3, 45.50, -4.00, '2024-12-12 18:00:00'),   
(3, 4, 4, 1, 180.00, 8.00, '2024-12-12 11:30:00'),   
(5, 13, 6, 1, 95.00, -10.00, '2024-12-11 12:45:00'), 
(2, 8, 6, 1, 90.00, 25.00, '2024-12-10 09:00:00'),   
(4, 7, 6, 1, 105.00, -8.00, '2024-12-10 10:30:00'),  
(3, 1, 1, 3, 47.00, -7.00, '2024-12-10 12:00:00');  


-- Вывод количества определенного товара по магазинам с русскими названиями столбцов и форматированной датой
SELECT s.name AS [Название магазина],
       SUM(i.quantity) AS [Общее количество]
FROM Zhiznevskiy.Inventory i
JOIN Zhiznevskiy.Shop s ON i.shop_id = s.id
JOIN Zhiznevskiy.Product p ON i.product_id = p.id
WHERE p.name = 'Молоко Ирбитское 3%' 
GROUP BY s.name; 
GO

-- Вывод минимальной, максимальной и средней цены товара
SELECT MIN(i.price) AS [Минимальная цена], 
       MAX(i.price) AS [Максимальная цена], 
        FORMAT(AVG(i.price), 'N2') AS [Средняя цена] 
FROM Zhiznevskiy.Inventory i
JOIN Zhiznevskiy.Product p ON i.product_id = p.id
WHERE p.name = 'Молоко Ирбитское 3%';
GO

-- Общее количество на складах
SELECT s.name AS [Название магазина],
       SUM(i.quantity) AS [Количество товара]
FROM Zhiznevskiy.Inventory i
JOIN Zhiznevskiy.Shop s ON i.shop_id = s.id
GROUP BY s.name;
GO


-- Остаток на текущую дату 
SELECT s.name AS [Название магазина],
       p.name AS [Тип товара],
       SUM(i.quantity) AS [Общее количество]
FROM Zhiznevskiy.Inventory i
JOIN Zhiznevskiy.Product p ON i.product_id = p.id
JOIN Zhiznevskiy.Shop s ON i.shop_id = s.id
GROUP BY s.name, p.name
ORDER BY s.name
GO

-- Количество товара в определённую дату 
DECLARE @checked_date DATETIME = '2024-12-09 15:30:00';

SELECT s.name AS [Название магазина],
	   p.name AS [Товар],
       SUM(i.quantity) AS [Общее количество]
FROM Zhiznevskiy.Inventory i
JOIN Zhiznevskiy.Product p ON i.product_id = p.id
JOIN Zhiznevskiy.Shop s ON i.shop_id = s.id
WHERE i.date < @checked_date
GROUP BY s.name, p.name
ORDER BY s.name
GO
