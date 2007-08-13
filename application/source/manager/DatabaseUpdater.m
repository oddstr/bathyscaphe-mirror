//
//  DatabaseUpdater.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/02/03.
//

#import "DatabaseUpdater.h"

/*
 *	Version 0: 初期データベース
 *	Version 1: Version Table を導入
 *	Version 2: BoardInfoHistoryTableName 上のインデックスを修正
 *	Version 3: Version Table を廃止。 ThreadInfo Table に IsDatOchiColumn カラムを追加
 */

@interface DatabaseUpdaterOneToTow : DatabaseUpdater
@end
@interface DatabaseUpdaterToThree : DatabaseUpdater
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
