//: NSWindow-SGExtensions.h
/**
  * $Id: NSWindow-SGExtensions.h,v 1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>


@interface NSWindow(SGExtensions)
- (NSSize) minContentSize;

- (void) setFrame : (NSRect) frameRect
          display : (BOOL  ) displayFlag
          animate : (BOOL  ) animationFlag
      autoresizes : (BOOL  ) isAutoresize;
@end

