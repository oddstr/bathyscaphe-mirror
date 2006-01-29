/**
  * $Id: CMRMainMenuManager.m,v 1.8.2.1 2006/01/29 12:58:10 masakih Exp $
  * 
  * CMRMainMenuManager.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRMainMenuManager.h"

#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"

#define		APPLICATION_MENU_TAG	0
#define		FILE_MENU_TAG			1
#define		EDIT_MENU_TAG			2
#define		BROWSER_MENU_TAG		3
#define		BBS_MENU_TAG			4
#define		THREAD_MENU_TAG			5
#define		WINDOW_MENU_TAG			6
#define		HELP_MENU_TAG			7
#define		SCRIPTS_MENU_TAG		8
#define		HISTORY_MENU_TAG		9

#define		FILE_ONLINEMODE_TAG		1
#define		BROWSER_ARRANGEMENT_TAG	1
#define		BROWSER_COLUMNS_TAG		2
#define		HISTORY_INSERT_MARKER	1001
#define		BROWSER_FILTERING_TAG	3

@implementation CMRMainMenuManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager)

#define MENU_ACCESSER(aMethodName, aTag)		\
- (NSMenuItem *) aMethodName { return (NSMenuItem*)[[NSApp mainMenu] itemWithTag : (aTag)]; }

MENU_ACCESSER(applicationMenuItem, APPLICATION_MENU_TAG)
MENU_ACCESSER(fileMenuItem, FILE_MENU_TAG)
MENU_ACCESSER(editMenuItem, EDIT_MENU_TAG)
MENU_ACCESSER(browserMenuItem, BROWSER_MENU_TAG)
MENU_ACCESSER(historyMenuItem, HISTORY_MENU_TAG)
MENU_ACCESSER(BBSMenuItem, BBS_MENU_TAG)
MENU_ACCESSER(threadMenuItem, THREAD_MENU_TAG)
MENU_ACCESSER(windowMenuItem, WINDOW_MENU_TAG)
MENU_ACCESSER(helpMenuItem, HELP_MENU_TAG)
MENU_ACCESSER(scriptsMenuItem, SCRIPTS_MENU_TAG)


#undef MENU_ACCESSER

- (int) historyItemInsertionIndex
{
	return ([[[self historyMenuItem] submenu] indexOfItemWithTag : HISTORY_INSERT_MARKER]+1);
}

- (NSMenu *) fileMenu
{
	return [[self fileMenuItem] submenu];
}
@end



@implementation CMRMainMenuManager(CMRApp)
- (NSMenuItem *) isOnlineModeMenuItem
{
	return (NSMenuItem*)[[[self applicationMenuItem] submenu] itemWithTag : FILE_ONLINEMODE_TAG];
}
- (NSMenuItem *) browserArrangementMenuItem
{
	return (NSMenuItem*)[[[self browserMenuItem] submenu] 
				itemWithTag : BROWSER_ARRANGEMENT_TAG];
}
- (NSMenuItem *) browserListColumnsMenuItem
{
	return (NSMenuItem*)[[[self browserMenuItem] submenu] 
				itemWithTag : BROWSER_COLUMNS_TAG];
}
- (NSMenuItem *) browserStatusFilteringMenuItem
{
	return (NSMenuItem*)[[[self browserMenuItem] submenu]
				itemWithTag : BROWSER_FILTERING_TAG];
}
@end



@implementation CMRMainMenuManager(SynchronizeWithDefaults)
- (void) synchronizeBrowserArrangementMenuItemState
{
	NSMenu			*browserArrangementSubmenu_;
	NSEnumerator	*itemIter_;
	NSMenuItem		*item_;
	
	browserArrangementSubmenu_ = [[self browserArrangementMenuItem] submenu];
	UTILAssertNotNil(
		browserArrangementSubmenu_);
	
	itemIter_ = [[browserArrangementSubmenu_ itemArray] objectEnumerator];
	while (item_ = [itemIter_ nextObject]) {
		BOOL		state_;
		NSNumber	*represent_;
		
		represent_ = [item_ representedObject];
		UTILAssertKindOfClass(represent_, NSNumber);
		
		state_ = [CMRPref isSplitViewVertical];
		state_ = (state_ == [represent_ boolValue]);
		[item_ setState : (state_ ? NSOnState : NSOffState)];
	}
}
- (void) synchronizeIsOnlineModeMenuItemState
{
	NSMenuItem	*menuItem_;
	BOOL		isOnlineMode_;
	
	menuItem_ = [self isOnlineModeMenuItem];
	
	UTILAssertNotNil(menuItem_);
	isOnlineMode_ = [CMRPref isOnlineMode];	
	[menuItem_ setState : isOnlineMode_ ? NSOnState : NSOffState];
}
- (void) synchronizeStatusFilteringMenuItemState
{
	NSMenu			*browserFilteringSubmenu_;
	NSEnumerator	*itemIter_;
	NSMenuItem		*item_;
	NSNumber		*currentStatus;
	
	browserFilteringSubmenu_ = [[self browserStatusFilteringMenuItem] submenu];
	UTILAssertNotNil(browserFilteringSubmenu_);
	
	currentStatus = [NSNumber numberWithUnsignedInt : [CMRPref browserStatusFilteringMask]];

	itemIter_ = [[browserFilteringSubmenu_ itemArray] objectEnumerator];

	while (item_ = [itemIter_ nextObject]) {
		NSNumber	*represent_;
		
		represent_ = [item_ representedObject];
		UTILAssertKindOfClass(represent_, NSNumber);
		
		if ([represent_ isEqualToNumber: currentStatus]) {
			[item_ setState : NSOnState];
		} else {
			[item_ setState : NSOffState];
		}
	}
}
@end
