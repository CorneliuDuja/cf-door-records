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
			O.[name]	= 'Point.Filter'))
	DROP PROCEDURE [Feed].[Point.Filter];
GO

CREATE PROCEDURE [Feed].[Point.Filter]
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
	
	DECLARE @point TABLE ([Id] UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED);

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
				INSERT @point SELECT DISTINCT P.[PointId] FROM [Feed].[Point] P
				INNER JOIN	@name	X	ON	P.[PointName]	LIKE X.[Name];
			ELSE 
				INSERT @point SELECT DISTINCT P.[PointId] FROM [Feed].[Point] P
				LEFT JOIN	@name	X	ON	P.[PointName]	LIKE X.[Name]
				WHERE X.[Name] IS NULL;
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @point	X
				LEFT JOIN
				(
					SELECT DISTINCT P.[PointId] FROM [Feed].[Point] P
					INNER JOIN	@name	X	ON	P.[PointName]	LIKE X.[Name]
				)	P	ON	X.[Id]	= P.[PointId]
				WHERE P.[PointId]	IS NULL;
			ELSE
				DELETE X FROM @point	X
				LEFT JOIN
				(
					SELECT DISTINCT P.[PointId] FROM [Feed].[Point] P
					LEFT JOIN	@name	X	ON	P.[PointName]	LIKE X.[Name]
					WHERE X.[Name] IS NULL
				)	P	ON	X.[Id]	= P.[PointId]
				WHERE P.[PointId]	IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by point file type
	DECLARE @pointActionType TABLE ([PointActionType] NVARCHAR(MAX));
	INSERT @pointActionType SELECT DISTINCT LTRIM(X.[Entity].value('(text())[1]', 'NVARCHAR(MAX)')) [PointActionType]
	FROM @predicate.nodes('/*/PointActionType/Value/PointActionType') X ([Entity])
	IF (@@ROWCOUNT > 0) BEGIN 
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/PointActionType/IsExcluded')), 0);
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @point SELECT DISTINCT P.[PointId] FROM [Feed].[Point] P
				INNER JOIN	@pointActionType	X	ON P.[PointActionType]	LIKE X.[PointActionType];
			ELSE 
				INSERT @point SELECT DISTINCT P.[PointId] FROM [Feed].[Point] P
				LEFT JOIN	@pointActionType	X	ON P.[PointActionType]	LIKE X.[PointActionType]
				WHERE X.[PointActionType] IS NULL;
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @point	X
				LEFT JOIN
				(
					SELECT DISTINCT P.[PointId] FROM [Feed].[Point] P
					INNER JOIN	@pointActionType	X	ON P.[PointActionType]	LIKE X.[PointActionType]
				)	P	ON	X.[Id]	= P.[PointId]
				WHERE P.[PointId] IS NULL;
			ELSE
				DELETE X FROM @point	X
				LEFT JOIN
				(
					SELECT DISTINCT P.[PointId] FROM [Feed].[Point] P
					LEFT JOIN	@pointActionType	X	ON P.[PointActionType]	LIKE X.[PointActionType]
					WHERE X.[PointActionType] IS NULL
				)	P	ON	X.[Id]	= P.[PointId]
				WHERE P.[PointId] IS NULL;
		SET @isFiltered = 1;
	END

--	Filter by point
	SET @query = @predicate.query('/*/Point/Value/Point');
	DECLARE @entity TABLE ([Id] UNIQUEIDENTIFIER);
	INSERT @entity SELECT DISTINCT P.[Id]
	FROM [Common].[Entity.Table](@query) X
	CROSS APPLY [Feed].[Point.Table](X.[Entity]) P;
	IF (@@ROWCOUNT > 0) BEGIN
		SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/Point/IsExcluded')), 0);
		DELETE X FROM @entity X WHERE X.[Id] IS NULL;
		IF (@isFiltered = 0)
			IF (@isExcluded = 0)
				INSERT @point SELECT * FROM @entity;
			ELSE
				INSERT @point SELECT P.[PointId] FROM [Feed].[Point] P
				WHERE P.[PointId] NOT IN (SELECT * FROM @entity);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @point X WHERE X.[Id] NOT IN (SELECT * FROM @entity);
			ELSE
				DELETE X FROM @point X WHERE X.[Id] IN (SELECT * FROM @entity);
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
				INSERT @point SELECT DISTINCT E.[EventPointId] FROM [Feed].[Event] E
				WHERE E.[EventRegisteredOn] BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn]);
			ELSE 
				INSERT @point SELECT DISTINCT E.[EventPointId] FROM [Feed].[Event] E
				WHERE E.[EventRegisteredOn] NOT BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn]);
		ELSE
			IF (@isExcluded = 0)
				DELETE X FROM @point	X
				LEFT JOIN
				(
					SELECT DISTINCT E.[EventPointId] FROM [Feed].[Event] E
					WHERE E.[EventRegisteredOn] BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn])
				)	E	ON	X.[Id]	= E.[EventPointId]
				WHERE E.[EventPointId] IS NULL;
			ELSE
				DELETE X FROM @point	X
				LEFT JOIN
				(
					SELECT DISTINCT E.[EventPointId] FROM [Feed].[Event] E
					WHERE E.[EventRegisteredOn] NOT BETWEEN ISNULL(@dateFrom, E.[EventRegisteredOn]) AND ISNULL(@dateTo, E.[EventRegisteredOn])
				)	E	ON	X.[Id]	= E.[EventPointId]
				WHERE E.[EventPointId] IS NULL;
		SET @isFiltered = 1;
	END

	SET @isExcluded = ISNULL([Common].[Bool.Scalar](@predicate.query('/*/IsExcluded')), 0);

	SET @guids = (SELECT X.[Id] [guid] FROM @point X FOR XML PATH(''), ROOT('Guids'));

	IF (@isCountable = 0) RETURN;

--	Apply filters
	IF (@isFiltered = 0)
		SELECT @number = COUNT(*) FROM [Feed].[Point] P;
	ELSE
		IF (@isExcluded = 0)
			SELECT @number = COUNT(*) FROM @point X;
		ELSE
			SELECT @number = COUNT(*) FROM [Feed].[Point] P
			LEFT JOIN	@point	X	ON	P.[PointId] = X.[Id]
			WHERE X.[Id] IS NULL;

END
GO
