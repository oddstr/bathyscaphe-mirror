/**
  * $Id: CMRMainMenuManager.h,v 1.4 2005/06/11 10:41:34 tsawada2 Exp $
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
- (NSMenuItem *) BBSMenuItem;
- (NSMenuItem *) threadMenuItem;
- (NSMenuItem *) windowMenuItem;
- (NSMenuItem *) helpMenuItem;
- (NSMenuItem *) scriptsMenuItem;
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
