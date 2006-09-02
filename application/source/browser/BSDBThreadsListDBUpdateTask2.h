//
//  BSDBThreadsListDBUpdateTask2.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRTask.h"
#import "CMXWorkerContext.h"

@class SQLiteReservedQuery;

@interface BSDBThreadsListDBUpdateTask2 : NSObject <CMXRunnable>
{
	NSString *bbsName;
	NSData *subjectData;
	
	NSNumber *boardID;
	
	SQLiteReservedQuery *reservedInsert;
	SQLiteReservedQuery *reservedUpdate;
	SQLiteReservedQuery *reservedInsertNumber;
	SQLiteReservedQuery *reservedSelectThreadTable;
	
	BOOL isInterrupted;
}

+ (id)taskWithBBSName:(NSString *)name data:(NSData *)data;
- (id)initWithBBSName:(NSString *)name data:(NSData *)data;

- (void)setBBSName:(NSString *)name;
@end

@interface BSDBThreadsListDBUpdateTask2(TaskNotification)
- (void) postNotificationWithName:(NSString *)name;
- (void) postTaskWillStartNotification;
- (void) postTaskDidFinishNotification;
@end

extern NSString *BSDBThreadsListDBUpdateTask2DidFinishNotification;
