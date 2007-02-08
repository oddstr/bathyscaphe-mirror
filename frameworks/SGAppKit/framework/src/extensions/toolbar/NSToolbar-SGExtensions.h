//: NSToolbar-SGExtensions.h
/**
  * $Id: NSToolbar-SGExtensions.h,v 1.3 2007/02/08 00:20:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSToolbarItem.h>

@interface NSToolbarItem(SGExtensions)
- (NSString *) title;
- (void) setTitle : (NSString *) aTitle;
@end
