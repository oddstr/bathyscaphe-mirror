//
//  BSThreadsListOPTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BSDBThreadList.h"

#import "CMRTask.h"
#import "CMXWorkerContext.h"

#import "CMRThreadLayoutTask.h"

@class BSDownloadTask, BSDBThreadsListDBUpdateTask2;

@interface BSThreadsListOPTask : CMRThreadLayoutConcreateTask
{
	BSDBThreadList *m_targetList;
	BOOL m_forceDL;
	
	NSURL *targetURL;
	NSString *bbsName;
	BSDownloadTask *dlTask;
	BSDBThreadsListDBUpdateTask2 *dbupTask;
	
	NSData *m_downloadData;
	NSError *m_downloadError;
}

+ (id)taskWithThreadList:(BSDBThreadList *)list forceDownload:(BOOL)forceDL;
- (id)initWithThreadList:(BSDBThreadList *)list forceDownload:(BOOL)forceDL;

- (void)setBoardName:(NSString *)name;
- (NSString *)boardName;
@end

extern NSString *const ThreadsListDownloaderShouldRetryUpdateNotification;
