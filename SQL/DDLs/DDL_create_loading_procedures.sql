--PROCEDURES FOR INSERTING DATA from staging table
--Province
USE [OrdersDWH]
GO
CREATE OR ALTER PROCEDURE [dbo].[upload_Province]
AS
INSERT INTO [dbo].[Province] ([Province])
SELECT DISTINCT [dbo].[raw.Orders].Province
FROM [dbo].[raw.Orders]
WHERE [dbo].[raw.Orders].Province NOT IN (SELECT [Province] FROM [dbo].[Province]) 
GO

-- Customers
CREATE OR ALTER PROCEDURE [dbo].[upload_Customers] 
AS
INSERT INTO [dbo].[Customers] ([CustomerID],[CustomerName])
SELECT MIN(CAST([CustomerID] AS INT)), [Customer]
FROM [dbo].[raw.Orders]
WHERE [dbo].[raw.Orders].[Customer] NOT IN (SELECT [CustomerName] FROM [dbo].[Customers])
AND  --SAME CustomerID, DIFFERENT NAME
[dbo].[raw.Orders].[CustomerID] NOT IN (
SELECT a.[CustomerID]
FROM (SELECT MIN(CAST([CustomerID] AS INT)) AS CustomerID, [Customer]
FROM [dbo].[raw.Orders]
GROUP BY [Customer]) a
INNER JOIN (SELECT MIN(CAST([CustomerID] AS INT)) AS CustomerID, [Customer]
FROM [dbo].[raw.Orders]
GROUP BY [Customer]) b ON a.[CustomerID]=b.[CustomerID]
WHERE a.[Customer]<>b.[Customer])
GROUP BY [Customer];
GO

--Product
CREATE OR ALTER PROCEDURE [dbo].[upload_Product]
AS
INSERT INTO [dbo].[Product] ([ProductName],[ProductCategoryID],[ProductCategory])
SELECT DISTINCT a.[Product], PrCat.[ProductCategoryID], a.[ProductCategory]
  FROM [dbo].[raw.Orders] a
LEFT JOIN (SELECT [ProductCategoryID],[ProductCategory]
			FROM [dbo].[Product]
			UNION
			SELECT DISTINCT (DENSE_RANK() OVER (ORDER BY [ProductCategory]))+
							(CASE WHEN EXISTS (SELECT 1 FROM [dbo].[Product])
								  THEN (SELECT MAX([ProductCategoryID]) FROM [dbo].[Product])
								  ELSE 0
							 END) 
			AS [ProductCategoryID], [ProductCategory]
			FROM [dbo].[raw.Orders]
			WHERE [ProductCategory] NOT IN (SELECT [ProductCategory] FROM [dbo].[Product])
			) PrCat
  ON a.[ProductCategory]=PrCat.[ProductCategory]
EXCEPT
SELECT [ProductName],[ProductCategoryID],[ProductCategory] FROM [dbo].[Product] ;
GO


--Fact Orders
CREATE OR ALTER PROCEDURE [dbo].[upload_Orders.fact]
AS
MERGE [dbo].[Orders.fact] as Target
	USING (
			SELECT DISTINCT [ProductID],c.[CustomerID],[Value1],[Value2],[Value3],[ProvinceID],[Value4],e.DateID
			FROM [dbo].[raw.Orders] a
			INNER JOIN [dbo].[Product] b ON a.Product = b.ProductName
			INNER JOIN [dbo].[Customers] c ON a.Customer=c.CustomerName
			INNER JOIN [dbo].[Province] d ON a.Province=d.Province
			INNER JOIN [dbo].[dim_Dates] e ON CAST(a.[LoadDate] AS DATE)=e.[DateName]
			) as Source
	ON Source.[ProductID] = Target.[ProductID] AND Source.[CustomerID]  = Target.[CustomerID] 
		AND Source.[ProvinceID] = Target.[ProvinceID] AND Source.DateID = Target.[InsertDate]
WHEN NOT MATCHED BY Target THEN
	INSERT ([ProductID],[CustomerID],[Value1],[Value2],[Value3],[ProvinceID],[Value4],[InsertDate],[UpdateDate])
	VALUES (Source.[ProductID],Source.[CustomerID],Source.[Value1],Source.[Value2],Source.[Value3]
			,Source.[ProvinceID],Source.[Value4],Source.DateID, Source.DateID)
WHEN MATCHED THEN UPDATE SET
	Target.[Value1] = Source.[Value1], Target.[Value2] = Source.[Value2]
	,Target.[Value3] = Source.[Value3], Target.[Value4] = Source.[Value4]
	,Target.[UpdateDate] = Source.DateID;
GO