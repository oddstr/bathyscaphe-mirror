/**
  * $Id: TestSGStringReader.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * TestSGStringReader.m
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "TestSGStringReader.h"
#import <SGFoundation/SGFoundation.h>
#import "UTILKit.h"


@implementation TestSGStringReader
- (void) testInit
{
	SGStringReader *srd;
	
	srd = [[SGStringReader alloc] initWithString : @"test"];
	[self assertString:[srd string] equals:@"test"];
	[srd release];
}
- (void) testRead
{
	SGStringReader *srd;
	NSString *s = @"test";
	int i;
	
	srd = [[SGStringReader alloc] initWithString : s];
	for (i = 0; i < [s length]; i++) {
		[self assertInt:[srd read] equals:[s characterAtIndex:i]];
	}
	[self assertInt:[srd read] equals:EOF];
	[srd release];
}
- (void) testReadLength
{
	SGStringReader *srd;
	NSString *s = @"test";
	int i, ret;
	unsigned len;
	unichar buf[4];
	
	srd = [[SGStringReader alloc] initWithString : s];
	ret = [srd read:buf length:4 autualLength:&len];
	
	[self assertInt:ret equals:0];
	[self assertInt:len equals:4];
	
	for (i = 0; i < [s length]; i++) {
		[self assertInt:buf[i] equals:[s characterAtIndex:i]];
	}
	[self assertInt:[srd read:buf length:4 autualLength:&len]
		  equals:EOF];
	[self assertInt:len equals:0];
	
	[srd release];
}
@end
