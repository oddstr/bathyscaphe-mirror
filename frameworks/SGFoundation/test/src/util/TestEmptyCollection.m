/**
  * $Id: TestEmptyCollection.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * TestEmptyCollection.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "TestEmptyCollection.h"


@implementation TestEmptyCollection
- (void) setUp
{
	;
}
- (void) tearDown
{
	;
}

- (void) test_identity_array
{
	[self assert : [NSArray empty]
		  equals : [NSArray empty]
		 message : @"[NSArray empty] == [NSArray empty]"];
	[self assert : [NSArray empty]
		  equals : [NSArray array]
		 message : @"[NSArray empty] == [NSArray array]"];
	[self assertTrue : 
		[[NSArray empty] isEqualToArray : [NSArray empty]]
		 message : @"isEqualToArray 1"];
	[self assertTrue : 
		[[NSArray empty] isEqualToArray : [NSArray array]]
		 message : @"isEqualToArray 1"];
}
- (void) test_identity_dictionary
{
	[self assert : [NSDictionary empty]
		  equals : [NSDictionary empty]
		 message : @"[NSDictionary empty] == [NSDictionary empty]"];
	[self assert : [NSDictionary empty]
		  equals : [NSDictionary dictionary]
		 message : @"[NSDictionary empty] == [NSDictionary dictionary]"];
	[self assertTrue : 
		[[NSDictionary empty] isEqualToDictionary : [NSDictionary empty]]
		 message : @"isEqualToDictionary 1"];
	[self assertTrue : 
		[[NSDictionary empty] isEqualToDictionary : [NSDictionary dictionary]]
		 message : @"isEqualToDictionary 1"];
}
- (void) test_count
{
	[self assertInt : [[NSArray empty] count]
			 equals : 0
			message : @"[SGEmptyArray count]"];
	[self assertInt : [[NSDictionary empty] count]
			 equals : 0
			message : @"[SGEmptyDictionary count]"];
}
@end
