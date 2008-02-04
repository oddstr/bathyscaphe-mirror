/**
  * $Id: CMRMainMenuManager.h,v 1.17 2008/02/04 06:40:18 tsawada2 Exp $
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
- (NSMenu *) boardHistoryMenu; // Available in Starlight Breaker and later.
- (NSMenu *) fileMenu;
- (NSMenu *)templatesMenu; // Available in BathyScaphe 1.6.1 and later.

- (NSMenu *)threadContexualMenuTemplate; // Available in Twincam Angel.
@end



@interface CMRMainMenuManager(CMRApp)
//- (NSMenuItem *) isOnlineModeMenuItem;
//- (NSMenuItem *) browserArrangementMenuItem;
- (NSMenuItem *) browserListColumnsMenuItem;
//- (NSMenuItem *) browserStatusFilteringMenuItem; // available in Vita and later.

- (void)removeOpenRecentsMenuItem;
- (void)removeQuickLookMenuItemIfNeeded;
@end


/*
@interface CMRMainMenuManager(SynchronizeWithDefaults)
- (void) synchronizeBrowserArrangementMenuItemState;
- (void) synchronizeIsOnlineModeMenuItemState;
- (void) synchronizeStatusFilteringMenuItemState; // available in Vita and later.
@end
*/