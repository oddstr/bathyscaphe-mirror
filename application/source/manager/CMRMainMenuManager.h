/**
  * $Id: CMRMainMenuManager.h,v 1.11 2007/04/15 13:49:38 tsawada2 Exp $
  * BathyScaphe
  *
  *
  * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
  *
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
- (NSMenu *) historyMenu;
- (NSMenu *) boardHistoryMenu; // available in Starlight Breaker.
- (NSMenu *) fileMenu;
@end



@interface CMRMainMenuManager(CMRApp)
- (NSMenuItem *) isOnlineModeMenuItem;
- (NSMenuItem *) browserArrangementMenuItem;
- (NSMenuItem *) browserListColumnsMenuItem;
- (NSMenuItem *) browserStatusFilteringMenuItem; // available in Vita and later.
@end



@interface CMRMainMenuManager(SynchronizeWithDefaults)
- (void) synchronizeBrowserArrangementMenuItemState;
- (void) synchronizeIsOnlineModeMenuItemState;
- (void) synchronizeStatusFilteringMenuItemState; // available in Vita and later.
@end
