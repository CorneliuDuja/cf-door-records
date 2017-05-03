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
			O.[name]	= 'String.Table'))
	DROP FUNCTION [Common].[String.Table];
GO

CREATE FUNCTION [Common].[String.Table](@entity XML)
RETURNS TABLE 
AS
RETURN
(
	SELECT X.[string] FROM
	(
		SELECT LTRIM(X.[Entity].value('(text())[1]',	'NVARCHAR(MAX)')) [string]
		FROM @entity.nodes('/*/string') X ([Entity])
	) X
)
GO
