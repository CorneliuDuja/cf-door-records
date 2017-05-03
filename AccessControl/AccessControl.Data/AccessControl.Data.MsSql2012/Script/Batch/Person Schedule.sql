SELECT * FROM [State].[Schedule] S;

SELECT * FROM [Feed].[Person] P ORDER BY P.[PersonName];

INSERT [State].[Schedule]
        ( [SchedulePersonId] ,
          [ScheduleStartedOn] ,
          [ScheduleEndedOn] ,
          [ScheduleDuration]
        )
VALUES  ( 'DFABB735-D6AA-E411-B723-005056B6557D' , -- SchedulePersonId - uniqueidentifier
          '1800-01-01' , -- ScheduleStartedOn - datetime
          '2015-02-01' , -- ScheduleEndedOn - datetime
          28800  -- ScheduleDuration - float
        );

INSERT [State].[Schedule]
        ( [SchedulePersonId] ,
          [ScheduleStartedOn] ,
          [ScheduleEndedOn] ,
          [ScheduleDuration]
        )
VALUES  ( 'DFABB735-D6AA-E411-B723-005056B6557D' , -- SchedulePersonId - uniqueidentifier
          '2015-02-01' , -- ScheduleStartedOn - datetime
          '2200-01-01' , -- ScheduleEndedOn - datetime
          21600  -- ScheduleDuration - float
        );

SELECT * FROM [State].[Schedule.View] S;
