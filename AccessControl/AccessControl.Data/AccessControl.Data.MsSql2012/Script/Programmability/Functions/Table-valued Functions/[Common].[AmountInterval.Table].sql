SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Common'	AND
			O.[type]	= 'IF'		AND
			O.[name]	= 'AmountInterval.Table'))
	DROP FUNCTION [Common].[AmountInterval.Table];
GO

CREATE FUNCTION [Common].[AmountInterval.Table](@entity XML)
RETURNS TABLE 
AS
RETURN
(
	SELECT 
		X.[Entity].value('(AmountFrom/text())[1]',	'FLOAT')	[AmountFrom],
		X.[Entity].value('(AmountTo/text())[1]',	'FLOAT')	[AmountTo]
	FROM @entity.nodes('/*') X ([Entity])
)
GO
