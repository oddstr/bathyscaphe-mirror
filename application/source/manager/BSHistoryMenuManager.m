//
//  BSHistoryMenuManager.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/07/09.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import "BSHistoryMenuManager.h"

#import "CMRMainMenuManager.h"

#define kHistoryMenuItemTagMaximalNumKey	900

@implementation BSHistoryMenuManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (id) init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(applicationDidReset:)
					    name : CMRApplicationDidResetNotification
					  object : nil];
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[super dealloc];
}

+ (void) setupHistoryMenu
{
	NSMenuItem	*historyMenu_;
	
	historyMenu_ = [[CMRMainMenuManager defaultManager] historyMenuItem];
	[[historyMenu_ submenu] setDelegate : [self defaultManager]];
	
	[[self defaultManager] updateHistoryMenuWithMenu : [historyMenu_ submenu]];
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
		/*
			2005-07-09 tsawada2<ben-sawa@td5.so-net.ne.jp>
			「履歴」メニューの、履歴以外の項目には 1000 番台ないしは 1100 番台のタグが
			振ってある。それ以外のタグなら、履歴項目と判断できる。
		*/
		// 2005-12-12 修正：1000 番台のタグを「掲示板」メニューの項目が利用しているため、validation 上問題がある。
		// このため、900 番台に修正する。
		if ([eachItem_ tag] < kHistoryMenuItemTagMaximalNumKey) {
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
	
	if ([[menu itemArray] count] > 4) [self eraseHistoryMenuItemsOfMenu : menu]; // まず、メニューから履歴項目を削除
	
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
	// 最後に、「履歴の消去」との間に区切り線を追加（ただし、履歴が空だった場合は追加しない）
	if (index > initIndex) [menu insertItem : [NSMenuItem separatorItem] atIndex : index];
}

- (void) updateHistoryMenuWithDefaultMenu
{
	NSMenu	*menu_;
	
	menu_ = [[[CMRMainMenuManager defaultManager] historyMenuItem] submenu];
	[self updateHistoryMenuWithMenu : menu_];
}

- (void) applicationDidReset : (NSNotification *) theNotification
{
	[self updateHistoryMenuWithDefaultMenu];
}
@end
