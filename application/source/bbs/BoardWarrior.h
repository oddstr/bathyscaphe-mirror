//
//  BoardWarrior.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/08/06.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMRTask.h"

@class BSIPIDownload;

@interface BoardWarrior : NSObject<CMRTask> {
	@private
	BOOL			m_isInProgress;
	NSString		*m_progressMessage;

	double			m_expectedContentLength;
	double			m_downloadedContentLength;
	
	BSIPIDownload	*m_currentDownload; // No retain/release
	NSString		*m_bbsMenuPath;
}

+ (id) warrior;

- (void) setMessage: (NSString *) progressMessage;

- (NSString *) bbsMenuPath;
- (void) setBbsMenuPath: (NSString *) filePath;

- (BOOL) syncBoardListsWithURL: (NSURL *) anURL;
- (BOOL) syncBoardLists;

- (double) expectedContentLength;
- (double) downloadedContentLength;

- (BOOL) writeLogsToFileWithUTF8Data: (NSData *) encodedData;
@end

extern NSString *const BoardWarriorWillStartDownloadNotification;
extern NSString *const BoardWarriorDidFinishDownloadNotification;
extern NSString *const BoardWarriorDidFailDownloadNotification;
extern NSString *const BoardWarriorDidFailInitASNotification; // Available in Starlight Breaker.

extern NSString *const BoardWarriorWillStartCreateDefaultListTaskNotification;
extern NSString *const BoardWarriorDidFailCreateDefaultListTaskNotification;

extern NSString *const BoardWarriorWillStartSyncUserListTaskNotification;
extern NSString *const BoardWarriorDidFailSyncUserListTaskNotification;

extern NSString *const BoardWarriorDidFinishAllTaskNotification;

extern NSString *const kBWInfoExpectedLengthKey;
extern NSString *const kBWInfoErrorStringKey;
