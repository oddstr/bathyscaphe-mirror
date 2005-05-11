/**
  * $Id: TestUTILKit.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * TestUTILKit.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestUTILKit.h"
#import "UTILKit.h"



#define NUMBER_OF_ELEMENTS		5



@implementation TestUTILKit
- (void) setUp 
{
	//...
}

- (void) tearDown
{
	//...
}

//////////////////////////////////////////////////////////////////////
//////////////////////// [ テストコード ] ////////////////////////////
//////////////////////////////////////////////////////////////////////
- (void) test_UTILComparisonResultString
{
	[self assertString : UTILComparisonResultString(NSOrderedAscending)
			equals : @"NSOrderedAscending"
			message : @"NSOrderedAscending"];
	[self assertString : UTILComparisonResultString(NSOrderedDescending)
			equals : @"NSOrderedDescending"
			message : @"NSOrderedDescending"];
	[self assertString : UTILComparisonResultString(NSOrderedSame)
			equals : @"NSOrderedSame"
			message : @"NSOrderedSame"];
	[self assertString : UTILComparisonResultString(500)
			equals : @"None"
			message : @"None"];
}

- (void) test_UTILNumberOfCArray
{
	int		array[NUMBER_OF_ELEMENTS];
	
	[self assertInt : UTILNumberOfCArray(array)
			 equals : NUMBER_OF_ELEMENTS
			   name : @"UTILNumberOfCArray"];
}

- (void) test_UTILComparisionResultPrimitives
{
	[self assertTrue : (NSOrderedSame == UTILComparisionResultPrimitives(1,1))
				name : @"UTILComparisionResultPrimitives - Same"];
	[self assertTrue : 
		(NSOrderedAscending == UTILComparisionResultPrimitives(1, 5))
				name : @"UTILComparisionResultPrimitives - Ascending"];
	[self assertTrue : 
		(NSOrderedDescending == UTILComparisionResultPrimitives(10, 5))
				name : @"UTILComparisionResultPrimitives - Descending"];
}

- (void) test_UTILComparisionResultReversed
{
	[self assertTrue : 
		(NSOrderedSame == UTILComparisionResultReversed(NSOrderedSame))
				name : @"UTILComparisionResultReversed - NSOrderedSame"];
	[self assertTrue : 
		(NSOrderedAscending == UTILComparisionResultReversed(NSOrderedDescending))
				name : @"UTILComparisionResultReversed - NSOrderedDescending"];
	[self assertTrue : 
		(NSOrderedDescending == UTILComparisionResultReversed(NSOrderedAscending))
				name : @"UTILComparisionResultReversed - NSOrderedAscending"];
}

@end
