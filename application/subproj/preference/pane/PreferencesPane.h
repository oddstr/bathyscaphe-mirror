/**
  * $Id: PreferencesPane.h,v 1.1.1.1 2005/05/11 17:51:11 tsawada2 Exp $
  * 
  * PreferencesPane.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>

@class AppDefaults;
@class PreferencesController;



@interface PreferencesPane : NSWindowController
{
	IBOutlet NSView		*_contentView;
	AppDefaults			*_preferences;
	NSMutableDictionary	*_toolbarItems;
	NSMutableArray		*_controllers;
	NSString			*_currentIdentifier;
}
- (id) initWithPreferences : (AppDefaults *) prefs;
- (AppDefaults *) preferences;
- (void) setPreferences : (AppDefaults *) aPreferences;
- (NSString *) displayName;
@end



@interface PreferencesPane(ViewAccessor)
- (void) setupUIComponents;
- (void) updateUIComponents;
@end



@interface PreferencesPane(ToolbarSupport)
- (NSMutableDictionary *) toolbarItems;
- (void) setupToolbar;
@end



@interface PreferencesPane(PreferencesControllerManagement)
- (NSView *) contentView;
- (void) setContentView : (NSView *) contentView;
- (NSMutableArray *) controllers;
- (NSString *) currentIdentifier;
- (void) setCurrentIdentifier : (NSString *) identifier;
- (void) makePreferencesControllers;

- (PreferencesController *) controllerWithIdentifier : (NSString *) identifier;

- (void) setContentViewWithController : (PreferencesController *) controller;
- (IBAction) selectController : (id) sender;
@end



extern NSString *const PPLastOpenPaneIdentifier;
extern NSString *const PPToolbarIdentifier;
