SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Slice'	AND
			O.[type]	= 'V'		AND
			O.[name]	= 'Day.View'))
	DROP VIEW [Slice].[Day.View];
GO

CREATE VIEW [Slice].[Day.View]
AS
SELECT * FROM [Slice].[Day]	D
INNER JOIN	[Feed].[Person]	P	ON	D.[DayPersonId]	= P.[PersonId]
GO
