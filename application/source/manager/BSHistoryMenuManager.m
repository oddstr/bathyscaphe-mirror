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

- (void) updateHistoryMenuWithMenu : (NSMenu *) menu
{
    NSEnumerator		*iter_;
	NSArray				*historyItemsArray_;
	CMRHistoryItem		*item_;
	int					index = [[CMRMainMenuManager defaultManager] historyItemInsertionIndex];
   
    if (nil == menu) return;
	
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

		//NSLog(@"%@",[[item_ representedObject] description]);

        [menu insertItem : menuItem_ atIndex : index];
        [menuItem_ release];
		
		index += 1;
    }
}

@end
