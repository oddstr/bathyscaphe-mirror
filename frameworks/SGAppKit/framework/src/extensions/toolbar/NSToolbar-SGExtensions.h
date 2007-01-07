//: NSToolbar-SGExtensions.h
/**
  * $Id: NSToolbar-SGExtensions.h,v 1.2 2007/01/07 17:04:24 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
//#import <AppKit/NSToolbar.h>
#import <AppKit/NSToolbarItem.h>


/*
@interface NSToolbar(UnsupportedAccessor)
- (BOOL) allowsUserCustomizationByDragging;
- (void) setAllowsUserCustomizationByDragging : (BOOL) flag;

- (BOOL) showsContextMenu;
- (void) setShowsContextMenu : (BOOL) flag;

- (unsigned int) firstMoveableItemIndex;
- (void) setFirstMoveableItemIndex : (unsigned int) anIndex;
@end



@interface NSToolbar(SGExtensions1109)
+ (NSSize) iconSizeWithSizeMode : (NSToolbarSizeMode) mode;
@end
*/


@interface NSToolbarItem(SGExtensions)
- (NSString *) title;
- (void) setTitle : (NSString *) aTitle;
@end
