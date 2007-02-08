//: NSToolbar-SGExtensions.m
/**
  * $Id: NSToolbar-SGExtensions.m,v 1.3 2007/02/08 00:20:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSToolbar-SGExtensions.h"

@implementation NSToolbarItem(SGExtensions)
- (NSString *) title
{
	return [self label];
}
- (void) setTitle : (NSString *) aTitle
{
	[self setLabel : aTitle];
}
@end

