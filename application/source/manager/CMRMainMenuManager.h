/**
  * $Id: CMRMainMenuManager.h,v 1.7 2005/07/08 19:37:31 tsawada2 Exp $
  * 
  * CMRMainMenuManager.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


@interface CMRMainMenuManager : NSObject
+ (id) defaultManager;

- (NSMenuItem *) applicationMenuItem;
- (NSMenuItem *) fileMenuItem;
- (NSMenuItem *) editMenuItem;
- (NSMenuItem *) browserMenuItem;
- (NSMenuItem *) historyMenuItem;
- (NSMenuItem *) BBSMenuItem;
- (NSMenuItem *) threadMenuItem;
- (NSMenuItem *) windowMenuItem;
- (NSMenuItem *) helpMenuItem;
- (NSMenuItem *) scriptsMenuItem;

- (int) historyItemInsertionIndex;
@end



@interface CMRMainMenuManager(CMRApp)
- (NSMenuItem *) isOnlineModeMenuItem;
- (NSMenuItem *) browserArrangementMenuItem;
- (NSMenuItem *) browserListColumnsMenuItem;
@end



@interface CMRMainMenuManager(SynchronizeWithDefaults)
- (void) synchronizeBrowserArrangementMenuItemState;
- (void) synchronizeIsOnlineModeMenuItemState;
@end
