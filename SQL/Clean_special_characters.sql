--Remove uploaded special characters
UPDATE [dbo].[raw.Orders]
SET [Product] = REPLACE([Product],'«','') --(R)-> «
GO

UPDATE [dbo].[raw.Orders]
SET [Product] = REPLACE([Product],'Ö','') --(TM)-> Ö
GO

UPDATE [dbo].[raw.Orders]
SET [Product] = REPLACE([Product],'ö','"') --” -> ö
GO

UPDATE [dbo].[raw.Orders]
SET [Product] = REPLACE([Product],'ô','"') --“ -> ô
GO
