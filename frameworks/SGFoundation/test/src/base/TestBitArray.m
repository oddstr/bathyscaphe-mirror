//: TestBitArray.m
/**
  * $Id: TestBitArray.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestBitArray.h"


@implementation TestBitArray
- (void) setUp
{
	_bitArray = SGBaseBitArrayAlloc();
}
- (void) tearDown
{
	SGBaseBitArrayDealloc(_bitArray);
}
- (void) test_set
{
	SGBaseBitArraySetAtIndex(_bitArray, 0);
	[self assertTrue : SGBaseBitArrayGetAtIndex(_bitArray, 0)];
}
- (void) test_length
{
	unsigned	len_;
	
	len_ = SGBaseBitArrayGetLength(_bitArray);
	SGBaseBitArraySetAtIndex(_bitArray, len_-1);
	[self assertTrue : SGBaseBitArrayGetAtIndex(_bitArray, len_ -1)];
}
- (void) test_setLength
{
	SGBaseBitArraySetLength(_bitArray, 100);
	[self assertFalse : SGBaseBitArrayGetAtIndex(_bitArray, 63)];
	SGBaseBitArraySetAtIndex(_bitArray, 63);
	[self assertTrue : SGBaseBitArrayGetAtIndex(_bitArray, 63)];
	
	SGBaseBitArraySetLength(_bitArray, 64);
	[self assertTrue : SGBaseBitArrayGetAtIndex(_bitArray, 63)];
	
	SGBaseBitArrayClearAtIndex(_bitArray, 63);
	[self assertFalse : SGBaseBitArrayGetAtIndex(_bitArray, 63)
				message : @"SGBaseBitArrayClearAtIndex"];
}
- (void) test_reserve
{
	unsigned	length_;
	
	length_ = SGBaseBitArrayGetLength(_bitArray);
	SGBaseBitArrayReserve(_bitArray, length_/2);
	
	[self assertInt : length_
			 equals : SGBaseBitArrayGetLength(_bitArray)
			message : @"Reserve less"];
	
	SGBaseBitArrayReserve(_bitArray, length_*2);
	
	[self assertTrue : SGBaseBitArrayGetLength(_bitArray) > length_
			 message : @"Reserve more"];
}
@end
