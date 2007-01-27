//
//  DatabaseManager.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DatabaseManager.h"

#import <SQLiteDB.h>

#import "ThreadTextDownloader.h"
#import "CMRDocumentFileManager.h"
#import "CMRTrashbox.h"
#import "Browser.h"
NSString *FavoritesTableName = @"Favorites";
NSString *BoardInfoTableName = @"BoardInfo";
NSString *ThreadInfoTableName = @"ThreadInfo";
NSString *BoardInfoHistoryTableName = @"BoardInfoHistory";
//NSString *ResponseTableName = @"Response";
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

//------ static ------//
static long sDatabaseFileVersion = 1;


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
		[[NSNotificationCenter defaultCenter]
			 addObserver : _instance
				selector : @selector(downloaderTextUpdatedNotified:)
					name : ThreadTextDownloaderUpdatedNotification
				  object : nil];

		[[NSNotificationCenter defaultCenter]
			 addObserver : _instance
				selector : @selector(cleanUpItemsToBeRemoved:)
					name : CMRTrashboxDidPerformNotification
				  object : [CMRTrashbox trash]];
	}
	
	return _instance;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}

+ (Class) databaseFileUpdaterClassFrom:(int)currentVersion to:(int)newVersion
{
	return Nil;
}
+ (int) currentDatabaseFileVersion
{
	SQLiteDB *db = [[self defaultManager] databaseForCurrentThread];
	if (!db) return -1;
	
	if (![[db tables] containsObject : VersionTableName]) {
		return 0;
	}
	
	int version = -1;
	if([db beginTransaction]) {
		id query = [NSString stringWithFormat : @"SELEST %@ FROM %@",
			VersionColumn, VersionTableName];
		id cursor = [db cursorForSQL : query];
		if ([db lastErrorID] != 0) goto abort;
		
		if([cursor rowCount] == 0) {
			return 0;
		}
		id verStr = [cursor valueForColumn:VersionColumn atRow:0];
		version = [verStr intValue];
	}
	
	return version;
	
abort:
	[db rollbackTransaction];
	return -1;
}
+ (void) checkDatabaseFileVersion
{
	int currentDatabaseFileVersion = [self currentDatabaseFileVersion];
	if(currentDatabaseFileVersion < sDatabaseFileVersion) {
		Class updaterClass = [self databaseFileUpdaterClassFrom:currentDatabaseFileVersion
															 to:sDatabaseFileVersion];
		id updater = [[updaterClass alloc] init];
		[updater update];
	}
}
+ (void) setupDatabase
{
	[self checkDatabaseFileVersion];
	
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
	if (![[self defaultManager] createVersionTable]) {
		NSLog(@"Can not create Version table");
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
 

#pragma mark ## Notification (Moved From BSDBThreadList) ##
- (void) makeThreadsListsUpdateCursor
{
	NSArray *docs = [NSApp orderedDocuments];
	NSEnumerator *iter_ = [docs objectEnumerator];
	id	eachDoc;
	while (eachDoc = [iter_ nextObject]) {
		if ([eachDoc isMemberOfClass: [Browser class]]) {
			[[(Browser *)eachDoc currentThreadsList] updateCursor];
		}
	}
}

- (BOOL) searchBoardID: (int *) outBoardID threadID: (NSString **) outThreadID fromFilePath: (NSString *) inFilePath
{
	CMRDocumentFileManager *dfm = [CMRDocumentFileManager defaultManager];
	
	if (outThreadID) {
		*outThreadID = [dfm datIdentifierWithLogPath : inFilePath];
	}
	
	if (outBoardID) {
		NSString *boardName;
		NSArray *boardIDs;
		id boardID;
		
		boardName = [dfm boardNameWithLogPath : inFilePath];
		if (!boardName) return NO;
		
		boardIDs = [self boardIDsForName : boardName];
		if (!boardIDs || [boardIDs count] == 0) return NO;
		
		boardID = [boardIDs objectAtIndex : 0];
		
		*outBoardID = [boardID intValue];
	}
	
	return YES;
}

- (void) downloaderTextUpdatedNotified : (NSNotification *) notification
{
	CMRDownloader			*downloader_;
	NSDictionary			*userInfo_;
	NSDictionary			*newContents_;
/*	
	UTILAssertNotificationName(
							   notification,
							   ThreadTextDownloaderUpdatedNotification);
*/	
	
	downloader_ = [notification object];
//	UTILAssertKindOfClass(downloader_, CMRDownloader);
	
	userInfo_ = [notification userInfo];
//	UTILAssertNotNil(userInfo_);
	
	newContents_ = [userInfo_ objectForKey : CMRDownloaderUserInfoContentsKey];
/*	UTILAssertKindOfClass(
						  newContents_,
						  NSDictionary);*/
	
	do {
		SQLiteDB *db;
		NSMutableString *sql;
		
		int		cnt_;
		NSArray		*messages_;
		NSDate *modDate = [newContents_ objectForKey : CMRThreadModifiedDateKey];
		
		int baordID = 0;
		NSString *threadID;
		
		db = [self databaseForCurrentThread];
		if(!db) break;
		
		messages_ = [newContents_ objectForKey : ThreadPlistContentsKey];
		cnt_ = (messages_ != nil) ? [messages_ count] : 0;
		
		if (NO == [self searchBoardID: &baordID threadID: &threadID fromFilePath: [downloader_ filePathToWrite]]) {
			break;
		}
		
		sql = [NSMutableString stringWithFormat : @"UPDATE %@ ", ThreadInfoTableName];
		[sql appendFormat : @"SET %@ = %u, %@ = %u, %@ = %u, %@ = %.0lf ",
			NumberOfAllColumn, cnt_,
			NumberOfReadColumn, cnt_,
			ThreadStatusColumn, ThreadLogCachedStatus,
			ModifiedDateColumn, [modDate timeIntervalSince1970]];
		[sql appendFormat : @"WHERE %@ = %u AND %@ = %@",
			BoardIDColumn, baordID, ThreadIDColumn, threadID];
		
		[db cursorForSQL : sql];
		
		if ([db lastErrorID] != 0) {
			NSLog(@"Fail Insert or udate. Reson: %@", [db lastError] );
		}

		[self makeThreadsListsUpdateCursor];
	} while ( NO );
	
}

- (void) cleanUpItemsToBeRemoved : (NSNotification *) aNotification
{
	NSNumber *err_;
	NSArray *files;

	err_ = [[aNotification userInfo] objectForKey : kAppTrashUserInfoStatusKey];
	if(nil == err_) return;
//	UTILAssertKindOfClass(err_, NSNumber);
	if([err_ intValue] != noErr) return;
	
	files = [[aNotification userInfo] objectForKey : kAppTrashUserInfoFilesKey];

	SQLiteDB *db = [self databaseForCurrentThread];
	NSString *query;
	
	NSEnumerator *filesEnum;
	NSString *path;
	
	if([db beginTransaction]) {
		filesEnum = [files objectEnumerator];
		while(path = [filesEnum nextObject]) {
			int boardID = 0;
			NSString *threadID;
			
			if([self searchBoardID: &boardID threadID: &threadID fromFilePath: path]) {
				
				query = [NSString stringWithFormat:
					@"UPDATE %@\n"
					@"SET %@ = NULL,\n"
					@"%@ = NULL,\n"
					@"%@ = %d,\n"
					@"%@ = NULL,\n"
					@"%@ = NULL\n"
					@"WHERE %@ = %d\n"
					@"AND %@ = %@",
					ThreadInfoTableName,
					NumberOfReadColumn,
					ModifiedDateColumn,
					ThreadStatusColumn, ThreadNoCacheStatus,
					ThreadAboneTypeColumn,
					ThreadLabelColumn,
					BoardIDColumn, boardID,
					ThreadIDColumn, threadID];
				
				[db performQuery:query];
			}
			
		}
		[db commitTransaction];
	}
	
	[self makeThreadsListsUpdateCursor];
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
	}
	
	return [sortCol lowercaseString];
}
