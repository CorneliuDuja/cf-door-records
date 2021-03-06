SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'State'	AND
			O.[type]	= 'P'		AND
			O.[name]	= 'Schedule.Action'))
	DROP PROCEDURE [State].[Schedule.Action];
GO

CREATE PROCEDURE [State].[Schedule.Action]
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
	
	IF (@actionType = 'ScheduleRead') BEGIN
		SELECT S.* FROM [State].[Schedule.View]			S
		INNER JOIN	[State].[Schedule.Table](@entity)	X	ON	S.[ScheduleId]	= X.[Id];
		SET @number = @@ROWCOUNT;
	END

END
GO
