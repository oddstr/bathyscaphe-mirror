/**
  * $Id: TextFinder.m,v 1.6 2007/02/17 15:34:10 tsawada2 Exp $
  *
  * Copyright 2005 BathyScaphe Project. All rights reserved.
  *
  */

#import "TextFinder.h"
#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import "CMRSearchOptions.h"
#import "CMRThreadViewer.h"

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
	
	s = [self loadFindStringFromPasteboard];
	if (s != nil)
		[self setFindString: s];

	[[self findTextField] setDelegate : self];
    [[self window] setFrameAutosaveName : APP_FIND_PANEL_AUTOSAVE_NAME];
}

- (CMRSearchOptions *) currentOperation
{
	NSString		*string_ = [self findString];
	CMRSearchMask	option = [CMRPref contentsSearchOption];
	unsigned int  generalOption = 0;

	if (!string_)
		return nil;

	if (option & CMRSearchOptionCaseInsensitive)
		generalOption |= NSCaseInsensitiveSearch;
	
	return [CMRSearchOptions operationWithFindObject : string_
											 replace : nil
											userInfo : [NSNumber numberWithUnsignedInt : option]
											  option : generalOption];
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
- (void) controlTextDidChange : (NSNotification *) aNotification
{
	NSString *name_;
	
	name_ = [aNotification name];
	
	if ([name_ isEqualToString : NSControlTextDidChangeNotification]) {
		[self setFindStringToPasteboard];
	}
}

- (void) findWillStart : (NSNotification *) aNotification
{
	[[self notFoundField] setHidden : YES];
}

- (void) findDidEnd : (NSNotification *) aNotification
{
	unsigned	num;
	num = [[[aNotification userInfo] objectForKey : kAppThreadViewerFindInfoKey] unsignedIntValue];
	//NSLog(@"%i", num);
	if (num != 1) {
		[[self notFoundField] setHidden : NO];
		[[self notFoundField] setStringValue: (num == 0) ? NSLocalizedString(@"No Match", @"No Match")
														 : [NSString stringWithFormat: NSLocalizedString(@"%u Res(s)", @"%u Res(s)"), num]];
	}
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
}

- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : BSThreadViewerWillStartFindingNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : BSThreadViewerDidEndFindingNotification
	          object : nil];	
}

- (void) dealloc
{
	[self removeFromNotificationCenter];
	[m_findString release];
	[super dealloc];
}
@end
