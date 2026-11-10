
USE [master]
GO

-- Если базы ещё нет на сервере — создаём её 
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Barbershop')
BEGIN
    CREATE DATABASE [Barbershop]
END
GO

USE [Barbershop]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------- Справочники ---------- */

IF OBJECT_ID(N'[dbo].[Specialization]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Specialization](
        [ID_Specialization] [int] NOT NULL,
        [Name] [nvarchar](255) NULL,
        PRIMARY KEY CLUSTERED ([ID_Specialization] ASC)
    )
END
GO

IF OBJECT_ID(N'[dbo].[Role]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Role](
        [ID_Role] [int] NOT NULL,
        [Name] [nvarchar](255) NULL,
        PRIMARY KEY CLUSTERED ([ID_Role] ASC)
    )
END
GO

IF OBJECT_ID(N'[dbo].[Type_Service]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Type_Service](
        [ID_Type_Service] [int] NOT NULL,
        [Name] [nvarchar](255) NULL,
        PRIMARY KEY CLUSTERED ([ID_Type_Service] ASC)
    )
END
GO

IF OBJECT_ID(N'[dbo].[Status_Visit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Status_Visit](
        [ID_Status_Visit] [int] NOT NULL,
        [Name] [nvarchar](255) NULL,
        PRIMARY KEY CLUSTERED ([ID_Status_Visit] ASC)
    )
END
GO

/* ---------- Основные таблицы ---------- */

IF OBJECT_ID(N'[dbo].[Client]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Client](
        [ID_Client] [int] NOT NULL,
        [Surname] [nvarchar](255) NULL,
        [Name] [nvarchar](255) NULL,
        [Patronymic] [nvarchar](255) NULL,
        [Phone] [nvarchar](255) NULL,
        [DateOfBirth] [date] NULL,
        PRIMARY KEY CLUSTERED ([ID_Client] ASC)
    )
END
GO

IF OBJECT_ID(N'[dbo].[Employee]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Employee](
        [ID_Employee] [int] NOT NULL,
        [FIO] [nvarchar](255) NULL,
        [Phone] [nvarchar](255) NULL,
        [Login] [nvarchar](255) NULL,
        [Password] [nvarchar](255) NULL,
        [DateOfBirth] [date] NULL,
        [ID_Role] [int] NULL,
        [IsActive] [bit] NULL CONSTRAINT [DF_Employee_IsActive] DEFAULT ((1)),
        PRIMARY KEY CLUSTERED ([ID_Employee] ASC),
        CONSTRAINT [FK_Employee_Role] FOREIGN KEY ([ID_Role]) REFERENCES [dbo].[Role] ([ID_Role])
    )
END
GO

IF OBJECT_ID(N'[dbo].[Service]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Service](
        [ID_Service] [int] NOT NULL,
        [Name] [nvarchar](255) NULL,
        [Opisanie] [nvarchar](255) NULL,
        [Duration] [int] NULL,
        [Price] [decimal](18, 2) NULL,
        [ID_Type_Service] [int] NULL,
        PRIMARY KEY CLUSTERED ([ID_Service] ASC),
        CONSTRAINT [FK_Service_Type] FOREIGN KEY ([ID_Type_Service]) REFERENCES [dbo].[Type_Service] ([ID_Type_Service]),
        CONSTRAINT [CHK_Service_Duration] CHECK ([Duration] > (0)),
        CONSTRAINT [CHK_Service_Price] CHECK ([Price] >= (0))
    )
END
GO

IF OBJECT_ID(N'[dbo].[Barber_Specialization]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Barber_Specialization](
        [ID_Barber] [int] NOT NULL,
        [ID_Specialization] [int] NOT NULL,
        PRIMARY KEY CLUSTERED ([ID_Barber] ASC, [ID_Specialization] ASC),
        CONSTRAINT [FK_BarberSpec_Employee] FOREIGN KEY ([ID_Barber]) REFERENCES [dbo].[Employee] ([ID_Employee]),
        CONSTRAINT [FK_BarberSpec_Specialization] FOREIGN KEY ([ID_Specialization]) REFERENCES [dbo].[Specialization] ([ID_Specialization])
    )
END
GO

IF OBJECT_ID(N'[dbo].[Visit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Visit](
        [ID_Visit] [int] NOT NULL,
        [ID_Client] [int] NULL,
        [ID_Barber] [int] NULL,
        [Visit_Date] [date] NULL,
        [Visit_Time] [time](7) NULL,
        [Total_Duration] [int] NULL,
        [Total_Price] [decimal](18, 2) NULL,
        [ID_Status_Visit] [int] NULL,
        [Comment] [nvarchar](255) NULL,
        PRIMARY KEY CLUSTERED ([ID_Visit] ASC),
        CONSTRAINT [FK_Visit_Barber] FOREIGN KEY ([ID_Barber]) REFERENCES [dbo].[Employee] ([ID_Employee]),
        CONSTRAINT [FK_Visit_Client] FOREIGN KEY ([ID_Client]) REFERENCES [dbo].[Client] ([ID_Client]),
        CONSTRAINT [FK_Visit_Status] FOREIGN KEY ([ID_Status_Visit]) REFERENCES [dbo].[Status_Visit] ([ID_Status_Visit]),
        CONSTRAINT [CHK_Visit_Price] CHECK ([Total_Price] >= (0))
    )
END
GO

IF OBJECT_ID(N'[dbo].[Visit_Service]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Visit_Service](
        [ID_Visit] [int] NOT NULL,
        [ID_Service] [int] NOT NULL,
        [Price] [decimal](18, 2) NULL,
        PRIMARY KEY CLUSTERED ([ID_Visit] ASC, [ID_Service] ASC),
        CONSTRAINT [FK_VisitServ_Service] FOREIGN KEY ([ID_Service]) REFERENCES [dbo].[Service] ([ID_Service]),
        CONSTRAINT [FK_VisitServ_Visit] FOREIGN KEY ([ID_Visit]) REFERENCES [dbo].[Visit] ([ID_Visit]),
        CONSTRAINT [CHK_VisitServ_Price] CHECK ([Price] >= (0))
    )
END
GO

SET NOCOUNT ON
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Role])
    INSERT INTO [dbo].[Role] ([ID_Role], [Name]) VALUES
        (1, N'Администратор'),
        (2, N'Барбер');
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Specialization])
    INSERT INTO [dbo].[Specialization] ([ID_Specialization], [Name]) VALUES
        (1, N'Классические стрижки'),
        (2, N'Fade и современные стрижки'),
        (3, N'Моделирование бороды'),
        (4, N'Королевское бритьё'),
        (5, N'Детские стрижки');
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Type_Service])
    INSERT INTO [dbo].[Type_Service] ([ID_Type_Service], [Name]) VALUES
        (1, N'Стрижки'),
        (2, N'Борода и усы'),
        (3, N'Бритьё'),
        (4, N'Уход и окрашивание');
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Status_Visit])
    INSERT INTO [dbo].[Status_Visit] ([ID_Status_Visit], [Name]) VALUES
        (1, N'Ожидается'),
        (2, N'Завершён'),
        (3, N'Отменён'),
        (4, N'Не явился');
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Service])
    INSERT INTO [dbo].[Service] ([ID_Service], [Name], [Opisanie], [Duration], [Price], [ID_Type_Service]) VALUES
        (1, N'Мужская стрижка', N'Классическая стрижка ножницами и машинкой с мытьём головы', 60, 1500.00, 1),
        (2, N'Стрижка машинкой', N'Стрижка под одну насадку или с переходом', 30, 900.00, 1),
        (3, N'Fade-стрижка', N'Стрижка с плавным переходом (фейд) и укладкой', 75, 2000.00, 1),
        (4, N'Детская стрижка', N'Стрижка для детей до 12 лет', 45, 1000.00, 1),
        (5, N'Моделирование бороды', N'Придание формы и коррекция бороды', 45, 1200.00, 2),
        (6, N'Оформление усов', N'Коррекция формы и длины усов', 20, 500.00, 2),
        (7, N'Королевское бритьё', N'Бритьё опасной бритвой с горячим полотенцем', 40, 1500.00, 3),
        (8, N'Бритьё головы', N'Бритьё головы с уходом после процедуры', 40, 1300.00, 3),
        (9, N'Камуфляж седины', N'Тонирование волос и бороды', 60, 1800.00, 4),
        (10, N'Укладка', N'Укладка волос стайлингом', 20, 600.00, 4),
        (11, N'Стрижка + борода', N'Комплекс: стрижка и моделирование бороды', 90, 2500.00, 1);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employee])
    INSERT INTO [dbo].[Employee] ([ID_Employee], [FIO], [Phone], [Login], [Password], [DateOfBirth], [ID_Role], [IsActive]) VALUES
        (1, N'Администратор Системы', N'+7 (900) 100-00-01', N'admin', N'admin123', '19900115', 1, 1),
        (2, N'Громов Александр Сергеевич', N'+7 (900) 100-00-02', N'barber1', N'barber123', '19920321', 2, 1),
        (3, N'Власов Дмитрий Игоревич', N'+7 (900) 100-00-03', N'barber2', N'barber123', '19940709', 2, 1),
        (4, N'Крылов Максим Андреевич', N'+7 (900) 100-00-04', N'barber3', N'barber123', '19891130', 2, 1),
        (5, N'Соколов Артём Павлович', N'+7 (900) 100-00-05', N'barber4', N'barber123', '19960517', 2, 1),
        (6, N'Орлов Кирилл Владимирович', N'+7 (900) 100-00-06', N'barber5', N'barber123', '19910902', 2, 1);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Barber_Specialization])
    INSERT INTO [dbo].[Barber_Specialization] ([ID_Barber], [ID_Specialization]) VALUES
        (2, 1),
        (2, 4),
        (3, 2),
        (3, 3),
        (4, 1),
        (4, 3),
        (4, 4),
        (5, 2),
        (5, 5),
        (6, 1),
        (6, 2),
        (6, 5);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Client])
    INSERT INTO [dbo].[Client] ([ID_Client], [Surname], [Name], [Patronymic], [Phone], [DateOfBirth]) VALUES
        (1, N'Иванов', N'Матвей', N'Игоревич', N'+7 (911) 278-82-70', '19830603'),
        (2, N'Петров', N'Евгений', N'Михайлович', N'+7 (909) 435-39-51', '19780128'),
        (3, N'Смирнов', N'Тимофей', N'Николаевич', N'+7 (909) 243-55-99', '19880122'),
        (4, N'Кузнецов', N'Тимофей', N'Николаевич', N'+7 (906) 932-38-32', '20020929'),
        (5, N'Попов', N'Кирилл', N'Дмитриевич', N'+7 (903) 257-30-36', '19940417'),
        (6, N'Васильев', N'Алексей', N'Иванович', N'+7 (904) 593-16-20', '19730330'),
        (7, N'Михайлов', N'Артём', N'Михайлович', N'+7 (903) 587-33-21', '19990410'),
        (8, N'Новиков', N'Александр', N'Дмитриевич', N'+7 (906) 185-89-26', '19910105'),
        (9, N'Фёдоров', N'Михаил', N'Сергеевич', N'+7 (905) 248-37-73', '19820309'),
        (10, N'Морозов', N'Тимофей', N'Александрович', N'+7 (903) 150-85-46', '19730316'),
        (11, N'Волков', N'Илья', N'Николаевич', N'+7 (905) 128-67-35', '19971122'),
        (12, N'Алексеев', N'Артём', N'Николаевич', N'+7 (902) 911-98-69', '19870408'),
        (13, N'Лебедев', N'Никита', N'Иванович', N'+7 (912) 383-10-46', '19700911'),
        (14, N'Семёнов', N'Дмитрий', N'Александрович', N'+7 (909) 756-54-17', '19780426'),
        (15, N'Егоров', N'Егор', N'Дмитриевич', N'+7 (911) 156-27-20', '19900925'),
        (16, N'Павлов', N'Андрей', N'Владимирович', N'+7 (900) 341-76-84', '19990923'),
        (17, N'Козлов', N'Евгений', N'Андреевич', N'+7 (912) 134-95-70', '19880316'),
        (18, N'Степанов', N'Арсений', N'Дмитриевич', N'+7 (903) 437-61-19', '19780219'),
        (19, N'Николаев', N'Илья', N'Андреевич', N'+7 (901) 668-61-97', '19710617'),
        (20, N'Орлов', N'Владислав', N'Андреевич', N'+7 (905) 203-20-58', '19980219'),
        (21, N'Андреев', N'Владислав', N'Дмитриевич', N'+7 (910) 223-37-33', '19881231'),
        (22, N'Макаров', N'Егор', N'Александрович', N'+7 (908) 683-39-33', '19931123'),
        (23, N'Захаров', N'Дмитрий', N'Михайлович', N'+7 (906) 612-12-39', '19780521'),
        (24, N'Зайцев', N'Тимофей', N'Иванович', N'+7 (901) 462-50-72', '19860526'),
        (25, N'Соловьёв', N'Денис', N'Дмитриевич', N'+7 (911) 235-61-42', '19881121');
GO

SET NOCOUNT ON
SET XACT_ABORT ON

IF NOT EXISTS (SELECT 1 FROM [dbo].[Visit])
BEGIN
    DECLARE @StatusID int =
        (SELECT TOP (1) ID_Status_Visit FROM dbo.Status_Visit WHERE Name LIKE N'Ожида%' ORDER BY ID_Status_Visit);

    IF OBJECT_ID(N'tempdb..#Clients')  IS NOT NULL DROP TABLE #Clients;
    IF OBJECT_ID(N'tempdb..#Barbers')  IS NOT NULL DROP TABLE #Barbers;
    IF OBJECT_ID(N'tempdb..#Services') IS NOT NULL DROP TABLE #Services;

    SELECT ROW_NUMBER() OVER (ORDER BY ID_Client) - 1 AS rn, ID_Client
    INTO #Clients FROM dbo.Client;

    SELECT ROW_NUMBER() OVER (ORDER BY e.ID_Employee) - 1 AS rn, e.ID_Employee
    INTO #Barbers
    FROM dbo.Employee e
    WHERE ISNULL(e.IsActive, 1) = 1
      AND (   EXISTS (SELECT 1 FROM dbo.Role r WHERE r.ID_Role = e.ID_Role AND r.Name LIKE N'%арбер%')
           OR EXISTS (SELECT 1 FROM dbo.Barber_Specialization bs WHERE bs.ID_Barber = e.ID_Employee));

    SELECT ROW_NUMBER() OVER (ORDER BY ID_Service) - 1 AS rn, ID_Service, Price, Duration
    INTO #Services
    FROM dbo.Service
    WHERE Price IS NOT NULL AND Duration BETWEEN 1 AND 120;

    DECLARE @ClientCnt int  = (SELECT COUNT(*) FROM #Clients);
    DECLARE @BarberCnt int  = (SELECT COUNT(*) FROM #Barbers);
    DECLARE @ServiceCnt int = (SELECT COUNT(*) FROM #Services);
    DECLARE @BaseID int     = ISNULL((SELECT MAX(ID_Visit) FROM dbo.Visit), 0);
    DECLARE @Today date     = CAST(GETDATE() AS date);

    IF @StatusID IS NOT NULL AND @ClientCnt > 0 AND @BarberCnt > 0 AND @ServiceCnt > 0
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            /* ===== сегодня + 1 дн. ===== */
            -- Визит 1: день +1, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 1,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3813 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3638 % @BarberCnt),
                   DATEADD(DAY, 1, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4107 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 1, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4107 % @ServiceCnt;

            -- Визит 2: день +1, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 2,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3814 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 920 % @BarberCnt),
                   DATEADD(DAY, 1, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5111 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 2, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5111 % @ServiceCnt;

            -- Визит 3: день +1, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 3,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3815 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2069 % @BarberCnt),
                   DATEADD(DAY, 1, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8576 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 3, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8576 % @ServiceCnt;

            /* ===== сегодня + 2 дн. ===== */
            -- Визит 4: день +2, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 4,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4654 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5077 % @BarberCnt),
                   DATEADD(DAY, 2, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3923 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 4, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3923 % @ServiceCnt;

            -- Визит 5: день +2, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 5,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4655 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6332 % @BarberCnt),
                   DATEADD(DAY, 2, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8377 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 5, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8377 % @ServiceCnt;

            -- Визит 6: день +2, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 6,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4656 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7942 % @BarberCnt),
                   DATEADD(DAY, 2, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1789 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 6, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1789 % @ServiceCnt;

            /* ===== сегодня + 3 дн. ===== */
            -- Визит 7: день +3, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 7,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6435 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9043 % @BarberCnt),
                   DATEADD(DAY, 3, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7504 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 7, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7504 % @ServiceCnt;

            -- Визит 8: день +3, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 8,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6436 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1163 % @BarberCnt),
                   DATEADD(DAY, 3, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 374 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 8, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 374 % @ServiceCnt;

            -- Визит 9: день +3, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 9,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6437 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8040 % @BarberCnt),
                   DATEADD(DAY, 3, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6339 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 9, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6339 % @ServiceCnt;

            /* ===== сегодня + 4 дн. ===== */
            -- Визит 10: день +4, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 10,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4062 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 943 % @BarberCnt),
                   DATEADD(DAY, 4, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6790 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 10, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6790 % @ServiceCnt;

            -- Визит 11: день +4, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 11,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4063 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2263 % @BarberCnt),
                   DATEADD(DAY, 4, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 267 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 11, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 267 % @ServiceCnt;

            -- Визит 12: день +4, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 12,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4064 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9221 % @BarberCnt),
                   DATEADD(DAY, 4, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7185 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 12, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7185 % @ServiceCnt;

            /* ===== сегодня + 5 дн. ===== */
            -- Визит 13: день +5, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 13,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3665 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3204 % @BarberCnt),
                   DATEADD(DAY, 5, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6837 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 13, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6837 % @ServiceCnt;

            -- Визит 14: день +5, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 14,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3666 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8841 % @BarberCnt),
                   DATEADD(DAY, 5, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1787 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 14, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1787 % @ServiceCnt;

            -- Визит 15: день +5, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 15,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3667 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2121 % @BarberCnt),
                   DATEADD(DAY, 5, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7143 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 15, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7143 % @ServiceCnt;

            /* ===== сегодня + 6 дн. ===== */
            -- Визит 16: день +6, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 16,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7088 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2026 % @BarberCnt),
                   DATEADD(DAY, 6, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9565 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 16, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9565 % @ServiceCnt;

            -- Визит 17: день +6, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 17,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7089 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8478 % @BarberCnt),
                   DATEADD(DAY, 6, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9919 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 17, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9919 % @ServiceCnt;

            -- Визит 18: день +6, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 18,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7090 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6332 % @BarberCnt),
                   DATEADD(DAY, 6, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9783 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 18, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9783 % @ServiceCnt;

            /* ===== сегодня + 7 дн. ===== */
            -- Визит 19: день +7, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 19,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6426 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4577 % @BarberCnt),
                   DATEADD(DAY, 7, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1973 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 19, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1973 % @ServiceCnt;

            -- Визит 20: день +7, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 20,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6427 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4772 % @BarberCnt),
                   DATEADD(DAY, 7, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1902 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 20, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1902 % @ServiceCnt;

            -- Визит 21: день +7, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 21,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6428 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7973 % @BarberCnt),
                   DATEADD(DAY, 7, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6799 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 21, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6799 % @ServiceCnt;

            /* ===== сегодня + 8 дн. ===== */
            -- Визит 22: день +8, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 22,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4609 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 208 % @BarberCnt),
                   DATEADD(DAY, 8, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3232 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 22, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3232 % @ServiceCnt;

            -- Визит 23: день +8, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 23,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4610 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2622 % @BarberCnt),
                   DATEADD(DAY, 8, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 608 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 23, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 608 % @ServiceCnt;

            -- Визит 24: день +8, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 24,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4611 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 339 % @BarberCnt),
                   DATEADD(DAY, 8, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1467 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 24, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1467 % @ServiceCnt;

            /* ===== сегодня + 9 дн. ===== */
            -- Визит 25: день +9, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 25,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5931 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3739 % @BarberCnt),
                   DATEADD(DAY, 9, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 490 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 25, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 490 % @ServiceCnt;

            -- Визит 26: день +9, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 26,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5932 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8771 % @BarberCnt),
                   DATEADD(DAY, 9, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7395 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 26, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7395 % @ServiceCnt;

            -- Визит 27: день +9, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 27,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5933 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5256 % @BarberCnt),
                   DATEADD(DAY, 9, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7723 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 27, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7723 % @ServiceCnt;

            /* ===== сегодня + 10 дн. ===== */
            -- Визит 28: день +10, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 28,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9671 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5324 % @BarberCnt),
                   DATEADD(DAY, 10, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8037 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 28, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8037 % @ServiceCnt;

            -- Визит 29: день +10, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 29,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9672 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2012 % @BarberCnt),
                   DATEADD(DAY, 10, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9850 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 29, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9850 % @ServiceCnt;

            -- Визит 30: день +10, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 30,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9673 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9375 % @BarberCnt),
                   DATEADD(DAY, 10, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6986 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 30, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6986 % @ServiceCnt;

            /* ===== сегодня + 11 дн. ===== */
            -- Визит 31: день +11, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 31,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2959 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8736 % @BarberCnt),
                   DATEADD(DAY, 11, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2295 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 31, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2295 % @ServiceCnt;

            -- Визит 32: день +11, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 32,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2960 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2837 % @BarberCnt),
                   DATEADD(DAY, 11, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2539 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 32, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2539 % @ServiceCnt;

            -- Визит 33: день +11, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 33,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2961 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9730 % @BarberCnt),
                   DATEADD(DAY, 11, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2837 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 33, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2837 % @ServiceCnt;

            /* ===== сегодня + 12 дн. ===== */
            -- Визит 34: день +12, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 34,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5528 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1548 % @BarberCnt),
                   DATEADD(DAY, 12, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3506 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 34, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3506 % @ServiceCnt;

            -- Визит 35: день +12, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 35,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5529 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8568 % @BarberCnt),
                   DATEADD(DAY, 12, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7070 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 35, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7070 % @ServiceCnt;

            -- Визит 36: день +12, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 36,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5530 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9108 % @BarberCnt),
                   DATEADD(DAY, 12, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1345 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 36, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1345 % @ServiceCnt;

            /* ===== сегодня + 13 дн. ===== */
            -- Визит 37: день +13, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 37,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1764 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9211 % @BarberCnt),
                   DATEADD(DAY, 13, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4050 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 37, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4050 % @ServiceCnt;

            -- Визит 38: день +13, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 38,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1765 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4613 % @BarberCnt),
                   DATEADD(DAY, 13, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5782 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 38, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5782 % @ServiceCnt;

            -- Визит 39: день +13, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 39,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1766 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8074 % @BarberCnt),
                   DATEADD(DAY, 13, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8344 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 39, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8344 % @ServiceCnt;

            /* ===== сегодня + 14 дн. ===== */
            -- Визит 40: день +14, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 40,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 152 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2150 % @BarberCnt),
                   DATEADD(DAY, 14, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1980 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 40, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1980 % @ServiceCnt;

            -- Визит 41: день +14, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 41,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 153 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2269 % @BarberCnt),
                   DATEADD(DAY, 14, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6407 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 41, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6407 % @ServiceCnt;

            -- Визит 42: день +14, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 42,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 154 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2221 % @BarberCnt),
                   DATEADD(DAY, 14, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8959 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 42, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8959 % @ServiceCnt;

            /* ===== сегодня + 15 дн. ===== */
            -- Визит 43: день +15, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 43,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6469 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7999 % @BarberCnt),
                   DATEADD(DAY, 15, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2811 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 43, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2811 % @ServiceCnt;

            -- Визит 44: день +15, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 44,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6470 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4440 % @BarberCnt),
                   DATEADD(DAY, 15, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5545 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 44, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5545 % @ServiceCnt;

            -- Визит 45: день +15, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 45,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6471 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7340 % @BarberCnt),
                   DATEADD(DAY, 15, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4417 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 45, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4417 % @ServiceCnt;

            /* ===== сегодня + 16 дн. ===== */
            -- Визит 46: день +16, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 46,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3959 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7010 % @BarberCnt),
                   DATEADD(DAY, 16, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5093 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 46, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5093 % @ServiceCnt;

            -- Визит 47: день +16, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 47,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3960 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 221 % @BarberCnt),
                   DATEADD(DAY, 16, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3250 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 47, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3250 % @ServiceCnt;

            -- Визит 48: день +16, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 48,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3961 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 25 % @BarberCnt),
                   DATEADD(DAY, 16, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9567 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 48, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9567 % @ServiceCnt;

            /* ===== сегодня + 17 дн. ===== */
            -- Визит 49: день +17, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 49,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9313 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8036 % @BarberCnt),
                   DATEADD(DAY, 17, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2920 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 49, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2920 % @ServiceCnt;

            -- Визит 50: день +17, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 50,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9314 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2543 % @BarberCnt),
                   DATEADD(DAY, 17, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1172 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 50, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1172 % @ServiceCnt;

            -- Визит 51: день +17, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 51,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9315 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6678 % @BarberCnt),
                   DATEADD(DAY, 17, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9600 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 51, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9600 % @ServiceCnt;

            /* ===== сегодня + 18 дн. ===== */
            -- Визит 52: день +18, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 52,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1670 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9854 % @BarberCnt),
                   DATEADD(DAY, 18, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 290 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 52, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 290 % @ServiceCnt;

            -- Визит 53: день +18, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 53,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1671 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5828 % @BarberCnt),
                   DATEADD(DAY, 18, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4264 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 53, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4264 % @ServiceCnt;

            -- Визит 54: день +18, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 54,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1672 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5576 % @BarberCnt),
                   DATEADD(DAY, 18, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8347 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 54, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8347 % @ServiceCnt;

            /* ===== сегодня + 19 дн. ===== */
            -- Визит 55: день +19, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 55,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 761 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9847 % @BarberCnt),
                   DATEADD(DAY, 19, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5410 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 55, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5410 % @ServiceCnt;

            -- Визит 56: день +19, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 56,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 762 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2624 % @BarberCnt),
                   DATEADD(DAY, 19, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1553 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 56, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1553 % @ServiceCnt;

            -- Визит 57: день +19, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 57,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 763 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 750 % @BarberCnt),
                   DATEADD(DAY, 19, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8092 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 57, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8092 % @ServiceCnt;

            /* ===== сегодня + 20 дн. ===== */
            -- Визит 58: день +20, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 58,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5999 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5220 % @BarberCnt),
                   DATEADD(DAY, 20, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7161 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 58, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7161 % @ServiceCnt;

            -- Визит 59: день +20, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 59,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6000 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8144 % @BarberCnt),
                   DATEADD(DAY, 20, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1780 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 59, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1780 % @ServiceCnt;

            -- Визит 60: день +20, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 60,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6001 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9641 % @BarberCnt),
                   DATEADD(DAY, 20, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6419 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 60, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6419 % @ServiceCnt;

            /* ===== сегодня + 21 дн. ===== */
            -- Визит 61: день +21, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 61,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5265 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7127 % @BarberCnt),
                   DATEADD(DAY, 21, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2335 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 61, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2335 % @ServiceCnt;

            -- Визит 62: день +21, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 62,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5266 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9749 % @BarberCnt),
                   DATEADD(DAY, 21, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1062 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 62, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1062 % @ServiceCnt;

            -- Визит 63: день +21, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 63,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5267 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5178 % @BarberCnt),
                   DATEADD(DAY, 21, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5477 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 63, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5477 % @ServiceCnt;

            /* ===== сегодня + 22 дн. ===== */
            -- Визит 64: день +22, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 64,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7949 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7509 % @BarberCnt),
                   DATEADD(DAY, 22, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3332 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 64, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3332 % @ServiceCnt;

            -- Визит 65: день +22, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 65,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7950 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9278 % @BarberCnt),
                   DATEADD(DAY, 22, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1174 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 65, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1174 % @ServiceCnt;

            -- Визит 66: день +22, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 66,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7951 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8784 % @BarberCnt),
                   DATEADD(DAY, 22, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5799 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 66, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5799 % @ServiceCnt;

            /* ===== сегодня + 23 дн. ===== */
            -- Визит 67: день +23, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 67,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1616 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1593 % @BarberCnt),
                   DATEADD(DAY, 23, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1274 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 67, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1274 % @ServiceCnt;

            -- Визит 68: день +23, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 68,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1617 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9872 % @BarberCnt),
                   DATEADD(DAY, 23, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1312 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 68, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1312 % @ServiceCnt;

            -- Визит 69: день +23, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 69,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1618 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5214 % @BarberCnt),
                   DATEADD(DAY, 23, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8788 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 69, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8788 % @ServiceCnt;

            /* ===== сегодня + 24 дн. ===== */
            -- Визит 70: день +24, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 70,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1083 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7969 % @BarberCnt),
                   DATEADD(DAY, 24, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5676 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 70, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5676 % @ServiceCnt;

            -- Визит 71: день +24, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 71,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1084 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2642 % @BarberCnt),
                   DATEADD(DAY, 24, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9742 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 71, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9742 % @ServiceCnt;

            -- Визит 72: день +24, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 72,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1085 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3769 % @BarberCnt),
                   DATEADD(DAY, 24, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7610 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 72, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7610 % @ServiceCnt;

            /* ===== сегодня + 25 дн. ===== */
            -- Визит 73: день +25, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 73,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1859 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7088 % @BarberCnt),
                   DATEADD(DAY, 25, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 21 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 73, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 21 % @ServiceCnt;

            -- Визит 74: день +25, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 74,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1860 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5961 % @BarberCnt),
                   DATEADD(DAY, 25, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2490 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 74, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2490 % @ServiceCnt;

            -- Визит 75: день +25, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 75,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1861 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4305 % @BarberCnt),
                   DATEADD(DAY, 25, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3509 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 75, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3509 % @ServiceCnt;

            /* ===== сегодня + 26 дн. ===== */
            -- Визит 76: день +26, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 76,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6069 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3849 % @BarberCnt),
                   DATEADD(DAY, 26, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6452 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 76, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6452 % @ServiceCnt;

            -- Визит 77: день +26, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 77,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6070 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4950 % @BarberCnt),
                   DATEADD(DAY, 26, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7826 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 77, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7826 % @ServiceCnt;

            -- Визит 78: день +26, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 78,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6071 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9780 % @BarberCnt),
                   DATEADD(DAY, 26, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1752 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 78, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1752 % @ServiceCnt;

            /* ===== сегодня + 27 дн. ===== */
            -- Визит 79: день +27, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 79,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3583 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2210 % @BarberCnt),
                   DATEADD(DAY, 27, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5899 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 79, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5899 % @ServiceCnt;

            -- Визит 80: день +27, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 80,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3584 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9109 % @BarberCnt),
                   DATEADD(DAY, 27, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6086 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 80, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6086 % @ServiceCnt;

            -- Визит 81: день +27, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 81,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3585 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7777 % @BarberCnt),
                   DATEADD(DAY, 27, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2025 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 81, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2025 % @ServiceCnt;

            /* ===== сегодня + 28 дн. ===== */
            -- Визит 82: день +28, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 82,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 972 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8176 % @BarberCnt),
                   DATEADD(DAY, 28, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1101 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 82, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1101 % @ServiceCnt;

            -- Визит 83: день +28, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 83,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 973 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5418 % @BarberCnt),
                   DATEADD(DAY, 28, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1443 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 83, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1443 % @ServiceCnt;

            -- Визит 84: день +28, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 84,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 974 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2633 % @BarberCnt),
                   DATEADD(DAY, 28, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2724 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 84, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2724 % @ServiceCnt;

            /* ===== сегодня + 29 дн. ===== */
            -- Визит 85: день +29, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 85,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1292 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6500 % @BarberCnt),
                   DATEADD(DAY, 29, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7646 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 85, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7646 % @ServiceCnt;

            -- Визит 86: день +29, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 86,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1293 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1067 % @BarberCnt),
                   DATEADD(DAY, 29, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7710 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 86, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7710 % @ServiceCnt;

            -- Визит 87: день +29, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 87,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1294 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1157 % @BarberCnt),
                   DATEADD(DAY, 29, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8958 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 87, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8958 % @ServiceCnt;

            /* ===== сегодня + 30 дн. ===== */
            -- Визит 88: день +30, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 88,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7975 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7331 % @BarberCnt),
                   DATEADD(DAY, 30, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2528 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 88, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2528 % @ServiceCnt;

            -- Визит 89: день +30, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 89,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7976 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2048 % @BarberCnt),
                   DATEADD(DAY, 30, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1408 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 89, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1408 % @ServiceCnt;

            -- Визит 90: день +30, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 90,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7977 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3398 % @BarberCnt),
                   DATEADD(DAY, 30, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8301 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 90, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8301 % @ServiceCnt;

            /* ===== сегодня + 31 дн. ===== */
            -- Визит 91: день +31, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 91,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2524 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9828 % @BarberCnt),
                   DATEADD(DAY, 31, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7962 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 91, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7962 % @ServiceCnt;

            -- Визит 92: день +31, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 92,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2525 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8138 % @BarberCnt),
                   DATEADD(DAY, 31, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8315 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 92, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8315 % @ServiceCnt;

            -- Визит 93: день +31, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 93,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2526 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5704 % @BarberCnt),
                   DATEADD(DAY, 31, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9800 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 93, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9800 % @ServiceCnt;

            /* ===== сегодня + 32 дн. ===== */
            -- Визит 94: день +32, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 94,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3084 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6002 % @BarberCnt),
                   DATEADD(DAY, 32, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8344 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 94, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8344 % @ServiceCnt;

            -- Визит 95: день +32, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 95,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3085 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2624 % @BarberCnt),
                   DATEADD(DAY, 32, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5170 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 95, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5170 % @ServiceCnt;

            -- Визит 96: день +32, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 96,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3086 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3223 % @BarberCnt),
                   DATEADD(DAY, 32, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7269 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 96, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7269 % @ServiceCnt;

            /* ===== сегодня + 33 дн. ===== */
            -- Визит 97: день +33, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 97,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2410 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8973 % @BarberCnt),
                   DATEADD(DAY, 33, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8675 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 97, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8675 % @ServiceCnt;

            -- Визит 98: день +33, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 98,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2411 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1987 % @BarberCnt),
                   DATEADD(DAY, 33, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8308 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 98, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8308 % @ServiceCnt;

            -- Визит 99: день +33, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 99,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2412 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1331 % @BarberCnt),
                   DATEADD(DAY, 33, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1304 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 99, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1304 % @ServiceCnt;

            /* ===== сегодня + 34 дн. ===== */
            -- Визит 100: день +34, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 100,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8302 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5782 % @BarberCnt),
                   DATEADD(DAY, 34, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1416 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 100, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1416 % @ServiceCnt;

            -- Визит 101: день +34, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 101,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8303 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9828 % @BarberCnt),
                   DATEADD(DAY, 34, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6026 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 101, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6026 % @ServiceCnt;

            -- Визит 102: день +34, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 102,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8304 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1240 % @BarberCnt),
                   DATEADD(DAY, 34, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5424 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 102, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5424 % @ServiceCnt;

            /* ===== сегодня + 35 дн. ===== */
            -- Визит 103: день +35, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 103,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1101 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5487 % @BarberCnt),
                   DATEADD(DAY, 35, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4884 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 103, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4884 % @ServiceCnt;

            -- Визит 104: день +35, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 104,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1102 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5480 % @BarberCnt),
                   DATEADD(DAY, 35, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9600 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 104, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9600 % @ServiceCnt;

            -- Визит 105: день +35, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 105,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1103 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3112 % @BarberCnt),
                   DATEADD(DAY, 35, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5687 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 105, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5687 % @ServiceCnt;

            /* ===== сегодня + 36 дн. ===== */
            -- Визит 106: день +36, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 106,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4900 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4959 % @BarberCnt),
                   DATEADD(DAY, 36, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2810 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 106, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2810 % @ServiceCnt;

            -- Визит 107: день +36, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 107,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4901 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3194 % @BarberCnt),
                   DATEADD(DAY, 36, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2099 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 107, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2099 % @ServiceCnt;

            -- Визит 108: день +36, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 108,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4902 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1164 % @BarberCnt),
                   DATEADD(DAY, 36, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4635 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 108, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4635 % @ServiceCnt;

            /* ===== сегодня + 37 дн. ===== */
            -- Визит 109: день +37, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 109,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9018 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6576 % @BarberCnt),
                   DATEADD(DAY, 37, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7174 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 109, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7174 % @ServiceCnt;

            -- Визит 110: день +37, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 110,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9019 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4813 % @BarberCnt),
                   DATEADD(DAY, 37, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7912 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 110, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7912 % @ServiceCnt;

            -- Визит 111: день +37, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 111,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9020 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 943 % @BarberCnt),
                   DATEADD(DAY, 37, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3667 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 111, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3667 % @ServiceCnt;

            /* ===== сегодня + 38 дн. ===== */
            -- Визит 112: день +38, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 112,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7771 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 285 % @BarberCnt),
                   DATEADD(DAY, 38, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 101 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 112, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 101 % @ServiceCnt;

            -- Визит 113: день +38, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 113,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7772 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1003 % @BarberCnt),
                   DATEADD(DAY, 38, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9963 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 113, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9963 % @ServiceCnt;

            -- Визит 114: день +38, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 114,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7773 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6335 % @BarberCnt),
                   DATEADD(DAY, 38, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9737 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 114, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9737 % @ServiceCnt;

            /* ===== сегодня + 39 дн. ===== */
            -- Визит 115: день +39, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 115,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6999 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1659 % @BarberCnt),
                   DATEADD(DAY, 39, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2896 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 115, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2896 % @ServiceCnt;

            -- Визит 116: день +39, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 116,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7000 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8062 % @BarberCnt),
                   DATEADD(DAY, 39, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8501 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 116, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8501 % @ServiceCnt;

            -- Визит 117: день +39, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 117,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7001 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 103 % @BarberCnt),
                   DATEADD(DAY, 39, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7401 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 117, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7401 % @ServiceCnt;

            /* ===== сегодня + 40 дн. ===== */
            -- Визит 118: день +40, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 118,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2040 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5486 % @BarberCnt),
                   DATEADD(DAY, 40, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3945 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 118, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3945 % @ServiceCnt;

            -- Визит 119: день +40, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 119,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2041 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9808 % @BarberCnt),
                   DATEADD(DAY, 40, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7560 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 119, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7560 % @ServiceCnt;

            -- Визит 120: день +40, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 120,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2042 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9067 % @BarberCnt),
                   DATEADD(DAY, 40, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7291 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 120, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7291 % @ServiceCnt;

            /* ===== сегодня + 41 дн. ===== */
            -- Визит 121: день +41, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 121,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4335 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7308 % @BarberCnt),
                   DATEADD(DAY, 41, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9071 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 121, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9071 % @ServiceCnt;

            -- Визит 122: день +41, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 122,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4336 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4796 % @BarberCnt),
                   DATEADD(DAY, 41, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6652 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 122, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6652 % @ServiceCnt;

            -- Визит 123: день +41, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 123,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4337 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9662 % @BarberCnt),
                   DATEADD(DAY, 41, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1911 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 123, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1911 % @ServiceCnt;

            /* ===== сегодня + 42 дн. ===== */
            -- Визит 124: день +42, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 124,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5058 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6561 % @BarberCnt),
                   DATEADD(DAY, 42, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3022 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 124, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3022 % @ServiceCnt;

            -- Визит 125: день +42, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 125,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5059 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2708 % @BarberCnt),
                   DATEADD(DAY, 42, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3294 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 125, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3294 % @ServiceCnt;

            -- Визит 126: день +42, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 126,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5060 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5797 % @BarberCnt),
                   DATEADD(DAY, 42, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2844 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 126, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2844 % @ServiceCnt;

            /* ===== сегодня + 43 дн. ===== */
            -- Визит 127: день +43, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 127,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2019 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9233 % @BarberCnt),
                   DATEADD(DAY, 43, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3349 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 127, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3349 % @ServiceCnt;

            -- Визит 128: день +43, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 128,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2020 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1351 % @BarberCnt),
                   DATEADD(DAY, 43, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2590 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 128, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2590 % @ServiceCnt;

            -- Визит 129: день +43, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 129,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2021 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6429 % @BarberCnt),
                   DATEADD(DAY, 43, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 957 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 129, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 957 % @ServiceCnt;

            /* ===== сегодня + 44 дн. ===== */
            -- Визит 130: день +44, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 130,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2394 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7190 % @BarberCnt),
                   DATEADD(DAY, 44, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3518 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 130, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3518 % @ServiceCnt;

            -- Визит 131: день +44, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 131,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2395 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5909 % @BarberCnt),
                   DATEADD(DAY, 44, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2328 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 131, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2328 % @ServiceCnt;

            -- Визит 132: день +44, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 132,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2396 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 783 % @BarberCnt),
                   DATEADD(DAY, 44, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2500 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 132, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2500 % @ServiceCnt;

            /* ===== сегодня + 45 дн. ===== */
            -- Визит 133: день +45, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 133,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7942 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4833 % @BarberCnt),
                   DATEADD(DAY, 45, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8610 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 133, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8610 % @ServiceCnt;

            -- Визит 134: день +45, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 134,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7943 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5336 % @BarberCnt),
                   DATEADD(DAY, 45, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8663 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 134, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8663 % @ServiceCnt;

            -- Визит 135: день +45, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 135,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 7944 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5285 % @BarberCnt),
                   DATEADD(DAY, 45, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3383 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 135, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3383 % @ServiceCnt;

            /* ===== сегодня + 46 дн. ===== */
            -- Визит 136: день +46, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 136,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3231 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9812 % @BarberCnt),
                   DATEADD(DAY, 46, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9611 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 136, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9611 % @ServiceCnt;

            -- Визит 137: день +46, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 137,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3232 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9713 % @BarberCnt),
                   DATEADD(DAY, 46, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7642 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 137, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7642 % @ServiceCnt;

            -- Визит 138: день +46, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 138,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3233 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4866 % @BarberCnt),
                   DATEADD(DAY, 46, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 178 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 138, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 178 % @ServiceCnt;

            /* ===== сегодня + 47 дн. ===== */
            -- Визит 139: день +47, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 139,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5591 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 9836 % @BarberCnt),
                   DATEADD(DAY, 47, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1090 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 139, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1090 % @ServiceCnt;

            -- Визит 140: день +47, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 140,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5592 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4546 % @BarberCnt),
                   DATEADD(DAY, 47, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3282 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 140, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3282 % @ServiceCnt;

            -- Визит 141: день +47, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 141,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5593 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1456 % @BarberCnt),
                   DATEADD(DAY, 47, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6803 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 141, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6803 % @ServiceCnt;

            /* ===== сегодня + 48 дн. ===== */
            -- Визит 142: день +48, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 142,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9354 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5300 % @BarberCnt),
                   DATEADD(DAY, 48, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3944 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 142, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3944 % @ServiceCnt;

            -- Визит 143: день +48, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 143,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9355 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6419 % @BarberCnt),
                   DATEADD(DAY, 48, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7122 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 143, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7122 % @ServiceCnt;

            -- Визит 144: день +48, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 144,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9356 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4747 % @BarberCnt),
                   DATEADD(DAY, 48, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8709 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 144, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8709 % @ServiceCnt;

            /* ===== сегодня + 49 дн. ===== */
            -- Визит 145: день +49, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 145,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9376 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 146 % @BarberCnt),
                   DATEADD(DAY, 49, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7434 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 145, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7434 % @ServiceCnt;

            -- Визит 146: день +49, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 146,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9377 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3649 % @BarberCnt),
                   DATEADD(DAY, 49, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1894 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 146, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1894 % @ServiceCnt;

            -- Визит 147: день +49, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 147,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9378 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6317 % @BarberCnt),
                   DATEADD(DAY, 49, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8272 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 147, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8272 % @ServiceCnt;

            /* ===== сегодня + 50 дн. ===== */
            -- Визит 148: день +50, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 148,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 79 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4464 % @BarberCnt),
                   DATEADD(DAY, 50, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3057 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 148, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3057 % @ServiceCnt;

            -- Визит 149: день +50, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 149,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 80 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6832 % @BarberCnt),
                   DATEADD(DAY, 50, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4069 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 149, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4069 % @ServiceCnt;

            -- Визит 150: день +50, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 150,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 81 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1756 % @BarberCnt),
                   DATEADD(DAY, 50, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3272 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 150, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3272 % @ServiceCnt;

            /* ===== сегодня + 51 дн. ===== */
            -- Визит 151: день +51, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 151,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3761 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2576 % @BarberCnt),
                   DATEADD(DAY, 51, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6396 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 151, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6396 % @ServiceCnt;

            -- Визит 152: день +51, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 152,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3762 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8644 % @BarberCnt),
                   DATEADD(DAY, 51, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3257 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 152, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3257 % @ServiceCnt;

            -- Визит 153: день +51, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 153,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 3763 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2041 % @BarberCnt),
                   DATEADD(DAY, 51, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1688 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 153, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1688 % @ServiceCnt;

            /* ===== сегодня + 52 дн. ===== */
            -- Визит 154: день +52, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 154,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9818 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7319 % @BarberCnt),
                   DATEADD(DAY, 52, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7407 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 154, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7407 % @ServiceCnt;

            -- Визит 155: день +52, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 155,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9819 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1720 % @BarberCnt),
                   DATEADD(DAY, 52, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 1112 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 155, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 1112 % @ServiceCnt;

            -- Визит 156: день +52, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 156,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 9820 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6811 % @BarberCnt),
                   DATEADD(DAY, 52, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 2188 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 156, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 2188 % @ServiceCnt;

            /* ===== сегодня + 53 дн. ===== */
            -- Визит 157: день +53, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 157,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5054 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6217 % @BarberCnt),
                   DATEADD(DAY, 53, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9431 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 157, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9431 % @ServiceCnt;

            -- Визит 158: день +53, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 158,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5055 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 4582 % @BarberCnt),
                   DATEADD(DAY, 53, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4466 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 158, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4466 % @ServiceCnt;

            -- Визит 159: день +53, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 159,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5056 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 2120 % @BarberCnt),
                   DATEADD(DAY, 53, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9791 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 159, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9791 % @ServiceCnt;

            /* ===== сегодня + 54 дн. ===== */
            -- Визит 160: день +54, 10:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 160,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6444 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1003 % @BarberCnt),
                   DATEADD(DAY, 54, @Today), '10:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4043 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 160, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4043 % @ServiceCnt;

            -- Визит 161: день +54, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 161,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6445 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 838 % @BarberCnt),
                   DATEADD(DAY, 54, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4744 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 161, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4744 % @ServiceCnt;

            -- Визит 162: день +54, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 162,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6446 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3883 % @BarberCnt),
                   DATEADD(DAY, 54, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5898 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 162, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5898 % @ServiceCnt;

            /* ===== сегодня + 55 дн. ===== */
            -- Визит 163: день +55, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 163,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1486 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1945 % @BarberCnt),
                   DATEADD(DAY, 55, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5175 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 163, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5175 % @ServiceCnt;

            -- Визит 164: день +55, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 164,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1487 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3754 % @BarberCnt),
                   DATEADD(DAY, 55, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8408 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 164, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8408 % @ServiceCnt;

            -- Визит 165: день +55, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 165,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 1488 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7296 % @BarberCnt),
                   DATEADD(DAY, 55, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3578 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 165, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3578 % @ServiceCnt;

            /* ===== сегодня + 56 дн. ===== */
            -- Визит 166: день +56, 10:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 166,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8518 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 515 % @BarberCnt),
                   DATEADD(DAY, 56, @Today), '10:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8389 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 166, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8389 % @ServiceCnt;

            -- Визит 167: день +56, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 167,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8519 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5225 % @BarberCnt),
                   DATEADD(DAY, 56, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3449 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 167, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3449 % @ServiceCnt;

            -- Визит 168: день +56, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 168,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8520 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3700 % @BarberCnt),
                   DATEADD(DAY, 56, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 654 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 168, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 654 % @ServiceCnt;

            /* ===== сегодня + 57 дн. ===== */
            -- Визит 169: день +57, 09:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 169,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2461 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 7773 % @BarberCnt),
                   DATEADD(DAY, 57, @Today), '09:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3958 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 169, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3958 % @ServiceCnt;

            -- Визит 170: день +57, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 170,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2462 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5909 % @BarberCnt),
                   DATEADD(DAY, 57, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3878 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 170, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3878 % @ServiceCnt;

            -- Визит 171: день +57, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 171,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 2463 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 705 % @BarberCnt),
                   DATEADD(DAY, 57, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4121 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 171, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4121 % @ServiceCnt;

            /* ===== сегодня + 58 дн. ===== */
            -- Визит 172: день +58, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 172,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8693 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3773 % @BarberCnt),
                   DATEADD(DAY, 58, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 6364 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 172, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 6364 % @ServiceCnt;

            -- Визит 173: день +58, 14:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 173,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8694 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3864 % @BarberCnt),
                   DATEADD(DAY, 58, @Today), '14:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4795 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 173, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4795 % @ServiceCnt;

            -- Визит 174: день +58, 18:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 174,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 8695 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1881 % @BarberCnt),
                   DATEADD(DAY, 58, @Today), '18:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7238 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 174, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7238 % @ServiceCnt;

            /* ===== сегодня + 59 дн. ===== */
            -- Визит 175: день +59, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 175,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6513 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 6423 % @BarberCnt),
                   DATEADD(DAY, 59, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 7047 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 175, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 7047 % @ServiceCnt;

            -- Визит 176: день +59, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 176,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6514 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3150 % @BarberCnt),
                   DATEADD(DAY, 59, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4893 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 176, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4893 % @ServiceCnt;

            -- Визит 177: день +59, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 177,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 6515 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 780 % @BarberCnt),
                   DATEADD(DAY, 59, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4512 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 177, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4512 % @ServiceCnt;

            /* ===== сегодня + 60 дн. ===== */
            -- Визит 178: день +60, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 178,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4500 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 5473 % @BarberCnt),
                   DATEADD(DAY, 60, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 9560 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 178, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 9560 % @ServiceCnt;

            -- Визит 179: день +60, 14:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 179,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4501 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8144 % @BarberCnt),
                   DATEADD(DAY, 60, @Today), '14:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 8369 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 179, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 8369 % @ServiceCnt;

            -- Визит 180: день +60, 17:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 180,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 4502 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 8359 % @BarberCnt),
                   DATEADD(DAY, 60, @Today), '17:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 4290 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 180, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 4290 % @ServiceCnt;

            /* ===== сегодня + 61 дн. ===== */
            -- Визит 181: день +61, 09:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 181,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5951 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 3193 % @BarberCnt),
                   DATEADD(DAY, 61, @Today), '09:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 3404 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 181, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 3404 % @ServiceCnt;

            -- Визит 182: день +61, 13:30
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 182,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5952 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 1087 % @BarberCnt),
                   DATEADD(DAY, 61, @Today), '13:30', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 5904 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 182, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 5904 % @ServiceCnt;

            -- Визит 183: день +61, 18:00
            INSERT INTO dbo.Visit (ID_Visit, ID_Client, ID_Barber, Visit_Date, Visit_Time, Total_Duration, Total_Price, ID_Status_Visit, Comment)
            SELECT @BaseID + 183,
                   (SELECT ID_Client   FROM #Clients WHERE rn = 5953 % @ClientCnt),
                   (SELECT ID_Employee FROM #Barbers WHERE rn = 732 % @BarberCnt),
                   DATEADD(DAY, 61, @Today), '18:00', s.Duration, s.Price, @StatusID, NULL
            FROM #Services s WHERE s.rn = 734 % @ServiceCnt;
            INSERT INTO dbo.Visit_Service (ID_Visit, ID_Service, Price)
            SELECT @BaseID + 183, s.ID_Service, s.Price FROM #Services s WHERE s.rn = 734 % @ServiceCnt;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH
    END

    DROP TABLE #Clients;
    DROP TABLE #Barbers;
    DROP TABLE #Services;
END
GO
