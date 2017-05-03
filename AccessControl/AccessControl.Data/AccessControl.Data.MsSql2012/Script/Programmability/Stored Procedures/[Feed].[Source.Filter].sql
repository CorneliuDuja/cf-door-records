SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Feed'		AND
			O.[type]	= 'P'			AND
			O.[name]	= 'Source.Filter'))
	DROP PROCEDURE [Feed].[Source.Filter];
GO

CREATE PROCEDURE [Feed].[Source.Filter]
(
	@predicate		XML,
	@isCountable	BIT	= NULL,
	@guids			XML			OUTPUT,
	@isExcluded		BIT			OUTPUT,
	@isFiltered		BIT			OUTPUT,
	@number			INT			OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @source TABLE ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);

	DECLARE 
		@dateFrom	DATETIMEOFFSET,
		@dateTo		DATETIMEOFFSET,
		@amountFrom FLOAT,
		@amountTo	FLOAT,
		@query		XML;
	
	SET @isFiltered = 0;

--	Filter by date
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/Date/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Date/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceDate] BETWEEN ISNULL(@dateFrom, S.[SourceDate]) AND ISNULL(@dateTo, S.[SourceDate]);
			ELSE 
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceDate] NOT BETWEEN ISNULL(@dateFrom, S.[SourceDate]) AND ISNULL(@dateTo, S.[SourceDate]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceDate] BETWEEN ISNULL(@dateFrom, S.[SourceDate]) AND ISNULL(@dateTo, S.[SourceDate])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
			ELSE
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceDate] NOT BETWEEN ISNULL(@dateFrom, S.[SourceDate]) AND ISNULL(@dateTo, S.[SourceDate])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by source file type
	DECLARE @sourceFileType TABLE ([SourceFileType] NVARCHAR(MAX));
	INSERT @sourceFileType SELECT DISTINCT LTRIM(X.[Entity].value('(text())[1]', 'NVARCHAR(MAX)')) [SourceFileType]
	FROM @predicate.nodes('/*/SourceFileType/Value/SourceFileType') X ([Entity])
	IF (@@ROWCOUNT > 0) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/SourceFileType/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT DISTINCT S.[SourceId] FROM [Feed].[Source] S
				INNER JOIN	@sourceFileType	X	ON S.[SourceFileType]	LIKE X.[SourceFileType];
			ELSE 
				INSERT @source SELECT DISTINCT S.[SourceId] FROM [Feed].[Source] S
				LEFT JOIN	@sourceFileType	X	ON S.[SourceFileType]	LIKE X.[SourceFileType]
				WHERE X.[SourceFileType] IS NULL;
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT DISTINCT S.[SourceId] FROM [Feed].[Source] S
					INNER JOIN	@sourceFileType	X	ON S.[SourceFileType]	LIKE X.[SourceFileType]
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
			ELSE
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT DISTINCT S.[SourceId] FROM [Feed].[Source] S
					LEFT JOIN	@sourceFileType	X	ON S.[SourceFileType]	LIKE X.[SourceFileType]
					WHERE X.[SourceFileType] IS NULL
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by loaded datetime offset
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/LoadedOn/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/LoadedOn/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceLoadedOn] BETWEEN ISNULL(@dateFrom, S.[SourceLoadedOn]) AND ISNULL(@dateTo, S.[SourceLoadedOn]);
			ELSE 
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceLoadedOn] NOT BETWEEN ISNULL(@dateFrom, S.[SourceLoadedOn]) AND ISNULL(@dateTo, S.[SourceLoadedOn]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceLoadedOn] BETWEEN ISNULL(@dateFrom, S.[SourceLoadedOn]) AND ISNULL(@dateTo, S.[SourceLoadedOn])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
			ELSE
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceLoadedOn] NOT BETWEEN ISNULL(@dateFrom, S.[SourceLoadedOn]) AND ISNULL(@dateTo, S.[SourceLoadedOn])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by extracted datetime offset
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/ExtractedOn/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/ExtractedOn/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceExtractedOn] BETWEEN ISNULL(@dateFrom, S.[SourceExtractedOn]) AND ISNULL(@dateTo, S.[SourceExtractedOn]);
			ELSE 
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceExtractedOn] NOT BETWEEN ISNULL(@dateFrom, S.[SourceExtractedOn]) AND ISNULL(@dateTo, S.[SourceExtractedOn]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceExtractedOn] BETWEEN ISNULL(@dateFrom, S.[SourceExtractedOn]) AND ISNULL(@dateTo, S.[SourceExtractedOn])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
			ELSE
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceExtractedOn] NOT BETWEEN ISNULL(@dateFrom, S.[SourceExtractedOn]) AND ISNULL(@dateTo, S.[SourceExtractedOn])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by transformed datetime offset
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/TransformedOn/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/TransformedOn/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceTransformedOn] BETWEEN ISNULL(@dateFrom, S.[SourceTransformedOn]) AND ISNULL(@dateTo, S.[SourceTransformedOn]);
			ELSE 
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceTransformedOn] NOT BETWEEN ISNULL(@dateFrom, S.[SourceTransformedOn]) AND ISNULL(@dateTo, S.[SourceTransformedOn]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceTransformedOn] BETWEEN ISNULL(@dateFrom, S.[SourceTransformedOn]) AND ISNULL(@dateTo, S.[SourceTransformedOn])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
			ELSE
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceTransformedOn] NOT BETWEEN ISNULL(@dateFrom, S.[SourceTransformedOn]) AND ISNULL(@dateTo, S.[SourceTransformedOn])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by analysed datetime offset
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/AnalysedOn/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/AnalysedOn/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceAnalysedOn] BETWEEN ISNULL(@dateFrom, S.[SourceAnalysedOn]) AND ISNULL(@dateTo, S.[SourceAnalysedOn]);
			ELSE 
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceAnalysedOn] NOT BETWEEN ISNULL(@dateFrom, S.[SourceAnalysedOn]) AND ISNULL(@dateTo, S.[SourceAnalysedOn]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceAnalysedOn] BETWEEN ISNULL(@dateFrom, S.[SourceAnalysedOn]) AND ISNULL(@dateTo, S.[SourceAnalysedOn])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
			ELSE
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceAnalysedOn] NOT BETWEEN ISNULL(@dateFrom, S.[SourceAnalysedOn]) AND ISNULL(@dateTo, S.[SourceAnalysedOn])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by length
	SELECT @amountFrom = NULL, @amountTo = NULL;
	SELECT 
		@amountFrom	= X.[AmountFrom], 
		@amountTo	= X.[AmountTo] 
	FROM [Common].[AmountInterval.Table](@predicate.query('/*/Length/Value')) X;
	IF (COALESCE(@amountFrom, @amountTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Length/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceLength] BETWEEN ISNULL(@amountFrom, S.[SourceLength]) AND ISNULL(@amountTo, S.[SourceLength]);
			ELSE 
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceLength] NOT BETWEEN ISNULL(@amountFrom, S.[SourceLength]) AND ISNULL(@amountTo, S.[SourceLength]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceLength] BETWEEN ISNULL(@amountFrom, S.[SourceLength]) AND ISNULL(@amountTo, S.[SourceLength])	
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
			ELSE
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE S.[SourceLength] NOT BETWEEN ISNULL(@amountFrom, S.[SourceLength]) AND ISNULL(@amountTo, S.[SourceLength])
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by source
	SET @query = @predicate.query('/*/Source/Value/Source');
	DECLARE @entity TABLE ([Id] UNIQUEIDENTIFIER);
	INSERT @entity SELECT DISTINCT S.[Id]
	FROM [Common].[Entity.Table](@query) X
	CROSS APPLY [Feed].[Source.Table](X.[Entity]) S;
	IF (@@ROWCOUNT > 0) BEGIN
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Source/IsExcluded')), 0);
		DELETE X FROM @entity X WHERE X.[Id] IS NULL;
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT * FROM @entity;
			ELSE
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE S.[SourceId] NOT IN (SELECT * FROM @entity);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source X WHERE X.[Id] NOT IN (SELECT * FROM @entity);
			ELSE
				DELETE X FROM @source X WHERE X.[Id] IN (SELECT * FROM @entity);
		SET @isFiltered = 1;
	END

--	Filter by weekdays
	DECLARE @weekdays INT;
	SELECT @weekdays = ISNULL(X.[Entity].value('(Value/text())[1]', 'INT'), 0) FROM @predicate.nodes('/*/Weekdays') X ([Entity]);
	IF (@weekdays IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Weekdays/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, S.[SourceDate]) - 1)) = @weekdays;
			ELSE 
				INSERT @source SELECT S.[SourceId] FROM [Feed].[Source] S
				WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, S.[SourceDate]) - 1)) <> @weekdays;
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, S.[SourceDate]) - 1)) = @weekdays
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
			ELSE
				DELETE X FROM @source	X
				LEFT JOIN
				(
					SELECT S.[SourceId] FROM [Feed].[Source] S
					WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, S.[SourceDate]) - 1)) <> @weekdays
				)	S	ON	X.[Id]	= S.[SourceId]
				WHERE S.[SourceId] IS NULL;
		SET @isFiltered = 1;
	END

	SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/IsExcluded')), 0);

	SET @guids = (SELECT X.[Id] [guid] FROM @source X FOR XML PATH(''), ROOT('Guids'));

	IF (@isCountable = 0) RETURN;

--	Apply filters
	IF (@isFiltered = 0)
		SELECT @number = COUNT(*) FROM [Feed].[Source] S;
	ELSE
		IF (@isExcluded = 0)
			SELECT @number = COUNT(*) FROM @source X;
		ELSE
			SELECT @number = COUNT(*) FROM [Feed].[Source] S
			LEFT JOIN	@source	X	ON	S.[SourceId] = X.[Id]
			WHERE X.[Id] IS NULL;

END
GO
