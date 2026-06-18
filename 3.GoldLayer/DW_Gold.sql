--Creating new schema
CREATE SCHEMA Gold;

-- Creating dimensions
-- Dimensión 1: Hotel
CREATE TABLE [DWHotel].[Gold].[dimHotel] 
(
	HotelID BIGINT NOT NULL,
	Hotel VARCHAR(8000) NOT NULL
);

INSERT INTO [DWHotel].[Gold].[dimHotel] (HotelID, Hotel)
SELECT 
	ROW_NUMBER() OVER (ORDER BY Hotel) AS HotelID,
	Hotel
FROM (
	SELECT DISTINCT Hotel
	FROM [DWHotel].[Silver].[DatosSilver]
	WHERE Hotel IS NOT NULL
) AS distinct_hotels;

-- Dimension 2: Client type
CREATE TABLE [DWHotel].[Gold].[dimClienteTipo] (
    TipoClienteID BIGINT,
    TipodeCliente VARCHAR(8000)
);

INSERT INTO [DWHotel].[Gold].[dimClienteTipo]
SELECT 
    ROW_NUMBER() OVER (ORDER BY TipodeCliente) AS TipoClienteID,
    TipodeCliente
FROM (
    SELECT DISTINCT TipodeCliente
    FROM [DWHotel].[Silver].[DatosSilver]
    WHERE TipodeCliente IS NOT NULL
) AS tipos;

-- Dimension 3: Country
CREATE TABLE [DWHotel].[Gold].[dimPais] (
    PaisID BIGINT,
    Pais VARCHAR(8000)
);

INSERT INTO [DWHotel].[Gold].[dimPais]
SELECT 
    ROW_NUMBER() OVER (ORDER BY País) AS PaisID,
    País
FROM (
    SELECT DISTINCT País
    FROM [DWHotel].[Silver].[DatosSilver]
    WHERE País IS NOT NULL
) AS paises;

-- Dimension 4: Channel
CREATE TABLE [DWHotel].[Gold].[dimCanal] (
    CanalID BIGINT,
    CanalDeDistribucion VARCHAR(8000)
);


INSERT INTO [DWHotel].[Gold].[dimCanal]
SELECT 
    ROW_NUMBER() OVER (ORDER BY [CanaldeDistribución]) AS CanalID,
    [CanaldeDistribución] 
FROM (
    SELECT DISTINCT [CanaldeDistribución]
    FROM [DWHotel].[Silver].[DatosSilver]
    WHERE [CanaldeDistribución] IS NOT NULL
) AS distinct_canales;
-- Dimension 5: Booking status
CREATE TABLE [DWHotel].[Gold].[dimEstadoReserva] (
    EstadoID BIGINT,
    Estado VARCHAR(8000)
);

INSERT INTO [DWHotel].[Gold].[dimEstadoReserva]
SELECT 
    ROW_NUMBER() OVER (ORDER BY Estado) AS EstadoID,
    Estado
FROM (
    SELECT DISTINCT Estado
    FROM [DWHotel].[Silver].[DatosSilver]
    WHERE Estado IS NOT NULL
) AS distinct_estados;

-- Dimension 6: Deposit type
CREATE TABLE [DWHotel].[Gold].[dimTipoDeposito] (
    TipoDepositoID BIGINT,
    TipodeDeposito VARCHAR(8000)
);


INSERT INTO [DWHotel].[Gold].[dimTipoDeposito]
SELECT 
    ROW_NUMBER() OVER (ORDER BY [TipodeDepósito]) AS TipoDepositoID,
    [TipodeDepósito] AS TipodeDeposito
FROM (
    SELECT DISTINCT [TipodeDepósito]
    FROM [DWHotel].[Silver].[DatosSilver]
    WHERE [TipodeDepósito] IS NOT NULL
) AS distinct_depositos;

-----Calendar dimension 
SELECT
    MIN([FechadeReserva]) AS MinFechadeReserva,
    MAX([FechadeReserva]) AS MaxFechadeReserva,
    MIN([FechadeLlegada]) AS MinFechadeLlegada,
    MAX([FechadeLlegada]) AS MaxFechadeLlegada
FROM [DWHSOLUCIONENDTOEND].[Silver].[DatosSilver]
WHERE [FechadeReserva] IS NOT NULL AND [FechadeLlegada] IS NOT NULL;

-- 2) Creating calendar table

CREATE TABLE [DWHotel].[Gold].[dimCalendario]
(
	[FechaClave] [int] NULL,
	[Fecha] [date] NULL,
	[Año] [int] NULL,
	[Mes] [int] NULL,
	[NombreMes] [varchar](20) NULL,
	[Trimestre] [int] NULL,
	[SemanaAño] [int] NULL,
	[NombreDia] [varchar](20) NULL,
	[DiaSemana] [int] NULL
)
GO

-- 3) Creating a stored procedure to generate it 
CREATE OR ALTER PROCEDURE [Gold].[sp_GenerarCalendario]
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete table
    DELETE FROM [DWHotel].[Gold].[dimCalendario];

    -- Generating dates
    WITH Numeros AS (
        SELECT TOP (DATEDIFF(DAY, @FechaInicio, @FechaFin) + 1)
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Num
        FROM (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) AS X(n)
        CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) AS Y(n)
        CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) AS Z(n)
        CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) AS W(n)
        CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) AS V(n)
    )

    INSERT INTO [DWHotel].[Gold].[dimCalendario] (
        FechaClave,
        Fecha,
        Año,
        Mes,
        NombreMes,
        Trimestre,
        SemanaAño,
        NombreDia,
        DiaSemana
    )
    SELECT DISTINCT
        CAST(FORMAT(DATEADD(DAY, Num, @FechaInicio), 'yyyyMMdd') AS INT) AS FechaClave,
        DATEADD(DAY, Num, @FechaInicio) AS Fecha,
        YEAR(DATEADD(DAY, Num, @FechaInicio)) AS Año,
        MONTH(DATEADD(DAY, Num, @FechaInicio)) AS Mes,
        DATENAME(MONTH, DATEADD(DAY, Num, @FechaInicio)) AS NombreMes,
        DATEPART(QUARTER, DATEADD(DAY, Num, @FechaInicio)) AS Trimestre,
        DATEPART(WEEK, DATEADD(DAY, Num, @FechaInicio)) AS SemanaAño,
        DATENAME(WEEKDAY, DATEADD(DAY, Num, @FechaInicio)) AS NombreDia,
        DATEPART(WEEKDAY, DATEADD(DAY, Num, @FechaInicio)) AS DiaSemana
    FROM Numeros;
END;
-- 3) Executing SP 
EXEC [Gold].[sp_GenerarCalendario] '2013-06-24', '2017-08-31';


--------
--------
-- Creating fact table
-------
-------
CREATE TABLE [DWHotel].[Gold].[factReservas] (
    ReservaID INT,
    FechaReservaID INT,
    FechaLlegadaID INT,
    ClienteTipoID BIGINT,
    CanalID BIGINT,
    EstadoID BIGINT,
    HotelID BIGINT,
    PaisID BIGINT,
    TipoDepositoID BIGINT,
    Anticipacion INT,
    Noches INT,
    Huespedes INT,
    TarifaMediaDiaria FLOAT,
    Cancelado INT,
    Ingresos FLOAT,
    PerdidaIngresos FLOAT
);

-- 2) Creating the fact table using our dimension tables
INSERT INTO [DWHotel].[Gold].[factReservas]
SELECT
    S.IDdeReserva AS ReservaID,
    C1.FechaClave AS FechaReservaID,
    C2.FechaClave AS FechaLlegadaID,
    CT.TipoClienteID,
    CA.CanalID,
    ER.EstadoID,
    H.HotelID,
    P.PaisID,
    TD.TipoDepositoID,
    S.Anticipación,
    S.Noches,
    S.Huéspedes,
    TRY_CAST(S.TarifaMediaDiaria AS FLOAT),
    S.Cancelado,
    TRY_CAST(S.Ingresos AS FLOAT),
    TRY_CAST(S.PérdidadIngresos AS FLOAT)
FROM [DWHotel].[Silver].[DatosSilver] AS S
-- Dates
LEFT JOIN [DWHotel].[Gold].[dimCalendario] AS C1
    ON C1.Fecha = S.FechadeReserva
LEFT JOIN [DWHotel].[Gold].[dimCalendario] AS C2
    ON C2.Fecha = S.FechadeLlegada
-- Dimensions
LEFT JOIN [DWHotel].[Gold].[dimClienteTipo] AS CT
    ON CT.TipodeCliente = S.TipodeCliente
LEFT JOIN [DWHotel].[Gold].[dimCanal] AS CA
    ON CA.CanalDeDistribucion = S.CanaldeDistribución
LEFT JOIN [DWHotel].[Gold].[dimEstadoReserva] AS ER
    ON ER.Estado = S.Estado
LEFT JOIN [DWHotel].[Gold].[dimHotel] AS H
    ON H.Hotel = S.Hotel
LEFT JOIN [DWHotel].[Gold].[dimPais] AS P
    ON P.Pais = S.País
LEFT JOIN [DWHotel].[Gold].[dimTipoDeposito] AS TD
    ON TD.TipodeDeposito = S.TipodeDepósito;



