DECLARE
	@personNameFom	NVARCHAR(200)	= 'Grini Chirill',
	@personNameTo	NVARCHAR(200)	= 'Chirill Grini';

DECLARE
	@personIdFrom	UNIQUEIDENTIFIER,
	@personIdTo		UNIQUEIDENTIFIER;

SELECT @personIdFrom = P.[PersonId] 
FROM [Feed].[Person] P 
WHERE P.[PersonName] = @personNameFom;

SELECT @personIdTo = P.[PersonId] 
FROM [Feed].[Person] P 
WHERE P.[PersonName] = @personNameTo;

IF (@personIdFrom	IS NOT NULL AND
	@personIdTo		IS NOT NULL AND
	@personIdFrom <> @personIdTo) BEGIN

	BEGIN TRANSACTION;

	UPDATE D SET D.[DayPersonId] = @personIdTo
	FROM [Slice].[Day] D
	WHERE D.[DayPersonId] = @personIdFrom;

	UPDATE E SET E.[EventPersonId] = @personIdTo
	FROM [Feed].[Event] E
	WHERE E.[EventPersonId] = @personIdFrom;

	DELETE P FROM [Feed].[Person] P
	WHERE P.[PersonId] = @personIdFrom;

	COMMIT TRANSACTION;

END