/**
  * $Id: PreferencesPane.m,v 1.2 2005/05/22 18:02:26 tsawada2 Exp $
  * 
  * PreferencesPane.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "PreferencesPane.h"
#import "AppDefaults.h"
#import "PreferencesController.h"

#define DefineConstStr(symbol, value)		NSString *const symbol = value

DefineConstStr(PPLastOpenPaneIdentifier, @"PPLastOpenPaneIdentifier");
DefineConstStr(PPToolbarIdentifier, @"PreferencesPane Toolbar");

DefineConstStr(PPShowAllIdentifier, @"ShowAll");
DefineConstStr(PPGeneralPreferencesIdentifier, @"General");
DefineConstStr(PPAdvancedPreferencesIdentifier, @"Advanced");
DefineConstStr(PPFilterPreferencesIdentifier, @"Filter");
DefineConstStr(PPAccountSettingsIdentifier, @"AccountSettings");
DefineConstStr(PPFontsAndColorsIdentifier, @"FontsAndColors");
DefineConstStr(PPReplyDefaultIdentifier, @"ReplyDefaults");



@implementation PreferencesPane
- (id) initWithPreferences : (AppDefaults *) prefs
{
	if (self = [super initWithWindowNibName : @"PreferencesPane"]) {
		[self setPreferences : prefs];
		[self makePreferencesControllers];
	}
	return self;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter]
		removeObserver : self
		name : NSWindowWillCloseNotification
		object : [self window]]; 
	
	[_preferences release];
	[_toolbarItems release];
	[_controllers release];
	[_currentIdentifier release];
	[super dealloc];
}

- (AppDefaults *) preferences
{
	return _preferences;
}
- (void) setPreferences : (AppDefaults *) aPreferences
{
	id		tmp;
	
	tmp = _preferences;
	_preferences = [aPreferences retain];
	[tmp release];
}
- (void) awakeFromNib
{
	[self setupUIComponents];
	[[NSNotificationCenter defaultCenter]
		addObserver : self
		selector : @selector(windowWillClose:)
		name : NSWindowWillCloseNotification
		object : [self window]];
}

- (IBAction) showWindow : (id) sender
{
	BOOL	isWindowLoaded_;
	
	isWindowLoaded_ = [self isWindowLoaded];
	
	[super showWindow : sender];
	
	if (isWindowLoaded_)
		[self updateUIComponents];
}

- (NSString *) displayName
{
	PreferencesController	*controller_;
	
	controller_ = [self controllerWithIdentifier : [self currentIdentifier]];
	
	if (nil == controller_) return @"";	
	return [controller_ label];
}



- (void) applicationDidBecomeActive : (NSNotification *) notification
{
	[self updateUIComponents];
}

// NSNotification
- (void) windowWillClose : (NSNotification *) notification
{
	PreferencesController	*cntl;
	
	cntl = [self controllerWithIdentifier : [self currentIdentifier]];
	[cntl willUnselect];
	[cntl didUnselect];
}
@end
