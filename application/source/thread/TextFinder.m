/**
  * $Id: TextFinder.m,v 1.11 2007/03/18 17:46:52 tsawada2 Exp $
  *
  * Copyright 2005-2007 BathyScaphe Project. All rights reserved.
  *
  */

#import "TextFinder.h"
#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import "BSSearchOptions.h"
#import "CMRThreadViewer.h"
#import <OgreKit/OgreKit.h>

#define kLoadNibName					@"TextFind"
#define APP_FIND_PANEL_AUTOSAVE_NAME	@"BathyScaphe:Find Panel Autosave"


@implementation TextFinder
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(standardTextFinder);

- (id) init
{
	if (self = [super initWithWindowNibName : kLoadNibName]) {
		[self registerToNotificationCenter];
	}
	return self;
}

- (void) awakeFromNib
{
	[self setupUIComponents];
}

- (void) setupUIComponents
{
	NSString		*s;		// from Pasteboard
	NSArray			*array = [CMRPref contentsSearchTargetArray];
	int	i;
	
	s = [self loadFindStringFromPasteboard];
	if (s != nil)
		[self setFindString: s];

	for (i = 0; i < 5; i++) {
		NSButtonCell *cell = [[self targetMatrix] cellWithTag: i];
		if ([[array objectAtIndex: i] respondsToSelector: @selector(intValue)]) {
			[cell setState: [[array objectAtIndex: i] intValue]];
		}
	}

	if (NO == [CMRPref findPanelExpanded]) {
		[m_disclosureTriangle setState: NSOffState];
		[self expandOrShrinkPanel: NO animate: NO];
	}
	
	[self updateLinkOnlyBtnEnabled];

    [[self window] setFrameAutosaveName : APP_FIND_PANEL_AUTOSAVE_NAME];
}

- (void) updateLinkOnlyBtnEnabled
{
	BOOL	tmp = ([[[self targetMatrix] cellWithTag: 4] state] == NSOnState);
	if (NO == tmp && [self isLinkOnly]) {
		[self setIsLinkOnly: NO];
	}
	[[self linkOnlyButton] setEnabled: tmp];
}

- (BSSearchOptions *) currentOperation
{
	static NSArray *allKeys = nil;

	NSString		*findString = [self findString];
	if (!findString) return nil;

	if (allKeys == nil) {
		allKeys = [[NSArray alloc] initWithObjects: @"name", @"mail", @"IDString", @"host", @"cachedMessage", nil];
	}

	NSArray			*boolArray = [CMRPref contentsSearchTargetArray];
	NSMutableArray	*tmpArray = [NSMutableArray array];
	CMRSearchMask	optionMask = [CMRPref contentsSearchOption];
	int				i;

	for (i = 0; i < 5; i++) {
		if ([[boolArray objectAtIndex: i] intValue] == NSOnState) {
			[tmpArray addObject: [allKeys objectAtIndex: i]];
		}
	}

	return [BSSearchOptions operationWithFindObject: findString
											options: optionMask
											 target: tmpArray];
}

- (void) showWindow : (id) sender
{
	[super showWindow: sender];
	[[self findTextField] selectText : sender];
	[[self notFoundField] setHidden : YES];
}

#pragma mark Accessors
- (NSTextField *) findTextField
{
	return _findTextField;
}

- (NSTextField *) notFoundField
{
	return _notFoundField;
}

- (NSBox *) optionsBox
{
	return m_optionsBox;
}

- (NSMatrix *) targetMatrix
{
	return m_targetMatrix;
}

- (NSView *) findButtonsView
{
	return m_findButtonsView;
}

- (NSButton *) linkOnlyButton
{
	return m_linkOnlyButton;
}

#pragma mark Cocoa Binding
- (NSString *) findString
{
	return m_findString;
}

- (void) setFindString : (NSString *) aString
{
	[aString retain];
	[m_findString release];
	m_findString = aString;
}

- (BOOL) isCaseInsensitive
{
	CMRSearchMask	option = [CMRPref contentsSearchOption];
	return (option & CMRSearchOptionCaseInsensitive);
}

- (void) setIsCaseInsensitive : (BOOL) checkBoxState
{
	CMRSearchMask	option = [CMRPref contentsSearchOption];
	if (checkBoxState) {
		option |= CMRSearchOptionCaseInsensitive;
	} else {
		option ^= CMRSearchOptionCaseInsensitive;
	}
	[CMRPref setContentsSearchOption : option];
}

- (BOOL) isLinkOnly
{
	CMRSearchMask	option = [CMRPref contentsSearchOption];
	return (option & CMRSearchOptionLinkOnly);
}

- (void) setIsLinkOnly : (BOOL) checkBoxState
{
	CMRSearchMask	option = [CMRPref contentsSearchOption];
	if (checkBoxState) {
		option |= CMRSearchOptionLinkOnly;
	} else {
		option ^= CMRSearchOptionLinkOnly;
	}
	[CMRPref setContentsSearchOption : option];
}

- (BOOL) usesRegularExpression
{
	CMRSearchMask	option = [CMRPref contentsSearchOption];
	return (option & CMRSearchOptionUseRegularExpression);
}

- (void) setUsesRegularExpression : (BOOL) checkBoxState
{
	CMRSearchMask	option = [CMRPref contentsSearchOption];
	if (checkBoxState) {
		option |= CMRSearchOptionUseRegularExpression;
	} else {
		option ^= CMRSearchOptionUseRegularExpression;
	}
	[CMRPref setContentsSearchOption : option];
}

#pragma mark IBActions
- (IBAction) changeTargets: (id) sender
{
	[CMRPref setContentsSearchTargetArray: [[[self targetMatrix] cells] valueForKey: @"state"]];
	[self updateLinkOnlyBtnEnabled];
}

- (void) expandOrShrinkPanel: (BOOL) willExpand animate: (BOOL) shouldAnimate
{
	NSRect	windowFrame = [[self window] frame];
	NSRect	boxFrame = [[self optionsBox] frame];

	float	boxHeight = boxFrame.size.height;

	if (willExpand) {
		windowFrame.size.height += boxHeight;
		windowFrame.origin.y -= boxHeight;
		if (windowFrame.origin.y < 10) {
			windowFrame.origin.y = 10;
		}
		[[self window] setFrame: windowFrame display: YES animate: shouldAnimate];
		[[self optionsBox] setFrameOrigin: NSMakePoint(21, [[self findButtonsView] frame].size.height)];
		[[self optionsBox] setHidden: NO];
	} else {
		windowFrame.size.height -= boxHeight;
		windowFrame.origin.y += boxHeight;
		[[self optionsBox] setHidden: YES];
		[[self window] setFrame: windowFrame display: YES animate: shouldAnimate];
		[[self findButtonsView] setFrameOrigin: NSZeroPoint];
	}
}

- (IBAction) togglePanelMode: (id) sender
{
	BOOL willExpand = ([sender state] == NSOnState);
	[self expandOrShrinkPanel: willExpand animate: YES];
}

#pragma mark Working with pasteboards
- (NSString *) loadFindStringFromPasteboard
{
	NSPasteboard *pasteboard;

	pasteboard = [NSPasteboard pasteboardWithName : NSFindPboard];
	
	if ([[pasteboard types] containsObject : NSStringPboardType])
		return [pasteboard stringForType : NSStringPboardType];
	
	return nil;
}

- (void) setFindStringToPasteboard
{
	NSString		*string_ = [self findString];
	NSPasteboard	*pasteboard;

	if (string_ == nil)
		return;

	pasteboard = [NSPasteboard pasteboardWithName : NSFindPboard];
	[pasteboard declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: nil];
	[pasteboard setString: string_ forType: NSStringPboardType];
}

#pragma mark Delegate
- (void) controlTextDidEndEditing : (NSNotification *) aNotification
{
	[self setFindStringToPasteboard];
}

- (void) findWillStart : (NSNotification *) aNotification
{
	[[self notFoundField] setHidden : YES];
	[m_progressSpin startAnimation: nil];
}

- (void) findDidEnd : (NSNotification *) aNotification
{
	unsigned	num;
	num = [[[aNotification userInfo] objectForKey : kAppThreadViewerFindInfoKey] unsignedIntValue];
	//NSLog(@"%i", num);
	[m_progressSpin stopAnimation: nil];
	if (num != 1) {
		[[self notFoundField] setHidden : NO];
		[[self notFoundField] setStringValue: (num == 0) ? NSLocalizedString(@"No Match", @"")
														 : [NSString stringWithFormat: NSLocalizedString(@"%u Res(s)", @""), num]];
	}
}

- (void) applicationWillQuit: (NSNotification *) aNotification
{
	[CMRPref setFindPanelExpanded: ([m_disclosureTriangle state] == NSOnState)];
//	[CMRPref setContentsSearchTargetArray: [[[self targetMatrix] cells] valueForKey: @"state"]];
}

- (void) registerToNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(findWillStart:)
	            name : BSThreadViewerWillStartFindingNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(findDidEnd:)
	            name : BSThreadViewerDidEndFindingNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(applicationWillQuit:)
	            name : NSApplicationWillTerminateNotification
	          object : NSApp];
}

- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
}

- (void) dealloc
{
	[self removeFromNotificationCenter];
	[m_findString release];
	[super dealloc];
}
@end
