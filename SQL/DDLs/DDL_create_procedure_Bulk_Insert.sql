-- stored procedure BULK LOAD from CSV into Staging table

USE [OrdersDWH]
GO

CREATE OR ALTER PROCEDURE import_csv_test (@FilePath VARCHAR(MAX), @FileName VARCHAR(MAX))
AS
BEGIN

Declare @Query varchar(8000)

SET @Query = '
	BULK INSERT [dbo].[raw.Orders]
	FROM ''' + @FilePath + @FileName +'''
	WITH
	(
		FORMAT= ''CSV'',
		ROWTERMINATOR = ''\n'',
		ERRORFILE = ''' + @FilePath + @FileName + '_error.csv' +''',
		MAXERRORS = 999,
		BATCHSIZE=1000,
		TABLOCK
	)'
    EXEC(@Query)
END
GO