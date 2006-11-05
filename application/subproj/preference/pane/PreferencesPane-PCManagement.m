/**
  * $Id: PreferencesPane-PCManagement.m,v 1.5 2006/11/05 13:02:22 tsawada2 Exp $
  * 
  * PreferencesPane-PCManagement.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "PreferencesPane.h"
#import "AppDefaults.h"
#import "PreferencesController.h"

#import "FCController.h"
#import "AccountController.h"
#import "CMRReplyDefaultsController.h"
#import "GeneralPrefController.h"
#import "AdvancedPrefController.h"
#import "CMRFilterPrefController.h"
#import "SoundsPaneController.h"
#import "SyncPaneController.h"

@implementation PreferencesPane(PreferencesControllerManagement)
- (NSView *) contentView
{
	return _contentView;
}
- (void) setContentView : (NSView *) contentView
{
	_contentView = contentView;
}

- (NSMutableArray *) controllers
{
	if (nil == _controllers) {
		_controllers = [[NSMutableArray allocWithZone : [self zone]] init];
	}
	return _controllers;
}
- (NSString *) currentIdentifier
{
	return _currentIdentifier;
}
- (void) setCurrentIdentifier : (NSString *) aCurrentIdentifier
{
	[aCurrentIdentifier retain];
	[_currentIdentifier release];
	_currentIdentifier = aCurrentIdentifier;
	
	if (nil == _currentIdentifier) return;

	[[NSUserDefaults standardUserDefaults] setObject : _currentIdentifier
				  forKey : PPLastOpenPaneIdentifier];
}


- (void) makePreferencesControllers
{
	Class	defs[] = {
		[GeneralPrefController class],
		[AccountController class],
		[CMRFilterPrefController class],
		[FCController class],
		[CMRReplyDefaultsController class],
		[AdvancedPrefController class],
		[SoundsPaneController class],
		[SyncPaneController class],
		Nil
	};
	
	PreferencesController	*controller_;
	Class					*p;
	
	for (p = defs; *p != Nil; p++) {
		controller_ = [[*p alloc] initWithPreferences : [self preferences]];
		
		[[self controllers] addObject : controller_];
		[controller_ release];
	}
}

- (PreferencesController *) controllerWithIdentifier : (NSString *) identifier
{
	NSEnumerator			*iter_;
	PreferencesController	*controller_;
	
	if (nil == identifier) return nil;
	
	iter_ = [[self controllers] objectEnumerator];
	while (controller_ = [iter_ nextObject]) {
		if ([identifier isEqualToString : [controller_ identifier]])
			return controller_;
	}
	return nil;
}

/*** Select preference pane ***/

// calc window, contentView frame for new pane
- (void) calcFramesForContentFrame : (NSRect) newFrame
					   windowFrame : (NSRect *) windowFrame
					  contentFrame : (NSRect *) contentFrame
{
	NSRect	wFrame   = [[self window] frame];
	NSRect	oldFrame = [[self contentView] frame];
	float	dHeight;
	
	NSAssert(windowFrame && contentFrame, @"Arguments");
	wFrame.size.width = newFrame.size.width = 
		(NSWidth(wFrame) < NSWidth(newFrame)) 
			? NSWidth(newFrame)
			: NSWidth(wFrame);
	
	dHeight = (NSHeight(oldFrame) - NSHeight(newFrame));
	wFrame.size.height -= dHeight; wFrame.origin.y += dHeight;
	
	*windowFrame = wFrame;
	*contentFrame = newFrame;
}

- (void) setContentViewWithController : (PreferencesController *) controller
{
	PreferencesController	*oldController;
	NSView					*mainView_;
	NSView	*tmp_;
	NSRect	wFrame;
	NSRect	newFrame;
	
	if (nil == [[self contentView] superview])
		return;
	
	mainView_ = [controller mainView];
	oldController = [self controllerWithIdentifier : [self currentIdentifier]];
	
	[self calcFramesForContentFrame : [mainView_ frame]
						windowFrame : &wFrame
					   contentFrame : &newFrame];
	
	// insert new pane
	[controller willSelect];
	[oldController willUnselect];

	tmp_ = [[self contentView] superview];
	[[self contentView] removeFromSuperviewWithoutNeedingDisplay];

	[mainView_ setFrame : newFrame];
	[[self window] setFrame : wFrame
					display : YES
					animate : YES];

	[tmp_ addSubview : mainView_];
	[self setContentView : mainView_];

	[oldController setWindow : nil];
	[controller setWindow : [self window]];
	[oldController didUnselect];
	[controller didSelect];

	[self setCurrentIdentifier : [controller identifier]];
	[self updateUIComponents];
}

- (IBAction) selectController : (id) sender
{
	id	object_;
	
	if (NO == [sender respondsToSelector : @selector(itemIdentifier)])
		return;
	
	object_ = [sender itemIdentifier];
	if (nil ==  object_ || [object_ isEqualToString : [self currentIdentifier]])
		return;
	
	if (nil == (object_ = [self controllerWithIdentifier : object_]))
		return;
	
	[self setContentViewWithController : object_];
}
@end
