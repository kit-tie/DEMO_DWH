--USE Practice
--DROP DATABASE [OrdersDWH]
CREATE DATABASE OrdersDWH
GO
USE [OrdersDWH]
GO
SET ANSI_NULLS ON
GO
--CREATE TABLES
--Province
CREATE TABLE [dbo].[Province](
	[ProvinceID] [int] PRIMARY KEY IDENTITY(1,1),
	[Province] [nvarchar](255) NOT NULL
)
GO
-- Customers
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] PRIMARY KEY,
	[CustomerName] [nvarchar](255) NOT NULL
)
GO
--Product
CREATE TABLE [dbo].[Product](
	[ProductID] [int] PRIMARY KEY IDENTITY,
	[ProductName] [nvarchar](255) NOT NULL,
	[ProductCategoryID] [int] NOT NULL,
	[ProductCategory] [nvarchar](255) NOT NULL
)
GO

--Dates
CREATE TABLE [dbo].[dim_Dates](
	[DateID] [int] PRIMARY KEY IDENTITY,
	[DateName] [date] NOT NULL,
	[Year] [smallint] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[MonthName] VARCHAR(9),
	[Quarter] [tinyint] NOT NULL
)
GO

--Fact Orders
CREATE TABLE [dbo].[Orders.fact](
	[OrderID] [int] PRIMARY KEY IDENTITY,
	[ProductID] [int] FOREIGN KEY REFERENCES [dbo].[Product](ProductID),
	[CustomerID] [int] FOREIGN KEY REFERENCES [dbo].[Customers](CustomerID),
	[Value1] [float] NULL,
	[Value2] [float] NULL,
	[Value3] [float] NULL,
	[ProvinceID] [int] FOREIGN KEY REFERENCES [dbo].[Province](ProvinceID) NULL,
	[Value4] [float] NULL,
	[OrderDate] [int] FOREIGN KEY REFERENCES [dbo].[dim_Dates](DateID) NULL
)


--PROCEDURES FOR INSERTING DATA
--Province
CREATE OR ALTER PROCEDURE [dbo].[upload_Province]
AS
INSERT INTO [dbo].[Province] ([Province])
SELECT DISTINCT [Practice].[dbo].[raw.Orders].Province
FROM [Practice].[dbo].[raw.Orders]
WHERE [Practice].[dbo].[raw.Orders].Province NOT IN (SELECT [Province] FROM [dbo].[Province]) 
GO

-- Customers
CREATE OR ALTER PROCEDURE [dbo].[upload_Customers] 
AS
INSERT INTO [dbo].[Customers] ([CustomerID],[CustomerName])
SELECT MIN(CAST([CustomerID] AS INT)), [Customer]
FROM [Practice].[dbo].[raw.Orders]
WHERE [Practice].[dbo].[raw.Orders].[Customer] NOT IN (SELECT [CustomerName] FROM [dbo].[Customers])
AND  --SAME CustomerID, DIFFERENT NAME
[Practice].[dbo].[raw.Orders].[CustomerID] NOT IN (
SELECT a.[CustomerID]
FROM (SELECT MIN(CAST([CustomerID] AS INT)) AS CustomerID, [Customer]
FROM [Practice].[dbo].[raw.Orders]
GROUP BY [Customer]) a
INNER JOIN (SELECT MIN(CAST([CustomerID] AS INT)) AS CustomerID, [Customer]
FROM [Practice].[dbo].[raw.Orders]
GROUP BY [Customer]) b ON a.[CustomerID]=b.[CustomerID]
WHERE a.[Customer]<>b.[Customer])
GROUP BY [Customer];
GO

--Product
CREATE OR ALTER PROCEDURE [dbo].[upload_Product]
AS
INSERT INTO [dbo].[Product] ([ProductName],[ProductCategoryID],[ProductCategory])
SELECT DISTINCT a.[Product], PrCat.[ProductCategoryID], a.[ProductCategory]
  FROM [Practice].[dbo].[raw.Orders] a
LEFT JOIN (SELECT [ProductCategoryID],[ProductCategory]
			FROM [dbo].[Product]
			UNION
			SELECT DISTINCT (DENSE_RANK() OVER (ORDER BY [ProductCategory]))+
							(CASE WHEN EXISTS (SELECT 1 FROM [dbo].[Product])
								  THEN (SELECT MAX([ProductCategoryID]) FROM [dbo].[Product])
								  ELSE 0
							 END) 
			AS [ProductCategoryID], [ProductCategory]
			FROM [Practice].[dbo].[raw.Orders]
			WHERE [ProductCategory] NOT IN (SELECT [ProductCategory] FROM [dbo].[Product])
			) PrCat
  ON a.[ProductCategory]=PrCat.[ProductCategory]
EXCEPT
SELECT [ProductName],[ProductCategoryID],[ProductCategory] FROM [dbo].[Product] ;
GO


--Fact Orders
CREATE OR ALTER PROCEDURE [dbo].[upload_Orders.fact]
AS
INSERT INTO [dbo].[Orders.fact] ([ProductID],[CustomerID],[Value1],[Value2],[Value3],[ProvinceID],[Value4])
SELECT DISTINCT [ProductID],c.[CustomerID],[Value1],[Value2],[Value3],[ProvinceID],[Value4]
FROM [Practice].[dbo].[raw.Orders] a
INNER JOIN [dbo].[Product] b ON a.Product = b.ProductName
INNER JOIN [dbo].[Customers] c ON a.Customer=c.CustomerName
INNER JOIN [dbo].[Province] d ON a.Province=d.Province;
GO

