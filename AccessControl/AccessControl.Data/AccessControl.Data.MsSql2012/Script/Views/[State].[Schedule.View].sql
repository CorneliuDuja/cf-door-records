SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'State'	AND
			O.[type]	= 'V'		AND
			O.[name]	= 'Schedule.View'))
	DROP VIEW [State].[Schedule.View];
GO

CREATE VIEW [State].[Schedule.View]
AS
SELECT * FROM [State].[Schedule]	S
INNER JOIN	[Feed].[Person]			P	ON	S.[SchedulePersonId]	= P.[PersonId]
GO
