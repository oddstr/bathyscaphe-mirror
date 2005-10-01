/**
  * $Id: CMRSplitView.m,v 1.3 2005/10/01 15:08:57 tsawada2 Exp $
  * 
  * CMRSplitView.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRSplitView.h"

@implementation CMRSplitView
- (void) kfSetupResizeCursors
{
	// Mac OS X 10.3 以降なので、より適切なカーソルを使用することができる。
    if (kfIsVerticalResizeCursor == nil)
    {
        kfIsVerticalResizeCursor = [[NSCursor resizeLeftRightCursor] retain];
    }
    if (kfNotIsVerticalResizeCursor == nil)
    {
        kfNotIsVerticalResizeCursor = [[NSCursor resizeUpDownCursor] retain];
    }
}

- (void) drawDividerInRect : (NSRect) aRect
{
	if (![self isVertical]) {
		// 左のボーダーが欠けるので改めて描く
		[[NSColor gridColor] set];
		NSRectFill(NSMakeRect(NSMinX(aRect), NSMinY(aRect), 1.0, NSHeight(aRect)));
	}
	[super drawDividerInRect : aRect];
}
@end