//
//  DatabaseManager-Notifications.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/06/26.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "DatabaseManager.h"

#import "ThreadTextDownloader.h"
#import "CMRDocumentFileManager.h"
#import "CMRTrashbox.h"
#import "CMRReplyMessenger.h"

#import <Carbon/Carbon.h>

NSString *const DatabaseDidFinishUpdateDownloadedOrDeletedThreadInfoNotification = @"DatabaseDidFinishUpdateDownloadedOrDeletedThreadInfoNotification";

@implementation DatabaseManager(Notifications)
-(void)registNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

	[nc addObserver:self
		   selector:@selector(finishWriteMesssage:)
			   name:CMRReplyMessengerDidFinishPostingNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(applicationWillTerminate:)
			   name:NSApplicationWillTerminateNotification
			 object:NSApp];
}

#pragma mark ## Notification (Moved From BSDBThreadList) ##
- (void)makeThreadsListsUpdateCursor
{
	NSNotification *notification = [NSNotification notificationWithName:DatabaseDidFinishUpdateDownloadedOrDeletedThreadInfoNotification object:self];
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

- (BOOL)searchBoardID:(int *)outBoardID threadID:(NSString **)outThreadID fromFilePath:(NSString *)inFilePath
{
	CMRDocumentFileManager *dfm = [CMRDocumentFileManager defaultManager];
	
	if (outThreadID) {
		*outThreadID = [dfm datIdentifierWithLogPath:inFilePath];
	}
	
	if (outBoardID) {
		NSString *boardName;
		NSArray *boardIDs;
		id boardID;
		
		boardName = [dfm boardNameWithLogPath:inFilePath];
		if (!boardName) return NO;
		
		boardIDs = [self boardIDsForName:boardName];
		if (!boardIDs || [boardIDs count] == 0) return NO;
		
		boardID = [boardIDs objectAtIndex:0];
		
		*outBoardID = [boardID intValue];
	}
	
	return YES;
}

- (void)threadTextDownloader:(ThreadTextDownloader *)downloader didUpdateWithContents:(NSDictionary *)userInfo
{
	CMRThreadSignature	*signature;
	
	UTILAssertKindOfClass(downloader, ThreadTextDownloader);
	UTILAssertNotNil(userInfo);
	UTILAssertKindOfClass(userInfo, NSDictionary);

	signature = [downloader threadSignature];
	UTILAssertNotNil(signature);

	do {
		SQLiteDB *db;
		NSMutableString *sql;
		NSArray *boardIDs;
		
		NSDate *modDate = [userInfo objectForKey:@"ttd_date"];
		unsigned int count = [[userInfo objectForKey:@"ttd_count"] unsignedIntValue];
		
		int boardID = 0;
		NSString *threadID;
		
		db = [self databaseForCurrentThread];
		if (!db) break;

		threadID = [signature identifier];
		
		boardIDs = [self boardIDsForName:[signature boardName]];
		if (!boardIDs || [boardIDs count] == 0) break;
		
		boardID = [[boardIDs objectAtIndex:0] intValue];


		sql = [NSMutableString stringWithFormat:@"UPDATE %@ ", ThreadInfoTableName];
		[sql appendFormat:@"SET %@ = %u, %@ = %u, %@ = %u, %@ = %.0lf ",
			NumberOfAllColumn, count,
			NumberOfReadColumn, count,
			ThreadStatusColumn, ThreadLogCachedStatus,
			ModifiedDateColumn, [modDate timeIntervalSince1970]];
		[sql appendFormat:@"WHERE %@ = %u AND %@ = %@",
			BoardIDColumn, boardID, ThreadIDColumn, threadID];
		
		[db cursorForSQL:sql];
		
		if ([db lastErrorID] != 0) {
			NSLog(@"Fail to update. Reason: %@", [db lastError] );
		}

		[self makeThreadsListsUpdateCursor];
	} while (NO);
}

//- (void)cleanUpItemsToBeRemoved:(NSNotification *)aNotification
- (void)cleanUpItemsWhichHasBeenRemoved:(NSArray *)files
{
/*	NSNumber *err_;
	NSArray *files;
	
	err_ = [[aNotification userInfo] objectForKey:kAppTrashUserInfoStatusKey];
	if (!err_) return;
	UTILAssertKindOfClass(err_, NSNumber);
	if ([err_ intValue] != noErr) return;

	files = [[aNotification userInfo] objectForKey:kAppTrashUserInfoFilesKey];
*/
	SQLiteDB *db = [self databaseForCurrentThread];
	NSString *query;
	
	NSEnumerator *filesEnum;
	NSString *path;
	
	if ([db beginTransaction]) {
		filesEnum = [files objectEnumerator];
		while (path = [filesEnum nextObject]) {
			int boardID = 0;
			NSString *threadID;
			
			if ([self searchBoardID:&boardID threadID:&threadID fromFilePath:path]) {
				query = [NSString stringWithFormat:
						 @"UPDATE %@\n"
						 @"SET %@ = NULL,\n"
						 @"%@ = NULL,\n"
						 @"%@ = %d,\n"
						 @"%@ = NULL,\n"
						 @"%@ = NULL,\n"
						 @"%@ = 0,\n"
						 @"%@ = 0\n"
						 @"WHERE %@ = %d\n"
						 @"AND %@ = %@",
						 ThreadInfoTableName,
						 NumberOfReadColumn,
						 ModifiedDateColumn,
						 ThreadStatusColumn, ThreadNoCacheStatus,
						 ThreadAboneTypeColumn,
						 ThreadLabelColumn,
						 IsDatOchiColumn,
						 IsFavoriteColumn,
						 BoardIDColumn, boardID,
						 ThreadIDColumn, threadID];
				
				[db performQuery:query];
				if([db lastErrorID] != 0) goto abort;
				
				query = [NSMutableString stringWithFormat:
						 @"DELETE FROM %@"
						 @" WHERE %@ = %u"
						 @" AND %@ = %@",
						 FavoritesTableName,
						 BoardIDColumn, boardID,
						 ThreadIDColumn, threadID];
				[db performQuery : query];
				if([db lastErrorID] != 0) goto abort;
			}
			
		}
		[db commitTransaction];
	}
	
	[self makeThreadsListsUpdateCursor];
	
	return;
	
abort:
	NSLog(@"FAIL delete threadInfo. Reson : %@", [db lastError]);
	[db rollbackTransaction];
}

- (void)finishWriteMesssage:(NSNotification *)aNotification
{
	id obj = [aNotification object];
	UTILAssertKindOfClass(obj, [CMRReplyMessenger class]);
	
	id boardName = [obj boardName];
	id threadID = [obj datIdentifier];
	id writeDate = [obj modifiedDate];
	
	id boardIDs = [self boardIDsForName:boardName];
	// TODO 二つ以上あった場合
	int boardID = [[boardIDs objectAtIndex:0] intValue];
	
	[self setLastWriteDate:writeDate atBoardID:boardID threadIdentifier:threadID];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	//	NSEvent *event = [NSApp currentEvent];
	//	int isAltKey = [event modifierFlags] & NSAlternateKeyMask;
	//	if(!isAltKey) return;
	KeyMap m;
	long lm;
	GetKeys(m);
#if TARGET_RT_LITTLE_ENDIAN
	lm = EndianU32_LtoB(m[1].bigEndianValue);
#else
	lm = m[1];
#endif
	if((lm & 0x4) != 0x4/*option key*/) return;
	
	UTILDebugWrite(@"START VACUUM");
	[[self databaseForCurrentThread] performQuery:@"VACUUM"];
	UTILDebugWrite(@"END VACUUM");
}
@end
