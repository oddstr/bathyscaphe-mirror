//
//  BoardWarrior.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/08/06.
//  Copyright 2006-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

@class BSURLDownload;
@protocol CMRTask;

enum {
	BWDidFailInitializeAppleScript = -1000,
	BWDidFailExecuteAppleScriptHandler = -1001//,
/*	BWDidFailCreatingLogFile = -2000,
	BWDidFailWritingLogToFile = -2001 // reserved */
};

@interface BoardWarrior : NSObject<CMRTask> {
	@private
	BOOL			m_isInProgress;
	NSString		*m_progressMessage;

//	double			m_expectedContentLength;
//	double			m_downloadedContentLength;
	
	BSURLDownload	*m_currentDownload; // No retain/release
	NSString		*m_bbsMenuPath;
	
	id				m_delegate; // No retain/release
}

+ (id)warrior;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

- (BOOL)syncBoardListsWithURL:(NSURL *)anURL;
- (BOOL)syncBoardLists;

- (NSString *)logFilePath;
@end


@interface NSObject(BoardWarriorDelegate)
- (void)warriorWillStartSyncing:(BoardWarrior *)warrior;
- (void)warriorDidFinishSyncing:(BoardWarrior *)warrior;
- (void)warrior:(BoardWarrior *)warrior didFailSync:(NSError *)error;
//- (void)warrior:(BoardWarrior *)warrior didFailLogging:(NSError *)error;
@end

extern NSString *const kBoardWarriorErrorDomain;
