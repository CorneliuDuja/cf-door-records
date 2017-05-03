SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Slice'		AND
			O.[type]	= 'P'			AND
			O.[name]	= 'Day.Filter'))
	DROP PROCEDURE [Slice].[Day.Filter];
GO

CREATE PROCEDURE [Slice].[Day.Filter]
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
	
	DECLARE @day TABLE ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);

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
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayDate] BETWEEN ISNULL(@dateFrom, D.[DayDate]) AND ISNULL(@dateTo, D.[DayDate]);
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayDate] NOT BETWEEN ISNULL(@dateFrom, D.[DayDate]) AND ISNULL(@dateTo, D.[DayDate]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayDate] BETWEEN ISNULL(@dateFrom, D.[DayDate]) AND ISNULL(@dateTo, D.[DayDate])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayDate] NOT BETWEEN ISNULL(@dateFrom, D.[DayDate]) AND ISNULL(@dateTo, D.[DayDate])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by min in datetime offset
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/FirstIn/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/FirstIn/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayFirstIn] BETWEEN ISNULL(@dateFrom, D.[DayFirstIn]) AND ISNULL(@dateTo, D.[DayFirstIn]);
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayFirstIn] NOT BETWEEN ISNULL(@dateFrom, D.[DayFirstIn]) AND ISNULL(@dateTo, D.[DayFirstIn]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayFirstIn] BETWEEN ISNULL(@dateFrom, D.[DayFirstIn]) AND ISNULL(@dateTo, D.[DayFirstIn])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayFirstIn] NOT BETWEEN ISNULL(@dateFrom, D.[DayFirstIn]) AND ISNULL(@dateTo, D.[DayFirstIn])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by max out datetime offset
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/LastOut/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/LastOut/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayLastOut] BETWEEN ISNULL(@dateFrom, D.[DayLastOut]) AND ISNULL(@dateTo, D.[DayLastOut]);
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayLastOut] NOT BETWEEN ISNULL(@dateFrom, D.[DayLastOut]) AND ISNULL(@dateTo, D.[DayLastOut]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayLastOut] BETWEEN ISNULL(@dateFrom, D.[DayLastOut]) AND ISNULL(@dateTo, D.[DayLastOut])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayLastOut] NOT BETWEEN ISNULL(@dateFrom, D.[DayLastOut]) AND ISNULL(@dateTo, D.[DayLastOut])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by duration
	SELECT @amountFrom = NULL, @amountTo = NULL;
	SELECT 
		@amountFrom	= X.[AmountFrom], 
		@amountTo	= X.[AmountTo] 
	FROM [Common].[AmountInterval.Table](@predicate.query('/*/Duration/Value')) X;
	IF (COALESCE(@amountFrom, @amountTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Duration/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayDuration] BETWEEN ISNULL(@amountFrom, D.[DayDuration]) AND ISNULL(@amountTo, D.[DayDuration]);
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayDuration] NOT BETWEEN ISNULL(@amountFrom, D.[DayDuration]) AND ISNULL(@amountTo, D.[DayDuration]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayDuration] BETWEEN ISNULL(@amountFrom, D.[DayDuration]) AND ISNULL(@amountTo, D.[DayDuration])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayDuration] NOT BETWEEN ISNULL(@amountFrom, D.[DayDuration]) AND ISNULL(@amountTo, D.[DayDuration])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by deviation
	SELECT @amountFrom = NULL, @amountTo = NULL;
	SELECT 
		@amountFrom	= X.[AmountFrom], 
		@amountTo	= X.[AmountTo] 
	FROM [Common].[AmountInterval.Table](@predicate.query('/*/Deviation/Value')) X;
	IF (COALESCE(@amountFrom, @amountTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Deviation/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayDeviation] BETWEEN ISNULL(@amountFrom, D.[DayDeviation]) AND ISNULL(@amountTo, D.[DayDeviation]);
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayDeviation] NOT BETWEEN ISNULL(@amountFrom, D.[DayDeviation]) AND ISNULL(@amountTo, D.[DayDeviation]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayDeviation] BETWEEN ISNULL(@amountFrom, D.[DayDeviation]) AND ISNULL(@amountTo, D.[DayDeviation])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayDeviation] NOT BETWEEN ISNULL(@amountFrom, D.[DayDeviation]) AND ISNULL(@amountTo, D.[DayDeviation])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by trusted
	SELECT @amountFrom = NULL, @amountTo = NULL;
	SELECT 
		@amountFrom	= X.[AmountFrom], 
		@amountTo	= X.[AmountTo] 
	FROM [Common].[AmountInterval.Table](@predicate.query('/*/Trusted/Value')) X;
	IF (COALESCE(@amountFrom, @amountTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Trusted/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayTrusted] BETWEEN ISNULL(@amountFrom, D.[DayTrusted]) AND ISNULL(@amountTo, D.[DayTrusted]);
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayTrusted] NOT BETWEEN ISNULL(@amountFrom, D.[DayTrusted]) AND ISNULL(@amountTo, D.[DayTrusted]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayTrusted] BETWEEN ISNULL(@amountFrom, D.[DayTrusted]) AND ISNULL(@amountTo, D.[DayTrusted])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayTrusted] NOT BETWEEN ISNULL(@amountFrom, D.[DayTrusted]) AND ISNULL(@amountTo, D.[DayTrusted])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by doubtful
	SELECT @amountFrom = NULL, @amountTo = NULL;
	SELECT 
		@amountFrom	= X.[AmountFrom], 
		@amountTo	= X.[AmountTo] 
	FROM [Common].[AmountInterval.Table](@predicate.query('/*/Doubtful/Value')) X;
	IF (COALESCE(@amountFrom, @amountTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Doubtful/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayDoubtful] BETWEEN ISNULL(@amountFrom, D.[DayDoubtful]) AND ISNULL(@amountTo, D.[DayDoubtful]);
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayDoubtful] NOT BETWEEN ISNULL(@amountFrom, D.[DayDoubtful]) AND ISNULL(@amountTo, D.[DayDoubtful]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayDoubtful] BETWEEN ISNULL(@amountFrom, D.[DayDoubtful]) AND ISNULL(@amountTo, D.[DayDoubtful])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayDoubtful] NOT BETWEEN ISNULL(@amountFrom, D.[DayDoubtful]) AND ISNULL(@amountTo, D.[DayDoubtful])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by reliability
	SELECT @amountFrom = NULL, @amountTo = NULL;
	SELECT 
		@amountFrom	= X.[AmountFrom], 
		@amountTo	= X.[AmountTo] 
	FROM [Common].[AmountInterval.Table](@predicate.query('/*/Reliability/Value')) X;
	IF (COALESCE(@amountFrom, @amountTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Reliability/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayReliability] BETWEEN ISNULL(@amountFrom, D.[DayReliability]) AND ISNULL(@amountTo, D.[DayReliability]);
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayReliability] NOT BETWEEN ISNULL(@amountFrom, D.[DayReliability]) AND ISNULL(@amountTo, D.[DayReliability]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayReliability] BETWEEN ISNULL(@amountFrom, D.[DayReliability]) AND ISNULL(@amountTo, D.[DayReliability])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE D.[DayReliability] NOT BETWEEN ISNULL(@amountFrom, D.[DayReliability]) AND ISNULL(@amountTo, D.[DayReliability])
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by day
	SET @query = @predicate.query('/*/Day/Value/Day');
	DECLARE @entity TABLE ([Id] UNIQUEIDENTIFIER);
	INSERT @entity SELECT DISTINCT D.[Id]
	FROM [Common].[Entity.Table](@query) X
	CROSS APPLY [Slice].[Day.Table](X.[Entity]) D;
	IF (@@ROWCOUNT > 0) BEGIN
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Day/IsExcluded')), 0);
		DELETE X FROM @entity X WHERE X.[Id] IS NULL;
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT * FROM @entity;
			ELSE
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE D.[DayId] NOT IN (SELECT * FROM @entity);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day X WHERE X.[Id] NOT IN (SELECT * FROM @entity);
			ELSE
				DELETE X FROM @day X WHERE X.[Id] IN (SELECT * FROM @entity);
		SET @isFiltered = 1;
	END

--	Filter by person predicate
	DECLARE 
		@personPredicate	XML,
		@personIsCountable	BIT,
		@personGuids		XML,
		@personIsFiltered	BIT,
		@personNumber		INT;
	SELECT 
		@personPredicate	= @predicate.query('/*/PersonPredicate'),
		@personIsCountable	= 0,
		@personIsFiltered	= @predicate.exist('/*/PersonPredicate/*');
	IF (@personIsFiltered = 1) BEGIN
		DECLARE @person TABLE ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);
		EXEC sp_executesql 
			N'EXEC [Feed].[Person.Filter]
			@predicate,
			@isCountable,
			@guids		OUTPUT,
			@isExcluded OUTPUT,
			@isFiltered OUTPUT,
			@number		OUTPUT',
			N'@predicate	XML,
			@isCountable	BIT,
			@guids			XML OUTPUT,
			@isExcluded		BIT OUTPUT,
			@isFiltered		BIT OUTPUT,
			@number			INT OUTPUT',
			@predicate		= @personPredicate,
			@isCountable	= @personIsCountable,
			@guids			= @personGuids			OUTPUT,
			@isExcluded		= @isExcluded			OUTPUT,
			@isFiltered		= @personIsFiltered		OUTPUT,
			@number			= @personNumber			OUTPUT;
		INSERT @person SELECT * FROM [Common].[Guid.Table](@personGuids);
		IF (@personIsFiltered = 1) BEGIN
			IF (@isFiltered = 0)
				IF (@isExcluded = 0)
					INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
					INNER JOIN	@person	X	ON	D.[DayPersonId]	= X.[Id];
				ELSE
					INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
					LEFT JOIN	@person	X	ON	D.[DayPersonId]	= X.[Id]
					WHERE X.[Id] IS NULL;
			ELSE
				IF (@isExcluded = 0)
					DELETE X FROM @day	X
					LEFT JOIN
					(
						SELECT D.[DayId] FROM [Slice].[Day] D
						INNER JOIN	@person	X	ON	D.[DayPersonId]	= X.[Id]
					)	D	ON	X.[Id]	= D.[DayId]
					WHERE D.[DayId] IS NULL;
				ELSE
					DELETE X FROM @day	X
					LEFT JOIN
					(
						SELECT D.[DayId] FROM [Slice].[Day] D
						LEFT JOIN	@person	X	ON	D.[DayPersonId]	= X.[Id]
						WHERE X.[Id] IS NULL
					)	D	ON	X.[Id]	= D.[DayId]
					WHERE D.[DayId] IS NULL;
			SET @isFiltered = 1;
		END
	END

--	Filter by weekdays
	DECLARE @weekdays INT;
	SELECT @weekdays = ISNULL(X.[Entity].value('(Value/text())[1]', 'INT'), 0) FROM @predicate.nodes('/*/Weekdays') X ([Entity]);
	IF (@weekdays IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Weekdays/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, D.[DayDate]) - 1)) = @weekdays;
			ELSE 
				INSERT @day SELECT D.[DayId] FROM [Slice].[Day] D
				WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, D.[DayDate]) - 1)) <> @weekdays;
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, D.[DayDate]) - 1)) = @weekdays
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
			ELSE
				DELETE X FROM @day	X
				LEFT JOIN
				(
					SELECT D.[DayId] FROM [Slice].[Day] D
					WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, D.[DayDate]) - 1)) <> @weekdays
				)	D	ON	X.[Id]	= D.[DayId]
				WHERE D.[DayId] IS NULL;
		SET @isFiltered = 1;
	END

	SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/IsExcluded')), 0);

	SET @guids = (SELECT X.[Id] [guid] FROM @day X FOR XML PATH(''), ROOT('Guids'));

	IF (@isCountable = 0) RETURN;

--	Apply filters
	IF (@isFiltered = 0)
		SELECT @number = COUNT(*) FROM [Slice].[Day] D;
	ELSE
		IF (@isExcluded = 0)
			SELECT @number = COUNT(*) FROM @day X;
		ELSE
			SELECT @number = COUNT(*) FROM [Slice].[Day] D
			LEFT JOIN	@day	X	ON	D.[DayId] = X.[Id]
			WHERE X.[Id] IS NULL;

END
GO
