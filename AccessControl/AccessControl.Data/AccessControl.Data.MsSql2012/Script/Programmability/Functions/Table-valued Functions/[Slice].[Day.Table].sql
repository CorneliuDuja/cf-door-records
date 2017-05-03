SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Slice'	AND
			O.[type]	= 'IF'		AND
			O.[name]	= 'Day.Table'))
	DROP FUNCTION [Slice].[Day.Table];
GO

CREATE FUNCTION [Slice].[Day.Table](@entity XML)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		COALESCE(XI.[DayId], XPD.[DayId])	[Id],
		X.[PersonId],
		X.[Date],
		X.[FirstIn],
		X.[LastOut],
		X.[Duration],
		X.[Deviation],
		X.[Trusted],
		X.[Doubtful],
		X.[Reliability]
	FROM
	(
		SELECT TOP 1
			X.[Id],
			P.[Id]	[PersonId],
			X.[Date],
			X.[FirstIn],
			X.[LastOut],
			X.[Duration],
			X.[Deviation],
			X.[Trusted],
			X.[Doubtful],
			X.[Reliability]
		FROM 
		(
			SELECT
				X.[Entity].value('(Id/text())[1]',					'UNIQUEIDENTIFIER')	[Id],
				X.[Entity].query('Person')					   							[Person],
				[Common].[DateTimeOffset.Scalar](X.[Entity].query('Date'))				[Date],
				[Common].[DateTimeOffset.Scalar](X.[Entity].query('FirstIn'))			[FirstIn],
				[Common].[DateTimeOffset.Scalar](X.[Entity].query('LastOut'))			[LastOut],
				ISNULL(X.[Entity].value('(Duration/text())[1]',		'FLOAT'), 0)		[Duration],
				ISNULL(X.[Entity].value('(Deviation/text())[1]',	'FLOAT'), 0)		[Deviation],
				ISNULL(X.[Entity].value('(Trusted/text())[1]',		'FLOAT'), 0)		[Trusted],
				ISNULL(X.[Entity].value('(Doubtful/text())[1]',		'FLOAT'), 0)		[Doubtful],
				ISNULL(X.[Entity].value('(Reliability/text())[1]',	'FLOAT'), 0)		[Reliability]
			FROM @entity.nodes('/*') X ([Entity])
		)												X
		OUTER APPLY	[Feed].[Person.Table](X.[Person])	P
	)							X
	LEFT JOIN	[Slice].[Day]	XI	ON	X.[Id]			= XI.[DayId]
	LEFT JOIN	[Slice].[Day]	XPD	ON	X.[PersonId]	= XPD.[DayPersonId]	AND
										X.[Date]		= XPD.[DayDate]
)
GO
