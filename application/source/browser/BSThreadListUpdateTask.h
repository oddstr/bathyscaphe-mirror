//
//  BSThreadListUpdateTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/29.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRTask.h"

@class BSDBThreadList;

@interface BSThreadListUpdateTask : NSObject <CMRTask>
{
	BSDBThreadList *target;
	BOOL progress;
	BOOL userCanceled;
}

+ (id)taskWithBSDBThreadList:(BSDBThreadList *)threadList;
- (id)initWithBSDBThreadList:(BSDBThreadList *)threadList;

- (id)cursor;

@end

@interface BSThreadListUpdateTask(TaskNotification)
- (void) postTaskWillStartNotification;
- (void) postTaskDidFinishNotification;
@end