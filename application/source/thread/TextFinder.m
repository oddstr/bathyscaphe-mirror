/**
  * $Id: TextFinder.m,v 1.3 2005/12/03 09:01:50 tsawada2 Exp $
  *
  * Copyright 2005 BathyScaphe Project. All rights reserved.
  *
  */

#import "TextFinder.h"
#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import "CMRSearchOptions.h"

#define kLoadNibName					@"TextFind"
#define APP_FIND_PANEL_AUTOSAVE_NAME	@"BathyScaphe:Find Panel Autosave"


@implementation TextFinder
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(standardTextFinder);

- (id) init
{
	if (self = [super initWithWindowNibName : kLoadNibName]) {
		;
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
	if (s != nil) {
		[[self findTextField] setStringValue : s];
	}

	[[self findTextField] setDelegate : self];
    [[self window] setFrameAutosaveName : APP_FIND_PANEL_AUTOSAVE_NAME];
}

- (CMRSearchOptions *) currentOperation
{
	CMRSearchMask	option = [CMRPref contentsSearchOption];
	unsigned int  generalOption = 0;
	
	if (option & CMRSearchOptionCaseInsensitive)
		generalOption |= NSCaseInsensitiveSearch;
	
	return [CMRSearchOptions operationWithFindObject : [[self findTextField] stringValue]
											 replace : nil
											userInfo : [NSNumber numberWithUnsignedInt : option]
											  option : generalOption];
}

- (void) showWindow : (id) sender
{
	[[self window] makeKeyAndOrderFront : self];
	[[self findTextField] selectText : sender];
	[[self notFoundField] setHidden : YES];
}

- (void) setFindString : (NSString *) aString
{
    if (aString)
		[[self findTextField] setStringValue : aString];
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
	NSPasteboard *pasteboard;
	
	pasteboard = [NSPasteboard pasteboardWithName : NSFindPboard];
	if ([[[self findTextField] stringValue] length] > 0) {
		NSArray *types_;
		
		types_ = [NSArray arrayWithObject : NSStringPboardType];
		
		[pasteboard declareTypes : types_
						   owner : nil];
		[pasteboard setString : [[self findTextField] stringValue] 
					  forType : NSStringPboardType];
	}
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
@end