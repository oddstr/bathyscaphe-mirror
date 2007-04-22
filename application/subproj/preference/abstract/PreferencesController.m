/**
  * $Id: PreferencesController.m,v 1.5 2007/04/22 15:51:30 tsawada2 Exp $
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
- (void) willSelect { ; }
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
- (void) didSelect { ; }
- (void) didUnselect { ; }

// utitlity
/*- (void) preferencesRespondsTo : (SEL        ) respondsSEL
					 ofControl : (NSControl *) aControl
{
	[aControl setEnabled : [[self preferences] respondsToSelector : respondsSEL]];
}
- (void) syncButtonState : (NSButton *) aButton
				    with : (SEL       ) boolValueSEL
{
	id		v;
	
	v = [[self preferences] valueForKey : NSStringFromSelector(boolValueSEL)];
	if (NO == [v respondsToSelector : @selector(boolValue)]) {
		NSLog(
			@"Maybe, - [NSObject valueForKey:] does not sopport bool value.\n"
			@"please send report to development team.\n\n"
			
			@"Thanks! -- CocoMonar Developers");
	}
	UTILAssertRespondsTo(v, @selector(boolValue));
	
	[aButton setState : (([v boolValue]) ? NSOnState : NSOffState)];
}
- (void) syncSelectedTag : (NSMatrix *) aMatrix
				    with : (SEL       ) boolValueSEL
{
	id		v;
	int		tag;
	
	v = [[self preferences] valueForKey : NSStringFromSelector(boolValueSEL)];
	UTILAssertRespondsTo(v, @selector(intValue));
	
	tag = [v intValue];
	[aMatrix deselectSelectedCell];
	[aMatrix selectCellWithTag : tag];
}*/


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



