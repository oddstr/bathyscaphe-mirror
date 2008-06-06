//
//  DatabaseManager-Notifications.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/06/26.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
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
/*	[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(downloaderTextUpdatedNotified:)
					name : ThreadTextDownloaderUpdatedNotification
				  object : nil];*/
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(cleanUpItemsToBeRemoved:)
			   name:CMRTrashboxDidPerformNotification
			 object:[CMRTrashbox trash]];
	
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
/*	NSArray *docs = [NSApp orderedDocuments];
	NSEnumerator *iter_ = [docs objectEnumerator];
	id	eachDoc;
	while (eachDoc = [iter_ nextObject]) {
		if ([eachDoc isMemberOfClass: [Browser class]]) {
			//			[[(Browser *)eachDoc currentThreadsList] updateCursor];
			// Why this works well?
			[[(Browser *)eachDoc currentThreadsList] performSelector: @selector(updateCursor) withObject: nil afterDelay: 0.0];
		}
	}*/
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

//- (void)downloaderTextUpdatedNotified:(NSNotification *)notification
- (void)threadTextDownloader:(CMRDownloader *)downloader didUpdateWithContents:(NSDictionary *)userInfo
{
	NSDictionary			*newContents_;
/*	CMRDownloader			*downloader_;
	NSDictionary			*userInfo_;

	UTILAssertNotificationName(notification, ThreadTextDownloaderUpdatedNotification);
	
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, CMRDownloader);
	
	userInfo_ = [notification userInfo];
	UTILAssertNotNil(userInfo_);*/
	
	UTILAssertKindOfClass(downloader, CMRDownloader);
	UTILAssertNotNil(userInfo);
	UTILAssertKindOfClass(userInfo, NSDictionary);

	newContents_ = [userInfo objectForKey:CMRDownloaderUserInfoContentsKey];
	UTILAssertKindOfClass(newContents_, NSDictionary);
	
	do {
		SQLiteDB *db;
		NSMutableString *sql;
		
		int		cnt_;
		NSArray		*messages_;
		NSDate *modDate = [newContents_ objectForKey:CMRThreadModifiedDateKey];
		
		int boardID = 0;
		NSString *threadID;
		
		db = [self databaseForCurrentThread];
		if (!db) break;

		messages_ = [newContents_ objectForKey:ThreadPlistContentsKey];
		cnt_ = (messages_ != nil) ? [messages_ count] : 0;

//		if (![self searchBoardID:&baordID threadID:&threadID fromFilePath:[downloader_ filePathToWrite]]) {
		if (![self searchBoardID:&boardID threadID:&threadID fromFilePath:[downloader filePathToWrite]]) {
			break;
		}

		sql = [NSMutableString stringWithFormat:@"UPDATE %@ ", ThreadInfoTableName];
		[sql appendFormat:@"SET %@ = %u, %@ = %u, %@ = %u, %@ = %.0lf ",
			NumberOfAllColumn, cnt_,
			NumberOfReadColumn, cnt_,
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

- (void)cleanUpItemsToBeRemoved:(NSNotification *)aNotification
{
	NSNumber *err_;
	NSArray *files;
	
	err_ = [[aNotification userInfo] objectForKey:kAppTrashUserInfoStatusKey];
	if (!err_) return;
	UTILAssertKindOfClass(err_, NSNumber);
	if ([err_ intValue] != noErr) return;

	files = [[aNotification userInfo] objectForKey:kAppTrashUserInfoFilesKey];

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
			}
			
		}
		[db commitTransaction];
	}
	
	[self makeThreadsListsUpdateCursor];
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
