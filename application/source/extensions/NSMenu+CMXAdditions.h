//: NSMenu+CMXAdditions.h
/**
  * $Id: NSMenu+CMXAdditions.h,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


@interface NSMenu(CMXAdditions)
+ (void) popUpContextMenu : (NSMenu *) aMenu
			      forView : (NSView *) aView
				       at : (NSPoint ) location;
@end
