//
//  BSIPIPrefsTbDelegate.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/09/15.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIPrefsTbDelegate.h"


@implementation BSIPIPrefsTbDelegate
- (void) awakeFromNib
{
    NSToolbar*  toolbar = [[[NSToolbar alloc] initWithIdentifier: @"PrefsTabToolbar"] autorelease];
    
    [toolbar setDelegate: self];
	[toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
	[toolbar setSizeMode: NSToolbarSizeModeRegular];//Small];
	[toolbar setAllowsUserCustomization: NO];
	[toolbar setSelectedItemIdentifier: @"generalPane"];
    [[self prefsWindow] setToolbar: toolbar];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
	// 識別子の配列を返します
    return [NSArray arrayWithObjects: @"generalPane", @"windowPane", nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
    return [self toolbarDefaultItemIdentifiers: toolbar];
}

- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar
{
    return [self toolbarDefaultItemIdentifiers: toolbar];
}


- (NSString *) localizedStrForKey : (NSString *) key
{
	NSBundle *selfBundle = [NSBundle bundleForClass : [self class]];
	return [selfBundle localizedStringForKey : key value : key table : nil];
}

- (NSImage *) imageResourceWithName: (NSString *) name
{
	NSBundle *bundle_;
	NSString *filepath_;
	bundle_ = [NSBundle bundleForClass : [self class]];
	filepath_ = [bundle_ pathForImageResource : name];
	
	if(nil == filepath_) return nil;
	
	return [[[NSImage alloc] initWithContentsOfFile : filepath_] autorelease];
}

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) itemId willBeInsertedIntoToolbar: (BOOL) willBeInserted
{
    NSToolbarItem*  toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemId] autorelease];
	[toolbarItem setTarget: self];
	[toolbarItem setAction: @selector(switchTab:)];
    
    if ([itemId isEqualToString: @"generalPane"]) {
        [toolbarItem setLabel: [self localizedStrForKey: @"generalPref"]];
        [toolbarItem setImage: [self imageResourceWithName: @"Settings"]];
        
        return toolbarItem;
    }

    if ([itemId isEqualToString: @"windowPane"]) {
        [toolbarItem setLabel: [self localizedStrForKey: @"windowPref"]];
        [toolbarItem setImage: [self imageResourceWithName: @"AppearancePreferences"]];
        
        return toolbarItem;
    }
    
    return nil;
}

- (IBAction) switchTab: (id) sender
{
    [[self prefsTabView] selectTabViewItemWithIdentifier: [sender itemIdentifier]];
}

- (NSPanel *) prefsWindow
{
	return m_prefsWindow;
}

- (NSTabView *) prefsTabView
{
	return m_prefsTabView;
}
@end
