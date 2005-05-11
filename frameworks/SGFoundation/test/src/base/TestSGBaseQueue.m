//: TestSGBaseQueue.m
/**
  * $Id: TestSGBaseQueue.m,v 1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestSGBaseQueue.h"


@implementation TestSGBaseThreadSafeQueue
- (void) setUp
{
	_queue = [[SGBaseThreadSafeQueue alloc] init];
}
@end
@implementation TestSGBaseQueue
- (void) setUp
{
	_queue = [[SGBaseQueue alloc] init];
}
- (void) tearDown
{
	[_queue release];
}
- (void) testPutNil
{
	NSException		*exception_ = nil;
	
	NS_DURING
		
		[_queue put : nil];
		
	NS_HANDLER
		exception_ = localException;
		[self assertString : [localException name]
				    equals : NSInvalidArgumentException
					  name : @"Put nil"];
		
	NS_ENDHANDLER
	
	[self assertNotNil : exception_];
	
}
- (void) testPutAndTake
{
	id		item_;
	
	item_ = [[NSObject alloc] init];
	[_queue put : item_];
	
	[self assert : [_queue take]
		  equals : item_
		  name : @"Item"];
	[self assertNil : [_queue take]];
}
@end
