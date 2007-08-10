//
//  AdvancedPrefController.m
//  BachyScaphe
//
//  Created by Tsutomu Sawada on 05/05/22.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "AdvancedPrefController.h"
#import "PreferencePanes_Prefix.h"

static NSString *const kAdvancedPaneLabelKey = @"Advanced Label";
static NSString *const kAdvancedPaneToolTipKey = @"Advanced ToolTip";
static NSString *const kAdvancedPaneIconKey = @"AdvancedPreferences";
static NSString *const kAdvancedPaneHelpAnchorKey = @"Help_Advanced";


@implementation AdvancedPrefController
- (NSString *)mainNibName
{
	return @"AdvancedPane";
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

- (void)didEndExtensionsEditor:(NSPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet close];
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

- (IBAction)openSheet:(id)sender
{
	[NSApp beginSheet:[self extensionsEditor]
	   modalForWindow:[self window]
	    modalDelegate:self
	   didEndSelector:@selector(didEndExtensionsEditor:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (IBAction)closeSheet:(id)sender
{
	[NSApp endSheet:[self extensionsEditor] returnCode:NSOKButton];
}

#pragma mark Accessors
- (NSPopUpButton *)dlFolderBtn
{
	return m_dlFolderBtn;
}

- (NSButton *)openSheetBtn
{
	return m_openSheetBtn;
}

- (NSPanel *)extensionsEditor
{
	return m_extensionsEditor;
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
	NSMenuItem	*theItem = [[self dlFolderBtn] itemAtIndex:0];

	[icon setSize:NSMakeSize(16,16)];

	[theItem setTitle:displayTitle];
	[theItem setToolTip:fullPath];
	[theItem setImage:icon];

	[[self dlFolderBtn] selectItem:nil];
	[[self dlFolderBtn] synchronizeTitleAndSelectedItem];
}

- (void)updateUIComponents
{
	[self updateFolderButtonUI];
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

@implementation AdvancedPrefController(Toolbar)
- (NSString *)identifier
{
	return PPAdvancedPreferencesIdentifier;
}
- (NSString *)helpKeyword
{
	return PPLocalizedString(kAdvancedPaneHelpAnchorKey);
}
- (NSString *)label
{
	return PPLocalizedString(kAdvancedPaneLabelKey);
}
- (NSString *)paletteLabel
{
	return PPLocalizedString(kAdvancedPaneLabelKey);
}
- (NSString *)toolTip
{
	return PPLocalizedString(kAdvancedPaneToolTipKey);
}
- (NSString *)imageName
{
	return kAdvancedPaneIconKey;
}
@end

