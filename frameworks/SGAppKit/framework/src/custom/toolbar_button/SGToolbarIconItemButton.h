//: CMRTrashItemButton.h
/**
  * $Id: SGToolbarIconItemButton.h,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <AppKit/NSButton.h>
#import <AppKit/NSToolbarItem.h>
#import <AppKit/NSToolbar.h>


@interface SGToolbarIconItemButton : NSButton
{

}
@end



@interface SGToolbarIconItemButton(SGExtension)
- (void) attachToolbarItem : (NSToolbarItem *) anItem;
@end