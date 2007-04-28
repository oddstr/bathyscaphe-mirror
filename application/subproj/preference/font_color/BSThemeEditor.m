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

#pragma mark IBActions
- (IBAction) closePanelAndUseTagForReturnCode: (id) sender
{
	if ([sender window] == [self window]) {
		[NSApp endSheet: [sender window] returnCode: [sender tag]];
	} else if ([sender window] == [self themeNamePanel]) {
		[NSApp stopModalWithCode: [sender tag]];
		if ([sender tag] == NSCancelButton)[[sender window] close];
	}
}

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
	
- (NSString *) createNewThemeFileFullPath: (NSString *) fileName
{
	return [[[[CMRFileManager defaultManager] supportDirectoryWithName: BSThemesDirectory] filepath] stringByAppendingPathComponent: fileName];
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

- (void) overlappingThemeNameAlertDidEnd: (NSAlert *) alert returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn) { // changeName
		[self setSaveThemeIdentifier: nil];
		[[alert window] orderOut: nil];
		[self saveTheme: nil];
		return;
	} else if (returnCode == NSAlertSecondButtonReturn) { // keep name
		BOOL hoge = [self saveThemeCore];
		[[alert window] orderOut: nil];
		[[self themeNamePanel] close];
		[NSApp endSheet: [self window] returnCode: (hoge ? 3 : NSCancelButton)];
	} else { // overWrite
		id	content = [[self themeGreenCube] content];
		// identifier から上書きすべきファイル名を逆引きして
		NSString *fileName = [self fileNameForIdentifier: [content identifier]];
		// 上書き保存
		if (fileName) {
			[content writeToFile: [self createNewThemeFileFullPath: fileName] atomically: YES];
			[[self themeNamePanel] close];
			[[[self delegate] preferences] setUsesCustomTheme: NO];
			[[[self delegate] preferences] setThemeFileName: fileName];
			[NSApp endSheet: [self window] returnCode: 3];
		}
	}
}

- (BOOL) saveThemeCore
{
	id	content = [[self themeGreenCube] content];

	NSString *fileName = [NSString stringWithFormat: @"UserTheme%.0f.plist", [[NSDate date] timeIntervalSince1970]];
	NSString *filePath = [self createNewThemeFileFullPath: fileName];

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

- (IBAction) saveTheme: (id) sender
{
	int returnCode = [NSApp runModalForWindow: m_themeNameSheet];

	if (returnCode == NSCancelButton) return;

	if ([self checkIfOverlappingThemeIdentifier]) {
		int myReturnCode = 3;
		[[self themeNamePanel] close];
		if (NO == [self saveThemeCore]) {
			myReturnCode = NSCancelButton;
		}
		[NSApp endSheet: [self window] returnCode: myReturnCode];
	} else {
		[self showOverlappingThemeIdAlert];
	}
}

- (IBAction) openHelpForEditingCustomTheme: (id) sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : PPLocalizedString(@"Help_View_Edit_Custom_Theme")
											   inBook : [NSBundle applicationHelpBookName]];
}

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
@end
