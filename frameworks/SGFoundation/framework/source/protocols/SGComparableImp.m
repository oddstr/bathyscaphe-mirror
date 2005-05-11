//: SGComparableImp.m
/**
  * $Id: SGComparableImp.m,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/SGComparable.h>


#define FRWK_COMPARABLE_IMP(Class_Name, Category_Name)		\
	@implementation Class_Name(Category_Name)\
	- (NSComparisonResult) compareTo : (id) other\
	{\
		return [self compare : (Class_Name*)other];\
	}\
	@end

FRWK_COMPARABLE_IMP(NSDate, SGComparable)
FRWK_COMPARABLE_IMP(NSString, SGComparable)
FRWK_COMPARABLE_IMP(NSNumber, SGComparable)
FRWK_COMPARABLE_IMP(NSCell, SGComparable)


#undef FRWK_COMPARABLE_IMP