//
//  CMRMainMenuManager.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface CMRMainMenuManager : NSObject {
}

+ (id)defaultManager;

- (NSMenuItem *)applicationMenuItem;
- (NSMenuItem *)fileMenuItem;
- (NSMenuItem *)editMenuItem;
- (NSMenuItem *)browserMenuItem;
- (NSMenuItem *)historyMenuItem;
- (NSMenuItem *)BBSMenuItem;
- (NSMenuItem *)threadMenuItem;
- (NSMenuItem *)windowMenuItem;
- (NSMenuItem *)helpMenuItem;
- (NSMenuItem *)scriptsMenuItem;

- (int)historyItemInsertionIndex;
- (NSMenu *)historyMenu;
- (NSMenu *)boardHistoryMenu; // Available in Starlight Breaker and later.
- (NSMenu *)fileMenu;
- (NSMenu *)templatesMenu; // Available in SilverGull and later.

- (NSMenu *)threadContexualMenuTemplate; // Available in Twincam Angel and later.
@end


@interface CMRMainMenuManager(CMRApp)
- (NSMenuItem *) browserListColumnsMenuItem;
//- (NSMenuItem *) browserStatusFilteringMenuItem;

- (void)removeOpenRecentsMenuItem;
- (void)removeQuickLookMenuItemIfNeeded;
- (void)removeShowLocalRulesMenuItemIfNeeded;
@end

/*
@interface CMRMainMenuManager(SynchronizeWithDefaults)
- (void) synchronizeStatusFilteringMenuItemState;
@end*/
