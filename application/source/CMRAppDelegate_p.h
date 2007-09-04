/**
 * $Id: CMRAppDelegate_p.h,v 1.12 2007/09/04 07:45:43 tsawada2 Exp $
 * 
 * CMRAppDelegate_p.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "CMRAppDelegate.h"

#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import "TextFinder.h"
#import "CMRTaskManager.h"
#import "CMRMainMenuManager.h"
#import "CMROpenURLManager.h"
#import "CMRHistoryManager.h"

// CMRLocalizableStringsOwner
#define APP_MAINMENU_LOCALIZABLE_FILE_NAME	@"Localizable"
#define APP_MAINMENU_SPVIEW_HORIZONTAL		@"NSSplitView Horizontal"
#define APP_MAINMENU_SPVIEW_VERTICAL		@"NSSplitView Vertical"
#define APP_MAINMENU_HELPER_NOTFOUND		@"Helper App Not Found"


//:CMRAppDelegate+Menu.m
@interface CMRAppDelegate(MenuSetup)
- (NSMenu *)browserListColumnsMenuTemplate;
- (void) setupMenu;
@end

// For AppleScript
@interface NSApplication(ScriptingSupport)
/* Property Support (Key-Value coding) */
- (BOOL) isOnlineMode;
- (void) setIsOnlineMode : (BOOL) flag;

/* Who needs these stupid properties... Huh! */
- (NSArray *) browserTableViewColor;
- (void) setBrowserTableViewColor : (NSArray *) colorValue;

- (NSArray *) boardListColor;
- (void) setBoardListColor : (NSArray *) colorValue;

/* Command Support */
- (void) handleOpenURLCommand : (NSScriptCommand *) command;
@end
