//: NSControl-SGExtensions.m
/**
  * $Id: NSControl-SGExtensions.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSControl-SGExtensions.h"
#import "SGAppKitFrameworkDefines.h"



@implementation NSControl(SGExtensions)
- (BOOL) sendsAction
{
	if(NULL == [self action])
		return NO;
	
	return [self sendAction:[self action] to:[self target]];
}
- (NSControlSize) controlSize
{
	return [[self cell] controlSize];
}
- (void) setControlSize : (NSControlSize) controlSize
{
	[[self cell] setControlSize : controlSize];
}
@end
