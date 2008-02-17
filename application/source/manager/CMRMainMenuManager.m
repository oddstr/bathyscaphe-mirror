//
//  CMRMainMenuManager.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRMainMenuManager.h"
#import "CocoMonar_Prefix.h"


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

#define		BROWSER_COLUMNS_TAG		2
#define		HISTORY_INSERT_MARKER	1001
#define		HISTORY_SUB_MARKER		1002
//#define		BROWSER_FILTERING_TAG	3
#define		TEMPLATES_SUB_MARKER	2001

#define		THREAD_CONTEXTUAL_MASK	5000

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

- (int)historyItemInsertionIndex
{
	return ([[[self historyMenuItem] submenu] indexOfItemWithTag:HISTORY_INSERT_MARKER]+1);
}

- (NSMenu *)historyMenu
{
	return [[self historyMenuItem] submenu];
}

- (NSMenu *)boardHistoryMenu
{
	return [[[[self historyMenuItem] submenu] itemWithTag:HISTORY_SUB_MARKER] submenu];
}

- (NSMenu *)fileMenu
{
	return [[self fileMenuItem] submenu];
}

- (NSMenu *)templatesMenu
{
	return [[[[self editMenuItem] submenu] itemWithTag:TEMPLATES_SUB_MARKER] submenu];
}

- (NSMenu *)threadContexualMenuTemplate
{
	NSMenu *menuTemplate = [[NSMenu alloc] initWithTitle:@""];

	NSMenu *menuBase = [[self threadMenuItem] submenu];
	NSEnumerator *iter = [[menuBase itemArray] objectEnumerator];
	NSMenuItem	*eachItem;
	NSMenuItem	*addingItem;

	while (eachItem = [iter nextObject]) {
		if ([eachItem tag] > THREAD_CONTEXTUAL_MASK) {
			addingItem = [eachItem copy];
			[addingItem setKeyEquivalent:@""];
			[menuTemplate addItem:addingItem];
			[addingItem release];
		}
	}
	
	return [menuTemplate autorelease];
}
@end


@implementation CMRMainMenuManager(CMRApp)
- (NSMenuItem *)browserListColumnsMenuItem
{
	return (NSMenuItem*)[[[self browserMenuItem] submenu] itemWithTag:BROWSER_COLUMNS_TAG];
}
/*
- (NSMenuItem *) browserStatusFilteringMenuItem
{
	return (NSMenuItem*)[[[self browserMenuItem] submenu]
				itemWithTag : BROWSER_FILTERING_TAG];
}
*/
- (void)removeOpenRecentsMenuItem
{
	NSMenu *menu = [self fileMenu];
	int openURLMenuItemIndex = [menu indexOfItemWithTarget:[NSApp delegate] andAction:@selector(openURLPanel:)];

    if (openURLMenuItemIndex >= 0 && [[menu itemAtIndex:openURLMenuItemIndex+1] hasSubmenu]) {
		[menu removeItemAtIndex:openURLMenuItemIndex+1];
    }
}

- (void)removeQuickLookMenuItemIfNeeded
{
	// Leopard
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_4) return;

	NSMenu *menu = [[self threadMenuItem] submenu];
	int index = [menu indexOfItemWithTarget:nil andAction:@selector(quickLook:)];

	if (index >= 0) {
		[menu removeItemAtIndex:index];
	}
}

- (void)removeShowLocalRulesMenuItemIfNeeded
{
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3) return;

	NSMenu *menu = [[self BBSMenuItem] submenu];
	int index = [menu indexOfItemWithTarget:nil andAction:@selector(showLocalRules:)];

	if (index >= 0) {
		[menu removeItemAtIndex:index];
	}
}
@end

/*
@implementation CMRMainMenuManager(SynchronizeWithDefaults)
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
@end*/
