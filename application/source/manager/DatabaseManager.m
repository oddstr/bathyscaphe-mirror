//
//  DatabaseManager.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "DatabaseManager.h"

#import "SQLiteDB.h"
#import "DatabaseUpdater.h"

#import "AppDefaults.h"

NSString *FavoritesTableName = @"Favorites";
NSString *BoardInfoTableName = @"BoardInfo";
NSString *ThreadInfoTableName = @"ThreadInfo";
NSString *BoardInfoHistoryTableName = @"BoardInfoHistory";
NSString *VersionTableName = @"Version";
NSString *VersionColumn = @"version";

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
NSString *IsDatOchiColumn = @"isDatOchi";
NSString *IsFavoriteColumn = @"IsFavorite";
NSString *NumberOfDifferenceColumn = @"numberOfDifference";
NSString *IsCachedColumn = @"isCached";
NSString *IsUpdatedColumn = @"isUpdated";
NSString *IsNewColumn = @"isNew";
NSString *IsHeadModifiedColumn = @"isHeadModified";

NSString *TempThreadNumberTableName = @"TempThreadNumber";
NSString *TempThreadThreadNumberColumn = @"threadNumber";

static NSString *ThreadDatabaseKey = @"ThreadDatabaseKey";

//------ static ------//
static long sDatabaseFileVersion = 5;


@implementation DatabaseManager

static NSZone *allocateZone = NULL;

#ifdef USE_NSZONE_MALLOC
extern void setSQLiteZone(NSZone *zone);

+ (void)initialize
{
	BOOL isFirst = YES;
	
	if(isFirst) {
		isFirst = NO;
		
		allocateZone = [SQLiteDB allocateZone];
	}
}
#endif

+ (id) defaultManager
{
	static id _instance = nil;
	
	if (!_instance) {
		_instance = [[self allocWithZone : allocateZone] init];
		if([_instance respondsToSelector:@selector(registNotifications)]) {
			[_instance performSelector:@selector(registNotifications)];
		}
		[self setupDatabase];
	}
	
	return _instance;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}

+ (int) currentDatabaseFileVersion
{
	int version = -1;
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if (!db) return -1;
	
	// VersionTableを持っている場合。
	if ([[db tables] containsObject : VersionTableName]) {	
		id query = [NSString stringWithFormat : @"SELECT %@ FROM %@",
			VersionColumn, VersionTableName];
		id cursor = [db cursorForSQL : query];
		if ([db lastErrorID] != 0) goto abort;
		
		if([cursor rowCount] == 0) {
			return 0;
		}
		id verStr = [cursor valueForColumn : VersionColumn atRow:0];
		version = [verStr intValue];
	}
	
	{
		id cursor = [db cursorForSQL : @"PRAGMA user_version;"];
		if ([db lastErrorID] != 0) goto abort;
		
		if([cursor rowCount] == 0) {
			return 0;
		}
		id verStr = [cursor valueForColumn : @"user_version" atRow:0];
		version = MAX(version, [verStr intValue]);
	}
	
	return version;
	
abort:
		[db rollbackTransaction];
	return -1;
}
+ (BOOL) setVersion : (int) newVersion
{
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if (!db) return NO;
	
	[db performQuery : [NSString stringWithFormat : @"PRAGMA user_version = %d;",
		newVersion]];
	if([db lastErrorID] != noErr) return NO;
	
	return YES;
}

+ (BOOL) mustCreateTables
{
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	NSString *colName = @"c";
	
	if (!db) return NO;
	
	id cursor = [db performQuery : 
		[NSString stringWithFormat : @"SELECT count(name) AS %@ FROM sqlite_master WHERE name LIKE '%@';",
			colName, [SQLiteDB prepareStringForQuery : ThreadInfoTableName]]];
	if([db lastErrorID] != noErr) return NO;
	if(!cursor) return NO;
	if([cursor rowCount] != 1) return NO;
	
	if([[cursor valueForColumn : colName atRow : 0] intValue] != 1) return YES;
	
	return NO;
}

+ (void) checkDatabaseFileVersion
{
	[DatabaseUpdater updateFrom : [self currentDatabaseFileVersion] to : sDatabaseFileVersion];
}

+ (BOOL) createTables
{
	if (![[self defaultManager] createFavoritesTable]) {
		NSLog(@"Can not create Favorites tables");
		return NO;
	}
	if (![[self defaultManager] createBoardInfoTable]) {
		NSLog(@"Can not create BoardInfo tables");
		return NO;
	}
	if (![[self defaultManager] createThreadInfoTable]) {
		NSLog(@"Can not create ThreadInfo tables");
		return NO;
	}
	if (![[self defaultManager] createBoardInfoHistoryTable]) {
		NSLog(@"Can not create BoardInfoHistory tables");
		return NO;
	}
	if (![[self defaultManager] createTempThreadNumberTable]) {
		NSLog(@"Can not create TempThreadNumber tables");
		return NO;
	}
	if (![[self defaultManager] createBoardThreadInfoView]) {
		NSLog(@"Can not create BoardThreadInfo view");
		return NO;
	}
	
	return [self setVersion : sDatabaseFileVersion];
}

+ (void)setupCacheSize
{
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if (!db) return;
	
	int cacheSize = [SGTemplateResource(@"System - SQLite Cache Size") intValue];
	UTILDebugWrite1(@"Try set sqlite cache size to %d", cacheSize);
	if(cacheSize <= 0) return;
	
	[db performQuery:[NSString stringWithFormat : @"PRAGMA cache_size = %d;", cacheSize]];
	if([db lastErrorID] != noErr) {
		UTILDebugWrite1(@"Abort PRAGMA chach_size.\n Reson %@", [db lastError]);
		return;
	}
	
	UTILDebugWrite1(@"Set sqlite cache size to %d", cacheSize);
}	

+ (void) setupDatabase
{
	if([self mustCreateTables]) {
		[self createTables];
	} else {
		[self checkDatabaseFileVersion];
	}
	
	[self setupCacheSize];
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
		ThreadStatusColumn, ThreadAboneTypeColumn, ThreadLabelColumn,
		IsDatOchiColumn,
		IsFavoriteColumn, nil];
}
- (NSArray *) threadInfoDataTypes
{
	return [NSArray arrayWithObjects : INTEGER_NOTNULL, INTEGER_NOTNULL, TEXT_NOTNULL,
		QLNumber, QLNumber,
		QLNumber, QLNumber,
		QLNumber, QLNumber, QLNumber,
		INTEGER_NOTNULL,
		INTEGER_NOTNULL, nil];
}

- (NSArray *) boardInfoHistoryColumns
{
	return [NSArray arrayWithObjects : BoardIDColumn, BoardNameColumn, BoardURLColumn, nil];
}
- (NSArray *) boardInfoHistoryDataTypes
{
	return [NSArray arrayWithObjects : INTEGER_NOTNULL, QLString, QLString, nil];
}

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
			 columns : (NSArray *)columns
		   dataTypes : (NSArray *)dataTypes
	   defaultValues : (NSArray *)defaultValues
	 checkConstrains : (NSArray *)checkConstrains
		indexQueries : (NSArray *)indexQuery
{
	BOOL isOK = NO;
	
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) return NO;
	
	isOK = [db createTable : tableName
				   columns : columns
				 datatypes : dataTypes
			 defaultValues : defaultValues
		   checkConstrains : checkConstrains];
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
		id n = [NSNull null];
		id defaultValues = [NSArray arrayWithObjects:n,n,n,n,n,n,n,n,n,n,@"0",@"0",nil];
		id checkConstrains = [NSArray arrayWithObjects:n,n,n,n,n,n,n,n,n,n,
							  [NSString stringWithFormat:@"%@ IN (0,1)", IsDatOchiColumn],
							  [NSString stringWithFormat:@"%@ IN (0,1)", IsFavoriteColumn],
							  nil];
		isOK = [self createTable : ThreadInfoTableName
						 columns : [self threadInfoColumns]
					   dataTypes : [self threadInfoDataTypes]
				   defaultValues : defaultValues
				 checkConstrains : checkConstrains
					indexQueries : indexies];
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
							   isUnique : NO];
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

- (BOOL) createVersionTable
{
	BOOL isOK = NO;
	
	SQLiteDB *db = [self databaseForCurrentThread];
	if (!db) return NO;
	
	if ([[db tables] containsObject : VersionTableName]) {
		return YES;
	}
	
	if ([db beginTransaction]) {
		isOK = [self createTable : VersionTableName
					 withColumns : [NSArray arrayWithObject:VersionColumn]
					andDataTypes : [NSArray arrayWithObject:NUMERIC_NOTNULL]
				 andIndexQueries : nil];
		if (!isOK) goto abort;
		
		// 
		id query = [NSString stringWithFormat : @"REPLACE INTO %@ (%@) VALUES(%ld)",
			VersionTableName, VersionColumn, sDatabaseFileVersion];
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

#pragma mark -
NSString *tableNameForKey( NSString *sortKey )
{
	NSString *sortCol = nil;
	
	if ([sortKey isEqualTo : CMRThreadTitleKey]) {
		sortCol = ThreadNameColumn;
	} else if ([sortKey isEqualTo : CMRThreadLastLoadedNumberKey]) {
		sortCol = NumberOfReadColumn;
	} else if ([sortKey isEqualTo : CMRThreadNumberOfMessagesKey]) {
		sortCol = NumberOfAllColumn;
	} else if ([sortKey isEqualTo : CMRThreadNumberOfUpdatedKey]) {
		sortCol = NumberOfDifferenceColumn;
	} else if ([sortKey isEqualTo : CMRThreadSubjectIndexKey]) {
		sortCol = TempThreadThreadNumberColumn;
	} else if ([sortKey isEqualTo : CMRThreadStatusKey]) {
		sortCol = ThreadStatusColumn;
	} else if ([sortKey isEqualTo : CMRThreadModifiedDateKey]) {
		sortCol = ModifiedDateColumn;
	} else if ([sortKey isEqualTo : ThreadPlistIdentifierKey]) {
		sortCol = ThreadIDColumn;
	} else if ([sortKey isEqualTo : ThreadPlistBoardNameKey]) {
		sortCol = BoardNameColumn;
	} else if ([sortKey isEqualTo : LastWrittenDateColumn]) {
		sortCol = LastWrittenDateColumn;
	} else if ([sortKey isEqualTo : BSThreadEnergyKey]) {
		sortCol = sortKey;
	}
	
	return [sortCol lowercaseString];
}

