//
//  BSThreadListSmartItemDBUpdateTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/31.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMRThreadLayoutTask.h"

@interface BSThreadListSmartItemDBUpdateTask : CMRThreadLayoutConcreateTask
{
	id target;
	NSArray *threads;
	unsigned mProgress;
	NSString *mAmountString;
	NSLock *mAmountStringLock;
}

+ (id)taskWithUpdateThreads:(NSArray *)threads;
- (id)initWithUpdateThreads:(NSArray *)threads;

- (void)setTarget:(id)target;

- (void)update;

- (NSString *)amountString;
- (void)setAmountString:(NSString *)new;
- (unsigned)progress;
- (void)setProgress:(unsigned) new;

@end

@interface BSThreadListSmartItemDBUpdateTask(TaskNotification)
- (void) postTaskWillStartNotification;
- (void) postTaskDidFinishNotification;
@end