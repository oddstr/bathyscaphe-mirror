//
//  DatabaseUpdater.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/02/03.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DatabaseUpdater.h"

/*
*	Version 0: 初期データベース
*	Version 1: Version Table を導入
*	Version 2: BoardInfoHistoryTableName 上のインデックスを修正
*/

@interface DatabaseUpdaterOneToTow : DatabaseUpdater
@end


@implementation DatabaseUpdater
+ (Class)updaterFrom:(int)from to:(int)to
{
	if((from == 0 && to == 2) || (from == 1 && to == 2)) {
		return [DatabaseUpdaterOneToTow class];
	}
	
	return Nil;
}

- (BOOL)updateVersion:(int)newVersion usingDB:(SQLiteDB *)db
{
	[db performQuery:[NSString stringWithFormat:@"UPDATE %@ SET %@ = %d",
		VersionTableName, VersionColumn, newVersion]];
	if([db lastErrorID] != noErr) return NO;
	
	return YES;
}
	
@end


/*	
*	Verwion 0 -> 2
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
		isOK = [db deleteIndexForColumn:BoardIDColumn inTable:BoardInfoHistoryTableName];
		if (!isOK) goto abort;
		
		isOK = [db createIndexForColumn : BoardIDColumn
								inTable : BoardInfoHistoryTableName
							   isUnique : NO];
		if (!isOK) goto abort;
		
		if(![self updateVersion:2 usingDB:db]) goto abort;
		
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
