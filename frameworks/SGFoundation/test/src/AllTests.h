//: AllTests.h
/**
  * $Id: AllTests.h,v 1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>

@class TestSuite;


@interface AllTests : NSObject
+ (TestSuite *) suite;
@end
