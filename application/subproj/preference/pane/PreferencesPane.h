//
//  PreferencesPane.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/15.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "BSPreferencesPaneInterface.h"

@class AppDefaults;
@class PreferencesController;

@interface PreferencesPane : NSWindowController<BSPreferencesPaneProtocol> {
	IBOutlet NSView		*_contentView;
	AppDefaults			*_preferences;
	NSMutableDictionary	*_toolbarItems;
	NSMutableArray		*_controllers;
	NSString			*_currentIdentifier;
}

- (AppDefaults *)preferences;
- (void)setPreferences:(AppDefaults *)aPreferences;
@end


@interface PreferencesPane(ViewAccessor)
// Returns current pane's display name suitable for Window's titlebar.
- (NSString *)displayName;

- (void)setupUIComponents;
- (void)updateUIComponents;
@end


@interface PreferencesPane(ToolbarSupport)
- (NSMutableDictionary *)toolbarItems;
- (void)setupToolbar;
@end


@interface PreferencesPane(PreferencesControllerManagement)
- (NSView *)contentView;
- (void)setContentView:(NSView *)contentView;

- (NSMutableArray *)controllers;

- (PreferencesController *)currentController;

- (void)makePreferencesControllers;
- (void)removeContentViewWithCurrentIdentifier;
- (void)insertContentViewWithCurrentIdentifier;

- (IBAction)selectController:(id)sender;
@end

extern NSString *const PPLastOpenPaneIdentifier;
