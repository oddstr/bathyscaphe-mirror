/**
  * $Id: PreferencesPane.m,v 1.3.4.3 2006/08/11 14:44:17 tsawada2 Exp $
  * 
  * PreferencesPane.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "PreferencesPane.h"
#import "AppDefaults.h"
#import "PreferencesController.h"

#import "BSTagValueTransformer.h"

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
DefineConstStr(PPSoundsPreferencesIdentifier, @"Sounds");
DefineConstStr(PPSyncPreferencesIdentifier, @"Sync");


@implementation PreferencesPane
- (id) initWithPreferences : (AppDefaults *) prefs
{
	if (self = [super initWithWindowNibName : @"PreferencesPane"]) {
		[self setPreferences : prefs];
		[self makePreferencesControllers];

		// For use in GeneralPref
		id transformer = [[[BSTagValueTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer: transformer forName: @"BSTagValueTransformer"];

		// For use in SyncPane
		//id transformer2 = [[[BSURLStringTransformer alloc] init] autorelease];
		//[NSValueTransformer setValueTransformer: transformer2 forName: @"BSURLStringTransformer"];
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

@implementation PreferencesPane(ViewAccessor)
- (void) setupUIComponents
{
	PreferencesController *controller_;
	NSUserDefaults *defaults_;
	NSString       *identifier_;
	
	defaults_ = [NSUserDefaults standardUserDefaults];
	identifier_ = [defaults_ stringForKey : PPLastOpenPaneIdentifier];
	
	controller_ = [self controllerWithIdentifier : identifier_];
	if(nil == controller_)
		identifier_ = PPFontsAndColorsIdentifier;
	controller_ = [self controllerWithIdentifier : identifier_];
	UTILAssertNotNil(controller_);
	
	[self setContentViewWithController : controller_];
	[self setupToolbar];
	[[[self window] toolbar] setSelectedItemIdentifier: identifier_];
}

- (void) updateUIComponents
{
	[[self controllerWithIdentifier : 
		[self currentIdentifier]] updateUIComponents];
	[[self window] setTitle : [self displayName]];
}
@end
