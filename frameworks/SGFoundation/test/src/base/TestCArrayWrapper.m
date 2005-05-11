/**
  * $Id: TestCArrayWrapper.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * TestCArrayWrapper.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestCArrayWrapper.h"



@implementation TestCArrayWrapper
- (void) setUp
{
	m_array = [[SGBaseCArrayWrapper alloc] init];;
}
- (void) tearDown
{
	[m_array release];
}



- (void) test_init
{
	[self assertNotNil : m_array
			   message : @"init"];
	[self assertTrue : (0 == [m_array count])
			 message : @"count"];
}
- (void) test_append
{
	NSMutableArray	*array_ = [SGBaseCArrayWrapper array];
	
	[self assertNotNil : array_ message:@"init"];
	
	[array_ addObject : @"addObject"];
	[self assert : [array_ objectAtIndex:0]
		  equals : @"addObject"
		 message : @"addObject"];
	
	[array_ insertObject:@"insertObject" atIndex:0];
	[self assert:[array_ objectAtIndex:0]
			equals : @"insertObject"
			message: @"insertObject1"];
	[self assert : [array_ objectAtIndex:1]
		  equals : @"addObject"
		 message : @"insertObject2"];
}

// ‘å—Ê‚Ì—v‘f
#define BULK_COUNT	1000
- (void) test_bulk
{
	int		i;
	
	for (i = 0; i < BULK_COUNT; i++) {
		[m_array addObject : self];
	}
	[self assertInt : [m_array count]
			 equals : BULK_COUNT
			message : @"addObject"];
			 
	for (i = 0; i < BULK_COUNT; i++) {
		[m_array insertObject:self atIndex:i];
	}
	[self assertInt : [m_array count]
			 equals : BULK_COUNT + BULK_COUNT
			message : @"insertObject"];
	
	for (i = 0; i < BULK_COUNT; i++) {
		[m_array removeObjectAtIndex : i];
	}
	[self assertInt : [m_array count]
			 equals : BULK_COUNT
			message : @"removeObjectAtIndex: ordered"];
	
	for (i = [m_array count] -1; i >= 0; i--) {
		[m_array removeObjectAtIndex : i];
	}
	[self assertInt : [m_array count]
			 equals : 0
			message : @"removeObjectAtIndex: reverse"];
}

- (void) test_lastObject
{
	[self assertNil : [m_array lastObject]];
	
	[m_array addObject : @"LAST"];
	[self assert : [m_array lastObject]
		  equals : @"LAST"];
	
	[m_array removeLastObject];
	[self assertInt : [m_array count]
			 equals : 0
			message : @"removeObjectAtIndex: reverse"];
	[m_array removeLastObject];
	[self assertInt : [m_array count]
			 equals : 0
			message : @"removeObjectAtIndex: reverse"];
}

- (void) test_initWithArray
{
	NSMutableArray	*array_;
	NSArray			*from_;
	
	from_ = [NSArray arrayWithObjects:@"1", @"2", nil];
	array_ = [SGBaseCArrayWrapper arrayWithArray:from_];
	
	[self assertNotNil : array_
	           message : @"arrayWithArray"];
	[self assertTrue : ([array_ isEqualToArray : from_])
	         message : @"isEqualToArray"];
}
@end
