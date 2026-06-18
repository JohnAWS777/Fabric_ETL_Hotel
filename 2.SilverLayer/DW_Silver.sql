-- We create a new schema known Silver
CREATE SCHEMA Silver;
-- Creating first table
CREATE TABLE [DWHotel].[Silver].[DatosSilver]
(
	[IDdeReserva] [int] NULL,
	[Hotel] [varchar](8000) NULL,
	[FechadeReserva] DATE NULL,
	[FechadeLlegada] DATE NULL,
	[Anticipación] [int] NULL,
	[Noches] [int] NULL,
	[Huéspedes] [int] NULL,
	[CanaldeDistribución] [varchar](8000) NULL,
	[TipodeCliente] [varchar](8000) NULL,
	[País] [varchar](8000) NULL,
	[TipodeDepósito] [varchar](8000) NULL,
	[TarifaMediaDiaria] INT NULL,
	[Estado] [varchar](8000) NULL,
	[ActualizacióndeEstado] DATE NULL,
	[Cancelado] [int] NULL,
	[Ingresos] INT NULL,
	[PérdidadIngresos] INT NULL
)
GO
-- 
INSERT INTO [DWHotel].[Silver].[DatosSilver]
(
	[IDdeReserva],
	[Hotel],
	[FechadeReserva],
	[FechadeLlegada],
	[Anticipación],
	[Noches],
	[Huéspedes],
	[CanaldeDistribución],
	[TipodeCliente],
	[País],
	[TipodeDepósito],
	[TarifaMediaDiaria],
	[Estado],
	[ActualizacióndeEstado],
	[Cancelado],
	[Ingresos],
	[PérdidadIngresos]
)
SELECT
	[IDdeReserva],
	[Hotel],
	PARSE([FechadeReserva] AS DATE USING 'es-ES'),-- keeping date in spanish
	PARSE([FechadeLlegada] AS DATE USING 'es-ES'),
	[Anticipación],
	[Noches],
	[Huéspedes],
	[CanaldeDistribución],
	[TipodeCliente],
	[País],
[TipodeDepósito],
	CONVERT(FLOAT, REPLACE([TarifaMediaDiaria], ',', '.')),
	[Estado],
	PARSE([ActualizacióndeEstado] AS DATE USING 'es-ES'),
	[Cancelado],
	CONVERT(FLOAT, REPLACE([Ingresos], ',', '.')),
	CONVERT(FLOAT, REPLACE([PérdidadIngresos], ',', '.'))
FROM  [DWHotel].[dbo].[datosbronce];

--                      Detecting duplicates
-- 1. Detecting duplicates by id (IDdeReserva)
SELECT 
	[IDdeReserva],
	COUNT(*) AS Cantidad
FROM [DWHotel].[Silver].[DatosSilver]
GROUP BY [IDdeReserva]
HAVING COUNT(*) > 1;

-- Deleting duplicates
WITH Duplicados AS(
		SELECT * 
			,ROW_NUMBER() OVER(PARTITION BY [IDdeReserva] ORDER BY FechadeReserva) as id_row
			FROM [DWHotel].[Silver].[DatosSilver]
	)
DELETE FROM Duplicados
WHERE id_row>1
	;
-- Processing null values
SELECT *
FROM [DWHotel].[Silver].[DatosSilver]
WHERE 
	[CanaldeDistribución] IS NULL OR
	[TipodeCliente] IS NULL OR
	[País] IS NULL OR
	[TipodeDepósito] IS NULL;
-- Tecnique 1: Replacing nulls by Desconocido or Unknown

UPDATE [DWHotel].[Silver].[DatosSilver]
SET [TipodeCliente] = 'Desconocido'
WHERE [TipodeCliente] IS NULL OR LTRIM(RTRIM([TipodeCliente])) = '';

UPDATE [DWHotel].[Silver].[DatosSilver]
SET [CanaldeDistribución] = 'Desconocido'
WHERE [CanaldeDistribución] IS NULL OR LTRIM(RTRIM([CanaldeDistribución])) = '';

-- Replacing by value that is more repeated
SELECT TOP 1 [TipodeDepósito], COUNT(*) AS Total
FROM [DWHotel].[Silver].[DatosSilver]
WHERE [TipodeDepósito] IS NOT NULL AND LTRIM(RTRIM([TipodeDepósito])) <> ''
GROUP BY [TipodeDepósito]
ORDER BY Total DESC;

UPDATE [DWHotel].[Silver].[DatosSilver]
SET [TipodeDepósito] = 'Sin depósito'
WHERE [TipodeDepósito] IS NULL OR LTRIM(RTRIM([TipodeDepósito])) = '';

SELECT TOP 1 [País], COUNT(*) AS Total
FROM [DWHotel].[Silver].[DatosSilver]
WHERE [País] IS NOT NULL AND LTRIM(RTRIM([País])) <> ''
GROUP BY [País]
ORDER BY Total DESC;

UPDATE [DWHotel].[Silver].[DatosSilver]
SET [País] = 'Portugal'
WHERE [País] IS NULL OR LTRIM(RTRIM([País])) = '';
