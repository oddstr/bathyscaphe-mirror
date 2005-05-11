//: SGQueue.m
/**
  * $Id: SGBaseQueue.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBaseQueue.h"


@implementation SGBaseQueue
+ (id) queue
{
	return [[[self alloc] init] autorelease];
}
- (id) init
{
	if(self = [super init]){
		_mutableArray = [[NSMutableArray alloc] init];
	}
	return self;
}
- (void) dealloc
{
	[_mutableArray release];
	_mutableArray = nil;
	[super dealloc];
}
// SGBaseQueue
- (void) put : (id) item
{
	if(nil == item)
		[NSException raise : NSInvalidArgumentException
					format : @"*** -[%@ %@]: attempt to put nil",
							NSStringFromClass([self class]),
							NSStringFromSelector(_cmd)];
	
	[_mutableArray addObject : item];
}
- (id) take
{
	id		item_;
	
	if(0 == [_mutableArray count])
		return nil;
	
	item_ = [[_mutableArray objectAtIndex : 0] retain];
	[_mutableArray removeObjectAtIndex : 0];
	
	return [item_ autorelease];
}
- (BOOL) isEmpty
{
	return (0 == [_mutableArray count]);
}
@end



@implementation SGBaseThreadSafeQueue
{
	NSLock			*_lock;
}
- (id) init
{
	if(self = [super init]){
		_lock = [[NSLock alloc] init];
	}
	return self;
}
- (void) dealloc
{
	[_lock release];
	_lock = nil;
	[super dealloc];
}
// SGBaseQueue
- (void) put : (id) item
{	
	[_lock lock];
	[super put : item];
	[_lock unlock];
}
- (id) take
{
	id		item_;
	
	[_lock lock];
	item_ = [super take];
	[_lock unlock];
	return item_;
}
@end
