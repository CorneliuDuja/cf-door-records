SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'State'	AND
			O.[type]	= 'FN'		AND
			O.[name]	= 'Schedule.Scalar'))
	DROP FUNCTION [State].[Schedule.Scalar];
GO

CREATE FUNCTION [State].[Schedule.Scalar]
(
	@id			UNIQUEIDENTIFIER,
	@personId	UNIQUEIDENTIFIER,
	@startedOn	DATETIMEOFFSET,
	@endedOn	DATETIMEOFFSET
)
RETURNS BIT
AS
BEGIN
	DECLARE @isValid BIT;
	SET @isValid = 1;
	IF (EXISTS 
		(
			SELECT * FROM [State].[Schedule] S
			WHERE 
				S.[SchedulePersonId] = @personId	AND 
				(
					(S.[ScheduleStartedOn] <= @startedOn AND @startedOn < S.[ScheduleEndedOn])	OR
					(@startedOn <= S.[ScheduleStartedOn] AND S.[ScheduleStartedOn] < @endedOn)
				)	AND
				S.[ScheduleId] <> @id
		)
	) SET @isValid = 0;
	RETURN @isValid;
END

GO


