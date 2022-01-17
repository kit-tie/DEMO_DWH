USE OrdersDWH

--Populate dim_Dates
DECLARE @CurrentDate date, @FirstDate date, @LastDate date
SET @FirstDate='1970-01-01'
SET @LastDate='2030-01-01'
SET @CurrentDate=@FirstDate

WHILE (@CurrentDate<@LastDate)
	BEGIN

		INSERT INTO [dbo].[dim_Dates]
			([DateName],
			[Year],
			[WeekOfYear],
			[Month],
			[MonthName],
			[Quarter]
			)
		SELECT 
			@CurrentDate as [DateName],
			DATEPART(YEAR,@CurrentDate) as [Year],
			DATEPART(WEEK,@CurrentDate) as [WeekOfYear],
			DATEPART(MONTH,@CurrentDate) as [Month],
			DATENAME(MONTH,@CurrentDate) as [MonthName],
			DATEPART(QUARTER,@CurrentDate) as [Quarter]

	SET @CurrentDate=DATEADD(DAY,1,@CurrentDate)
	END