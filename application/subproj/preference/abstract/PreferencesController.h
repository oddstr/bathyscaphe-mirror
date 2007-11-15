/**
  * $Id: PreferencesController.h,v 1.4 2007/11/15 15:35:24 tsawada2 Exp $
  * 
  * PreferencesController.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "AppDefaults.h"



@interface PreferencesController : NSObject
{
	IBOutlet NSView	*_contentView;
	NSWindow		*_window;
	AppDefaults		*_preferences;
}
- (id) initWithPreferences : (AppDefaults *) pref;

- (NSWindow *) window;
- (void) setWindow : (NSWindow *) aWindow;
- (AppDefaults *) preferences;
- (void) setPreferences : (AppDefaults *) aPreferences;

- (void) setupUIComponents;
- (void) updateUIComponents;


// same as NSPreferencePane
- (NSView *) loadMainView;
- (NSView *) mainView;
- (NSString *) mainNibName;
- (void) mainViewDidLoad;

// invoked by parent PreferencesPane
- (void) willUnselect;
- (void) didSelect;

- (IBAction) openHelp : (id) sender;
@end



@interface PreferencesController(Toolbar)
- (NSToolbarItem *) makeToolbarItem;
- (NSString *) identifier;
- (NSString *) helpKeyword;
- (NSString *) label;
- (NSString *) paletteLabel;
- (NSString *) toolTip;
- (NSImage *) image;
- (NSString *) imageName;
@end
