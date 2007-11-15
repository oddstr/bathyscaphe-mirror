//
//  PreferencesPane.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/16.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "PreferencesPane.h"
#import "AppDefaults.h"
#import "PreferencesController.h"

#import "BSTagValueTransformer.h"

#define DefineConstStr(symbol, value)		NSString *const symbol = value

DefineConstStr(PPLastOpenPaneIdentifier, @"PPLastOpenPaneIdentifier");

DefineConstStr(PPShowAllIdentifier, @"ShowAll");
DefineConstStr(PPGeneralPreferencesIdentifier, @"General");
DefineConstStr(PPAdvancedPreferencesIdentifier, @"Advanced");
DefineConstStr(PPFilterPreferencesIdentifier, @"Filter");
DefineConstStr(PPAccountSettingsIdentifier, @"AccountSettings");
DefineConstStr(PPFontsAndColorsIdentifier, @"FontsAndColors");
DefineConstStr(PPReplyDefaultIdentifier, @"ReplyDefaults");
DefineConstStr(PPSoundsPreferencesIdentifier, @"Sounds");
DefineConstStr(PPSyncPreferencesIdentifier, @"Sync");
DefineConstStr(PPLinkPreferencesIdentifier, @"Link");

@implementation PreferencesPane
- (id)initWithPreferences:(AppDefaults *)prefs
{
	if (self = [super initWithWindowNibName:@"PreferencesPane"]) {
		[self setPreferences:prefs];
		[self makePreferencesControllers];

		// For use in GeneralPref
		id transformer = [[[BSTagValueTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"BSTagValueTransformer"];

		// For use in FilterPane
		id transformer2 = [[[BSTagToBoolTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer2 forName:@"BSTagToBoolTransformer"];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:[self window]]; 

	[_preferences release];
	[_toolbarItems release];
	[_controllers release];
	[_currentIdentifier release];
	[super dealloc];
}

- (AppDefaults *)preferences
{
	return _preferences;
}

- (void)setPreferences:(AppDefaults *)aPreferences
{
	[aPreferences retain];
	[_preferences release];
	_preferences = aPreferences;
}

- (void)awakeFromNib
{
	[self setupUIComponents];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(windowWillClose:)
			   name:NSWindowWillCloseNotification
			 object:[self window]];
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];	
	if ([self isWindowLoaded]) {
		[self updateUIComponents];
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	PreferencesController	*cntl;
	
	cntl = [self currentController];
	[cntl willUnselect];
}
@end

@implementation PreferencesPane(ViewAccessor)
- (void)setupUIComponents
{
	NSString       *identifier_;	
	identifier_ = [[NSUserDefaults standardUserDefaults] stringForKey:PPLastOpenPaneIdentifier];
	
	if (![[[self controllers] valueForKey:@"identifier"] containsObject:identifier_]) {
		identifier_ = PPGeneralPreferencesIdentifier;
	}

	[self setupToolbar];
	[self setCurrentIdentifier:identifier_];

	[[self window] center];
}

- (NSString *)displayName
{
	PreferencesController	*controller_;
	
	controller_ = [self currentController];
	
	if (!controller_) return @"";	
	return [controller_ label];
}

- (void)updateUIComponents
{
	[[self window] setTitle:[self displayName]];
	[[self currentController] updateUIComponents];
}
@end
