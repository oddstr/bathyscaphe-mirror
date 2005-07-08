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
        
        /*if (0 == [title_ length]) {
            [menu addItem : [NSMenuItem separatorItem]];
            continue;
        }*/
        
        menuItem_ = [[NSMenuItem alloc]
                        initWithTitle : title_
                               action : NULL
                        keyEquivalent : @""];

		/*NSString        *URLString_;
		NSURL            *URLToOpen_;
		
		URLString_ = [item_ objectForKey : kCMRAppDelegateURLKey];
		if (nil == URLString_) {
			[menuItem_ release];
			continue;
		}
		URLToOpen_ = [NSURL URLWithString : URLString_];
                            
		[menuItem_ setTarget : self];
		[menuItem_ setAction : @selector(openURL:)];
		[menuItem_ setRepresentedObject : URLToOpen_];*/

        [menu insertItem : menuItem_ atIndex : index];
        [menuItem_ release];
		
		index += 1;
    }
}
@end
