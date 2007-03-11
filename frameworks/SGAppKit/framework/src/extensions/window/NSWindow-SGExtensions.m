//
//  NSWindow-SGExtensions.m
//  BathyScaphe
//
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//

#import "NSWindow-SGExtensions.h"

@implementation NSWindow(BSAddition)
- (BOOL) isNotMiniaturizedButCanMinimize
{
	// 最小化されていない、かつ、最小化可能であるウインドウである場合に YES を返す。
	// 最小化不可能なウインドウでは常に NO を返す。
	if (NO == ([self styleMask] & NSMiniaturizableWindowMask)) return NO;
	return (NO == [self isMiniaturized]);
}
@end
