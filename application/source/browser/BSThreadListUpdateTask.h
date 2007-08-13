//
//  BSThreadListUpdateTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/29.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRThreadLayoutTask.h"

@class BSDBThreadList;

@interface BSThreadListUpdateTask : CMRThreadLayoutConcreateTask //NSObject <CMRTask>
{
	BSDBThreadList *target;
	BOOL progress;
	BOOL userCanceled;
	
	NSString *bbsName;
	
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