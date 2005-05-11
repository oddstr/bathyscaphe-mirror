//: NSCoder-SGExtensions.m
/**
  * $Id: NSCoder-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "NSCoder-SGExtensions.h"



@implementation NSCoder(SGFoundationExtensions)
- (BOOL) supportsKeyedCoding
{
	return ([self respondsToSelector : @selector(allowsKeyedCoding)] && [self allowsKeyedCoding]);
}
@end
