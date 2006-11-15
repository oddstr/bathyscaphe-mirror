//
//  BSThreadsListOPTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BSDBThreadList.h"

#import "CMRTask.h"
#import "CMXWorkerContext.h"

#import "CMRThreadLayoutTask.h"

@class BSDownloadTask, BSDBThreadsListDBUpdateTask2;

@interface BSThreadsListOPTask : CMRThreadLayoutConcreateTask //NSObject <CMRTask, CMXRunnable>
{
	BSDBThreadList *targetList;
	BOOL forceDL;
	
	NSURL *targetURL;
	NSString *bbsName;
	BSDownloadTask *dlTask;
	BSDBThreadsListDBUpdateTask2 *dbupTask;
	
	NSData *downloadData;
}

+ (id)taskWithThreadList:(BSDBThreadList *)list forceDownload:(BOOL)forceDL;
- (id)initWithThreadList:(BSDBThreadList *)list forceDownload:(BOOL)forceDL;

- (void)setBoardName:(NSString *)name;
- (NSString *)boardName;

@end
