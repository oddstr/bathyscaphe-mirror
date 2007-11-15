//
//  LinkPrefController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/14.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "LinkPrefController.h"
#import "PreferencePanes_Prefix.h"

@implementation LinkPrefController
- (NSString *)mainNibName
{
	return @"LinkPreferences";
}

#pragma mark IBActions
- (void)didEndChooseFolderSheet:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		NSString	*folderPath_;

		folderPath_ =	[sheet directory];
		[[self preferences] setLinkDownloaderDestination:folderPath_];
	}
	[self updateFolderButtonUI];
}

- (IBAction)chooseDestination:(id)sender
{
	NSOpenPanel	*panel_ = [NSOpenPanel openPanel];
	[panel_ setCanChooseFiles:NO];
	[panel_ setCanChooseDirectories:YES];
	[panel_ setResolvesAliases:YES];
	[panel_ setAllowsMultipleSelection:NO];
	
	[panel_ beginSheetForDirectory:nil
							  file: nil
							 types:nil
					modalForWindow:[self window]
					 modalDelegate:self
					didEndSelector:@selector(didEndChooseFolderSheet:returnCode:contextInfo:)
					   contextInfo:nil];
}

- (IBAction)openPreviewerPrefs:(id)sender
{
	[[self preferences] letPreviewerShowPreferences:sender];
}

#pragma mark Accessors
- (NSPopUpButton *)downloadDestinationChooser
{
	return m_downloadDestinationChooser;
}

- (NSTextField *)previewerNameField
{
	return m_previewerNameField;
}

- (NSTextField *)previewerIdField
{
	return m_previewerIdField;
}

- (int)previewOption
{
	return [[self preferences] previewLinkWithNoModifierKey] ? 0 : 1;
}

- (void)setPreviewOption:(int)selectedTag
{
	BOOL	tmp_ = (selectedTag == 0) ? YES : NO;
	[[self preferences] setPreviewLinkWithNoModifierKey:tmp_];
}

#pragma mark Setting up UIs
- (void)updateFolderButtonUI
{
	NSString	*fullPath = [[self preferences] linkDownloaderDestination];
	NSString	*displayTitle = [[NSFileManager defaultManager] displayNameAtPath:fullPath];
	NSImage		*icon = [[NSWorkspace sharedWorkspace] iconForFile:fullPath];
	NSMenuItem	*theItem = [[self downloadDestinationChooser] itemAtIndex:0];

	[icon setSize:NSMakeSize(16,16)];

	[theItem setTitle:displayTitle];
	[theItem setToolTip:fullPath];
	[theItem setImage:icon];

	[[self downloadDestinationChooser] selectItem:nil];
	[[self downloadDestinationChooser] synchronizeTitleAndSelectedItem];
}

- (void)updatePreviewerFields
{
	NSBundle *info = [[self preferences] installedPreviewerBundle];
	NSString *displayName = [info objectForInfoDictionaryKey:@"BSPreviewerDisplayName"];
	if (!displayName) {
		displayName = [info objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	}
	BOOL	hoge = [[info bundlePath] hasPrefix:[[NSBundle mainBundle] builtInPlugInsPath]];
	
	NSString *bar = hoge ? PPLocalizedString(@"Built-in") : PPLocalizedString(@"Custom");

	NSString *foo = [NSString stringWithFormat:PPLocalizedString(@"PreviewerDisplayName"),
						displayName , bar, [info objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	[[self previewerNameField] setStringValue:foo];
	[[self previewerIdField] setStringValue:[info objectForInfoDictionaryKey:@"NSHumanReadableCopyright"]];
}

- (void)updateUIComponents
{
	[self updateFolderButtonUI];
	[self updatePreviewerFields];
}

- (void)setupUIComponents
{
	if (!_contentView) return;
	[self updateUIComponents];
}


#pragma mark NSTableView Delegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSString *str = [fieldEditor string];
	if ([str isEqualToString: @""]) {
		NSBeep();
		return NO;
	}
	return YES;
}
@end


@implementation LinkPrefController(Toolbar)
- (NSString *)identifier
{
	return @"Link";
}
- (NSString *)helpKeyword
{
	return PPLocalizedString(@"Help_Link");
}
- (NSString *)label
{
	return PPLocalizedString(@"Link Label");
}
- (NSString *)paletteLabel
{
	return PPLocalizedString(@"Link Label");
}
- (NSString *)toolTip
{
	return PPLocalizedString(@"Link ToolTip");
}
- (NSString *)imageName
{
	return @"LinkPreferences";
}
@end
