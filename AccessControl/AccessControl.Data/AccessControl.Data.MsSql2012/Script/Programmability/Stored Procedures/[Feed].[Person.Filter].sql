SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF (EXISTS(
		SELECT * FROM [sys].[schemas]	S
		INNER JOIN	[sys].[objects]		O	ON	S.[schema_id]	= O.[schema_id]
		WHERE 
			S.[name]	= 'Feed'	AND
			O.[type]	= 'P'		AND
			O.[name]	= 'Person.Filter'))
	DROP PROCEDURE [Feed].[Person.Filter];
GO

CREATE PROCEDURE [Feed].[Person.Filter]
(
	@predicate		XML,
	@isCountable	BIT	= NULL,
	@guids			XML			OUTPUT,
	@isExcluded		BIT			OUTPUT,
	@isFiltered		BIT			OUTPUT,
	@number			INT			OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @person TABLE ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);

	DECLARE 
		@dateFrom	DATETIMEOFFSET,
		@dateTo		DATETIMEOFFSET,
		@query		XML;

	SET @isFiltered = 0;

--	Filter by name
	DECLARE @name TABLE ([Name] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CS_AS);
	INSERT @name SELECT DISTINCT * FROM [Common].[String.Table](@predicate.query('/*/Name/Value'));
	IF (@@ROWCOUNT > 0) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Name/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @person SELECT DISTINCT P.[PersonId] FROM [Feed].[Person] P
				INNER JOIN	@name	X	ON	P.[PersonName]	LIKE X.[Name];
			ELSE 
				INSERT @person SELECT DISTINCT P.[PersonId] FROM [Feed].[Person] P
				LEFT JOIN	@name	X	ON	P.[PersonName]	LIKE X.[Name]
				WHERE X.[Name] IS NULL;
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @person	X
				LEFT JOIN
				(
					SELECT DISTINCT P.[PersonId] FROM [Feed].[Person] P
					INNER JOIN	@name	X	ON	P.[PersonName]	LIKE X.[Name]
				)	P	ON	X.[Id]	= P.[PersonId]
				WHERE P.[PersonId]	IS NULL;
			ELSE
				DELETE X FROM @person	X
				LEFT JOIN
				(
					SELECT DISTINCT P.[PersonId] FROM [Feed].[Person] P
					LEFT JOIN	@name	X	ON	P.[PersonName]	LIKE X.[Name]
					WHERE X.[Name] IS NULL
				)	P	ON	X.[Id]	= P.[PersonId]
				WHERE P.[PersonId]	IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by private status
	DECLARE @isPrivate BIT;
	SET @isPrivate = [Common].[Bool.Scalar](@predicate.query('/*/IsPrivate'));
	IF (@isPrivate IS NOT NULL) BEGIN
		IF (@isFiltered = 0)
			INSERT @person SELECT P.[PersonId] FROM [Feed].[Person] P
			WHERE P.[PersonIsPrivate] = @isPrivate;
		ELSE
			DELETE X FROM @person	X
			LEFT JOIN
			(
				SELECT P.[PersonId] FROM [Feed].[Person] P
				WHERE P.[PersonIsPrivate] = @isPrivate
			)	P	ON	X.[Id]	= P.[PersonId]
			WHERE P.[PersonId]	IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by person
	SET @query = @predicate.query('/*/Person/Value/Person');
	DECLARE @entity TABLE ([Id] UNIQUEIDENTIFIER);
	INSERT @entity SELECT DISTINCT P.[Id]
	FROM [Common].[Entity.Table](@query) X
	CROSS APPLY [Feed].[Person.Table](X.[Entity]) P;
	IF (@@ROWCOUNT > 0) BEGIN
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Person/IsExcluded')), 0);
		DELETE X FROM @entity X WHERE X.[Id] IS NULL;
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @person SELECT * FROM @entity;
			ELSE
				INSERT @person SELECT P.[PersonId] FROM [Feed].[Person] P
				WHERE P.[PersonId] NOT IN (SELECT * FROM @entity);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @person X WHERE X.[Id] NOT IN (SELECT * FROM @entity);
			ELSE
				DELETE X FROM @person X WHERE X.[Id] IN (SELECT * FROM @entity);
		SET @isFiltered = 1;
	END

--	Filter by event registered datetime offset
	SELECT @dateFrom = NULL, @dateTo = NULL;
	SELECT 
		@dateFrom	= X.[DateFrom], 
		@dateTo		= X.[DateTo] 
	FROM [Common].[DateInterval.Table](@predicate.query('/*/RegisteredOn/Value')) X;
	IF (COALESCE(@dateFrom, @dateTo) IS NOT NULL) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/RegisteredOn/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @person SELECT DISTINCT E.[EventPersonId] FROM [Feed].[Event] E
				WHERE E.[EventRegisteredOn] BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn]);
			ELSE 
				INSERT @person SELECT DISTINCT E.[EventPersonId] FROM [Feed].[Event] E
				WHERE E.[EventRegisteredOn] NOT BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @person	X
				LEFT JOIN
				(
					SELECT DISTINCT E.[EventPersonId] FROM [Feed].[Event] E
					WHERE E.[EventRegisteredOn] BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn])
				)	E	ON	X.[Id]	= E.[EventPersonId]
				WHERE E.[EventPersonId] IS NULL;
			ELSE
				DELETE X FROM @person	X
				LEFT JOIN
				(
					SELECT DISTINCT E.[EventPersonId] FROM [Feed].[Event] E
					WHERE E.[EventRegisteredOn] NOT BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn])
				)	E	ON	X.[Id]	= E.[EventPersonId]
				WHERE E.[EventPersonId] IS NULL;
		SET @isFiltered = 1;
	END

	SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/IsExcluded')), 0);

	SET @guids = (SELECT X.[Id] [guid] FROM @person X FOR XML PATH(''), ROOT('Guids'));

	IF (@isCountable = 0) RETURN;

--	Apply filters
	IF (@isFiltered = 0)
		SELECT @number = COUNT(*) FROM [Feed].[Person] P;
	ELSE
		IF (@isExcluded = 0)
			SELECT @number = COUNT(*) FROM @person X;
		ELSE
			SELECT @number = COUNT(*) FROM [Feed].[Person] P
			LEFT JOIN	@person	X	ON	P.[PersonId] = X.[Id]
			WHERE X.[Id] IS NULL;

END
GO
