//
//  BoardWarrior.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/08/06.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BoardWarrior : NSObject {
	@private
	BOOL			m_isInProgress;

	double			m_expectedContentLength;
	double			m_downloadedContentLength;
}

+ (id) warrior;

- (BOOL) syncBoardListsWithURL: (NSURL *) anURL;
- (BOOL) syncBoardLists;
- (BOOL) isInProgress;

- (double) expectedContentLength;
- (double) downloadedContentLength;

// on error, returns Error Description (as NSString.) on success, nil is returned.
- (NSString *) startKaleidoStage: (NSString *) scriptName withHTMLPath: (NSString *) htmlPath;
@end

extern NSString *const BoardWarriorWillStartDownloadNotification;
extern NSString *const BoardWarriorDidFinishDownloadNotification;
extern NSString *const BoardWarriorDidFailDownloadNotification;

extern NSString *const BoardWarriorWillStartCreateDefaultListTaskNotification;
extern NSString *const BoardWarriorDidFailCreateDefaultListTaskNotification;

extern NSString *const BoardWarriorWillStartSyncUserListTaskNotification;
extern NSString *const BoardWarriorDidFailSyncUserListTaskNotification;

extern NSString *const BoardWarriorDidFinishAllTaskNotification;

extern NSString *const kBWInfoExpectedLengthKey;
extern NSString *const kBWInfoErrorStringKey;
