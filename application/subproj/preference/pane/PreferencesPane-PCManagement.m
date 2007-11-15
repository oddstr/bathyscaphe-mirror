//
//  PreferencesPane-PCManagement.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/15.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "PreferencesPane.h"
#import "PreferencesController.h"

#import "FCController.h"
#import "AccountController.h"
#import "CMRReplyDefaultsController.h"
#import "GeneralPrefController.h"
#import "AdvancedPrefController.h"
#import "CMRFilterPrefController.h"
#import "SoundsPaneController.h"
#import "SyncPaneController.h"
#import "LinkPrefController.h"

@implementation PreferencesPane(PreferencesControllerManagement)
- (NSView *)contentView
{
	return _contentView;
}

- (void)setContentView:(NSView *)contentView
{
	_contentView = contentView;
}

- (NSMutableArray *)controllers
{
	if (!_controllers) {
		_controllers = [[NSMutableArray allocWithZone:[self zone]] init];
	}
	return _controllers;
}

- (NSString *)currentIdentifier
{
	return _currentIdentifier;
}

- (void)setCurrentIdentifier:(NSString *)aCurrentIdentifier
{
	[self removeContentViewWithCurrentIdentifier];

	[aCurrentIdentifier retain];
	[_currentIdentifier release];
	_currentIdentifier = aCurrentIdentifier;
	if (!_currentIdentifier) return;

	[[NSUserDefaults standardUserDefaults] setObject:_currentIdentifier forKey:PPLastOpenPaneIdentifier];

	[self insertContentViewWithCurrentIdentifier];
	[[[self window] toolbar] setSelectedItemIdentifier:aCurrentIdentifier];
}

- (void)makePreferencesControllers
{
	Class	defs[] = {
		[GeneralPrefController class],
		[FCController class],
		[AccountController class],
		[SyncPaneController class],
		[LinkPrefController class],
		[CMRFilterPrefController class],
		[CMRReplyDefaultsController class],
		[SoundsPaneController class],
		[AdvancedPrefController class],
		Nil
	};

	PreferencesController	*controller_;
	Class					*p;
	
	for (p = defs; *p != Nil; p++) {
		controller_ = [[*p alloc] initWithPreferences:[self preferences]];
		[[self controllers] addObject:controller_];
		[controller_ release];
	}
}

- (PreferencesController *)controllerWithIdentifier:(NSString *)identifier
{
	NSEnumerator			*iter_;
	PreferencesController	*controller_;
	
	if (!identifier) return nil;
	
	iter_ = [[self controllers] objectEnumerator];
	while (controller_ = [iter_ nextObject]) {
		if ([identifier isEqualToString:[controller_ identifier]])
			return controller_;
	}
	return nil;
}

- (PreferencesController *)currentController
{
	return [self controllerWithIdentifier:[self currentIdentifier]];
}

- (void)calcFramesForContentFrame:(NSRect)newFrame
					  windowFrame:(NSRect *)windowFrame
					 contentFrame:(NSRect *)contentFrame
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

- (void)removeContentViewWithCurrentIdentifier
{
	PreferencesController *controller = [self currentController];
	[controller willUnselect];
	[controller setWindow:nil];
}

- (void)insertContentViewWithCurrentIdentifier
{
	PreferencesController *controller = [self currentController];
	NSView	*mainView_;
	NSView	*tmp_;
	mainView_ = [controller mainView];

	NSRect	wFrame;
	NSRect	newFrame;
	
	[self calcFramesForContentFrame:[mainView_ frame]
						windowFrame:&wFrame
					   contentFrame:&newFrame];
	tmp_ = [[self contentView] superview];
	[[self contentView] removeFromSuperviewWithoutNeedingDisplay];

	[mainView_ setFrame:newFrame];
	[[self window] setFrame:wFrame display:YES animate:YES];


	[tmp_ addSubview:mainView_];
	[self setContentView:mainView_];

	[controller setWindow:[self window]];
	[controller didSelect];

	[self updateUIComponents];
}

- (IBAction)selectController:(id)sender
{
	if (!sender || ![sender respondsToSelector:@selector(itemIdentifier)]) {
		return;
	}
	[self setCurrentIdentifier:[sender itemIdentifier]];
}
@end
