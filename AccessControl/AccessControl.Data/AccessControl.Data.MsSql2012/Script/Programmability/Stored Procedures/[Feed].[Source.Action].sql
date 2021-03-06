SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Feed'	AND
			O.[type]	= 'P'		AND
			O.[name]	= 'Source.Action'))
	DROP PROCEDURE [Feed].[Source.Action];
GO

CREATE PROCEDURE [Feed].[Source.Action]
(
	@genericInput	XML,
	@number			INT	OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE 
		@actionType		NVARCHAR(MAX),
		@entity			XML,
		@predicate		XML,
		@index			INT,
		@size			INT,
		@startNumber	INT,
		@endNumber		INT,
		@order			NVARCHAR(MAX),
		@isCountable	BIT,
		@guids			XML,
		@isExcluded		BIT,
		@isFiltered		BIT,
		@command		NVARCHAR(MAX);
	
	DECLARE @output TABLE ([Id] UNIQUEIDENTIFIER);
	
	EXEC [Common].[GenericInput] 
		@genericInput	= @genericInput,
		@actionType		= @actionType		OUTPUT,
		@entity			= @entity			OUTPUT,
		@predicate		= @predicate		OUTPUT,
		@index			= @index			OUTPUT,
		@size			= @size				OUTPUT,
		@startNumber	= @startNumber		OUTPUT,
		@endNumber		= @endNumber		OUTPUT,
		@order			= @order			OUTPUT;

	SELECT * INTO [#input] FROM [Feed].[Source.Table](@entity) X;
	
	IF (@actionType = 'SourceCreate') BEGIN
		BEGIN TRANSACTION;
		BEGIN TRY
			DELETE D FROM [Slice].[Day]		D
			INNER JOIN	[#input]			X	ON	D.[DayDate]	= X.[Date];
			DELETE E FROM [Feed].[Event]	E
			INNER JOIN	[#input]			X	ON	DATEADD(DAY, 0, DATEDIFF(DAY, 0, E.[EventRegisteredOn]))	= DATEADD(DAY, 0, DATEDIFF(DAY, 0, X.[Date]));
			DELETE S FROM [Feed].[Source]	S
			INNER JOIN	[#input]			X	ON	S.[SourceDate]	= X.[Date];
			INSERT [Feed].[Source]
			(
				[SourceDate],
			    [SourceFileType],
			    [SourceLoadedOn],
			    [SourceExtractedOn],
			    [SourceTransformedOn],
			    [SourceAnalysedOn],
				[SourceLength]
			)
			OUTPUT INSERTED.[SourceId] INTO @output ([Id])
			SELECT 
				X.[Date],
			    X.[SourceFileType],
			    X.[LoadedOn],
			    X.[ExtractedOn],
			    X.[TransformedOn],
			    X.[AnalysedOn],
				X.[Length]
			FROM [#input] X;
			DECLARE
				@persons	XML	= @entity.query('/*/Persons/Person'),
				@points		XML	= @entity.query('/*/Points/Point'),
				@events		XML	= @entity.query('/*/Events/Event'),
				@days		XML	= @entity.query('/*/Days/Day');
			MERGE [Feed].[Person] P
			USING
			(
				SELECT P.* FROM [Common].[Entity.Table](@persons) X
				CROSS APPLY [Feed].[Person.Table](X.[Entity]) P
			)	X	ON	P.[PersonName]	= X.[Name]
			WHEN NOT MATCHED BY TARGET THEN INSERT
			(
				[PersonName],
                [PersonIsPrivate]
			)
			VALUES
			(
				X.[Name],
				X.[IsPrivate]
			);
			WITH XN AS
			(
				SELECT ISNULL(MAX(CAST(P.[PointName] AS INT)), 0) + 1	[Name]
				FROM [Feed].[Point] P
				WHERE ISNUMERIC(P.[PointName]) = 1
			)
			MERGE [Feed].[Point] P
			USING
			(
				SELECT 
					ISNULL(P.[Name], XN.[Name]) [Name],
					P.[PointActionType]
				FROM [Common].[Entity.Table](@points) X
				CROSS APPLY [Feed].[Point.Table](X.[Entity]) P
				OUTER APPLY XN
			)	X	ON	P.[PointName]	= X.[Name]
			WHEN NOT MATCHED BY TARGET THEN INSERT
			(
				[PointName],
                [PointActionType]
			)
			VALUES
			(
				X.[Name],
				X.[PointActionType]
			);
			MERGE [Feed].[Event] E
			USING
			(
				SELECT 
					S.[Id] [SourceId],
					E.[PersonId],
					E.[PointId],
					E.[RegisteredOn],
					E.[IsEnforced],
					E.[IsObsolete],
					E.[Interval],
					E.[Duration]
				FROM @output S,
				[Common].[Entity.Table](@events) X
				CROSS APPLY [Feed].[Event.Table](X.[Entity]) E
			)	X	ON	E.[EventPersonId]		= X.[PersonId]	AND
						E.[EventRegisteredOn]	= X.[RegisteredOn]
			WHEN NOT MATCHED BY TARGET THEN INSERT
			(
				[EventSourceId],
                [EventPersonId],
				[EventPointId],
				[EventRegisteredOn],
				[EventIsEnforced],
				[EventIsObsolete],
				[EventInterval],
				[EventDuration]
			)
			VALUES
			(
				X.[SourceId],
                X.[PersonId],
				X.[PointId],
				X.[RegisteredOn],
				X.[IsEnforced],
				X.[IsObsolete],
				X.[Interval],
				X.[Duration]
			);
			MERGE [Slice].[Day] D
			USING
			(
				SELECT D.* FROM [Common].[Entity.Table](@days) X
				CROSS APPLY [Slice].[Day.Table](X.[Entity]) D
			)	X	ON	D.[DayPersonId]	= X.[PersonId]	AND
						D.[DayDate]		= X.[Date]
			WHEN NOT MATCHED BY TARGET THEN INSERT
			(
				[DayPersonId],
                [DayDate],
				[DayFirstIn],
				[DayLastOut],
				[DayDuration],
				[DayDeviation],
				[DayTrusted],
				[DayDoubtful],
				[DayReliability]
			)
			VALUES
			(
				X.[PersonId],
                X.[Date],
				X.[FirstIn],
				X.[LastOut],
				X.[Duration],
				X.[Deviation],
				X.[Trusted],
				X.[Doubtful],
				X.[Reliability]
			);
			UPDATE D SET D.[DayDeviation] = D.[DayDuration] - S.[ScheduleDuration] 
			FROM [Slice].[Day]				D
			INNER JOIN [State].[Schedule]	S	ON	D.[DayPersonId] = S.[SchedulePersonId]	AND 
													(S.[ScheduleStartedOn] <= D.[DayDate] AND D.[DayDate] < S.[ScheduleEndedOn])	AND
													(S.[ScheduleWeekdays] | POWER(2, DATEPART(WEEKDAY, D.[DayDate]) - 1)) = S.[ScheduleWeekdays];
			COMMIT TRANSACTION;
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION;
			EXEC [Common].[Error.Throw];
		END CATCH;	
		SELECT S.* FROM [Feed].[Source]	S
		INNER JOIN	@output				X	ON	S.[SourceId]	= X.[Id];
		SET @number = @@ROWCOUNT;
	END
	
	IF (@actionType = 'SourceRead') BEGIN
		SELECT S.* FROM [Feed].[Source]	S
		INNER JOIN	[#input]			X	ON	S.[SourceId]	= X.[Id];
		SET @number = @@ROWCOUNT;
	END
	
	IF (@actionType = 'SourceSelect') BEGIN
		CREATE TABLE [#source] ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);
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
			@predicate		= @predicate,
			@isCountable	= @isCountable,
			@guids			= @guids		OUTPUT,
			@isExcluded		= @isExcluded	OUTPUT,
			@isFiltered		= @isFiltered	OUTPUT,
			@number			= @number		OUTPUT;
		INSERT [#source] SELECT * FROM [Common].[Guid.Table](@guids);
		SET @order = ISNULL(@order, ' ORDER BY [SourceDate] DESC ');
		IF (@isFiltered = 0)
			SET @command = '
			SELECT S.* FROM [Feed].[Source] S
			';
		ELSE
			IF (@isExcluded = 0)
				SET @command = '
				SELECT S.* FROM [#source]	X
				INNER JOIN	[Feed].[Source]	S	ON	X.[Id]	= S.[SourceId]
				';
			ELSE
				SET @command = '
				SELECT S.* FROM [Feed].[Source]	S
				LEFT JOIN	[#source]			X	ON	S.[SourceId]	= X.[Id]
				WHERE X.[Id] IS NULL
				';
		SET @command = @command + @order;
		IF (@startNumber IS NOT NULL AND @size IS NOT NULL)
			SET @command = @command + ' OFFSET ' + CAST(@startNumber AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@size AS NVARCHAR(MAX)) + ' ROWS ONLY ';
		EXEC sp_executesql @command;
	END

END
GO
