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
			O.[name]	= 'Source.Table'))
	DROP FUNCTION [Feed].[Source.Table];
GO

CREATE FUNCTION [Feed].[Source.Table](@entity XML)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP 1
		COALESCE(XI.[SourceId], XN.[SourceId])	[Id],
		X.[Date],
		X.[SourceFileType],
		X.[LoadedOn],
		X.[ExtractedOn],
		X.[TransformedOn],
		X.[AnalysedOn],
		X.[Length]
	FROM 
	(
		SELECT
			X.[Entity].value('(Id/text())[1]',				'UNIQUEIDENTIFIER')	[Id],
			[Common].[DateTimeOffset.Scalar](X.[Entity].query('Date'))			[Date],
			X.[Entity].value('(SourceFileType/text())[1]',	'NVARCHAR(MAX)')	[SourceFileType],
			[Common].[DateTimeOffset.Scalar](X.[Entity].query('LoadedOn'))		[LoadedOn],
			[Common].[DateTimeOffset.Scalar](X.[Entity].query('ExtractedOn'))	[ExtractedOn],
			[Common].[DateTimeOffset.Scalar](X.[Entity].query('TransformedOn'))	[TransformedOn],
			[Common].[DateTimeOffset.Scalar](X.[Entity].query('AnalysedOn'))	[AnalysedOn],
			ISNULL(X.[Entity].value('(Length/text())[1]',	'BIGINT'), 0)		[Length]
		FROM @entity.nodes('/*') X ([Entity])
	)							X
	LEFT JOIN	[Feed].[Source]	XI	ON	X.[Id]		= XI.[SourceId]
	LEFT JOIN	[Feed].[Source]	XN	ON	X.[Date]	= XN.[SourceDate]
)
GO
