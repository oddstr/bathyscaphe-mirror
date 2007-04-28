//
//  BSThemeEditor.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/04/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSThemeEditor.h"
#import "PreferencePanes_Prefix.h"
#import "AppDefaults.h"

@implementation BSThemeEditor
#pragma mark Overrides
- (id) init
{
	if (self = [super initWithWindowNibName: @"ThemeEditor"]) {
		[self window];
	}
	return self;
}

- (void) dealloc
{
	m_delegate = nil;
	[m_saveThemeIdentifier release];
	[super dealloc];
}

#pragma mark Accessors
- (id) delegate
{
	return m_delegate;
}

- (void) setDelegate: (id) aDelegate
{
	m_delegate = aDelegate;
}

- (NSString *) saveThemeIdentifier
{
	return m_saveThemeIdentifier;
}

- (void) setSaveThemeIdentifier: (NSString *) aString
{
	[aString retain];
	[m_saveThemeIdentifier release];
	m_saveThemeIdentifier = aString;
}

- (NSPanel *) themeNamePanel
{
	return m_themeNameSheet;
}

- (NSObjectController *) themeGreenCube
{
	return m_themeGreenCube;
}

#pragma mark Utilities
- (BOOL) checkIfOverlappingThemeIdentifier
{
	NSArray *identifiers = [[[[self delegate] preferences] installedThemes] valueForKey: @"Identifier"];
	if (!identifiers || NO == [identifiers containsObject: [self saveThemeIdentifier]]) { // 重複していない
		return YES;
	} else {
		return NO;
	}
}

- (NSString *) fileNameForIdentifier: (NSString *) identifier
{
	NSArray *array = [[[self delegate] preferences] installedThemes];
	NSArray *ids = [array valueForKey: @"Identifier"];
	unsigned idx = [ids indexOfObject: identifier];
	if (idx != NSNotFound) {
		return [[array valueForKey: @"FileName"] objectAtIndex: idx];
	} else {
		return nil;
	}
}

- (void) showOverlappingThemeIdAlert
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *saveIdentifier = [self saveThemeIdentifier];

	[alert setAlertStyle: NSWarningAlertStyle];
	[alert setMessageText: [NSString stringWithFormat: PPLocalizedString(@"overlappingThemeIdAlertTitle"), saveIdentifier]];
	[alert setInformativeText: PPLocalizedString(@"overlappingThemeIdAlertMsg")];
	[alert addButtonWithTitle: PPLocalizedString(@"overlappingThemeIdBtn1")];
	[alert addButtonWithTitle: PPLocalizedString(@"overlappingThemeIdBtn2")];
	[alert addButtonWithTitle: PPLocalizedString(@"overlappingThemeIdBtn3")];
	[alert beginSheetModalForWindow: [self themeNamePanel]
					  modalDelegate: self
					 didEndSelector: @selector(overlappingThemeNameAlertDidEnd:returnCode:contextInfo:)
						contextInfo: NULL];
}

- (BOOL) saveThemeCore
{
	id	content = [[self themeGreenCube] content];

	NSString *fileName = [NSString stringWithFormat: @"UserTheme%.0f.plist", [[NSDate date] timeIntervalSince1970]];
	NSString *filePath = [[[self delegate] preferences] createFullPathFromThemeFileName: fileName];

	[content setIdentifier: [self saveThemeIdentifier]];
	if ([content writeToFile: filePath atomically: YES]) {
		[[self delegate] addAndSelectSavedThemeOfTitle: [self saveThemeIdentifier] fileName: fileName];
		return YES;
	} else {
		NSBeep();
		NSLog(@"Failed to save theme file %@", filePath);
		return NO;
	}
}

- (void) doSaveOperation
{
	int myReturnCode = 3;
	[[self themeNamePanel] close];
	if (NO == [self saveThemeCore]) {
		myReturnCode = NSCancelButton;
	}
	[NSApp endSheet: [self window] returnCode: myReturnCode];
}

#pragma mark IBActions
- (IBAction) closePanelAndUseTagForReturnCode: (id) sender
{
	NSWindow *theWindow = [sender window];

	if (theWindow == [self window]) {
		[NSApp endSheet: theWindow returnCode: [sender tag]];
	} else if (theWindow == [self themeNamePanel]) {
		[NSApp stopModalWithCode: [sender tag]];
		if ([sender tag] == NSCancelButton) {
			[theWindow close];
		}
	}
}

- (IBAction) saveTheme: (id) sender
{
	int returnCode = [NSApp runModalForWindow: m_themeNameSheet];
	if (returnCode == NSCancelButton) return;

	if ([self checkIfOverlappingThemeIdentifier]) {
		[self doSaveOperation];
	} else {
		[self showOverlappingThemeIdAlert];
	}
}

- (IBAction) openHelpForEditingCustomTheme: (id) sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : PPLocalizedString(@"Help_View_Edit_Custom_Theme")
											   inBook : [NSBundle applicationHelpBookName]];
}


- (void) overlappingThemeNameAlertDidEnd: (NSAlert *) alert returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn) { // changeName
		[self setSaveThemeIdentifier: nil];
		[[alert window] orderOut: nil];
		[self saveTheme: nil];
		return;
	} else if (returnCode == NSAlertSecondButtonReturn) { // keep name
		[[alert window] orderOut: nil];
		[self doSaveOperation];
	} else { // overWrite
		[[alert window] orderOut: nil];
		id	content = [[self themeGreenCube] content];
		// identifier から上書きすべきファイル名を逆引きして
		NSString *fileName = [self fileNameForIdentifier: [self saveThemeIdentifier]];
		// 上書き保存
		if (fileName) {
			AppDefaults *prefs = [[self delegate] preferences];
			NSString *fullPath = [prefs createFullPathFromThemeFileName: fileName];
			[content setIdentifier: [self saveThemeIdentifier]];
			[content writeToFile: fullPath atomically: YES];
			[prefs setUsesCustomTheme: NO];
			[prefs setThemeFileName: fileName];
		} else {
			NSBeep();
			NSLog(@"Can't find fileName from Identifier %@", [self saveThemeIdentifier]);
		}
		[[self themeNamePanel] close];
		[NSApp endSheet: [self window] returnCode: 3];
	}
}

#pragma mark Public
- (void) beginSheetModalForWindow: (NSWindow *) window
					modalDelegate: (id) delegate
					  contextInfo: (void *) contextInfo
{
	[NSApp beginSheet: [self window]
	   modalForWindow: window
		modalDelegate: delegate
	   didEndSelector: @selector(themeEditSheetDidEnd:returnCode:contextInfo:) 
		  contextInfo: contextInfo];
}

#pragma mark NSFontPanel Validation
- (unsigned int) validModesForFontPanel : (NSFontPanel *) fontPanel
{
	return [[self delegate] validModesForFontPanel: fontPanel];
}
@end
