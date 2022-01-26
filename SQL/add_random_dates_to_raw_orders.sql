--populate [dbo].[raw.Orders] with random dates from [dbo].[dim_Dates]
CREATE TABLE #tmp (ID INT IDENTITY, SelectDate date)
DECLARE @CountRowsTmp INT = (SELECT COUNT(*) FROM #tmp)
WHILE (SELECT COUNT(*) FROM [dbo].[raw.Orders])>=@CountRowsTmp
BEGIN
	INSERT INTO #tmp (SelectDate)
	SELECT [DateName] FROM [dbo].[dim_Dates] ORDER BY NEWID() OFFSET 0 ROWS
	SET @CountRowsTmp=(SELECT COUNT(*) FROM #tmp)
END
GO

UPDATE [dbo].[raw.Orders]
SET [LoadDate] = (SELECT SelectDate FROM #tmp
					WHERE #tmp.ID=[dbo].[raw.Orders].[id]
				)
GO

DROP TABLE #tmp