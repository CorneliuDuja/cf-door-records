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
			O.[name]	= 'Event.Filter'))
	DROP PROCEDURE [Feed].[Event.Filter];
GO

CREATE PROCEDURE [Feed].[Event.Filter]
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
	
	DECLARE @event TABLE ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);

	DECLARE 
		@dateFrom	DATETIMEOFFSET,
		@dateTo		DATETIMEOFFSET,
		@amountFrom FLOAT,
		@amountTo	FLOAT,
		@query		XML;
	
	SET @isFiltered = 0;

--	Filter by registered datetime offset
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/RegisteredOn/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/RegisteredOn/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventRegisteredOn] BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn]);
			ELSE 
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventRegisteredOn] NOT BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @event	X
				LEFT JOIN
				(
					SELECT E.[EventId] FROM [Feed].[Event] E
					WHERE E.[EventRegisteredOn] BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn])
				)	E	ON	X.[Id]	= E.[EventId]
				WHERE E.[EventId] IS NULL;
			ELSE
				DELETE X FROM @event	X
				LEFT JOIN
				(
					SELECT E.[EventId] FROM [Feed].[Event] E
					WHERE E.[EventRegisteredOn] NOT BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn])
				)	E	ON	X.[Id]	= E.[EventId]
				WHERE E.[EventId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by enforced status
	DECLARE @isEnforced BIT;
	SET @isEnforced = [Common].[Bool.Scalar](@predicate.query('/*/IsEnforced'));
	IF (@isEnforced IS NOT NULL) BEGIN
		IF (@isFiltered = 0)
			INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
			WHERE E.[EventIsEnforced] = @isEnforced;
		ELSE
			DELETE X FROM @event	X
			LEFT JOIN
			(
				SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventIsEnforced] = @isEnforced
			)	E	ON	X.[Id]	= E.[EventId]
			WHERE E.[EventId]	IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by obsolete status
	DECLARE @isObsolete BIT;
	SET @isObsolete = [Common].[Bool.Scalar](@predicate.query('/*/IsObsolete'));
	IF (@isObsolete IS NOT NULL) BEGIN
		IF (@isFiltered = 0)
			INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
			WHERE E.[EventIsObsolete] = @isObsolete;
		ELSE
			DELETE X FROM @event	X
			LEFT JOIN
			(
				SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventIsObsolete] = @isObsolete
			)	E	ON	X.[Id]	= E.[EventId]
			WHERE E.[EventId]	IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by interval
	SELECT @amountFrom = NULL, @amountTo = NULL;
	SELECT 
		@amountFrom	= X.[AmountFrom], 
		@amountTo	= X.[AmountTo] 
	FROM [Common].[AmountInterval.Table](@predicate.query('/*/Interval/Value')) X;
	IF (COALESCE(@amountFrom, @amountTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Interval/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventInterval] BETWEEN ISNULL(@amountFrom, E.[EventInterval]) AND ISNULL(@amountTo, E.[EventInterval]);
			ELSE 
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventInterval] NOT BETWEEN ISNULL(@amountFrom, E.[EventInterval]) AND ISNULL(@amountTo, E.[EventInterval]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @event	X
				LEFT JOIN
				(
					SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventInterval] BETWEEN ISNULL(@amountFrom, E.[EventInterval]) AND ISNULL(@amountTo, E.[EventInterval])	
				)	E	ON	X.[Id]	= E.[EventId]
				WHERE E.[EventId] IS NULL;
			ELSE
				DELETE X FROM @event	X
				LEFT JOIN
				(
					SELECT E.[EventId] FROM [Feed].[Event] E
					WHERE E.[EventInterval] NOT BETWEEN ISNULL(@amountFrom, E.[EventInterval]) AND ISNULL(@amountTo, E.[EventInterval])
				)	E	ON	X.[Id]	= E.[EventId]
				WHERE E.[EventId] IS NULL;
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
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventDuration] BETWEEN ISNULL(@amountFrom, E.[EventDuration]) AND ISNULL(@amountTo, E.[EventDuration]);
			ELSE 
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventDuration] NOT BETWEEN ISNULL(@amountFrom, E.[EventDuration]) AND ISNULL(@amountTo, E.[EventDuration]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @event	X
				LEFT JOIN
				(
					SELECT E.[EventId] FROM [Feed].[Event] E
					WHERE E.[EventDuration] BETWEEN ISNULL(@amountFrom, E.[EventDuration]) AND ISNULL(@amountTo, E.[EventDuration])
				)	E	ON	X.[Id]	= E.[EventId]
				WHERE E.[EventId] IS NULL;
			ELSE
				DELETE X FROM @event	X
				LEFT JOIN
				(
					SELECT E.[EventId] FROM [Feed].[Event] E
					WHERE E.[EventDuration] NOT BETWEEN ISNULL(@amountFrom, E.[EventDuration]) AND ISNULL(@amountTo, E.[EventDuration])
				)	E	ON	X.[Id]	= E.[EventId]
				WHERE E.[EventId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by event
	SET @query = @predicate.query('/*/Event/Value/Event');
	DECLARE @entity TABLE ([Id] UNIQUEIDENTIFIER);
	INSERT @entity SELECT DISTINCT E.[Id]
	FROM [Common].[Entity.Table](@query) X
	CROSS APPLY [Feed].[Event.Table](X.[Entity]) E;
	IF (@@ROWCOUNT > 0) BEGIN
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Event/IsExcluded')), 0);
		DELETE X FROM @entity X WHERE X.[Id] IS NULL;
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @event SELECT * FROM @entity;
			ELSE
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE E.[EventId] NOT IN (SELECT * FROM @entity);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @event X WHERE X.[Id] NOT IN (SELECT * FROM @entity);
			ELSE
				DELETE X FROM @event X WHERE X.[Id] IN (SELECT * FROM @entity);
		SET @isFiltered = 1;
	END

--	Filter by source predicate
	DECLARE 
		@sourcePredicate	XML,
		@sourceIsCountable	BIT,
		@sourceGuids		XML,
		@sourceIsFiltered	BIT,
		@sourceNumber		INT;
	SELECT 
		@sourcePredicate	= @predicate.query('/*/SourcePredicate'),
		@sourceIsCountable	= 0,
		@sourceIsFiltered	= @predicate.exist('/*/SourcePredicate/*');
	IF (@sourceIsFiltered = 1) BEGIN
		DECLARE @source TABLE ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);
		EXEC sp_executesql 
			N'EXEC [Feed].[Source.Filter]
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
			@predicate		= @sourcePredicate,
			@isCountable	= @sourceIsCountable,
			@guids			= @sourceGuids			OUTPUT,
			@isExcluded		= @isExcluded			OUTPUT,
			@isFiltered		= @sourceIsFiltered		OUTPUT,
			@number			= @sourceNumber			OUTPUT;
		INSERT @source SELECT * FROM [Common].[Guid.Table](@sourceGuids);
		IF (@sourceIsFiltered = 1) BEGIN
			IF (@isFiltered = 0)
				IF (@isExcluded = 0)
					INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
					INNER JOIN	@source	X	ON	E.[EventSourceId]	= X.[Id];
				ELSE
					INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
					LEFT JOIN	@source	X	ON	E.[EventSourceId]	= X.[Id]
					WHERE X.[Id] IS NULL;
			ELSE
				IF (@isExcluded = 0)
					DELETE X FROM @event	X
					LEFT JOIN
					(
						SELECT E.[EventId] FROM [Feed].[Event] E
						INNER JOIN	@source	X	ON	E.[EventSourceId]	= X.[Id]
					)	E	ON	X.[Id]	= E.[EventId]
					WHERE E.[EventId] IS NULL;
				ELSE
					DELETE X FROM @event	X
					LEFT JOIN
					(
						SELECT E.[EventId] FROM [Feed].[Event] E
						LEFT JOIN	@source	X	ON	E.[EventSourceId]	= X.[Id]
						WHERE X.[Id] IS NULL
					)	E	ON	X.[Id]	= E.[EventId]
					WHERE E.[EventId] IS NULL;
			SET @isFiltered = 1;
		END
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
					INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
					INNER JOIN	@person	X	ON	E.[EventPersonId]	= X.[Id];
				ELSE
					INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
					LEFT JOIN	@person	X	ON	E.[EventPersonId]	= X.[Id]
					WHERE X.[Id] IS NULL;
			ELSE
				IF (@isExcluded = 0)
					DELETE X FROM @event	X
					LEFT JOIN
					(
						SELECT E.[EventId] FROM [Feed].[Event] E
						INNER JOIN	@person	X	ON	E.[EventPersonId]	= X.[Id]
					)	E	ON	X.[Id]	= E.[EventId]
					WHERE E.[EventId] IS NULL;
				ELSE
					DELETE X FROM @event	X
					LEFT JOIN
					(
						SELECT E.[EventId] FROM [Feed].[Event] E
						LEFT JOIN	@person	X	ON	E.[EventPersonId]	= X.[Id]
						WHERE X.[Id] IS NULL
					)	E	ON	X.[Id]	= E.[EventId]
					WHERE E.[EventId] IS NULL;
			SET @isFiltered = 1;
		END
	END

--	Filter by point predicate
	DECLARE 
		@pointPredicate		XML,
		@pointIsCountable	BIT,
		@pointGuids			XML,
		@pointIsFiltered	BIT,
		@pointNumber		INT;
	SELECT 
		@pointPredicate		= @predicate.query('/*/PointPredicate'),
		@pointIsCountable	= 0,
		@pointIsFiltered	= @predicate.exist('/*/PointPredicate/*');
	IF (@pointIsFiltered = 1) BEGIN
		DECLARE @point TABLE ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);
		EXEC sp_executesql 
			N'EXEC [Feed].[Point.Filter]
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
			@predicate		= @pointPredicate,
			@isCountable	= @pointIsCountable,
			@guids			= @pointGuids			OUTPUT,
			@isExcluded		= @isExcluded			OUTPUT,
			@isFiltered		= @pointIsFiltered		OUTPUT,
			@number			= @pointNumber			OUTPUT;
		INSERT @point SELECT * FROM [Common].[Guid.Table](@pointGuids);
		IF (@pointIsFiltered = 1) BEGIN
			IF (@isFiltered = 0)
				IF (@isExcluded = 0)
					INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
					INNER JOIN	@point	X	ON	E.[EventPointId]	= X.[Id];
				ELSE
					INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
					LEFT JOIN	@point	X	ON	E.[EventPointId]	= X.[Id]
					WHERE X.[Id] IS NULL;
			ELSE
				IF (@isExcluded = 0)
					DELETE X FROM @event	X
					LEFT JOIN
					(
						SELECT E.[EventId] FROM [Feed].[Event] E
						INNER JOIN	@point	X	ON	E.[EventPointId]	= X.[Id]
					)	E	ON	X.[Id]	= E.[EventId]
					WHERE E.[EventId] IS NULL;
				ELSE
					DELETE X FROM @event	X
					LEFT JOIN
					(
						SELECT E.[EventId] FROM [Feed].[Event] E
						LEFT JOIN	@point	X	ON	E.[EventPointId]	= X.[Id]
						WHERE X.[Id] IS NULL
					)	E	ON	X.[Id]	= E.[EventId]
					WHERE E.[EventId] IS NULL;
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
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, E.[EventRegisteredOn]) - 1)) = @weekdays;
			ELSE 
				INSERT @event SELECT E.[EventId] FROM [Feed].[Event] E
				WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, E.[EventRegisteredOn]) - 1)) <> @weekdays;
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @event	X
				LEFT JOIN
				(
					SELECT E.[EventId] FROM [Feed].[Event] E
					WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, E.[EventRegisteredOn]) - 1)) = @weekdays
				)	E	ON	X.[Id]	= E.[EventId]
				WHERE E.[EventId] IS NULL;
			ELSE
				DELETE X FROM @event	X
				LEFT JOIN
				(
					SELECT E.[EventId] FROM [Feed].[Event] E
					WHERE (@weekdays | POWER(2, DATEPART(WEEKDAY, E.[EventRegisteredOn]) - 1)) <> @weekdays
				)	E	ON	X.[Id]	= E.[EventId]
				WHERE E.[EventId] IS NULL;
		SET @isFiltered = 1;
	END

	SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/IsExcluded')), 0);

	SET @guids = (SELECT X.[Id] [guid] FROM @event X FOR XML PATH(''), ROOT('Guids'));

	IF (@isCountable = 0) RETURN;

--	Apply filters
	IF (@isFiltered = 0)
		SELECT @number = COUNT(*) FROM [Feed].[Event] E;
	ELSE
		IF (@isExcluded = 0)
			SELECT @number = COUNT(*) FROM @event X;
		ELSE
			SELECT @number = COUNT(*) FROM [Feed].[Event] E
			LEFT JOIN	@event	X	ON	E.[EventId] = X.[Id]
			WHERE X.[Id] IS NULL;

END
GO
