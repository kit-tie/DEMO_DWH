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
	[InsertDate] [int] FOREIGN KEY REFERENCES [dbo].[dim_Dates](DateID) NULL,
	[UpdateDate] [int] FOREIGN KEY REFERENCES [dbo].[dim_Dates](DateID) NULL
)
