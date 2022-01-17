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

--''C:\Users\Kateryna_Muraviova\Downloads\Import_error_file.csv'',

CREATE PROCEDURE import_csv_test (@FilePath VARCHAR(MAX), @FileName VARCHAR(MAX))
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
SET  @FilePath = 'D:\S3\bulk_insert\'
SET  @FileName = 'data.csv'
EXECUTE [dbo].[import_csv_test]  @FilePath, @FileName

SELECT CONNECTIONPROPERTY('local_net_address') AS [IP]

exec msdb.dbo.rds_gather_file_details 
SELECT * FROM msdb.dbo.rds_fn_list_file_details(28)
EXEC msdb..rds_task_status @task_id = 25

exec msdb.dbo.rds_download_from_s3
      @s3_arn_of_file='arn:aws:s3:::testbuck987/myfile.csv',
      @rds_file_path='D:\S3\bulk_insert\data.csv',
      @overwrite_file=1;

exec msdb.dbo.rds_delete_from_filesystem
    @rds_file_path='D:\S3\bulk_insert\data.csv_error.csv';