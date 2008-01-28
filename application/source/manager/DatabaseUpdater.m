//
//  DatabaseUpdater.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/02/03.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "DatabaseUpdater.h"

/*
 *	Version 0: 初期データベース
 *	Version 1: Version Table を導入
 *	Version 2: BoardInfoHistory 上のインデックスを修正
 *	Version 3: Version Table を廃止。 ThreadInfo Table に IsDatOchi カラムを追加
 *	Version 4: Favorites Table を廃止。 ThreadInfo Table に IsFavorite カラムを追加
 *	Version 5: BoardThreadInfoView を変更。 isCached, isUpdated, isNew, isHeadModified カラムを追加
 */

@interface DatabaseUpdaterOneToTow : DatabaseUpdater
@end
@interface DatabaseUpdaterToThree : DatabaseUpdater
@end
@interface DatabaseUpdaterToFour : DatabaseUpdater
@end
@interface DatabaseUpdaterToFive : DatabaseUpdater
@end


@implementation DatabaseUpdater

+ (BOOL)updateFrom:(int)fromVersion to:(int)toVersion
{
	BOOL result = YES;
	
	if(fromVersion < 0) return YES;
	
	if(fromVersion < 2 && toVersion >= 2) {
		result = [[[[DatabaseUpdaterOneToTow alloc] init] autorelease] updateDB];
	}
	if(!result) return result;
	
	if(fromVersion < 3 && toVersion >= 3) {
		result = [[[[DatabaseUpdaterToThree alloc] init] autorelease] updateDB];
	}
	if(!result) return result;
	
	if(fromVersion < 4 && toVersion >= 4) {
		result = [[[[DatabaseUpdaterToFour alloc] init] autorelease] updateDB];
	}
	if(!result) return result;
	
	if(fromVersion < 5 && toVersion >= 5) {
		result = [[[[DatabaseUpdaterToFive alloc] init] autorelease] updateDB];
	}
	if(!result) return result;
	
	return result;
}

- (BOOL)updateVersion:(int)newVersion usingDB:(SQLiteDB *)db
{
	if (!db) return NO;
	
	[db performQuery : [NSString stringWithFormat : @"PRAGMA user_version = %d;",
		newVersion]];
	if([db lastErrorID] != noErr) return NO;
	
	return YES;
}
	
@end


/*	
 *	Version 0 -> 2
 *	Version 1 -> 2
 *	
 *	BoardInfoHistoryTableName 上の BoardIDColumn のインデックスが UNIQUE インデックスになっていたのを
 *	通常のインデックスに変更
 */
@implementation DatabaseUpdaterOneToTow
- (BOOL) updateDB
{
	BOOL isOK = NO;
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if (!db) return NO;
	
	if ([db beginTransaction]) {
		isOK = [db deleteIndexForColumn : BoardIDColumn inTable : BoardInfoHistoryTableName];
		if (!isOK) goto abort;
		
		isOK = [db createIndexForColumn : BoardIDColumn
								inTable : BoardInfoHistoryTableName
							   isUnique : NO];
		if (!isOK) goto abort;
		
		if(![self updateVersion : 2 usingDB : db]) goto abort;
		
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

/*
 *	Version 2 -> 3
 *	
 *	ThreadInfo Table に IsDatOchiColumn カラムを追加
 */
@implementation DatabaseUpdaterToThree
- (BOOL) updateDB
{
	BOOL isOK = NO;
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if (!db) return NO;
	
	if ([db beginTransaction]) {
		id query = [NSString stringWithFormat : @"ALTER TABLE %@ ADD COLUMN %@ %@ DEFAULT 0 CHECK(%@ IN (0,1))",
			ThreadInfoTableName, IsDatOchiColumn, INTEGER_NOTNULL, IsDatOchiColumn];
		[db cursorForSQL : query];
		if ([db lastErrorID] != 0) goto abort;
		
		if(![self updateVersion : 3 usingDB : db]) goto abort;
		
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

/*
 *	Version 3 -> 4
 *	
 *	ThreadInfo Table に IsFavoriteColumn カラムを追加
 */
@implementation DatabaseUpdaterToFour
- (BOOL) restoreFavoriteOnDatabase:(SQLiteDB *)db
{
	NSString *query;
	id result;
	
	// お気に入り取り出し
	query = [NSString stringWithFormat : @"SELECT %@, %@ FROM %@",
		BoardIDColumn, ThreadIDColumn, FavoritesTableName];
	result = [db cursorForSQL : query];
	if ([db lastErrorID] != 0) goto abort;
	if(!result) goto abort;
	if([result rowCount] == 0) return YES;
	
	// お気に入りを ThreadInfoTable に登録
	SQLiteReservedQuery *insertFav;
	
	query = [NSString stringWithFormat : @"UPDATE OR IGNORE %@ SET %@ = 1 WHERE %@ = ? AND %@ = ?",
		ThreadInfoTableName, IsFavoriteColumn, BoardIDColumn, ThreadIDColumn];
	insertFav = [SQLiteReservedQuery sqliteReservedQueryWithQuery : query
													usingSQLiteDB : db];
	
	unsigned i, count;
	for(i = 0, count = [result rowCount]; i < count; i++) {
		id row = [result rowAtIndex : i];
		id boardID = [row valueForColumn : BoardIDColumn];
		id threadID = [row valueForColumn : ThreadIDColumn];
		
		[insertFav cursorForBindValues : [NSArray arrayWithObjects : boardID, threadID, nil]];
		if ([db lastErrorID] != 0) goto abort;
	}
	
	return YES;
	
abort:
	NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
//	[db rollbackTransaction];
	return NO;
}
- (BOOL) updateDB
{
	BOOL isOK = NO;
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if (!db) return NO;
	
	if ([db beginTransaction]) {
		id query = [NSString stringWithFormat : @"ALTER TABLE %@ ADD COLUMN %@ %@ DEFAULT 0 CHECK(%@ IN (0,1))",
			ThreadInfoTableName, IsFavoriteColumn, INTEGER_NOTNULL, IsFavoriteColumn];
		[db cursorForSQL : query];
		if ([db lastErrorID] != 0) goto abort;
		
		isOK = [self restoreFavoriteOnDatabase : db];
		if(!isOK) goto abort;
		
		isOK = [self updateVersion : 4 usingDB : db];
		if(!isOK) goto abort;
		
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

/*
 *	Version 4 -> 5
 *	
 *	BoardThreadInfoView を変更。 isCached, isUpdated, isNew, isHeadModified カラムを追加
 */
@implementation DatabaseUpdaterToFive
- (BOOL) updateDB
{
	BOOL isOK = NO;
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if (!db) return NO;
	
	if ([db beginTransaction]) {
		id query = [NSString stringWithFormat : @"DROP VIEW %@;", BoardThreadInfoViewName];
		[db cursorForSQL : query];
		if ([db lastErrorID] != 0) goto abort;
		
		query = [NSMutableString stringWithFormat : @"CREATE VIEW %@ AS\n", BoardThreadInfoViewName];
		[query appendFormat : @"\tSELECT *, (%@ - %@) AS %@\n",
		 NumberOfAllColumn, NumberOfReadColumn, NumberOfDifferenceColumn];
		[query appendFormat : @", NOT(%@ - %d) AS %@\n",
		 ThreadStatusColumn, ThreadLogCachedStatus, IsCachedColumn];
		[query appendFormat : @", NOT(%@ - %d) AS %@\n",
		 ThreadStatusColumn, ThreadUpdatedStatus, IsUpdatedColumn];
		[query appendFormat : @", NOT(%@ - %d) AS %@\n",
		 ThreadStatusColumn, ThreadNewCreatedStatus, IsNewColumn];
		[query appendFormat : @", NOT(%@ - %d) AS %@\n",
		 ThreadStatusColumn, ThreadHeadModifiedStatus, IsHeadModifiedColumn];
		[query appendFormat : @"FROM %@ INNER JOIN %@ USING(%@) ",
		 ThreadInfoTableName, BoardInfoTableName, BoardIDColumn];
		
		[db cursorForSQL : query];
		if ([db lastErrorID] != 0) goto abort;
		
		
		if(![self updateVersion : 5 usingDB : db]) goto abort;
		
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