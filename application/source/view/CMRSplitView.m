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
	// Mac OS X 10.3 �ȍ~�Ȃ̂ŁA���K�؂ȃJ�[�\�����g�p���邱�Ƃ��ł���B
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
		// ���̃{�[�_�[��������̂ŉ��߂ĕ`��
		[[NSColor gridColor] set];
		NSRectFill(NSMakeRect(NSMinX(aRect), NSMinY(aRect), 1.0, NSHeight(aRect)));
	}
	[super drawDividerInRect : aRect];
}
@end