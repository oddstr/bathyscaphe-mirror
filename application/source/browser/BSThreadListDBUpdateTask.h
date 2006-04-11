//
//  BSThreadListDBUpdateTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/30.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRTask.h"

@interface BSThreadListDBUpdateTask : NSObject <CMRTask>
{
	NSArray *threads;
	BOOL progress;
	BOOL userCanceled;
}

+ (id)taskWithUpdateThreads:(NSArray *)threads;
- (id)initWithUpdateThreads:(NSArray *)threads;

- (void)update;

@end

@interface BSThreadListDBUpdateTask(TaskNotification)
- (void) postTaskWillStartNotification;
- (void) postTaskDidFinishNotification;
@end