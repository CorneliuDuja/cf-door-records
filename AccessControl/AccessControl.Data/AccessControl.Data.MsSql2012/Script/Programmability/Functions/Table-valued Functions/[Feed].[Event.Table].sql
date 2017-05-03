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
			O.[name]	= 'Event.Table'))
	DROP FUNCTION [Feed].[Event.Table];
GO

CREATE FUNCTION [Feed].[Event.Table](@entity XML)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		COALESCE(XI.[EventId], XPR.[EventId])	[Id],
		X.[SourceId],
		X.[PersonId],
		X.[PointId],
		X.[RegisteredOn],
		X.[IsEnforced],
		X.[IsObsolete],
		X.[Interval],
		X.[Duration]
	FROM
	(
		SELECT TOP 1
			X.[Id],
			S.[Id]	[SourceId],
			PR.[Id]	[PersonId],
			PN.[Id]	[PointId],
			X.[RegisteredOn],
			X.[IsEnforced],
			X.[IsObsolete],
			X.[Interval],
			X.[Duration]
		FROM 
		(
			SELECT
				X.[Entity].value('(Id/text())[1]',					'UNIQUEIDENTIFIER')	[Id],
				X.[Entity].query('Source')					   							[Source],
				X.[Entity].query('Person')					   							[Person],
				X.[Entity].query('Point')					   							[Point],
				[Common].[DateTimeOffset.Scalar](X.[Entity].query('RegisteredOn'))		[RegisteredOn],
				ISNULL(X.[Entity].value('(IsEnforced/text())[1]',	'BIT'), 0)			[IsEnforced],
				ISNULL(X.[Entity].value('(IsObsolete/text())[1]',	'BIT'), 0)			[IsObsolete],
				X.[Entity].value('(Interval/text())[1]',			'INT')				[Interval],
				X.[Entity].value('(Duration/text())[1]',			'FLOAT')			[Duration]
			FROM @entity.nodes('/*') X ([Entity])
		)												X
		OUTER APPLY	[Feed].[Source.Table](X.[Source])	S
		OUTER APPLY	[Feed].[Person.Table](X.[Person])	PR
		OUTER APPLY	[Feed].[Point.Table](X.[Point])		PN
	)							X
	LEFT JOIN	[Feed].[Event]	XI	ON	X.[Id]				= XI.[EventId]
	LEFT JOIN	[Feed].[Event]	XPR	ON	X.[PersonId]		= XPR.[EventPersonId]	AND
										X.[RegisteredOn]	= XPR.[EventRegisteredOn]
)
GO
