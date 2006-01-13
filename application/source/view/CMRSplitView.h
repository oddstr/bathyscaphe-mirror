/**
  * $Id: CMRSplitView.h,v 1.3 2006/01/13 23:47:59 tsawada2 Exp $
  * 
  * CMRSplitView.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "KFSplitView.h"

@interface CMRSplitView : KFSplitView
{
	@private
	NSImage	*_splitterBg;
	NSImage *_splitterDimple;
	NSImage *_splitterBgVertical;
	NSImage *_splitterDimpleVertical;
}

- (void) kfSetupResizeCursors;
@end
