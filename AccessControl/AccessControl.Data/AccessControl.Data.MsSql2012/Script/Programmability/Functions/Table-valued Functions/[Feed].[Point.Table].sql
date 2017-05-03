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
			O.[name]	= 'Point.Table'))
	DROP FUNCTION [Feed].[Point.Table];
GO

CREATE FUNCTION [Feed].[Point.Table](@entity XML)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP 1
		COALESCE(XI.[PointId], XN.[PointId])	[Id],
		X.[Name],
		X.[PointActionType]
	FROM 
	(
		SELECT
			X.[Entity].value('(Id/text())[1]',				'UNIQUEIDENTIFIER')											[Id],
			X.[Entity].value('(Name/text())[1]',			'NVARCHAR(MAX)')	COLLATE SQL_Latin1_General_CP1_CS_AS	[Name],
			X.[Entity].value('(PointActionType/text())[1]',	'NVARCHAR(MAX)')											[PointActionType]
		FROM @entity.nodes('/*') X ([Entity])
	)							X
	LEFT JOIN	[Feed].[Point]	XI	ON	X.[Id]		= XI.[PointId]
	LEFT JOIN	[Feed].[Point]	XN	ON	X.[Name]	= XN.[PointName]
)
GO
