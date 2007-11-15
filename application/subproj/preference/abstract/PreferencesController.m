/**
  * $Id: PreferencesController.m,v 1.6 2007/11/15 15:35:24 tsawada2 Exp $
  * 
  * PreferencesController.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "PreferencesController.h"

#import <SGFoundation/NSBundle-SGExtensions.h>

@implementation PreferencesController
- (id) initWithPreferences : (AppDefaults *) pref
{
	if(self = [super init]){
		[self setPreferences : pref];
	}
	return self;
}
- (void) dealloc
{
	[_contentView release];
	[_preferences release];
	[super dealloc];
}
- (NSView *) contentView
{
	return [self mainView];
}
- (NSWindow *) window
{
	return _window;
}
- (void) setWindow : (NSWindow *) aWindow
{
	_window = aWindow;
	[_window setDelegate : self];
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

- (void) setupUIComponents
{
	;
}

- (void) updateUIComponents
{
	;
}

// same as NSPreferencePane
- (NSView *) loadMainView
{
	if(nil == [self mainNibName]) return nil;
	
	[NSBundle loadNibNamed : [self mainNibName]
					 owner : self];
	
	[self mainViewDidLoad];
	
	return _contentView;
}
- (NSView *) mainView
{
	if(nil == _contentView){
		[self loadMainView];
	}
	return _contentView;
}

- (NSString *) mainNibName;
{
	return nil;
}

- (void) mainViewDidLoad
{
	[self setupUIComponents];
}

// invoked by parent PreferencesPane
- (void) willUnselect 
{
	if ([[self window] makeFirstResponder:[self window]]) {
		/* All fields are now valid; itÅfs safe to use fieldEditor:forObject:
		to claim the field editor. */
	} else {
		/* Force first responder to resign. */
		[[self window] endEditingFor:nil];
	}
}
- (void) didSelect
{
	if ([[self window] respondsToSelector:@selector(recalculateKeyViewLoop)]) {
		[[self window] recalculateKeyViewLoop];
	}
}

- (IBAction) openHelp : (id) sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : [self helpKeyword]
											   inBook : [NSBundle applicationHelpBookName]];
}
@end



@implementation PreferencesController(Toolbar)
- (NSToolbarItem *) makeToolbarItem
{
	NSToolbarItem		*item_;
	
	item_ = [[NSToolbarItem alloc] initWithItemIdentifier : [self identifier]];
	[item_ setLabel : [self label]];
	[item_ setPaletteLabel : [self paletteLabel]];
	[item_ setToolTip : [self toolTip]];
	[item_ setImage : [self image]];

	return item_;
}

- (NSString *) identifier
{
	return nil;
}
- (NSString *) helpKeyword
{
	return nil;
}
- (NSString *) label
{
	return nil;
}
- (NSString *) paletteLabel
{
	return nil;
}
- (NSString *) toolTip
{
	return nil;
}
- (NSImage *) image
{
	NSString	*filepath_;
	
	filepath_ = [[NSBundle bundleForClass : [self class]]
					pathForImageResource : [self imageName]];
	
	if(nil == filepath_) return nil;
	
	return [[[NSImage alloc] initWithContentsOfFile : filepath_] autorelease];
}
- (NSString *) imageName
{
	return nil;
}
@end
