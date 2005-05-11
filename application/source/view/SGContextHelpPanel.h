/**
  * $Id: SGContextHelpPanel.h,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * SGContextHelpPanel.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>


@interface NSWindow(PopUpWindow)
- (BOOL) isPopUpWindow;
@end



@interface SGContextHelpPanel : NSPanel

@end
