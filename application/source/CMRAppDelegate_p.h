/**
 * $Id: CMRAppDelegate_p.h,v 1.13 2007/12/15 16:20:53 tsawada2 Exp $
 * 
 * CMRAppDelegate_p.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "CMRAppDelegate.h"

#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
//#import "TextFinder.h"
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
