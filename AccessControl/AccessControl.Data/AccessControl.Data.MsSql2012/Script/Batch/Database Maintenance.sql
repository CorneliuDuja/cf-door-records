SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

SET NOCOUNT ON;
GO

DECLARE 
	@batchStart				DATETIMEOFFSET,
	@batchEnd				DATETIMEOFFSET,
	@batchBefore			INT,
	@batchAfter				INT,
	@operationStart			DATETIMEOFFSET,
	@operationEnd			DATETIMEOFFSET,
	@operationBefore		INT,
	@operationAfter			INT,
	@operationResults		XML,
	@name					VARCHAR(MAX)	= DB_NAME(),
	@tableSchema			NVARCHAR(MAX),
	@tableName				NVARCHAR(MAX),
	@maximumFragmentation	MONEY			= NULL,
	@objectId				INT,
	@indexName				NVARCHAR(MAX),
	@logicalFragmentation	MONEY,
	@recoveryModel			NVARCHAR(MAX),
	@logicalFileName		VARCHAR(MAX),
	@results				NVARCHAR(MAX),
	@command				NVARCHAR(MAX);

DECLARE @databases TABLE 
(
	[Name]		NVARCHAR(MAX),
	[Size]		INT,
	[Remarks]	NVARCHAR(MAX)
)

DECLARE @operations TABLE 
(
	[BatchId]				UNIQUEIDENTIFIER,
	[Code]					INT,
	[OperationTuningType]	NVARCHAR(MAX),
	[Start]					DATETIMEOFFSET,
	[End]					DATETIMEOFFSET,
	[Before]				INT,
	[After]					INT,
	[Results]				XML
);

BEGIN TRY

--	Checkpoint
	SET @batchStart = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @batchBefore = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	SELECT
		@operationStart		= @batchStart,
		@operationBefore	= @batchBefore;
	CHECKPOINT;
	SET @operationEnd = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationAfter = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	INSERT @operations 
	(
		[Code],
		[OperationTuningType],
		[Start],
		[End],
		[Before],
		[After]
	) 
	VALUES 
	(
		1,
		'CHECKPOINT',
		@operationStart,
		@operationEnd,
		@operationBefore,
		@operationAfter
	);

--	UpdateUsage
	SET @operationStart = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationBefore = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	DBCC UPDATEUSAGE(@name) WITH NO_INFOMSGS;
	SET @operationEnd = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationAfter = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	INSERT @operations 
	(
		[Code],
		[OperationTuningType],
		[Start],
		[End],
		[Before],
		[After]
	) 
	VALUES 
	(
		2,
		'UPDATEUSAGE',
		@operationStart,
		@operationEnd,
		@operationBefore,
		@operationAfter
	);

--	ShowContig
	SET @operationStart = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationBefore = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	DECLARE @showContigs TABLE 
	(
		[ObjectName]			NVARCHAR(MAX),
		[ObjectId]				INT,
		[IndexName]				NVARCHAR(MAX),
		[IndexId]				INT,
		[Level]					INT,
		[Pages]					INT,
		[Rows]					INT,
		[MinimumRecordSize]		INT,
		[MaximumRecordSize]		INT,
		[AverageRecordSize]		INT,
		[ForwardedRecords]		INT,
		[Extents]				INT,
		[ExtentSwitches]		INT,
		[AverageFreeBytes]		INT,
		[AveragePageDensity]	INT,
		[ScanDensity]			MONEY,
		[BestCount]				INT,
		[ActualtCount]			INT,
		[LogicalFragmentation]	MONEY,
		[ExtentFragmentation]	MONEY
	);
	DECLARE databaseTables CURSOR FOR
	SELECT 
		IST.[TABLE_SCHEMA], 
		IST.[TABLE_NAME]
	FROM [INFORMATION_SCHEMA].[TABLES] IST
	WHERE TABLE_TYPE = 'BASE TABLE';
	OPEN databaseTables;
	FETCH NEXT FROM databaseTables INTO 
		@tableSchema, 
		@tableName;
	WHILE @@FETCH_STATUS = 0 BEGIN
		SELECT @command = 'DBCC SHOWCONTIG(''[' + @tableSchema + '].[' + @tableName + ']'') WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS';
		INSERT INTO @showContigs EXEC (@command);
		UPDATE SC SET SC.[ObjectName] = '[' + @tableSchema + '].[' + @tableName + ']' 
		FROM @showContigs SC WHERE SC.[ObjectName] = @tableName;
		FETCH NEXT FROM databaseTables INTO 
			@tableSchema, 
			@tableName;
	END
	CLOSE databaseTables;
	DEALLOCATE databaseTables;
	SET @operationResults = (SELECT * FROM @showContigs FOR XML RAW('ShowContig'), ELEMENTS);
	SET @operationEnd = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationAfter = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	INSERT @operations 
	(
		[Code],
		[OperationTuningType],
		[Start],
		[End],
		[Before],
		[After],
		[Results]
	) 
	VALUES 
	(
		3,
		'SHOWCONTIG',
		@operationStart,
		@operationEnd,
		@operationBefore,
		@operationAfter,
		@operationResults
	);

--	DbReindex
	SET @operationStart = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationBefore = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	SET @maximumFragmentation = ISNULL(@maximumFragmentation, 30);
	DECLARE databaseIndexes CURSOR FOR
	SELECT 
		SC.[ObjectName],
		SC.[ObjectId],
		SC.[IndexName],
		SC.[LogicalFragmentation]
	FROM @showContigs SC
	WHERE 
		SC.[LogicalFragmentation] >= @maximumFragmentation	AND
		INDEXPROPERTY(SC.[ObjectId], SC.[IndexName], 'IndexDepth') > 0;
	SET @results = '<string>Re-index database indexes, fragmented more than ' + RTRIM(CAST(@maximumFragmentation AS NVARCHAR(MAX))) + '%.</string>';
	OPEN databaseIndexes;
	FETCH NEXT FROM databaseIndexes INTO 
		@tableName, 
		@objectId, 
		@indexName, 
		@logicalFragmentation;
	WHILE @@FETCH_STATUS = 0 BEGIN
		SET @results = @results + '<string>Re-index [' + RTRIM(@indexName) + '] of [' + RTRIM(@indexName) + '] table, fragmented at ' + RTRIM(CAST(@logicalFragmentation AS NVARCHAR(MAX))) + '%.</string>';
		SET @command = 'DBCC DBREINDEX(''' + RTRIM(@tableName) + ''', ''' + RTRIM(@indexName) + ''', 0) WITH NO_INFOMSGS';
		EXEC (@command);
		FETCH NEXT FROM databaseIndexes INTO 
			@tableName, 
			@objectId, 
			@indexName, 
			@logicalFragmentation;
	END
	CLOSE databaseIndexes;
	DEALLOCATE databaseIndexes;
	SET @operationResults = CAST(@results AS XML);
	SET @operationEnd = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationAfter = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	INSERT @operations 
	(
		[Code],
		[OperationTuningType],
		[Start],
		[End],
		[Before],
		[After],
		[Results]
	) 
	VALUES 
	(
		4,
		'DBREINDEX',
		@operationStart,
		@operationEnd,
		@operationBefore,
		@operationAfter,
		@operationResults
	);

--	ShrinkDatabase
	SET @operationStart = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationBefore = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	DBCC SHRINKDATABASE(@name, 0) WITH NO_INFOMSGS;
	SET @operationEnd = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationAfter = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	INSERT @operations 
	(
		[Code],
		[OperationTuningType],
		[Start],
		[End],
		[Before],
		[After]
	) 
	VALUES 
	(
		5,
		'SHRINKDATABASE',
		@operationStart,
		@operationEnd,
		@operationBefore,
		@operationAfter
	);

--	BackupLog
	IF ((SELECT CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX))) LIKE '9%') BEGIN 
		SET @operationStart = SYSDATETIMEOFFSET();
		DELETE X FROM @databases X;
		INSERT @databases EXEC [dbo].[sp_databases];
		SELECT @operationBefore = X.[Size] FROM @databases X WHERE X.[Name] = @name;
		CHECKPOINT;
		SET @command = 'BACKUP LOG [' + @name + '] WITH TRUNCATE_ONLY';
		EXEC (@command);
		SET @operationEnd = SYSDATETIMEOFFSET();
		DELETE X FROM @databases X;
		INSERT @databases EXEC [dbo].[sp_databases];
		SELECT @operationAfter = X.[Size] FROM @databases X WHERE X.[Name] = @name;
		INSERT @operations 
		(
			[Code],
			[OperationTuningType],
			[Start],
			[End],
			[Before],
			[After]
		) 
		VALUES 
		(
			6,
			'BACKUPLOG',
			@operationStart,
			@operationEnd,
			@operationBefore,
			@operationAfter
		);
	END

--	ShrinkFile
	SET @operationStart = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationBefore = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	SELECT @recoveryModel = D.[recovery_model_desc] FROM [sys].[databases] D WHERE D.[name] = @name;
	SET @command = 'ALTER DATABASE [' + @name + '] SET RECOVERY SIMPLE';
	EXEC (@command);
	CHECKPOINT;
	SELECT @logicalFileName = DF.[name] FROM [sys].[database_files] DF WHERE DF.[type] = 0;
	DBCC SHRINKFILE(@logicalFileName, TRUNCATEONLY) WITH NO_INFOMSGS;
	SELECT @logicalFileName = DF.[name] FROM [sys].[database_files] DF WHERE DF.[type] = 1;
	DBCC SHRINKFILE(@logicalFileName, TRUNCATEONLY) WITH NO_INFOMSGS;
	SET @command = 'ALTER DATABASE [' + @name + '] SET RECOVERY ' + @recoveryModel;
	EXEC (@command);
	SET @operationEnd = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationAfter = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	INSERT @operations 
	(
		[Code],
		[OperationTuningType],
		[Start],
		[End],
		[Before],
		[After]
	) 
	VALUES 
	(
		7,
		'SHRINKFILE',
		@operationStart,
		@operationEnd,
		@operationBefore,
		@operationAfter
	);

--	UpdateStatistics
	SET @operationStart = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationBefore = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	EXEC sp_updatestats;
	SET @operationEnd = SYSDATETIMEOFFSET();
	DELETE X FROM @databases X;
	INSERT @databases EXEC [dbo].[sp_databases];
	SELECT @operationAfter = X.[Size] FROM @databases X WHERE X.[Name] = @name;
	INSERT @operations 
	(
		[Code],
		[OperationTuningType],
		[Start],
		[End],
		[Before],
		[After]
	) 
	VALUES 
	(
		8,
		'UPDATESTATISTICS',
		@operationStart,
		@operationEnd,
		@operationBefore,
		@operationAfter
	);

--	Show data
	SELECT
		@batchEnd	= @operationEnd,
		@batchAfter	= @operationAfter;
	SELECT 
		@batchStart		[BatchStart],
		@batchEnd		[BatchEnd],
		@batchBefore	[BatchBefore],
		@batchAfter		[BatchAfter];
	SELECT * FROM @operations O;

END TRY
BEGIN CATCH

	SELECT  
		ERROR_MESSAGE(),
		ERROR_NUMBER(), 
		ERROR_SEVERITY(),
		ERROR_STATE(), 
		ERROR_LINE(),
		ISNULL(ERROR_PROCEDURE(), '-');

END CATCH;
