SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'State'	AND
			O.[type]	= 'IF'		AND
			O.[name]	= 'Schedule.Table'))
	DROP FUNCTION [State].[Schedule.Table];
GO

CREATE FUNCTION [State].[Schedule.Table](@entity XML)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		COALESCE(XI.[ScheduleId], XPSE.[ScheduleId])	[Id],
		X.[PersonId],
		X.[StartedOn],
		X.[EndedOn],
		X.[Duration],
		X.[AppliedOn]
	FROM 
	(
		SELECT TOP 1
			X.[Id],
			P.[Id]	[PersonId],
			X.[StartedOn],
			X.[EndedOn],
			X.[Duration],
			X.[AppliedOn]
		FROM 
		(
			SELECT
				X.[Entity].value('(Id/text())[1]',				'UNIQUEIDENTIFIER')	[Id],
				X.[Entity].query('Person')											[Person],
				[Common].[DateTimeOffset.Scalar](X.[Entity].query('StartedOn'))		[StartedOn],
				[Common].[DateTimeOffset.Scalar](X.[Entity].query('EndedOn'))		[EndedOn],
				ISNULL(X.[Entity].value('(Duration/text())[1]',	'FLOAT'), 0)		[Duration],
				[Common].[DateTimeOffset.Scalar](X.[Entity].query('AppliedOn'))		[AppliedOn]
			FROM @entity.nodes('/*') X ([Entity])
		)												X
		OUTER APPLY [Feed].[Person.Table](X.[Person])	P
	)								X
	LEFT JOIN	[State].[Schedule]	XI		ON	X.[Id]			= XI.[ScheduleId]
	LEFT JOIN	[State].[Schedule]	XPSE	ON	X.[PersonId]	= XPSE.[SchedulePersonId]	AND
												(XPSE.[ScheduleStartedOn] <= X.[AppliedOn] AND X.[AppliedOn] < XPSE.[ScheduleEndedOn])
)
GO
