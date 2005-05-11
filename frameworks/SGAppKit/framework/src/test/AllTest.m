//: AllTests.m
/**
  * $Id: AllTest.m,v 1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "AllTest.h"
#import <ObjcUnit/TestSuite.h>

#import "TestKeyBindingSupport.h"

// 
// テスト用のリソースはこのディレクトリに置かれる。
// 
#define TESTS_RESOURCE_DIRNAME    @"Test-Resources"


@implementation AllTests
+ (TestSuite *) suite
{
	TestSuite *suite_ = [TestSuite suiteWithName : @"All Tests"];
	
	[TestCase setDefaultDirectoryName : TESTS_RESOURCE_DIRNAME];

	[suite_ addTestSuite : [TestKeyBindingSupport class]];

	return suite_;
}
@end
