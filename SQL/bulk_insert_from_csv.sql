USE [Practice]
GO

DROP TABLE IF EXISTS [dbo].[raw.Orders]
GO

CREATE TABLE [dbo].[raw.Orders](
	[Product] [Nvarchar](255) NULL,
	[Customer] [Nvarchar](255) NULL,
	[CustomerID] [Nvarchar](255) NULL,
	[Value1] [float] NULL,
	[Value2] [float] NULL,
	[Value3] [float] NULL,
	[Province] [Nvarchar](255) NULL,
	[ProductCategory] [Nvarchar](255) NULL,
	[Value4] [float] NULL
)
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
		BATCHSIZE=1,
		TABLOCK
	)'
    EXEC(@Query)
END
GO

USE [Practice]
GO
DECLARE @FilePath VARCHAR(MAX), @FileName VARCHAR(MAX)
SET  @FilePath = 'C:\Katie\DEMO_DWH\Sample_files'
SET  @FileName = 'SampleCSVFile_53000kb.csv'
EXECUTE [dbo].[import_csv_test]  @FilePath, @FileName
