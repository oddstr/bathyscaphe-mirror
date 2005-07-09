/**
 * $Id: CMRAppDelegate_p.h,v 1.5 2005/07/09 01:03:03 tsawada2 Exp $
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
#import "BSScriptsMenuManager.h"
#import "CMROpenURLManager.h"
#import "BSHistoryMenuManager.h"


// CMRLocalizableStringsOwner
#define APP_MAINMENU_LOCALIZABLE_FILE_NAME	@"CMRMainMenu"
#define APP_MAINMENU_SPVIEW_HORIZONTAL		@"NSSplitView Horizontal"
#define APP_MAINMENU_SPVIEW_VERTICAL		@"NSSplitView Vertical"
#define APP_MAINMENU_HELPER_NOTFOUND		@"Helper App Not Found"


//:CMRAppDelegate+Menu.m
@interface CMRAppDelegate(MenuSetup)
- (void) setupMenu;
@end