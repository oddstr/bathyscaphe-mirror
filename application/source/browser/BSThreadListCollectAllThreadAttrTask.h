//
//  BSThreadListCollectAllThreadAttrTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/30.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMRThreadLayoutTask.h"

@class BSDBThreadList;

@interface BSThreadListAllThreadAttrCollector : NSObject
{
	BSDBThreadList *target;
}

+ (id)collectorWithBSDBThreadList:(BSDBThreadList *)threadList;
- (id)initWithBSDBThreadList:(BSDBThreadList *)threadList;

- (id)allThread;

@end


enum {
	bsFakeArrayReady,
	bsFakeArrayNotReady,
};

@interface BSFakeThreadAttributeArray : CMRThreadLayoutConcreateTask
{
	BSDBThreadList *target;
	NSConditionLock *mLock;
	
	unsigned mProgress;
	NSString *mAmountString;
	NSLock *mAmountStringLock;
	
	id realizeArray;
}

+ (id)fakeArrayWithBSDBThreadList:(BSDBThreadList *)threadList;
- (id)initWithBSDBThreadList:(BSDBThreadList *)threadList;

// block while condition become bsFakeArrayReady.
- (id)objectEnumerator;

- (void)collect;

@end