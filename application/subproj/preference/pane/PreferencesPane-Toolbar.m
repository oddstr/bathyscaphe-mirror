//
//  PreferencesPane-Toolbar.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/15.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "PreferencesPane.h"
#import "PreferencesController.h"

static NSString *const PPToolbarIdentifier = @"PreferencesPane Toolbar";

@implementation PreferencesPane(ToolbarSupport)
- (NSMutableDictionary *)toolbarItems
{
	if (!_toolbarItems) {
		_toolbarItems = [[NSMutableDictionary alloc] init];
	}
	return _toolbarItems;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
	 itemForItemIdentifier:(NSString  *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem	*item_;
	NSToolbarItem	*newItem_;
	
	item_ = [[self toolbarItems] objectForKey:itemIdentifier];
	
	newItem_ = [item_ copyWithZone:[self zone]];

	if ([newItem_ view]) {
		NSSize itemSize = [[newItem_ view] bounds].size;
		[newItem_ setMinSize:itemSize];
		[newItem_ setMaxSize:itemSize];
	}
	
	return [newItem_ autorelease];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [[self controllers] valueForKey:@"identifier"];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [[self controllers] valueForKey:@"identifier"];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [[self controllers] valueForKey:@"identifier"];
}

- (void)setupToolbar
{
	NSToolbar				*toolbar_;
	NSToolbarItem			*tbItem_;
	NSEnumerator			*iter_;
	PreferencesController	*controller_;
	SEL action_ = @selector(selectController:);

	toolbar_= [[NSToolbar alloc] initWithIdentifier:PPToolbarIdentifier];
	
	iter_ = [[self controllers] objectEnumerator];

	while (controller_ = [iter_ nextObject]) {
		if(![controller_ identifier]) continue;
		
		tbItem_ = [controller_ makeToolbarItem];
		[tbItem_ setTarget:self];
		[tbItem_ setAction:action_];
		[[self toolbarItems] setObject:tbItem_ forKey:[controller_ identifier]];
		[tbItem_ release];
	}

	[toolbar_ setDelegate:self];
	[toolbar_ setAllowsUserCustomization:NO];
	[toolbar_ setAutosavesConfiguration:NO];
	[toolbar_ setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar_ setSizeMode:NSToolbarSizeModeRegular];

	[[self window] setToolbar:toolbar_];
	[toolbar_ release];

	[[self window] setShowsToolbarButton:NO];
}
@end
