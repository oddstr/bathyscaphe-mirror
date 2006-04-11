//
//  DatabaseManager-DatabaseAccess.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DatabaseManager.h"

#import "SQLiteDB.h"

static NSMutableDictionary *boardIDNameCache = nil;
static NSLock *boardIDNumberCacheLock = nil;

@implementation DatabaseManager (DatabaseAccess)

// return NSNotFound, if not registered.
- (unsigned) boardIDForURLString : (NSString *) urlString
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
	
	prepareURL = [SQLiteDB prepareStringForQuery : urlString];
	query = [NSMutableString stringWithFormat : @"SELECT %@ FROM %@", BoardIDColumn, BoardInfoTableName];
	[query appendFormat : @"\n\tWHERE %@ = '%@'", BoardURLColumn, prepareURL];
	cursor = [db performQuery : query];
	
	if (cursor && [cursor rowCount]) {
		found = YES;
	}
	
	if (!found) {
		query = [NSMutableString stringWithFormat : @"SELECT %@ FROM %@", BoardIDColumn, BoardInfoHistoryTableName];
		[query appendFormat : @"\n\tWHERE %@ = '%@'", BoardURLColumn, prepareURL];
		cursor = [db performQuery : query];
		if (cursor && [cursor rowCount]) {
			found = YES;
		}
	}
	
	if (!found) {
		return NSNotFound;
	}
	
	value = [cursor valueForColumn : BoardIDColumn atRow : 0];
	if (!value) {
		return NSNotFound;
	}
	if (![value respondsToSelector : @selector(intValue)]) {
		NSLog (@"%@ or %@ is broken.", BoardInfoTableName, BoardInfoHistoryTableName );
		return NSNotFound;
	}
	
	return (unsigned)[value intValue];
}
- (NSString *) urlStringForBoardID : (unsigned) boardID
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
	
	query = [NSMutableString stringWithFormat : @"SELECT %@ FROM %@", BoardURLColumn, BoardInfoTableName];
	[query appendFormat : @"\n\tWHERE %@ = %u", BoardIDColumn, boardID];
	cursor = [db performQuery : query];
	
	if (!cursor || ![cursor rowCount]) {
		return nil;
	}
	
	value = [cursor valueForColumn : BoardURLColumn atRow : 0];
	if (!value) {
		return nil;
	}
	
	url = [NSURL URLWithString : value];
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

- (BOOL) registerBoardName : (NSString *) name URLString : (NSString *) urlString
{
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
	
	return ([db lastErrorID] == 0);
}

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
	
	if ([db beginTransaction]) {
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
			NSLog(@"Fail insert into %@", BoardInfoHistoryTableName);
			[db rollbackTransaction];
			
			return NO;
		}
		
		[db commitTransaction];
		
		return YES;
	}
	
	return NO;
}

- (BOOL) renameBoardID : (unsigned) boardID
				toName : (NSString *) name
{
	NSMutableString *query;
	SQLiteDB *db;
	NSString *currentName;
	NSString *prepareName;
	
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
	
	if ([db beginTransaction]) {
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
		
		[db commitTransaction];
		
		return YES;
	}
	
	return NO;
}

/*
 - (BOOL) registerThreadName : (NSString *) name 
 threadIdentifier : (NSString *) identifier
 intoBoardID : (unsigned) boardID;
 - (BOOL) registerThreadNamesAndThreadIdentifiers : (NSArray *) array
 intoBoardID : (unsigned) boardID;
 */

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
	
	query = [NSMutableString stringWithFormat : @"SELECT count(*) FROM %@", FavoritesTableName];
	[query appendFormat : @" WHERE %@ = %u", BoardIDColumn, boardID];
	[query appendFormat : @" AND %@ LIKE '%@'", ThreadIDColumn, identifier];
	
	cursor = [db performQuery : query];
	if ([cursor rowCount]) {
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
	
	query = [NSMutableString stringWithFormat : @"INSERT INTO %@", FavoritesTableName];
	[query appendFormat : @" ( %@, %@ ) ", BoardIDColumn, ThreadIDColumn];
	[query appendFormat : @" VALUES ( %u, %@ ) ", boardID, identifier];
	[db performQuery : query];
	
	return ([db lastErrorID] == 0);
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
	
	query = [NSMutableString stringWithFormat : @"DELETE FROM %@", FavoritesTableName];
	[query appendFormat : @" WHERE %@ = %u", BoardIDColumn, boardID];
	[query appendFormat : @" AND %@ LIKE '%@'", ThreadIDColumn, identifier];
	[db performQuery : query];
	
	return ([db lastErrorID] == 0);
}

@end
