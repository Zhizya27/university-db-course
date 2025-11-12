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
  WHERE name = N'KN301_Zhiznevskiy'
)
DROP SCHEMA KN301_Zhiznevskiy;
GO

CREATE SCHEMA KN301_Zhiznevskiy;
GO


-- =============================================
-- Таблица для хранения тарифов
-- =============================================
CREATE TABLE KN301_Zhiznevskiy.Tarifs(
    ID INT,            
    Abonent_cost FLOAT NOT NULL,         -- Абонентская плата в рублях
    Minutes FLOAT NOT NULL,              -- Количество минут, включённых в тариф
    Cost_over_limit FLOAT NOT NULL,      -- Стоимость минуты сверх лимита
    CONSTRAINT Tarifs_PK PRIMARY KEY (ID)
)
GO

-- =============================================
-- Функция: Разница между числами
-- =============================================
CREATE FUNCTION KN301_Zhiznevskiy.NumDifference(@f FLOAT, @s FLOAT)
    RETURNS FLOAT
AS
BEGIN
    RETURN CASE 
        WHEN @f > @s THEN @f - @s 
        ELSE 0 
    END;
END;
GO

-- =============================================
-- Основная функция: Определение лучшего тарифа
-- =============================================
CREATE FUNCTION KN301_Zhiznevskiy.BestTarifs(@q FLOAT)
    RETURNS INT
AS
BEGIN
    DECLARE @min FLOAT;
    DECLARE @id INT;

    -- Найти минимальную стоимость
    SELECT TOP 1 
        @id = t.ID,
        @min = t.Abonent_cost + t.Cost_over_limit * KN301_Zhiznevskiy.NumDifference(@q, t.Minutes)
    FROM KN301_Zhiznevskiy.Tarifs t
    ORDER BY t.Abonent_cost + t.Cost_over_limit * KN301_Zhiznevskiy.NumDifference(@q, t.Minutes), t.ID;

    RETURN @id;
END;
GO

-- =============================================
-- Процедура: Разбиение диапазона на интервалы
-- =============================================
CREATE PROCEDURE KN301_Zhiznevskiy.OptimalTariffs
AS
BEGIN
    -- Создаем временную таблицу для точек разрыва
    CREATE TABLE #t (
        cost FLOAT NOT NULL,  -- Точка разрыва
        id1 INT,              -- ID первого тарифа
        id2 INT               -- ID второго тарифа
    ); 

    -- Находим точки пересечения тарифов
    INSERT INTO #t 
    SELECT DISTINCT
        (b.Abonent_cost - a.Abonent_cost - b.Minutes * b.Cost_over_limit + a.Minutes * a.Cost_over_limit) 
        / (a.Cost_over_limit - b.Cost_over_limit) AS cost,
        a.ID AS id1, 
        b.ID AS id2
    FROM KN301_Zhiznevskiy.Tarifs AS a
    CROSS JOIN KN301_Zhiznevskiy.Tarifs AS b
    WHERE a.ID < b.ID 
      AND a.Cost_over_limit <> b.Cost_over_limit
      AND (a.Cost_over_limit - b.Cost_over_limit) <> 0 
      AND (b.Abonent_cost - a.Abonent_cost - b.Minutes * b.Cost_over_limit + a.Minutes * a.Cost_over_limit) 
        / (a.Cost_over_limit - b.Cost_over_limit) > 0;

    -- Создаем временную таблицу для интервалов
    CREATE TABLE #set (
        l FLOAT,     -- Левая граница интервала
        r FLOAT,     -- Правая граница интервала
        id INT       -- ID наиболее выгодного тарифа
    ); 

    -- Инициализация курсора для обработки точек разрыва
    DECLARE @point FLOAT;
    DECLARE @id1 INT;
    DECLARE @id2 INT;
    DECLARE @l FLOAT = 0;

    DECLARE CUR CURSOR FOR
        SELECT cost, id1, id2 
        FROM #t
        ORDER BY cost;

    OPEN CUR;

    FETCH NEXT FROM CUR INTO @point, @id1, @id2;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Определяем наиболее выгодный тариф на интервале
        IF KN301_Zhiznevskiy.BestTarifs(@point - 0.001) = @id1
        BEGIN
            INSERT INTO #set (l, r, id) VALUES (@l, @point, @id1);
        END
        ELSE
        BEGIN
            INSERT INTO #set (l, r, id) VALUES (@l, @point, @id2);
        END
        SET @l = @point;

        FETCH NEXT FROM CUR INTO @point, @id1, @id2;
    END;

    CLOSE CUR;
    DEALLOCATE CUR;

    -- Добавляем последний интервал от последней точки до 500 минут
    INSERT INTO #set (l, r, id)
    VALUES (@l, 500, KN301_Zhiznevskiy.BestTarifs(500));

    -- Объединяем и выводим интервалы
    SELECT DISTINCT 
        l AS 'С какой минуты', 
        r AS 'По какую минуту', 
        id AS 'Тариф'
    FROM #set
    WHERE l <> r
    ORDER BY l;

    DROP TABLE #t;
    DROP TABLE #set;
END;
GO

-- Очистка данных из таблицы Tarifs
DELETE FROM KN301_Zhiznevskiy.Tarifs;
GO

-- =============================================
-- Добавление тарифов
-- =============================================
INSERT INTO KN301_Zhiznevskiy.Tarifs(ID, Abonent_cost, Minutes, Cost_over_limit) VALUES
    (1, 0, 0, 1),         -- Тариф "Поминутный"
    (2, 2, 4, 0.1),           -- Тариф безлимит до 2 минут, потом за одну минуту 0.1 рубль
    (3, 5, 500, 0);       -- Безлимитный тариф
GO

-- Тестирование функций
PRINT KN301_Zhiznevskiy.BestTarifs(500); -- Ожидается ID тарифа "Безлимитный" (3)
PRINT KN301_Zhiznevskiy.Besttarifs(6);

-- Выполнение процедуры
EXEC KN301_Zhiznevskiy.OptimalTariffs;
GO
