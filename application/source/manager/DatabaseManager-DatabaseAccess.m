//
//  DatabaseManager-DatabaseAccess.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "DatabaseManager.h"

#import "SQLiteDB.h"

static NSMutableDictionary *boardIDNameCache = nil;
static NSLock *boardIDNumberCacheLock = nil;

@implementation DatabaseManager (DatabaseAccess)
- (unsigned)boardIDForURLStringExceptingHistory:(NSString *)urlString
{
	NSMutableString *query;
	NSString *prepareURL;
	SQLiteDB *db;
	id <SQLiteCursor> cursor;
	id value;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NSNotFound;
	}
	
	prepareURL = [SQLiteDB prepareStringForQuery:urlString];
	query = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", BoardIDColumn, BoardInfoTableName];
	[query appendFormat:@"\n\tWHERE %@ = '%@'", BoardURLColumn, prepareURL];
	cursor = [db performQuery:query];
	
	if (!cursor || [cursor rowCount] == 0) {
		return NSNotFound;
	}

	value = [cursor valueForColumn:BoardIDColumn atRow:0];
	if (!value) {
		return NSNotFound;
	}
	if (![value respondsToSelector:@selector(intValue)]) {
		NSLog (@"%@ is broken.", BoardInfoTableName);
		return NSNotFound;
	}

	return (unsigned)[value intValue];
}

// return NSNotFound, if not registered.
- (unsigned)boardIDForURLString:(NSString *)urlString
{
	NSMutableString *query;
	NSString *prepareURL;
	SQLiteDB *db;
	id <SQLiteCursor> cursor;
	id value;
	BOOL found = NO;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NSNotFound;
	}
	
	prepareURL = [SQLiteDB prepareStringForQuery:urlString];
	query = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", BoardIDColumn, BoardInfoTableName];
	[query appendFormat:@"\n\tWHERE %@ = '%@'", BoardURLColumn, prepareURL];
	cursor = [db performQuery:query];
	
	if (cursor && [cursor rowCount]) {
		found = YES;
	}

	if (!found) {
		query = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", BoardIDColumn, BoardInfoHistoryTableName];
		[query appendFormat:@"\n\tWHERE %@ = '%@'", BoardURLColumn, prepareURL];
		cursor = [db performQuery:query];
		if (cursor && [cursor rowCount]) {
			found = YES;
		}
	}

	if (!found) {
		return NSNotFound;
	}

	value = [cursor valueForColumn:BoardIDColumn atRow:0];
	if (!value) {
		return NSNotFound;
	}
	if (![value respondsToSelector:@selector(intValue)]) {
		NSLog (@"%@ or %@ is broken.", BoardInfoTableName, BoardInfoHistoryTableName );
		return NSNotFound;
	}
	
	return (unsigned)[value intValue];
}

- (NSString *)urlStringForBoardID:(unsigned)boardID
{
	NSMutableString *query;
	NSURL *url;
	SQLiteDB *db;
	id <SQLiteCursor> cursor;
	id value;
	
	if (boardID == 0) return nil;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return nil;
	}

	query = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", BoardURLColumn, BoardInfoTableName];
	[query appendFormat:@"\n\tWHERE %@ = %u", BoardIDColumn, boardID];
	cursor = [db performQuery:query];
	
	if (!cursor || ![cursor rowCount]) {
		return nil;
	}

	value = [cursor valueForColumn:BoardURLColumn atRow:0];
	if (!value) {
		return nil;
	}

	url = [NSURL URLWithString:value];
	if (!url) {
		NSLog(@"%@ or %@ is broken.", BoardInfoTableName, BoardInfoHistoryTableName);
		return nil;
	}

	return value;
}
// return nil, if not registered.
- (NSArray *) boardIDsForName : (NSString *) name
{	
	NSMutableString *query;
	NSString *prepareName;
	SQLiteDB *db;
	id <SQLiteCursor> cursor;
	id value;
	BOOL found = NO;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return nil;
	}
	
	if(!boardIDNameCache) {
		boardIDNameCache = [[NSMutableDictionary alloc] init];
		boardIDNumberCacheLock = [[NSLock alloc] init];
		if(!boardIDNumberCacheLock) {
			[boardIDNameCache release];
			boardIDNameCache = nil;
		}
	}
	
	if(boardIDNameCache) {
		id idArray;
		
		idArray = [boardIDNameCache objectForKey:name];
		if(idArray) {
			return idArray;
		}
	}
	
	prepareName = [SQLiteDB prepareStringForQuery : name];
	query = [NSMutableString stringWithFormat : @"SELECT %@ FROM %@", BoardIDColumn, BoardInfoTableName];
	[query appendFormat : @"\n\tWHERE %@ LIKE '%@'", BoardNameColumn, prepareName];
	cursor = [db performQuery : query];
	
	if (cursor && [cursor rowCount]) {
		found = YES;
	}
	
	if (!found) {
		query = [NSMutableString stringWithFormat : @"SELECT %@ FROM %@", BoardIDColumn, BoardInfoHistoryTableName];
		[query appendFormat : @"\n\tWHERE %@ LIKE '%@'", BoardNameColumn, prepareName];
		cursor = [db performQuery : query];
		if (cursor && [cursor rowCount]) {
			found = YES;
		}
	}
	
	if (!found) {
		return nil;
	}
	
	value = [cursor valuesForColumn : BoardIDColumn];
	if([value count] != 0 ) {
		[boardIDNumberCacheLock lock];
		[boardIDNameCache setObject:value forKey:name];
		[boardIDNumberCacheLock unlock];
	}
	return [value count] > 0 ? value : nil;
}
- (NSString *) nameForBoardID : (unsigned) boardID
{
	NSMutableString *query;
	SQLiteDB *db;
	id <SQLiteCursor> cursor;
	id value;
	
	if (boardID == 0) return nil;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return nil;
	}
	
	query = [NSMutableString stringWithFormat : @"SELECT %@ FROM %@", BoardNameColumn, BoardInfoTableName];
	[query appendFormat : @"\n\tWHERE %@ = %u", BoardIDColumn, boardID];
	cursor = [db performQuery : query];
	
	if (!cursor || ![cursor rowCount]) {
		return nil;
	}
	
	value = [cursor valueForColumn : BoardNameColumn atRow : 0];
	
	return value;
}

// raise DatabaseManagerCantFountKeyExseption.
- (id)valueForKey:(NSString *)key boardID:(unsigned)boardID threadID:(NSString *)threadID
{
	NSString *query;
	SQLiteDB *db;
	id <SQLiteCursor> cursor;
	id value;
	
	if (boardID == 0) return nil;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	
	query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %u AND %@ = %@",
		BoardThreadInfoViewName,
		BoardIDColumn, boardID,
		ThreadIDColumn, threadID];
	cursor = [db performQuery : query];
	if (!cursor || ![cursor rowCount]) {
		return nil;
	}
	
	value = [cursor valueForColumn : key atRow : 0];
	
	return value;
}
	
//- (void)setValue:(id)value forKey:(NSString *)key boardID:(unsigned)boardID threadID:(NSString *)threadID;


- (BOOL) registerBoardName : (NSString *) name URLString : (NSString *) urlString
{
	BOOL result = NO;
	
	NSMutableString *query;
	NSString *prepareName;
	NSString *prepareURL;
	SQLiteDB *db;
	
	// checking URL.
	{
		if(!urlString) {
			NSLog(@"urlString is nil.");
			return NO;
		}
		id url = [NSURL URLWithString : urlString];
		if (!url) {
			NSLog(@"urlString (%@) is NOT url.", urlString);
			return NO;
		}
	}
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	
	prepareName = [SQLiteDB prepareStringForQuery : name];
	prepareURL = [SQLiteDB prepareStringForQuery : urlString];
	query = [NSMutableString stringWithFormat : @"INSERT INTO %@", BoardInfoTableName];
	[query appendFormat : @" ( %@, %@, %@ ) ", BoardIDColumn, BoardNameColumn, BoardURLColumn];
	[query appendFormat : @"VALUES ( (SELECT max(%@) FROM %@) + 1, '%@', '%@' ) ",
		BoardIDColumn, BoardInfoTableName, prepareName, prepareURL];
	[db performQuery : query];
	
	result = ([db lastErrorID] == 0);
	if(!result) {
		NSLog(@"Fail registerBoard.\nReson: %@", [db lastError]);
	}
	return result;
}

/*- (BOOL)deleteBoardOfBoardID:(unsigned)boardID
{
	SQLiteDB	*db;
	NSString	*query;

	[self recache];
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}

	query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %u", BoardInfoTableName, BoardIDColumn, boardID];
	[db performQuery:query];

	BOOL result = ([db lastErrorID] == 0);
	if(!result) {
		NSLog(@"Fail deleteBoard.\nReson: %@", [db lastError]);
	}
	return result;
}
}*/

/*
 - (BOOL) registerBoardNamesAndURLs : (NSArray *) array;
 */

- (BOOL) moveBoardID : (unsigned) boardID
		 toURLString : (NSString *) urlString
{
	NSMutableString *query;
	SQLiteDB *db;
	NSString *currentURLString;
	NSString *prepareURLString;
	
	BOOL inTransactionBlock = NO;
	
	if (!urlString || ![urlString length]) {
		NSLog(@"urlString MUST NOT be nil or NOT zero length.");
		return NO;
	}
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	
	currentURLString = [self urlStringForBoardID : boardID];
	if ([currentURLString isEqualTo : urlString]) return YES;
	
	if(![db beginTransaction]) {
		if([db lastErrorID] == 0) {
			inTransactionBlock = YES;
		} else {
			return NO;
		}
	}
	
	prepareURLString = [SQLiteDB prepareStringForQuery : currentURLString];
	query = [NSMutableString string];
	[query appendFormat : @"INSERT INTO %@", BoardInfoHistoryTableName];
	[query appendFormat : @"\t (%@, %@) ", BoardIDColumn, BoardURLColumn];
	[query appendFormat : @"\tVALUES (%u, '%@') ", boardID, prepareURLString];
	
	[db performQuery : query];
	if ([db lastErrorID] != 0 && [db lastErrorID] != SQLITE_CONSTRAINT) {
		NSLog(@"Fail insert into %@", BoardInfoHistoryTableName);
		[db rollbackTransaction];
		
		return NO;
	}
	
	prepareURLString = [SQLiteDB prepareStringForQuery : urlString];
	query = [NSMutableString string];
	[query appendFormat : @"UPDATE %@", BoardInfoTableName];
	[query appendFormat : @"\tSET %@ = '%@'", BoardURLColumn, prepareURLString];
	[query appendFormat : @"\tWHERE %@ = %u", BoardIDColumn, boardID];
	
	[db performQuery : query];
	if ([db lastErrorID] != 0) {
		NSLog(@"Fail update %@", BoardInfoTableName);
		[db rollbackTransaction];
		
		return NO;
	}
	
	if(!inTransactionBlock) {
		[db commitTransaction];
	}
	
	return YES;
}

- (BOOL) renameBoardID : (unsigned) boardID
				toName : (NSString *) name
{
	NSMutableString *query;
	SQLiteDB *db;
	NSString *currentName;
	NSString *prepareName;
	
	BOOL inTransactionBlock = NO;
	
	if (!name || ![name length]) {
		NSLog(@"name MUST NOT be nil or NOT zero length.");
		return NO;
	}
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	
	currentName = [self nameForBoardID : boardID];
	if ([currentName isEqualTo : name]) return YES;
	
	[self recache];
	
	if(![db beginTransaction]) {
		if([db lastErrorID] == 0) {
			inTransactionBlock = YES;
		} else {
			return NO;
		}
	}
	
	prepareName = [SQLiteDB prepareStringForQuery : currentName];
	query = [NSMutableString string];
	[query appendFormat : @"INSERT INTO %@", BoardInfoHistoryTableName];
	[query appendFormat : @"\t (%@, %@) ", BoardIDColumn, BoardNameColumn];
	[query appendFormat : @"\tVALUES (%u, '%@') ", boardID, prepareName];
	
	[db performQuery : query];
	if ([db lastErrorID] != 0 && [db lastErrorID] != SQLITE_CONSTRAINT) {
		NSLog(@"Fail insert into %@", BoardInfoHistoryTableName);
		[db rollbackTransaction];
		
		return NO;
	}
	
	prepareName = [SQLiteDB prepareStringForQuery : name];
	query = [NSMutableString string];
	[query appendFormat : @"UPDATE %@", BoardInfoTableName];
	[query appendFormat : @"\tSET %@ = '%@'", BoardNameColumn, prepareName];
	[query appendFormat : @"\tWHERE %@ = %u", BoardIDColumn, boardID];
	
	[db performQuery : query];
	if ([db lastErrorID] != 0) {
		NSLog(@"Fail insert into %@", BoardInfoHistoryTableName);
		[db rollbackTransaction];
		
		return NO;
	}
	
	if(!inTransactionBlock) {
		[db commitTransaction];
	}
	return YES;
}

/*
 - (BOOL) registerThreadName : (NSString *) name 
 threadIdentifier : (NSString *) identifier
 intoBoardID : (unsigned) boardID;
 - (BOOL) registerThreadNamesAndThreadIdentifiers : (NSArray *) array
 intoBoardID : (unsigned) boardID;
 */
- (BOOL)isThreadIdentifierRegistered:(NSString *)identifier onBoardID:(unsigned)boardID
{
	return [self isThreadIdentifierRegistered:identifier onBoardID:boardID numberOfAll:NULL];
}

- (BOOL)isThreadIdentifierRegistered:(NSString *)identifier onBoardID:(unsigned)boardID numberOfAll:(unsigned int *)number
{
	SQLiteDB *db = [self databaseForCurrentThread];
	
	if (!db) {
		return NO;
	}

	NSString *query;
	id<SQLiteCursor> cursor;	
	query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = %u AND %@ = %@",
				NumberOfAllColumn, ThreadInfoTableName, BoardIDColumn, boardID, ThreadIDColumn, identifier];
	cursor = [db performQuery:query];

	if (cursor && ([cursor rowCount] > 0)) {
		if (number != NULL) {
			id value = [cursor valueForColumn:NumberOfAllColumn atRow:0];
			if ([value isKindOfClass:[NSString class]]) {
				*number = [value intValue];
			}
		}
		return YES;
	}

	return NO;
}

- (BOOL) isFavoriteThreadIdentifier : (NSString *) identifier
						  onBoardID : (unsigned) boardID
{
	NSMutableString *query;
	SQLiteDB *db;
	id<SQLiteCursor> cursor;
	id value;
	BOOL isFavorite = NO;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	
	query = [NSMutableString stringWithFormat : @"SELECT count(*) FROM %@ WHERE %@ = %u AND %@ = %@ AND %@ = 1",
		ThreadInfoTableName, BoardIDColumn, boardID, ThreadIDColumn, identifier, IsFavoriteColumn];
	cursor = [db performQuery : query];
	if (cursor && [cursor rowCount]) {
		value = [cursor valueForColumn : @"count(*)" atRow : 0];
		if ([value intValue]) {
			isFavorite = YES;
		}
	}
	
	return isFavorite;
}
- (BOOL) appendFavoriteThreadIdentifier : (NSString *) identifier
							  onBoardID : (unsigned) boardID
{
	NSMutableString *query;
	SQLiteDB *db;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	
	if([db beginTransaction]) {
		query = [NSString stringWithFormat : @"UPDATE %@ SET %@ = 1 WHERE %@ = %u AND %@ = %@",
			ThreadInfoTableName, IsFavoriteColumn,
			BoardIDColumn, boardID, ThreadIDColumn, identifier];
		[db performQuery : query];
		if([db lastErrorID] != 0) goto abort;
		
		query = [NSMutableString stringWithFormat : @"INSERT INTO %@", FavoritesTableName];
		[query appendFormat : @" ( %@, %@ ) ", BoardIDColumn, ThreadIDColumn];
		[query appendFormat : @" VALUES ( %u, %@ ) ", boardID, identifier];
		[db performQuery : query];
		if([db lastErrorID] != 0) goto abort;
		
		[db commitTransaction];
	} else {
		return NO;
	}
	
	return YES;
	
abort:
	NSLog(@"FAIL append Favorote. Reson : %@", [db lastError]);
	[db rollbackTransaction];
	return NO;
}
- (BOOL) removeFavoriteThreadIdentifier : (NSString *) identifier
							  onBoardID : (unsigned) boardID
{
	NSMutableString *query;
	SQLiteDB *db;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	
	if([db beginTransaction]) {
		query = [NSString stringWithFormat : @"UPDATE %@ SET %@ = 0 WHERE %@ = %u AND %@ = %@",
			ThreadInfoTableName, IsFavoriteColumn,
			BoardIDColumn, boardID, ThreadIDColumn, identifier];
		[db performQuery : query];
		if([db lastErrorID] != 0) goto abort;
		
		query = [NSMutableString stringWithFormat : @"DELETE FROM %@", FavoritesTableName];
		[query appendFormat : @" WHERE %@ = %u", BoardIDColumn, boardID];
		[query appendFormat : @" AND %@ = %@", ThreadIDColumn, identifier];
		[db performQuery : query];
		if([db lastErrorID] != 0) goto abort;
		
		[db commitTransaction];
	} else {
		return NO;
	}
	
	return YES;
	
abort:
	NSLog(@"FAIL delete Favorote. Reson : %@", [db lastError]);
	[db rollbackTransaction];
	return NO;
}

- (BOOL)registerThreadFromFilePath:(NSString *)filepath
{
	return [self registerThreadFromFilePath:filepath needsDisplay:YES];
}

- (BOOL)registerThreadFromFilePath:(NSString *)filepath needsDisplay:(BOOL)flag
{
	NSDictionary *hoge = [NSDictionary dictionaryWithContentsOfFile:filepath];
	NSString *datNum, *title, *boardName;
	unsigned count;
	NSDate *date;
	CMRThreadUserStatus	*s;
	id rep;
	unsigned boardID;
	BOOL	isDatOchi;
	
	datNum = [hoge objectForKey:ThreadPlistIdentifierKey];
	if (!datNum) return NO;
	title = [hoge objectForKey:CMRThreadTitleKey];
	if (!title) return NO;
	boardName = [hoge objectForKey:ThreadPlistBoardNameKey];
	if (!boardName) return NO;
	count = [[hoge objectForKey: ThreadPlistContentsKey] count];
	
	rep = [hoge objectForKey:CMRThreadUserStatusKey];
	s = [CMRThreadUserStatus objectWithPropertyListRepresentation:rep];
	isDatOchi = (s ? [s isDatOchiThread] : NO);

	date = [hoge objectForKey:CMRThreadModifiedDateKey];

	NSArray *boardIDs = [self boardIDsForName:boardName];
	if (!boardIDs || [boardIDs count] == 0) {
		NSLog(@"board %@ is not registered.");
		return NO;
	}
	boardID = [[boardIDs objectAtIndex:0] unsignedIntValue];

	if ([self insertThreadOfIdentifier:datNum title:title count:count date:date isDatOchi:isDatOchi atBoard:boardID] && flag) {
		[self makeThreadsListsUpdateCursor];
		return YES;
	}
	return NO;
}

- (NSString *) threadTitleFromBoardName:(NSString *)boadName threadIdentifier:(NSString *)identifier
{
	NSString *boardID;
	NSArray *boardIDs;
	NSString *query;
	SQLiteDB *db;
	id<SQLiteCursor> cursor;
	
	NSString *title = nil;
	
	UTILAssertKindOfClass(boadName, NSString);
	UTILAssertKindOfClass(identifier, NSString);
	if([boadName length] == 0) return nil;
	if([identifier length] == 0) return nil;
	
	boardIDs = [self boardIDsForName:boadName];
	if(!boardIDs || [boardIDs count] == 0) return nil;
	
	boardID = [boardIDs objectAtIndex:0];
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return nil;
	}
	
	query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = %@ AND %@ = %@",
		ThreadNameColumn,
		ThreadInfoTableName,
		BoardIDColumn, boardID,
		ThreadIDColumn, identifier,
		nil];
	cursor = [db performQuery: query];
	if (cursor && [cursor rowCount]) {
		title = [cursor valueForColumn : ThreadNameColumn atRow : 0];
	}
	
	return title;
}

- (void)setLastWriteDate:(NSDate *)writeDate atBoardID:(unsigned)boardID threadIdentifier:(NSString *)identifier
{
	NSString *query;
	SQLiteDB *db;
	UTILAssertKindOfClass(identifier, NSString);
		
	if([identifier length] == 0) return;
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return;
	}
	
	query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %.0lf WHERE %@ = %u AND %@ = %@",
		ThreadInfoTableName,
		LastWrittenDateColumn, [writeDate timeIntervalSince1970],
		BoardIDColumn, boardID,
		ThreadIDColumn, identifier,
		nil];
	[db performQuery: query];
	if ([db lastErrorID] != 0) {
		NSLog(@"Fail update LastWrittenDate.");
	}
}

- (void) setIsDatOchi:(BOOL)flag
			boardName:(NSString *)boardName
	 threadIdentifier:(NSString *)identifier
{
	NSString *boardID;
	NSArray *boardIDs;
	NSString *query;
	SQLiteDB *db;
		
	UTILAssertKindOfClass(boardName, NSString);
	UTILAssertKindOfClass(identifier, NSString);
	if([boardName length] == 0) return;
	if([identifier length] == 0) return;
	
	boardIDs = [self boardIDsForName:boardName];
	if(!boardIDs || [boardIDs count] == 0) return;
	
	boardID = [boardIDs objectAtIndex:0];
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return;
	}
	
	query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = %@ AND %@ = %@",
		ThreadInfoTableName,
		IsDatOchiColumn, flag ? 1 : 0,
		BoardIDColumn, boardID,
		ThreadIDColumn, identifier,
		nil];
	[db performQuery: query];
	if ([db lastErrorID] != 0) {
		NSLog(@"Fail update IsDatOchi.");
	}
}
- (BOOL)isDatOchiBoardName:(NSString *)boardName threadIdentifier:(NSString *)identifier
{
	NSString *boardID;
	NSArray *boardIDs;
	NSString *query;
	SQLiteDB *db;
	id<SQLiteCursor> cursor;
	
	BOOL result = NO;
	
	UTILAssertKindOfClass(boardName, NSString);
	UTILAssertKindOfClass(identifier, NSString);
	if([boardName length] == 0) return nil;
	if([identifier length] == 0) return nil;
	
	boardIDs = [self boardIDsForName:boardName];
	if(!boardIDs || [boardIDs count] == 0) return nil;
	
	boardID = [boardIDs objectAtIndex:0];
	
	db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	
	query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = %@ AND %@ = %@",
		IsDatOchiColumn,
		ThreadInfoTableName,
		BoardIDColumn, boardID,
		ThreadIDColumn, identifier,
		nil];
	cursor = [db performQuery: query];
	if (cursor && [cursor rowCount]) {
		result = [[cursor valueForColumn : IsDatOchiColumn atRow : 0] intValue];
	}
	
	return result;
}

#pragma mark Testing...
static NSString *escapeQuotes(NSString *str)
{
	NSRange range = [str rangeOfString:@"'" options:NSLiteralSearch];
	if (range.location == NSNotFound) {
		return str;
	} else {
		NSMutableString *newStr = [str mutableCopy];
		[newStr replaceOccurrencesOfString:@"'" withString:@"''" options:NSLiteralSearch range:NSMakeRange(0, [newStr length])];
		return [newStr autorelease];
	}
}

- (BOOL)isRegisteredWithFavoritesTable:(NSString *)identifier atBoard:(unsigned)boardID
{
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}
	NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %u AND %@ = %@",
							FavoritesTableName, BoardIDColumn, boardID, ThreadIDColumn, identifier];
	id<SQLiteCursor> cursor;
	cursor = [db cursorForSQL:query];
	if (cursor && [cursor rowCount]) {
		return YES;
	}
	return NO;
}

- (BOOL)insertThreadOfIdentifier:(NSString *)identifier
						   title:(NSString *)title
						   count:(unsigned)count
						    date:(NSDate *)date
					   isDatOchi:(BOOL)flag
						 atBoard:(unsigned)boardID
{
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) {
		return NO;
	}

	double interval = 0;
	if (date && [date isKindOfClass:[NSDate class]]) {
		interval = [date timeIntervalSince1970];
	}

	unsigned int number = 0;
	ThreadStatus status = ThreadLogCachedStatus;
	NSMutableString *sql;
	BOOL isFavorite = [self isRegisteredWithFavoritesTable:identifier atBoard:boardID];

	if ([self isThreadIdentifierRegistered:identifier onBoardID:boardID numberOfAll:&number]) {
		if (number < count) {
			number = count;
		} else if (number > count) {
			status = ThreadUpdatedStatus;
		}

		sql = [NSMutableString stringWithFormat:@"UPDATE %@ ", ThreadInfoTableName];
		[sql appendFormat:@"SET %@ = %u, %@ = %u, %@ = %u, %@ = %.0lf, %@ = %u, %@ = %u ",
			NumberOfAllColumn, number,
			NumberOfReadColumn, count,
			ThreadStatusColumn, status,
			ModifiedDateColumn, interval,
			IsFavoriteColumn, (isFavorite ? 1 : 0),
			IsDatOchiColumn, (flag ? 1 : 0)];
		[sql appendFormat:@"WHERE %@ = %u AND %@ = %@",
			BoardIDColumn, boardID, ThreadIDColumn, identifier];
		
		[db cursorForSQL:sql];
		
		if ([db lastErrorID] != 0) {
			NSLog(@"Fail to update. Reason: %@", [db lastError]);
			return NO;
		}

	} else {
		sql = [NSString stringWithFormat:@"INSERT INTO %@ ( %@, %@, %@, %@, %@, %@, %@, %@, %@ ) VALUES ( %u, %@, '%@', %u, %u, %.0lf, %u, %u, %u)",
			ThreadInfoTableName,
			BoardIDColumn, ThreadIDColumn, ThreadNameColumn, NumberOfAllColumn, NumberOfReadColumn, ModifiedDateColumn, ThreadStatusColumn, IsFavoriteColumn,
			IsDatOchiColumn,
			boardID, identifier, escapeQuotes(title), count, count, interval, status, (isFavorite ? 1 : 0),
			(flag ? 1 : 0)];
		[db cursorForSQL:sql];

		if ([db lastErrorID] != 0) {
			NSLog(@"Fail Insert. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError]);
			return NO;
		}

	}

	return YES;
}

- (BOOL)recache
{
	[boardIDNumberCacheLock lock];
	[boardIDNameCache release];
	boardIDNameCache = [[NSMutableDictionary alloc] init];
	[boardIDNumberCacheLock unlock];
	
	return YES;
}

- (BOOL)deleteAllRecordsOfBoard:(unsigned)boardID
{
	SQLiteDB *db = [self databaseForCurrentThread];
	NSString *query = [NSString stringWithFormat:
		@"DELETE FROM %@ WHERE %@ = %u", ThreadInfoTableName, BoardIDColumn, boardID];
	if (!db) return NO;
	[db cursorForSQL:query];
	if ([db lastErrorID] != 0) {
		NSLog(@"Fail deleteAllRecordsOfBoard:%u. Reason: %@ (ErrorID -> %d)", boardID, [db lastError], [db lastErrorID]);
		return NO;
	}
	return YES;
}
@end
