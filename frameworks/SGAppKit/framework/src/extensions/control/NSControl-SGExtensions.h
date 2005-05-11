//: NSControl-SGExtensions.h
/**
  * $Id: NSControl-SGExtensions.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSControl.h>



@interface NSControl(SGExtensions)
- (BOOL) sendsAction;

// for fix NSToolbar sizeMode
- (NSControlSize) controlSize;
- (void) setControlSize : (NSControlSize) controlSize;
@end
