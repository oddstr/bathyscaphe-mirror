//
//  BSThreadsListOPTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRTask.h"
#import "CMXWorkerContext.h"

#import "CMRThreadLayoutTask.h"

@class BSDownloadTask,BSDBThreadsListUpdateTask, BSDBThreadsListDBUpdateTask2;

enum {
	BSThreadsListOPTaskStart = 0,
	BSThreadsListOPTaskFinishDL = 0x01,
	BSThreadsListOPTaskFinishUp = 0x02,
	BSThreadsListOPTaskFinishAll = BSThreadsListOPTaskFinishDL + BSThreadsListOPTaskFinishUp,
	
	BSThreadsListOPTaskFinishUpdateDB = 0x04,
};

@interface BSThreadsListOPTask : CMRThreadLayoutConcreateTask //NSObject <CMRTask, CMXRunnable>
{
	BOOL forceDL;
	int status;
	NSLock *statusLock;
	
	NSURL *targetURL;
	NSString *bbsName;
	BSDownloadTask *dlTask;
	BSDBThreadsListUpdateTask *dbloadTask;
	BSDBThreadsListDBUpdateTask2 *dbupTask;
	
	NSData *downloadData;
}

+ (id)taskWithBBSName:(NSString *)bbsName forceDownload:(BOOL)forceDL;
- (id)initWithBBSName:(NSString *)bbsName forceDownload:(BOOL)forceDL;

- (void)setURL:(NSURL *)url;
- (NSURL *)url;
@end
