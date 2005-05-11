//: SGSplitView.h
/**
  * $Id: SGSplitView.h,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSSplitView.h>


@interface SGSplitView : NSSplitView
- (void) doubleClickInDivider : (NSEvent *) theEvent;
- (void) mouseDownInDivider : (NSEvent *) theEvent;
@end



@interface NSObject(SGSplitViewDelegate)
- (void)     splitView : (NSSplitView *) splitView
  doubleClickInDivider : (NSEvent     *) theEvent;
@end