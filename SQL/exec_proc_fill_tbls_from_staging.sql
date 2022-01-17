USE [OrdersDWH]

EXECUTE [dbo].[upload_Province]
GO

EXECUTE [dbo].[upload_Customers] 
GO

EXECUTE [dbo].[upload_Product]
GO

EXECUTE [dbo].[upload_Orders.fact]
GO
