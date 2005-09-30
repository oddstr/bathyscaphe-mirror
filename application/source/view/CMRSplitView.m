/**
  * $Id: CMRSplitView.m,v 1.2 2005/09/30 10:52:06 tsawada2 Exp $
  * 
  * CMRSplitView.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRSplitView.h"

@implementation CMRSplitView
- (void)kfSetupResizeCursors
{
    if (kfIsVerticalResizeCursor == nil)
    {
        kfIsVerticalResizeCursor = [[NSCursor resizeLeftRightCursor] retain];
    }
    if (kfNotIsVerticalResizeCursor == nil)
    {
        kfNotIsVerticalResizeCursor = [[NSCursor resizeUpDownCursor] retain];
    }
}

- (void) drawDividerInRect:(NSRect)aRect
{
	if (![self isVertical]) {
		// 左のボーダーが欠けるので改めて描く
		[[NSColor gridColor] set];
		NSRectFill(NSMakeRect(NSMinX(aRect), NSMinY(aRect), 1.0, NSHeight(aRect)));
	}
	[super drawDividerInRect : aRect];
}
@end