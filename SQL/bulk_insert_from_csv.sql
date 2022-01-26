--Run bulk insert procedure [dbo].[import_csv_test]
USE [OrdersDWH]
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

DECLARE @FilePath VARCHAR(MAX), @FileName VARCHAR(MAX)
SET  @FilePath = 'C:\Katie\DEMO_DWH\Sample_files\'
SET  @FileName = 'SampleCSVFile_11_lines.csv'
EXECUTE [dbo].[import_csv_test]  @FilePath, @FileName
GO

ALTER TABLE [dbo].[raw.Orders]
ADD [LoadDate] [date],
	[id] INT IDENTITY
GO
