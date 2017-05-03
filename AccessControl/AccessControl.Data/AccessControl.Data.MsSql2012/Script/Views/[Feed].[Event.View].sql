SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Feed'	AND
			O.[type]	= 'V'		AND
			O.[name]	= 'Event.View'))
	DROP VIEW [Feed].[Event.View];
GO

CREATE VIEW [Feed].[Event.View]
AS
SELECT * FROM [Feed].[Event]	E
INNER JOIN	[Feed].[Source]		S	ON	E.[EventSourceId]	= S.[SourceId]
INNER JOIN	[Feed].[Person]		PR	ON	E.[EventPersonId]	= PR.[PersonId]
INNER JOIN	[Feed].[Point]		PN	ON	E.[EventPointId]	= PN.[PointId]
GO
