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
- (id)init
{
	if (self = [super initWithWindowNibName:@"ThemeEditor"]) {
		[self window];
	}
	return self;
}

- (void)dealloc
{
	m_delegate = nil;
	[self setSaveThemeIdentifier:nil];
	[self setThemeFileName:nil];
	[super dealloc];
}

#pragma mark Accessors
- (id)delegate
{
	return m_delegate;
}

- (void)setDelegate:(id)aDelegate
{
	m_delegate = aDelegate;
}

- (NSString *)saveThemeIdentifier
{
	return m_saveThemeIdentifier;
}

- (void)setSaveThemeIdentifier:(NSString *)aString
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

- (NSObjectController *)themeGreenCube
{
	return m_themeGreenCube;
}

#pragma mark Utilities
- (BOOL)checkIfOverlappingThemeIdentifier
{
	if ([[self saveThemeIdentifier] isEqualToString:[[[self themeGreenCube] content] identifier]]) {
		return YES;
	}

	NSMutableArray *identifiers = [NSMutableArray array];
	NSMutableArray *fileNames = [NSMutableArray array];
	[[[self delegate] preferences] getInstalledThemeIds:&identifiers fileNames:&fileNames];

	if (![identifiers containsObject:[self saveThemeIdentifier]]) { // 重複していない
		return YES;
	} else {
		if ([self isNewTheme]) {
			return NO;
		}
		unsigned int idx = [fileNames indexOfObject:[self themeFileName]];
		if (idx == NSNotFound) { // 重複していない
			return YES;
		}
		return NO;
	}
}

- (NSString *)fileNameForIdentifier:(NSString *)identifier
{
	NSMutableArray *ids = [NSMutableArray array];
	NSMutableArray *fileNames = [NSMutableArray array];
	[[[self delegate] preferences] getInstalledThemeIds:&ids fileNames:&fileNames];

	unsigned idx = [ids indexOfObject:identifier];
	if (idx != NSNotFound) {
		return [fileNames objectAtIndex:idx];
	} else {
		return nil;
	}
}

- (BOOL)saveThemeCore
{
	NSString *fileName;
	id	content = [[self themeGreenCube] content];

	if ([self themeFileName]) {
		fileName = [self themeFileName];
	} else {
		fileName = [NSString stringWithFormat:@"UserTheme%.0f.plist", [[NSDate date] timeIntervalSince1970]];
		[self setThemeFileName:fileName];
	}
	NSString *filePath = [[[self delegate] preferences] createFullPathFromThemeFileName:fileName];

	[content setIdentifier:[self saveThemeIdentifier]];
	NSError *theError;
	if ([content writeToFile:filePath options:NSAtomicWrite error:&theError]) {
		return YES;
	} else {
		[[NSAlert alertWithError:theError] runModal];
		return NO;
	}
}

- (void)showOverlappingThemeIdAlert
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *saveIdentifier = [self saveThemeIdentifier];

	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:[NSString stringWithFormat: PPLocalizedString(@"overlappingThemeIdAlertTitle"), saveIdentifier]];
	[alert setInformativeText:PPLocalizedString(@"overlappingThemeIdAlertMsg")];
	[alert addButtonWithTitle:PPLocalizedString(@"overlappingThemeIdBtn1")];
	[alert addButtonWithTitle:PPLocalizedString(@"overlappingThemeIdBtn2")];
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		if ([self saveThemeCore]) {
			[NSApp endSheet:[self window] returnCode:NSOKButton];
		}
	}
}

#pragma mark IBActions
- (IBAction)closePanelAndUseTagForReturnCode:(id)sender
{
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (IBAction)saveTheme:(id)sender
{
	[[self themeGreenCube] commitEditing];

	if ([self checkIfOverlappingThemeIdentifier]) {
		if ([self saveThemeCore]) {
			[NSApp endSheet:[self window] returnCode:NSOKButton];
		}
	} else {
		[self showOverlappingThemeIdAlert];
	}
}

- (IBAction)openHelpForEditingCustomTheme:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:PPLocalizedString(@"Help_View_Edit_Custom_Theme")
											   inBook:[NSBundle applicationHelpBookName]];
}

#pragma mark Public
- (void)beginSheetModalForWindow:(NSWindow *)window
				   modalDelegate:(id)delegate
					 contextInfo:(void *)contextInfo
{
	[NSApp beginSheet:[self window]
	   modalForWindow:window
		modalDelegate:delegate
	   didEndSelector:@selector(themeEditSheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:contextInfo];
}

#pragma mark NSFontPanel Validation
- (unsigned int)validModesForFontPanel:(NSFontPanel *)fontPanel
{
	return [[self delegate] validModesForFontPanel:fontPanel];
}
@end
