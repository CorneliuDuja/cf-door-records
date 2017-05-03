SELECT * FROM [Feed].[Source] S ORDER BY S.[SourceDate] DESC;

SELECT * FROM [Feed].[Person] P ORDER BY P.[PersonName];

SELECT * FROM [Feed].[Point] P;

SELECT * FROM [Feed].[Event] E ORDER BY E.[EventRegisteredOn] DESC;

SELECT * FROM [Slice].[Day] D ORDER BY D.[DayDate] DESC;

SELECT * FROM [Feed].[Event] E 
WHERE E.[EventPersonId] = 'D5126E81-585F-E411-95F1-00155D000B05'
AND E.[EventRegisteredOn] BETWEEN '20141015' AND '20141016'
ORDER BY E.[EventRegisteredOn] DESC;

SELECT * FROM [Slice].[Day] D
WHERE D.[DayPersonId] = 'D5126E81-585F-E411-95F1-00155D000B05'
AND D.[DayDate] = '20141015';

DELETE S FROM [Feed].[Source] S 
LEFT JOIN [Feed].[Event] E ON S.[SourceId] = E.[EventSourceId]
WHERE E.[EventId] IS NULL;

SELECT SUM(D.[DayDuration]) FROM [Slice].[Day] D

TRUNCATE TABLE [State].[Schedule];
TRUNCATE TABLE [Slice].[Day];
TRUNCATE TABLE [Feed].[Event];
DELETE P FROM [Feed].[Point] P;
DELETE P FROM [Feed].[Person] P;
DELETE S FROM [Feed].[Source] S;

SELECT * FROM [Feed].[Event] E
INNER JOIN [Feed].[Source] S ON E.[EventSourceId] = S.[SourceId]
WHERE S.[SourceDate] = '20141028'
ORDER BY E.[EventRegisteredOn] DESC;

SELECT * FROM [Feed].[Event.View] E
WHERE E.[SourceDate] = '20141028'
ORDER BY E.[EventRegisteredOn] DESC;

SELECT * FROM [Slice].[Day] D
WHERE D.[DayDate] BETWEEN '20141027' AND '20141028';

SELECT 
	D.[DayDate], 
	DATEADD(SECOND, AVG(DATEDIFF(SECOND, 0, CAST(D.[DayFirstIn] AS TIME))), 0), 
	AVG(DATEDIFF(SECOND, 0, CAST(D.[DayFirstIn] AS TIME)))
FROM [Slice].[Day] D
GROUP BY D.[DayDate];

declare @p2 int
set @p2=695
exec [Slice].[Day.Action] @genericInput=N'<GenericInputOfDayResumeDayPredicate7bZ_P6hY_S xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
  <ActionType>DayResumeSelect</ActionType>
  <Predicate>
    <Date>
      <Value>
        <DateTimeNow>2014-10-29T13:50:18.3126485+00:00</DateTimeNow>
        <DateIntervalType>CurrentYear</DateIntervalType>
        <DateFrom>2014-10-15T00:00:00</DateFrom>
        <DateTo>2014-10-16T00:00:00</DateTo>
      </Value>
    </Date>
  </Predicate>
</GenericInputOfDayResumeDayPredicate7bZ_P6hY_S>',@number=@p2 output
select @p2

SELECT * FROM [Slice].[Day.View] D
WHERE D.[PersonName] LIKE '%merjan%' OR D.[PersonName] LIKE '%Tatiana%';

SELECT * FROM [Slice].[Day.View] D
WHERE D.[PersonName] LIKE '%mama%';

SELECT MIN(E.[EventRegisteredOn]), MAX(E.[EventRegisteredOn]) FROM [Feed].[Event] E;

SELECT * FROM [Feed].[Person] P WHERE P.[PersonName] LIKE '%babii%';

SELECT 
	P.[PersonName],
	D.[DayDate],
	D.[DayDuration],
	D.[DayDeviation],
	S.[ScheduleStartedOn],
	S.[ScheduleEndedOn],
	S.[ScheduleDuration]
FROM [Slice].[Day] D
INNER JOIN [State].[Schedule] S ON D.[DayPersonId] = S.[SchedulePersonId] AND (S.[ScheduleStartedOn] <= D.[DayDate] AND D.[DayDate] < S.[ScheduleEndedOn])
INNER JOIN [Feed].[Person] P ON D.[DayPersonId] = P.[PersonId];

UPDATE D SET D.[DayDeviation] = D.[DayDuration] - S.[ScheduleDuration] FROM [Slice].[Day] D
INNER JOIN [State].[Schedule] S ON D.[DayPersonId] = S.[SchedulePersonId] AND (S.[ScheduleStartedOn] <= D.[DayDate] AND D.[DayDate] < S.[ScheduleEndedOn]);

SELECT * FROM [State].[Schedule.View] S ORDER BY S.[PersonName], S.[ScheduleStartedOn];

SELECT * FROM [Feed].[Person] P WHERE P.[PersonIsPrivate] = 1;

SELECT 
	P.[PersonName],
	D.[DayFirstIn],
	X.[FirstIn],
	D.[DayLastOut],
	X.[LastOut]
FROM [Slice].[Day]			D
INNER JOIN	[Feed].[Person]	P ON	D.[DayPersonId] = P.[PersonId]
INNER JOIN 
(
	SELECT 
		E.[EventPersonId]											[PersonId],
		DATEADD(DAY, 0, DATEDIFF(DAY, 0, E.[EventRegisteredOn]))	[Date],
		MIN(E.[EventRegisteredOn])									[FirstIn],
		MAX(E.[EventRegisteredOn])									[LastOut]
	FROM [Feed].[Event] E
	GROUP BY
		E.[EventPersonId],
		DATEADD(DAY, 0, DATEDIFF(DAY, 0, E.[EventRegisteredOn]))
)							X ON	D.[DayPersonId]	= X.[PersonId]	AND
									D.[DayDate]		= X.[Date]
WHERE 
	--ABS(DATEDIFF(SECOND, D.[DayFirstIn], X.[FirstIn])) > 1	OR
	--ABS(DATEDIFF(SECOND, D.[DayLastOut], X.[LastOut])) > 1;
	D.[DayFirstIn]	<>	X.[FirstIn]	OR
	D.[DayLastOut]	<>	X.[LastOut];

DECLARE 
	 @personName		NVARCHAR(MAX)		= 'Nelu Snegur'
	,@minDate			DATETIMEOFFSET		= '1800-01-01'
	,@maxDate			DATETIMEOFFSET		= '2200-01-01'
	,@date				DATETIMEOFFSET		= '2015-09-01'
	,@defaultDuration	INT					= 8*60*60
	,@currentDuration	INT					= 4*60*60
	,@weekdays			INT					= 62
	,@personId			UNIQUEIDENTIFIER;

SELECT @personId = P.[PersonId] FROM [Feed].[Person] P WHERE P.[PersonName] = @personName;

IF (@@ROWCOUNT = 1) BEGIN
	INSERT [State].[Schedule]
	( 
		 [SchedulePersonId]
		,[ScheduleStartedOn]
		,[ScheduleEndedOn]
		,[ScheduleDuration]
		,[ScheduleWeekdays]
	)
	VALUES
	(
		 @personId
		,@minDate
		,@date
		,@defaultDuration
		,@weekdays
	);
	INSERT [State].[Schedule]
	( 
		 [SchedulePersonId]
		,[ScheduleStartedOn]
		,[ScheduleEndedOn]
		,[ScheduleDuration]
		,[ScheduleWeekdays]
	)
	VALUES
	(
		 @personId
		,@date
		,@maxDate
		,@currentDuration
		,@weekdays
	);
END

--SELECT * FROM [State].[Schedule.View] S;

declare @p2 int
set @p2=695
exec [Slice].[Day.Action] @genericInput=N'<GenericInputOfDayResumeDayPredicate7bZ_P6hY_S xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
  <ActionType>DaySelect</ActionType>
  <Predicate>
    <Date>
      <Value>
        <DateTimeNow>2014-10-29T13:50:18.3126485+00:00</DateTimeNow>
        <DateIntervalType>CurrentYear</DateIntervalType>
        <DateFrom>2014-10-15T00:00:00</DateFrom>
        <DateTo>2014-10-16T00:00:00</DateTo>
      </Value>
    </Date>
	<Weekdays>
	  <Value>62</Value>
	</Weekdays>
  </Predicate>
</GenericInputOfDayResumeDayPredicate7bZ_P6hY_S>',@number=@p2 output
select @p2

declare @p2 int
set @p2=695
exec [Slice].[Day.Action] @genericInput=N'<GenericInputOfDayResumeDayPredicate7bZ_P6hY_S xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
  <ActionType>DaySelect</ActionType>
  <Predicate>
    <Date>
      <Value>
        <DateTimeNow>2014-10-29T13:50:18.3126485+00:00</DateTimeNow>
        <DateIntervalType>CurrentYear</DateIntervalType>
        <DateFrom>2015-05-04T00:00:00</DateFrom>
        <DateTo>2015-05-10T00:00:00</DateTo>
      </Value>
    </Date>
	<Weekdays>
	  <Value>62</Value>
	</Weekdays>
	<PersonPredicate>
	  <Person>
	    <Value>
	      <Person>
		    <Name>Paznic</Name>
		  </Person>
	    </Value>
	  </Person>
	</PersonPredicate>
  </Predicate>
</GenericInputOfDayResumeDayPredicate7bZ_P6hY_S>',@number=@p2 output
select @p2

UPDATE S SET S.[ScheduleWeekdays] = 62 FROM [State].[Schedule] S;

UPDATE D SET D.[DayDeviation] = D.[DayDuration] FROM [Slice].[Day] D
WHERE (62 | POWER(2, DATEPART(WEEKDAY, D.[DayDate]) - 1)) <> 62;

SELECT *
FROM 
(
	SELECT 
		*,
		DATEPART(TZOFFSET, E.[EventRegisteredOn])	[Offset]
	FROM [Feed].[Event] E 
) X
WHERE X.[Offset] <> 180
ORDER BY X.[EventRegisteredOn] DESC;
