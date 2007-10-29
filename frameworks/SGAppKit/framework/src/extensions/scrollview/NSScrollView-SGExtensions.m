//: NSScrollView-SGExtensions.m
/**
  * $Id: NSScrollView-SGExtensions.m,v 1.2 2007/10/29 05:54:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSScrollView-SGExtensions.h"


@implementation NSScrollView(SGExtensions)
- (NSSize) contentSizeForFrameSize : (NSSize) aFrame
{
	return [[self class] 
			contentSizeForFrameSize : aFrame
			  hasHorizontalScroller : [self hasHorizontalScroller]
				hasVerticalScroller : [self hasVerticalScroller]
						 borderType : [self borderType]];
}
- (NSSize) frameSizeForContentSize : (NSSize) contentSize
{
	return [[self class] frameSizeForContentSize : contentSize
		hasHorizontalScroller : [self hasHorizontalScroller]
		hasVerticalScroller : [self hasVerticalScroller]
		borderType : [self borderType]];
}
@end
