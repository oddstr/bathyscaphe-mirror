//: NSMenu-SGExtensions.h
/**
  * $Id: NSMenu-SGExtensions.h,v 1.2 2005/10/28 15:21:43 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSMenuItem.h>

@interface NSMenu(SGExtensions)
- (void) removeAllItems;
- (NSMenuItem *) addItemWithTitle : (NSString *) title;
- (void) addItemsWithTitles : (NSArray *) itemTitles;

//From NSMenu+CMXAdditions.h
//Available in BathyScaphe 1.1 and later, but currently not used.
+ (void) popUpContextMenu : (NSMenu *) aMenu
			      forView : (NSView *) aView
				       at : (NSPoint ) location;
@end
