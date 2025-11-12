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


-- Создам таблицу для валют
CREATE TABLE Zhiznevskiy.Currency (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name_currency nvarchar(20) UNIQUE
);

-- Создаем таблицу для хранения курсов валют
CREATE TABLE Zhiznevskiy.ExchangeRates (
    id INT IDENTITY(1,1) PRIMARY KEY,
    currency_from_id INT,               -- ID продаваемой валюты
    currency_to_id INT,                 -- ID покупаемой валюты
    exchange_rate DECIMAL(8, 4),      -- Курс обмена
    CONSTRAINT FK_CurrencyFromId FOREIGN KEY (currency_from_id) REFERENCES Zhiznevskiy.Currency(id),
    CONSTRAINT FK_BuyCurrency FOREIGN KEY (currency_to_id) REFERENCES Zhiznevskiy.Currency(id)
);

-- Создаем таблицу для харнения содержимого кошелька
CREATE TABLE Zhiznevskiy.Wallet (
    id INT IDENTITY(1,1) PRIMARY KEY,
    currency_id INT,  -- ID валюты
    name_currency varchar(20),
    amount decimal(8,2) CHECK (amount >= 0),  -- Сумма валюты (не может быть отрицательной)
    CONSTRAINT FK_Currency FOREIGN KEY (currency_id) REFERENCES Zhiznevskiy.Currency(id),
);



-- Вставляем несколько валют
INSERT INTO Zhiznevskiy.Currency(name_currency) VALUES ('USD'), ('EUR'), ('RUB');
GO

-- Вставляем курсы обмена
INSERT INTO Zhiznevskiy.ExchangeRates(currency_from_id, currency_to_id, exchange_rate)
VALUES ((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'USD'), (SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'EUR'), 0.85),
       ((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'USD'), (SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'RUB'), 75),
       ((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'EUR'), (SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'USD'), 1.17),
       ((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'EUR'), (SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'RUB'), 88),
       ((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'RUB'), (SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'USD'), 0.013),
       ((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'RUB'), (SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'EUR'), 0.011);
GO

-- Начальное состояние кошелька
INSERT INTO Zhiznevskiy.Wallet (currency_id, amount) VALUES
((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'USD'), 100),
((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'EUR'), 200),
((SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = 'RUB'), 5000);
GO


--Возвращает содержимое кошелька (таблица вида (валюта : сумма)).
CREATE FUNCTION Zhiznevskiy.GetWalletContent()
RETURNS TABLE
AS
RETURN
(
    SELECT c.name_currency AS [Название валюты], w.amount AS [Всего валюты]
    FROM Zhiznevskiy.Wallet w
    INNER JOIN Zhiznevskiy.Currency c ON w.currency_id = c.id
);
GO


CREATE PROCEDURE Zhiznevskiy.TotalAmount @target_currency_name NVARCHAR(50)
AS
BEGIN
    DECLARE @total DECIMAL(18, 2) = 0;
    DECLARE @wallet_amount DECIMAL(18, 2);
    DECLARE @rate DECIMAL(10, 4);
    DECLARE @currency_name NVARCHAR(50);

    -- Проход по всем валютам в кошельке
    DECLARE currency_cursor CURSOR FOR
    SELECT c.name_currency, w.amount
    FROM Zhiznevskiy.Wallet w
    JOIN Zhiznevskiy.Currency c ON w.currency_id = c.id;

    OPEN currency_cursor;

    FETCH NEXT FROM currency_cursor INTO @currency_name, @wallet_amount;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Получение курса для обмена валюты на целевую
        SELECT @rate = exchange_rate 
        FROM Zhiznevskiy.ExchangeRates er
        JOIN Zhiznevskiy.Currency c1 ON er.currency_from_id = c1.id
        JOIN Zhiznevskiy.Currency c2 ON er.currency_to_id = c2.id
        WHERE c1.name_currency = @currency_name AND c2.name_currency = @target_currency_name;

		IF @rate IS NULL
		BEGIN
			 RAISERROR('Валюта "%s" не найдена.', 16, 1, @target_currency_name); -- Ошибка при отсутствии валюты
        RETURN;
		END;

        -- Если курс найден, конвертируем валюту
        IF @rate IS NOT NULL
        BEGIN
            SET @total = @total + (@wallet_amount * @rate);
        END
        ELSE IF @currency_name = @target_currency_name
        BEGIN
            SET @total = @total + @wallet_amount; -- Если валюта совпадает с целевой, прибавляем напрямую
        END

        FETCH NEXT FROM currency_cursor INTO @currency_name, @wallet_amount;
    END;

    CLOSE currency_cursor;
    DEALLOCATE currency_cursor;

    -- Вывод результата
    SELECT @total AS [Общая сумма в выбранной валюте];
END;
GO


--Кладёт деньги в кошелёк в указанной валюте.
CREATE PROCEDURE Zhiznevskiy.AddMoneyInWallet (@currencyName NVARCHAR(50), @amount DECIMAL(18, 6))
AS
BEGIN
    -- Проверяем, существует ли такая валюта
    DECLARE @currency_id INT = (SELECT id FROM Currency WHERE name_currency = @currencyName);
    
    IF @currency_id IS NULL
    BEGIN
        RAISERROR('Валюта "%s" не найдена.', 16, 1, @currencyName); -- Ошибка при отсутствии валюты
        RETURN;
    END;
    
    -- Добавляем запись в кошелёк или обновляем существующую
    MERGE INTO Zhiznevskiy.Wallet AS target
    USING (VALUES (@currency_id, @amount)) AS source (currency_id, amount)
    ON (target.currency_id = source.currency_id)
    WHEN MATCHED THEN
        UPDATE SET target.amount = target.amount + source.amount
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (currency_id, amount) VALUES (source.currency_id, source.amount);
END;
GO

--Уменьшает баланс кошелька на указанную сумму в указанной валюте.
CREATE PROCEDURE Zhiznevskiy.SubMoneyInWallet (@currencyName NVARCHAR(50), @amount DECIMAL(8, 2))
AS
BEGIN
    DECLARE @currency_id INT;
    DECLARE @current_amount DECIMAL(18, 2);

    -- Получаем идентификатор валюты по названию
    SELECT @currency_id = id FROM Zhiznevskiy.Currency WHERE name_currency = @currencyName;

    IF @currency_id IS NULL
    BEGIN
        RAISERROR('Валюта не найдена', 16, 1);
        RETURN;
    END

    -- Проверка остатка валюты в кошельке
    SELECT @current_amount = amount FROM Zhiznevskiy.Wallet WHERE currency_id = @currency_id;

    IF @current_amount IS NULL
    BEGIN
        RAISERROR('Валюта отсутствует в кошельке', 16, 1);
    END
    ELSE IF @current_amount < @amount
    BEGIN
        RAISERROR('Недостаточно средств в кошельке', 16, 1);
    END
    ELSE
    BEGIN
        -- Выемка валюты
        UPDATE Zhiznevskiy.Wallet
        SET amount = amount - @amount
        WHERE currency_id = @currency_id;

        -- Если баланс валюты стал 0, удаляем её из кошелька
        IF (SELECT amount FROM Zhiznevskiy.Wallet WHERE currency_id = @currency_id) = 0
        BEGIN
            DELETE FROM Zhiznevskiy.Wallet WHERE currency_id = @currency_id;
        END
    END
END;
GO

CREATE PROCEDURE Zhiznevskiy.ConvertExpence 
    @currencyFrom NVARCHAR(50), 
    @currencyTo NVARCHAR(50), 
    @amount DECIMAL(18, 6)
AS
BEGIN
    BEGIN TRY
        -- Проверяем корректность суммы
        IF @amount <= 0
        BEGIN
            RAISERROR('Сумма для конверсии должна быть положительной.', 16, 1);
            RETURN;
        END;

        -- Проверяем наличие валют
        DECLARE @from_currency_id INT = (SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = @currencyFrom);
        DECLARE @to_currency_id INT = (SELECT id FROM Zhiznevskiy.Currency WHERE name_currency = @currencyTo);

        IF @from_currency_id IS NULL OR @to_currency_id IS NULL
        BEGIN
            RAISERROR('Одна из валют не найдена.', 16, 1);
            RETURN;
        END;

        -- Проверяем достаточность средств
        DECLARE @current_balance DECIMAL(18, 6) = (SELECT amount FROM Zhiznevskiy.Wallet WHERE currency_id = @from_currency_id);

        IF @current_balance IS NULL OR @current_balance < @amount
        BEGIN
            RAISERROR('Недостаточно средств для конверсии.', 16, 1);
            RETURN;
        END;

        -- Получаем курс обмена
        DECLARE @exchange_rate DECIMAL(18, 6) = 
            (SELECT exchange_rate 
             FROM Zhiznevskiy.ExchangeRates 
             WHERE currency_from_id = @from_currency_id AND currency_to_id = @to_currency_id);

        IF @exchange_rate IS NULL
        BEGIN
            RAISERROR('Курс обмена между этими валютами не найден.', 16, 1);
            RETURN;
        END;

        -- Рассчитываем сумму целевой валюты
        DECLARE @converted_amount DECIMAL(18, 6) = @amount * @exchange_rate;

        BEGIN TRANSACTION;

            -- Снимаем средства из исходной валюты
            UPDATE Zhiznevskiy.Wallet
            SET amount = amount - @amount
            WHERE currency_id = @from_currency_id;

            -- Если баланс исходной валюты стал 0, удаляем запись
            DELETE FROM Zhiznevskiy.Wallet 
            WHERE currency_id = @from_currency_id AND amount = 0;

            -- Добавляем средства в целевую валюту
            MERGE INTO Zhiznevskiy.Wallet AS target
            USING (VALUES (@to_currency_id, @converted_amount)) AS source (currency_id, amount)
            ON (target.currency_id = source.currency_id)
            WHEN MATCHED THEN
                UPDATE SET target.amount = target.amount + source.amount
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (currency_id, amount) VALUES (source.currency_id, source.amount);

        COMMIT TRANSACTION;

        PRINT 'Конвертация успешно выполнена.';
    END TRY
    BEGIN CATCH
        -- Откатываем транзакцию в случае ошибки
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Выводим сообщение об ошибке
        DECLARE @error_message NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @error_severity INT = ERROR_SEVERITY();
        DECLARE @error_state INT = ERROR_STATE();
        RAISERROR (@error_message, @error_severity, @error_state);
    END CATCH;
END;
GO

-- Посмотреть содержимое кошелька
SELECT * FROM Zhiznevskiy.GetWalletContent();

-- Узнаем общий баланс в евро
EXEC Zhiznevskiy.TotalAmount 'EUR';

-- Пополняем кошелёк на 100 евро
EXEC Zhiznevskiy.AddMoneyInWallet 'EUR', 100;

-- Пополняем кошелёк на 100 долларов
EXEC Zhiznevskiy.AddMoneyInWallet 'USD', 100;

-- Конвертируем 100 долларов в рубли
EXEC Zhiznevskiy.ConvertExpence 'RUB', 'USD', 4000;

-- Снимаем 300 рублей
EXEC Zhiznevskiy.SubMoneyInWallet 'RUB', 300;

-- Снимаем 200 долларов
EXEC Zhiznevskiy.SubMoneyInWallet 'EUR', 150;