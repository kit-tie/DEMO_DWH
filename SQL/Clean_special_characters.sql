--Remove uploaded special characters
UPDATE [dbo].[raw.Orders]
SET [Product] = REPLACE([Product],'�','') --(R)-> �
GO

UPDATE [dbo].[raw.Orders]
SET [Product] = REPLACE([Product],'�','') --(TM)-> �
GO

UPDATE [dbo].[raw.Orders]
SET [Product] = REPLACE([Product],'�','"') --� -> �
GO

UPDATE [dbo].[raw.Orders]
SET [Product] = REPLACE([Product],'�','"') --� -> �
GO
