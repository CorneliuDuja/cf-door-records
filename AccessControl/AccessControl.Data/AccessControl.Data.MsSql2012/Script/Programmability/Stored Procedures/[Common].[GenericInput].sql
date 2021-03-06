SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Common'	AND
			O.[type]	= 'P'		AND
			O.[name]	= 'GenericInput'))
	DROP PROCEDURE [Common].[GenericInput];
GO

CREATE PROCEDURE [Common].[GenericInput] 
(
	@genericInput	XML,
	@actionType		NVARCHAR(MAX)	OUTPUT,
	@entity			XML				OUTPUT,
	@predicate		XML				OUTPUT,
	@index			INT				OUTPUT,
	@size			INT				OUTPUT,
	@startNumber	INT				OUTPUT,
	@endNumber		INT				OUTPUT,
	@order			NVARCHAR(MAX)	OUTPUT
)
AS
BEGIN
	
	SELECT 
		@actionType		= X.[Entity].value('(ActionType/text())[1]', 'NVARCHAR(MAX)'),
		@entity			= @genericInput.query('/*/Entity'),
		@predicate		= @genericInput.query('/*/Predicate')
	FROM @genericInput.nodes('/*') X ([Entity]);
	
	SELECT 
		@index			= X.[Index],
		@size			= X.[Size],
		@startNumber	= X.[StartNumber], 
		@endNumber		= X.[EndNumber] 
	FROM [Common].[Pager.Table](@predicate.query('/*/Pager')) X;
	
	SELECT @order = X.[Entity].value('(Order/text())[1]', 'NVARCHAR(MAX)') FROM @predicate.nodes('/*') X ([Entity]);

END
GO
