//
//  BSThreadListUpdateTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/29.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRThreadLayoutTask.h"

@class BSDBThreadList;

@interface BSThreadListUpdateTask : CMRThreadLayoutConcreateTask //NSObject <CMRTask>
{
	BSDBThreadList *target;
	BOOL progress;
	BOOL userCanceled;
	
	id cursor;
}

+ (id)taskWithBSDBThreadList:(BSDBThreadList *)threadList;
- (id)initWithBSDBThreadList:(BSDBThreadList *)threadList;

- (id)cursor;

@end

@interface BSThreadListUpdateTask(Notification)
- (void) postTaskDidFinishNotification;
@end

extern NSString *BSThreadListUpdateTaskDidFinishNotification;