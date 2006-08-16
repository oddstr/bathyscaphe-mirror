//
//  DatabaseManager.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DatabaseManager.h"

#import <SQLiteDB.h>

NSString *FavoritesTableName = @"Favorites";
NSString *BoardInfoTableName = @"BoardInfo";
NSString *ThreadInfoTableName = @"ThreadInfo";
NSString *BoardInfoHistoryTableName = @"BoardInfoHistory";
//NSString *ResponseTableName = @"Response";

NSString *FavThreadInfoViewName = @"FavThreadInfoView";
NSString *BoardThreadInfoViewName = @"BoardThreadInfoView";

NSString *BoardIDColumn = @"boardID";
NSString *BoardURLColumn = @"boardURL";
NSString *BoardNameColumn = @"boardName";
NSString *ThreadIDColumn = @"threadID";
NSString *ThreadNameColumn = @"threadName";
NSString *NumberOfAllColumn = @"numberOfAll";
NSString *NumberOfReadColumn = @"numberOfRead";
NSString *ModifiedDateColumn = @"modifiedDate";
NSString *ThreadStatusColumn = @"threadStatus";
NSString *ThreadAboneTypeColumn = @"threadAboneType";
NSString *ThreadLabelColumn = @"threadLabel";
NSString *LastWrittenDateColumn = @"lastWrittenDate";
//NSString *NumberColumn = @"number";
//NSString *MailColumn = @"mail";
//NSString *DateColumn = @"date";
//NSString *IDColumn = @"id";
//NSString *HostColumn = @"host";
//NSString *BEColumn = @"be";
//NSString *ContentsColumn = @"contents";
//NSString *ResAboneTypeColumn = @"resAboneType";
//NSString *ResLabelColumn = @"resLabel";
NSString *NumberOfDifferenceColumn = @"numberOfDifference";

NSString *TempThreadNumberTableName = @"TempThreadNumber";
NSString *TempThreadThreadNumberColumn = @"threadNumber";

static NSString *ThreadDatabaseKey = @"ThreadDatabaseKey";

@implementation DatabaseManager

#ifdef USE_NSZONE_MALLOC
extern void setSQLiteZone(NSZone *zone);
#endif
+ (id) defaultManager
{
	static id _instance = nil;
	
	if (!_instance) {
#ifdef USE_NSZONE_MALLOC
		NSZone *zone;
		
		zone = NSCreateZone(NSPageSize(), NSPageSize(), NO);
		NSAssert(zone, @"Can NOT allocate zone.");
		
		NSSetZoneName(zone, @"DatabaseManager Zone");
		setSQLiteZone(zone);
		_instance = [[self allocWithZone : zone] init];
#else
		_instance = [[self alloc] init];
#endif		
	}
	
	return _instance;
}

+ (void) setupDatabase
{
	if (![[self defaultManager] createFavoritesTable]) {
		NSLog(@"Can not create Favorites tables");
	}
	if (![[self defaultManager] createBoardInfoTable]) {
		NSLog(@"Can not create BoardInfo tables");
	}
	if (![[self defaultManager] createThreadInfoTable]) {
		NSLog(@"Can not create ThreadInfo tables");
	}
	if (![[self defaultManager] createBoardInfoHistoryTable]) {
		NSLog(@"Can not create BoardInfoHistory tables");
	}
//	if (![[self defaultManager] createResponseTable]) {
//		NSLog(@"Can not create Response tables");
//	}
	if (![[self defaultManager] createTempThreadNumberTable]) {
		NSLog(@"Can not create TempThreadNumber tables");
	}
	
	/*
	 if (![[self defaultManager] createFavThraedInfoView]) {
		 NSLog(@"Can not create FavThraedInfo view");
	 }
	 */
	 if (![[self defaultManager] createBoardThreadInfoView]) {
		 NSLog(@"Can not create BoardThreadInfo view");
	 }
}

- (NSString *) databasePath
{	
	return [[CMRFileManager defaultManager] supportFilepathWithName : @"BathyScaphe.db"
												   resolvingFileRef : nil];
}

- (SQLiteDB *) databaseForCurrentThread
{
	SQLiteDB *result;
	
	id threadDict = [[NSThread currentThread] threadDictionary];
	
	result = [threadDict objectForKey : ThreadDatabaseKey];
	
	if (!result) {
		result = [[[SQLiteDB allocWithZone : [self zone]] initWithDatabasePath : [self databasePath]] autorelease];
		
		if (!result) {
			NSLog(@"Can NOT create Database into %@", [self databasePath]);
			return nil;
		}
		
		[threadDict setObject : result forKey : ThreadDatabaseKey];
		
		//	[result setIsInDebugMode : YES];
		//	[result setSendsSQLStatementWhenNotifyingOfChanges : YES];
	}
	
	if (![result isDatabaseOpen] && ![result open]) {
		NSLog(@"Can NOT open Database at %@.", [result databasePath]);
		return nil;
	}
	
	return result;
}

@end

@implementation DatabaseManager (CreateTable)

- (NSString *) commaSeparatedStringWithArray : (NSArray *) array
{	
	return [array componentsJoinedByString : @","];
}

- (NSArray *) favoritesColumns
{
	return [NSArray arrayWithObjects : BoardIDColumn, ThreadIDColumn, nil];
}
- (NSArray *) favoritesDataTypes
{
	return [NSArray arrayWithObjects : INTEGER_NOTNULL, TEXT_NOTNULL, nil];
}

- (NSArray *) boardInfoColumns
{
	return [NSArray arrayWithObjects : BoardIDColumn, BoardNameColumn, BoardURLColumn, nil];
}
- (NSArray *) boardInfoDataTypes
{
	return [NSArray arrayWithObjects : INTERGER_PRIMARY_KEY, TEXT_NOTNULL, TEXT_NOTNULL, nil];
}

- (NSArray *) threadInfoColumns
{
	return [NSArray arrayWithObjects : BoardIDColumn, ThreadIDColumn, ThreadNameColumn,
		NumberOfAllColumn, NumberOfReadColumn,
		ModifiedDateColumn, LastWrittenDateColumn, 
		ThreadStatusColumn, ThreadAboneTypeColumn, ThreadLabelColumn, nil];
}
- (NSArray *) threadInfoDataTypes
{
	return [NSArray arrayWithObjects : INTEGER_NOTNULL, INTEGER_NOTNULL, TEXT_NOTNULL,
		QLNumber, QLNumber,
		QLNumber, QLNumber,
		QLNumber, QLNumber, QLNumber, nil];
}

- (NSArray *) boardInfoHistoryColumns
{
	return [NSArray arrayWithObjects : BoardIDColumn, BoardNameColumn, BoardURLColumn, nil];
}
- (NSArray *) boardInfoHistoryDataTypes
{
	return [NSArray arrayWithObjects : INTEGER_NOTNULL, QLString, QLString, nil];
}

//- (NSArray *) responseColumns
//{
//	return [NSArray arrayWithObjects : BoardIDColumn, ThreadIDColumn, NumberColumn, MailColumn, DateColumn,
//		IDColumn, HostColumn, BEColumn, ContentsColumn, ResAboneTypeColumn, ResLabelColumn, nil];
//}
//- (NSArray *) responseDataTypes
//{
//	return [NSArray arrayWithObjects : INTEGER_NOTNULL, TEXT_NOTNULL, INTEGER_NOTNULL, QLString, QLDateTime,
//		QLString, QLString, QLString, QLString, QLNumber, QLNumber, nil];
//}

- (NSArray *) tempThreadNumberColumns
{
	return [NSArray arrayWithObjects : BoardIDColumn, ThreadIDColumn, TempThreadThreadNumberColumn, nil];
}
- (NSArray *) tempThreadNumberDataTypes
{
	return [NSArray arrayWithObjects : INTEGER_NOTNULL, TEXT_NOTNULL, INTEGER_NOTNULL, nil];
}

#pragma mark## Table creation  ##

- (NSString *) queryForCreateIndexWithMultiColumn : (NSString *) column
										  inTable : (NSString *)table
									     isUnique : (BOOL)flag
{    
    NSString *sqlQuery = nil;
	NSArray *columns;
	NSString *idxName = column;
	
	columns = [column componentsSeparatedByString : @","];
	if ([columns count]) {
		idxName = [columns componentsJoinedByString : @"_"];
	}
    
    if (flag) {
        sqlQuery = [[[NSString alloc]initWithFormat : @"CREATE UNIQUE INDEX %@_%@_IDX ON %@ (%@);", table, idxName, table, column] autorelease];
	} else {
        sqlQuery = [[[NSString alloc]initWithFormat : @"CREATE INDEX %@_%@_IDX ON %@ (%@);", table, idxName, table, column] autorelease];
	}
    
    return sqlQuery;
}
- (BOOL) createTable : (NSString *) tableName
	     withColumns : (NSArray *)columns
	    andDataTypes : (NSArray *)dataTypes
     andIndexQueries : (NSArray *)indexQuery
{
	BOOL isOK = NO;
	
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) return NO;
	
	isOK = [db createTable : tableName
			   withColumns : columns
			  andDatatypes : dataTypes];
	if (!isOK) goto finish;
	
	if (indexQuery && [indexQuery count]) {
		int i, count = [indexQuery count];
		
		for (i = 0; i < count; i++) {
			NSString *query = [indexQuery objectAtIndex : i];
			
			[db performQuery : query];
			isOK = ([db lastErrorID] == 0);
			if (!isOK) goto finish;
		}
	}
	
finish:
		return isOK;
}
- (BOOL) createFavoritesTable
{
	BOOL isOK = NO;
	NSString *query;
	
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) return NO;
	
	if ([[db tables] containsObject : FavoritesTableName]) {
		return YES;
	}
	
	query = [self queryForCreateIndexWithMultiColumn : [self commaSeparatedStringWithArray : [self favoritesColumns]]
											 inTable : FavoritesTableName
											isUnique : YES];
	if ([db beginTransaction]) {
		isOK = [self createTable : FavoritesTableName
					 withColumns : [self favoritesColumns]
					andDataTypes : [self favoritesDataTypes]
				 andIndexQueries : [NSArray arrayWithObject : query]];
		if (!isOK) goto abort;
		
		[db commitTransaction];
		[db save];
	}
	
	return isOK;
	
abort:
		
		NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	[db rollbackTransaction];
	return NO;
}
- (BOOL) createBoardInfoTable
{
	BOOL isOK = NO;
	NSString *query;
	
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) return NO;
	
	if ([[db tables] containsObject : BoardInfoTableName]) {
		return YES;
	}
	
	if ([db beginTransaction]) {
		isOK = [self createTable : BoardInfoTableName
					 withColumns : [self boardInfoColumns]
					andDataTypes : [self boardInfoDataTypes]
				 andIndexQueries : nil];
		if (!isOK) goto abort;
		
		isOK = [db createIndexForColumn : BoardIDColumn
								inTable : BoardInfoTableName
							   isUnique : YES];
		if (!isOK) goto abort;
		
		isOK = [db createIndexForColumn : BoardURLColumn
								inTable : BoardInfoTableName
							   isUnique : YES];
		if (!isOK) goto abort;
		
		// dummy data for set BoardIDColumn to 0.
		query = [NSString stringWithFormat : @"INSERT INTO %@ (%@, %@, %@) VALUES(0, '', '')", 
			BoardInfoTableName, BoardIDColumn, BoardURLColumn, BoardNameColumn];
		[db performQuery : query];
		isOK = ([db lastErrorID] == 0);
		if (!isOK) goto abort;
		
		[db commitTransaction];
		[db save];
	}
	
	return isOK;
	
abort:
		NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	[db rollbackTransaction];
	return NO;
}
- (BOOL) createThreadInfoTable
{
	BOOL isOK = NO;
	NSString *query;
	NSMutableArray *indexies;
	
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) return NO;
	
	if ([[db tables] containsObject : ThreadInfoTableName]) {
		return YES;
	}
	
	indexies =[NSMutableArray arrayWithCapacity:3];
	query = [self queryForCreateIndexWithMultiColumn : [NSString stringWithFormat : @"%@", BoardIDColumn]
											 inTable : ThreadInfoTableName
											isUnique : NO];
	[indexies addObject:query];
	query = [self queryForCreateIndexWithMultiColumn : [NSString stringWithFormat : @"%@", ThreadIDColumn]
											 inTable : ThreadInfoTableName
											isUnique : NO];
	[indexies addObject:query];
	query = [self queryForCreateIndexWithMultiColumn : [NSString stringWithFormat : @"%@,%@", BoardIDColumn, ThreadIDColumn]
											 inTable : ThreadInfoTableName
											isUnique : YES];
	[indexies addObject:query];
	if ([db beginTransaction]) {
		isOK = [self createTable : ThreadInfoTableName
					 withColumns : [self threadInfoColumns]
					andDataTypes : [self threadInfoDataTypes]
				 andIndexQueries : indexies];
		if (!isOK) goto abort;
		
		// dummy data for set ThreadIDColumn to 0.
		query = [NSString stringWithFormat : @"INSERT INTO %@ (%@, %@, %@) VALUES(0, 0, '')",
			ThreadInfoTableName, BoardIDColumn, ThreadIDColumn, ThreadNameColumn];
		[db performQuery : query];
		isOK = ([db lastErrorID] == 0);
		if (!isOK) goto abort;
		
		[db commitTransaction];
		[db save];
	}
	
	return isOK;
	
abort:
		NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	[db rollbackTransaction];
	return NO;
}
- (BOOL) createBoardInfoHistoryTable
{
	BOOL isOK = NO;
	
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) return NO;
	
	if ([[db tables] containsObject : BoardInfoHistoryTableName]) {
		return YES;
	}
	
	if ([db beginTransaction]) {
		isOK = [self createTable : BoardInfoHistoryTableName
					 withColumns : [self boardInfoHistoryColumns]
					andDataTypes : [self boardInfoHistoryDataTypes]
				 andIndexQueries : nil];
		if (!isOK) goto abort;
		
		isOK = [db createIndexForColumn : BoardIDColumn
								inTable : BoardInfoHistoryTableName
							   isUnique : YES];
		if (!isOK) goto abort;
		
		[db commitTransaction];
		[db save];
	}
	
	return isOK;
	
abort:
		NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	[db rollbackTransaction];
	return NO;
}
//- (BOOL) createResponseTable
//{
//	BOOL isOK = NO;
//	NSString *query;
//	
//	SQLiteDB *db = [self databaseForCurrentThread];
//	if (!db) return NO;
//	
//	if ([[db tables] containsObject : ResponseTableName]) {
//		return YES;
//	}
//	
//	query = [self queryForCreateIndexWithMultiColumn : [NSString stringWithFormat : @"%@,%@,%@", BoardIDColumn, ThreadIDColumn, NumberColumn]
//											 inTable : ResponseTableName
//											isUnique : YES];
//	if ([db beginTransaction]) {
//		isOK = [self createTable : ResponseTableName
//					 withColumns : [self responseColumns]
//					andDataTypes : [self responseDataTypes]
//				 andIndexQueries : [NSArray arrayWithObject : query]];
//		if (!isOK) goto abort;
//		
//		[db commitTransaction];
//		[db save];
//	}
//	
//	return isOK;
//	
//abort:
//		NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
//	[db rollbackTransaction];
//	return NO;
//}

- (BOOL) createTempThreadNumberTable
{
	BOOL isOK = NO;
	NSString *query;
	
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) return NO;
	
	if ([[db tables] containsObject : TempThreadNumberTableName]) {
		return YES;
	}
	
	query = [self queryForCreateIndexWithMultiColumn : [NSString stringWithFormat : @"%@,%@", BoardIDColumn, ThreadIDColumn]
											 inTable : TempThreadNumberTableName
											isUnique : YES];
	
	if ([db beginTransaction]) {
		isOK = [self createTable : TempThreadNumberTableName
					 withColumns : [self tempThreadNumberColumns]
					andDataTypes : [self tempThreadNumberDataTypes]
				 andIndexQueries : [NSArray arrayWithObject : query]];
		if (!isOK) goto abort;
		
		[db commitTransaction];
		[db save];
	}
	
	return isOK;
	
abort:
		NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	[db rollbackTransaction];
	return NO;
}
/*
 - (BOOL) createFavThraedInfoView
 {
	 BOOL isOK = NO;
	 NSMutableString *query;
	 
	 QuickLiteDatabase *db = [self databaseForCurrentThread];
	 if (!db) return NO;
	 
	 if ([[db tables] containsObject : FavThreadInfoViewName]) {
		 return YES;
	 }
	 
	 query = [NSMutableString stringWithFormat : @"CREATE VIEW %@ AS\n", FavThreadInfoViewName];
	 [query appendFormat : @"\tSELECT * FROM %@ NATURAL INNER JOIN %@\n",ThreadInfoTableName, FavoritesTableName];
	 [query appendFormat : @"\t\tWHERE %@.%@ = %@.%@ ", ThreadInfoTableName, BoardIDColumn, FavoritesTableName, BoardIDColumn];
	 [query appendFormat : @"AND %@.%@ = %@.%@", ThreadInfoTableName, ThreadIDColumn, FavoritesTableName, ThreadIDColumn];
	 
	 if ([db beginTransaction]) {
		 [db performQuery : query];
		 isOK = ([db lastErrorID] == 0);
		 if (!isOK) goto abort;
		 
		 [db commitTransaction];
		 [db save];
	 }
	 
	 return isOK;
	 
abort:
		 NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	 [db rollbackTransaction];
	 return NO;
 }
 */
 - (BOOL) createBoardThreadInfoView
 {
	 BOOL isOK = NO;
	 NSMutableString *query;
	 
	 SQLiteDB *db = [self databaseForCurrentThread];
	 if (!db) return NO;
	 
	 if ([[db tables] containsObject : BoardThreadInfoViewName]) {
		 return YES;
	 }
	 
	 query = [NSMutableString stringWithFormat : @"CREATE VIEW %@ AS\n", BoardThreadInfoViewName];
//	 query = [NSMutableString stringWithFormat : @"CREATE TEMPORARY VIEW %@ AS\n", BoardThreadInfoViewName];
	 [query appendFormat : @"\tSELECT *, (%@ - %@) AS %@ FROM %@ INNER JOIN %@",
		 NumberOfAllColumn, NumberOfReadColumn, NumberOfDifferenceColumn,
		 ThreadInfoTableName, BoardInfoTableName];
	 [query appendFormat : @" USING(%@) ", BoardIDColumn];
	 
	 if ([db beginTransaction]) {
		 [db performQuery : query];
		 isOK = ([db lastErrorID] == 0);
		 if (!isOK) goto abort;
		 
		 [db commitTransaction];
		 [db save];
	 }
	 
	 return isOK;
	 
abort:
		 NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	 [db rollbackTransaction];
	 return NO;
 }
 
@end
