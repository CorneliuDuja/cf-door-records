SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Feed'	AND
			O.[type]	= 'IF'		AND
			O.[name]	= 'Person.Table'))
	DROP FUNCTION [Feed].[Person.Table];
GO

CREATE FUNCTION [Feed].[Person.Table](@entity XML)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP 1
		COALESCE(XI.[PersonId], XN.[PersonId])	[Id],
		X.[Name],
		X.[IsPrivate]
	FROM 
	(
		SELECT
			X.[Entity].value('(Id/text())[1]',					'UNIQUEIDENTIFIER')											[Id],
			X.[Entity].value('(Name/text())[1]',				'NVARCHAR(MAX)')	COLLATE SQL_Latin1_General_CP1_CS_AS	[Name],
			ISNULL(X.[Entity].value('(IsPrivate/text())[1]',	'BIT'), 0)													[IsPrivate]
		FROM @entity.nodes('/*') X ([Entity])
	)							X
	LEFT JOIN	[Feed].[Person]	XI	ON	X.[Id]		= XI.[PersonId]
	LEFT JOIN	[Feed].[Person]	XN	ON	X.[Name]	= XN.[PersonName]
)
GO
