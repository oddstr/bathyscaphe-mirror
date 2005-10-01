/**
  * $Id: CMRSplitView.h,v 1.2 2005/10/01 15:08:57 tsawada2 Exp $
  * 
  * CMRSplitView.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "KFSplitView.h"

@interface CMRSplitView : KFSplitView
- (void) kfSetupResizeCursors;
@end
