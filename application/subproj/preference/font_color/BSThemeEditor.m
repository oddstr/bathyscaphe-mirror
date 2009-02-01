//
//  BSThemeEditor.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/04/22.
//  Copyright 2007-2009 BathyScaphe Project. All rights reserved.
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
	[self setSaveThemeIdentifier:nil];
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

- (BOOL)isNewTheme
{
	return m_isNewTheme;
}

- (void)setIsNewTheme:(BOOL)flag
{
	m_isNewTheme = flag;
}

- (NSString *)themeFileName
{
	return m_fileName;
}

- (void)setThemeFileName:(NSString *)filename
{
	[filename retain];
	[m_fileName release];
	m_fileName = filename;
}

- (NSObjectController *) themeGreenCube
{
	return m_themeGreenCube;
}

#pragma mark Utilities
- (BOOL)checkIfOverlappingThemeIdentifier
{
	if ([[self saveThemeIdentifier] isEqualToString:[[[self themeGreenCube] content] identifier]]) {
		return YES;
	}

	NSArray *array = [[[self delegate] preferences] installedThemes];
	NSArray *identifiers = [array valueForKey: @"Identifier"];
	if (!identifiers || ![identifiers containsObject: [self saveThemeIdentifier]]) { // 重複していない
		return YES;
	} else {
		if ([self isNewTheme]) {
			return NO;
		}
		unsigned int idx = [[array valueForKey:@"FileName"] indexOfObject:[self themeFileName]];
		if (idx == NSNotFound) { // 重複していない
			return YES;
		}
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

- (BOOL) saveThemeCore
{
	NSString *fileName;
	id	content = [[self themeGreenCube] content];
//	NSString *foo = [self fileNameForIdentifier:[content identifier]];

	if ([self themeFileName]) {
		fileName = [self themeFileName];
	} else {
		fileName = [NSString stringWithFormat: @"UserTheme%.0f.plist", [[NSDate date] timeIntervalSince1970]];
		[self setThemeFileName:fileName];
	}
	NSString *filePath = [[[self delegate] preferences] createFullPathFromThemeFileName: fileName];

	[content setIdentifier: [self saveThemeIdentifier]];
	if ([content writeToFile: filePath atomically: YES]) {
//		[[self delegate] addAndSelectSavedThemeOfTitle: [self saveThemeIdentifier] fileName: fileName];
		return YES;
	} else {
		NSBeep();
		NSLog(@"Failed to save theme file %@", filePath);
		return NO;
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
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		if ([self saveThemeCore]) {
			[NSApp endSheet:[self window] returnCode:NSOKButton];
		}
	};
}

/*- (void) doSaveOperation
{
	int myReturnCode = 3;
//	[[self themeNamePanel] close];
	if (NO == [self saveThemeCore]) {
		myReturnCode = NSCancelButton;
	}
	[NSApp endSheet: [self window] returnCode: myReturnCode];
}*/

#pragma mark IBActions
- (IBAction) closePanelAndUseTagForReturnCode: (id) sender
{
/*	NSWindow *theWindow = [sender window];

	if (theWindow == [self window]) {
		[NSApp endSheet: theWindow returnCode: [sender tag]];*/
/*	} else if (theWindow == [self themeNamePanel]) {
		[NSApp stopModalWithCode: [sender tag]];
		if ([sender tag] == NSCancelButton) {
			[theWindow close];
		}*/
//	}
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (IBAction) saveTheme: (id) sender
{
//	int returnCode = [NSApp runModalForWindow: m_themeNameSheet];
//	if (returnCode == NSCancelButton) return;

	if ([self checkIfOverlappingThemeIdentifier] && [self saveThemeCore]) {
		[NSApp endSheet:[self window] returnCode:NSOKButton];
	} else {
		[self showOverlappingThemeIdAlert];
	}
}

- (IBAction) openHelpForEditingCustomTheme: (id) sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : PPLocalizedString(@"Help_View_Edit_Custom_Theme")
											   inBook : [NSBundle applicationHelpBookName]];
}


/*- (void) overlappingThemeNameAlertDidEnd: (NSAlert *) alert returnCode: (int) returnCode contextInfo: (void *) contextInfo
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
//		[[self themeNamePanel] close];
		[NSApp endSheet: [self window] returnCode: 3];
	}
}*/

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
