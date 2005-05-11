//: AllTests.m
/**
  * $Id: AllTests.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "AllTests.h"
#import <ObjcUnit/TestSuite.h>

#import "NSStringEXTest.h"
#import "NSMutableStringEXTest.h"
#import "NSDictionaryEXTest.h"
#import "NSURLTest.h"
#import "NSDataExTest.h"
#import "TestCFURL.h"
#import "NSString+JapaneseTest.h"

// Base
#import "SGBaseChunkTest.h"
#import "SGBaseFixedAllocatorTest.h"
#import "SGBaseAllocatorTest.h"
#import "TestSGBaseQueue.h"
#import "TestSGBaseUnicode.h"
#import "TestCArrayWrapper.h"
#import "TestBitArray.h"

// Util
#import "TestUTILKit.h"
#import "TestSGUtilLogger.h"
#import "TestEmptyCollection.h"

// Class
#import "TestSGFileRef.h"
#import "TestSGZlibWrapper.h"
#import "TestXMLPull.h"
#import "TestSGStringReader.h"
#import "TestSGBufferedReader.h"

// NSR
#import "TestNSRString.h"




// 
// テスト用のリソースはこのディレクトリに置かれる。
// 
#define TESTS_RESOURCE_DIRNAME    @"Test-Resources"


@implementation AllTests
+ (TestSuite *) UTILKitTestSuite
{
	TestSuite *suite_ = [TestSuite suiteWithName : @"UTILKit TestSuite"];
	
	[suite_ addTestSuite : [TestUTILKit class]];
	
	[suite_ addTestSuite : [TestSGUtilLogger class]];
	[suite_ addTestSuite : [TestEmptyCollection class]];
	return suite_;
}

+ (TestSuite *) ExtentionsTestSuite
{
	TestSuite *suite_ = [TestSuite suiteWithName : @"Extentions TestSuite"];
	
	[suite_ addTestSuite : [NSStringEXTest class]];
	[suite_ addTestSuite : [NSMutableStringEXTest class]];
	[suite_ addTestSuite : [NSDictionaryEXTest class]];
	[suite_ addTestSuite : [NSURLTest class]];
	[suite_ addTestSuite : [NSDataExTest class]];
	[suite_ addTestSuite : [NSString_JapaneseTest class]];
	
	return suite_;
}

+ (TestSuite *) BaseTestSuite
{
	TestSuite *suite_ = [TestSuite suiteWithName : @"Base TestSuite"];
	
	[suite_ addTestSuite : [SGBaseChunkTest class]];
	[suite_ addTestSuite : [SGBaseFixedAllocatorTest class]];
	[suite_ addTestSuite : [SGBaseAllocatorTest class]];
	[suite_ addTestSuite : [TestSGBaseQueue class]];
	[suite_ addTestSuite : [TestSGBaseThreadSafeQueue class]];
	[suite_ addTestSuite : [TestSGBaseUnicode class]];
	[suite_ addTestSuite : [TestCArrayWrapper class]];
	[suite_ addTestSuite : [TestBitArray class]];


	return suite_;
}
+ (TestSuite *) NSRTestSuite
{
	TestSuite *suite_ = [TestSuite suiteWithName : @"NSR TestSuite"];

	// NSR
	[suite_ addTestSuite : [TestNSRString class]];
	
	return suite_;
}

+ (TestSuite *) ClassTestSuite
{
	TestSuite *suite_ = [TestSuite suiteWithName : @"Base TestSuite"];
	
	[suite_ addTestSuite : [TestSGFileRef class]];
	[suite_ addTestSuite : [TestSGZlibWrapper class]];
	[suite_ addTestSuite : [TestXMLPull class]];
	[suite_ addTestSuite : [TestSGStringReader class]];
	[suite_ addTestSuite : [TestSGBufferedReader class]];
	
	return suite_;
}
+ (TestSuite *) suite
{
	TestSuite *suite_ = [TestSuite suiteWithName : @"All Tests"];
	
	[TestCase setDefaultDirectoryName : TESTS_RESOURCE_DIRNAME];
	
	[suite_ addTest : [self UTILKitTestSuite]];
	[suite_ addTest : [self ExtentionsTestSuite]];
	[suite_ addTest : [self BaseTestSuite]];
	[suite_ addTest : [self ClassTestSuite]];
	[suite_ addTest : [self NSRTestSuite]];
	
	return suite_;
}
@end
