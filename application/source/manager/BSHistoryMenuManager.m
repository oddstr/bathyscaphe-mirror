//
//  BSHistoryMenuManager.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/07/09.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import "BSHistoryMenuManager.h"

#import "CMRMainMenuManager.h"

@implementation BSHistoryMenuManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

+ (void) setupHistoryMenu
{
	NSMenuItem	*historyMenu_;
	
	historyMenu_ = [[CMRMainMenuManager defaultManager] historyMenuItem];
	[[historyMenu_ submenu] setDelegate : [self defaultManager]];
	
	[[self defaultManager] buildHistoryMenuWithMenu : [historyMenu_ submenu]];
}

- (void) buildHistoryMenuWithMenu : (NSMenu *) menu
{
	[self updateHistoryMenuWithMenu : menu];
}

- (void) eraseHistoryMenuItemsOfMenu : (NSMenu *) menu
{
	NSArray	*items_;
	NSEnumerator	*iter_;
	id		eachItem_;

	if (nil == menu) return;

	items_ = [menu itemArray];
	if (items_ == nil || [items_ count] == 0) return;
	
	iter_ = [items_ objectEnumerator];
	while (eachItem_ = [iter_ nextObject]) {
		if ([eachItem_ tag] < 1000) {
			[menu removeItem : eachItem_];
		}
	}
}

- (void) updateHistoryMenuWithMenu : (NSMenu *) menu
{
    NSEnumerator		*iter_;
	NSArray				*historyItemsArray_;
	CMRHistoryItem		*item_;
	int					initIndex = [[CMRMainMenuManager defaultManager] historyItemInsertionIndex];
	int					index = initIndex;
   
    if (nil == menu) return;
	
	if ([[menu itemArray] count] > 4) [self eraseHistoryMenuItemsOfMenu : menu];
	
	historyItemsArray_ = [[CMRHistoryManager defaultManager] historyItemArrayForType : CMRHistoryThreadEntryType];
	if (nil == historyItemsArray_) return;
    
    iter_ = [historyItemsArray_ objectEnumerator];
    while (item_ = [iter_ nextObject]) {
        NSString		*title_;
        NSMenuItem		*menuItem_;
        
        if (NO == [item_ isKindOfClass : [CMRHistoryItem class]]) continue;
        
        title_ = [item_ title];
        if (nil == title_) continue;
        
        menuItem_ = [[NSMenuItem alloc]
                        initWithTitle : title_
                               action : @selector(showThreadWithMenuItem:)
                        keyEquivalent : @""];
                            
		[menuItem_ setTarget : nil];
		[menuItem_ setRepresentedObject : [item_ representedObject]];

        [menu insertItem : menuItem_ atIndex : index];
        [menuItem_ release];
		
		index += 1;
    }
	// 最後に区切り線を追加
	if (index > initIndex) [menu insertItem : [NSMenuItem separatorItem] atIndex : index];
}

- (void) updateHistoryMenuWithDefaultMenu
{
	NSMenu	*menu_;
	
	menu_ = [[[CMRMainMenuManager defaultManager] historyMenuItem] submenu];
	[self updateHistoryMenuWithMenu : menu_];
}
@end
