/**
  * $Id: CMRSplitView.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
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
@end