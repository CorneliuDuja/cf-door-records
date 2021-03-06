SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Slice'	AND
			O.[type]	= 'P'		AND
			O.[name]	= 'Day.Action'))
	DROP PROCEDURE [Slice].[Day.Action];
GO

CREATE PROCEDURE [Slice].[Day.Action]
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

	IF (@actionType LIKE '%Select') BEGIN
		CREATE TABLE [#day] ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);
		EXEC sp_executesql 
			N'EXEC [Slice].[Day.Filter]
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
		INSERT [#day] SELECT * FROM [Common].[Guid.Table](@guids);
	END
	
	IF (@actionType = 'DaySelect') BEGIN
		SET @order = ISNULL(@order, ' ORDER BY [PersonName] ASC, [DayDate] ASC ');
		IF (@isFiltered = 0)
			SET @command = '
			SELECT D.* FROM [Slice].[Day.View] D
			';
		ELSE
			IF (@isExcluded = 0)
				SET @command = '
				SELECT D.* FROM [#day]			X
				INNER JOIN	[Slice].[Day.View]	D	ON	X.[Id]	= D.[DayId]
				';
			ELSE
				SET @command = '
				SELECT D.* FROM [Slice].[Day.View]	D
				LEFT JOIN	[#day]					X	ON	D.[DayId]	= X.[Id]
				WHERE X.[Id] IS NULL
				';
		SET @command = @command + @order;
		IF (@startNumber IS NOT NULL AND @size IS NOT NULL)
			SET @command = @command + ' OFFSET ' + CAST(@startNumber AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@size AS NVARCHAR(MAX)) + ' ROWS ONLY ';
		EXEC sp_executesql @command;
	END

	IF (@actionType = 'DayResumeSelect') BEGIN
		SET @order = ISNULL(@order, ' ORDER BY [PersonName] ASC ');
		SET @command = '
		SELECT * FROM 
		(
			SELECT
				X.[DayPersonId],
				COUNT(*)				[Days],
				MIN(X.[DayFirstIn])		[DayMinFirstIn],
				MAX(X.[DayFirstIn])		[DayMaxFirstIn],
				AVG(X.[DayFirstIn])		[DayAvgFirstIn],
				MIN(X.[DayLastOut])		[DayMinLastOut],
				MAX(X.[DayLastOut])		[DayMaxLastOut],
				AVG(X.[DayLastOut])		[DayAvgLastOut],
				MIN(X.[DayDuration])	[DayMinDuration],
				MAX(X.[DayDuration])	[DayMaxDuration],
				AVG(X.[DayDuration])	[DayAvgDuration],
				SUM(X.[DayDuration])	[DaySumDuration],
				MIN(X.[DayDeviation])	[DayMinDeviation],
				MAX(X.[DayDeviation])	[DayMaxDeviation],
				AVG(X.[DayDeviation])	[DayAvgDeviation],
				SUM(X.[DayDeviation])	[DaySumDeviation],
				MIN(X.[DayTrusted])		[DayMinTrusted],
				MAX(X.[DayTrusted])		[DayMaxTrusted],
				AVG(X.[DayTrusted])		[DayAvgTrusted],
				SUM(X.[DayTrusted])		[DaySumTrusted],
				MIN(X.[DayDoubtful])	[DayMinDoubtful],
				MAX(X.[DayDoubtful])	[DayMaxDoubtful],
				AVG(X.[DayDoubtful])	[DayAvgDoubtful],
				SUM(X.[DayDoubtful])	[DaySumDoubtful],
				MIN(X.[DayReliability])	[DayMinReliability],
				MAX(X.[DayReliability])	[DayMaxReliability],
				AVG(X.[DayReliability])	[DayAvgReliability]
			FROM
			(
				SELECT 
					D.[DayPersonId],
					D.[DayDate],
					CAST(DATEDIFF(SECOND, 0, CAST(D.[DayFirstIn] AS TIME)) AS FLOAT)	[DayFirstIn],
					CAST(DATEDIFF(SECOND, 0, CAST(D.[DayLastOut] AS TIME)) AS FLOAT)	[DayLastOut],
					D.[DayDuration],
					D.[DayDeviation],
					D.[DayTrusted],
					D.[DayDoubtful],
					D.[DayReliability]
				FROM [#day]					X
				INNER JOIN	[Slice].[Day]	D	ON	X.[Id]	= D.[DayId]
			)	X
			GROUP BY X.[DayPersonId]
		)							X
		INNER JOIN	[Feed].[Person]	P	ON	X.[DayPersonId]	= P.[PersonId]
		';
		SET @command = @command + @order;
		EXEC sp_executesql @command;
		SET @number = @@ROWCOUNT;
	END

END
GO
