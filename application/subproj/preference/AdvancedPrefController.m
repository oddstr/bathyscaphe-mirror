//
//  AdvancedPrefController.m
//  BachyScaphe
//
//  Created by Tsutomu Sawada on 05/05/22.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import <CocoMonar/CocoMonar.h>
#import "AdvancedPrefController.h"
#import "PreferencePanes_Prefix.h"

#define kLabelKey		@"Advanced Label"
#define kToolTipKey		@"Advanced ToolTip"
#define kImageName		@"AdvancedPreferences"


@implementation AdvancedPrefController
- (NSString *) mainNibName
{
	return @"AdvancedPane";
}

#pragma mark -
- (void)didEndChooseFolderSheet:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		NSString	*folderPath_;

		folderPath_ =	[sheet directory];
		[[self preferences] setLinkDownloaderDestination:folderPath_];
	}
	[self updateHelperAppUI];
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

- (void)extensionsEditorDidEnd:(NSPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet close];
}

- (IBAction)openSheet:(id)sender
{
	[NSApp beginSheet:[self extensionsEditor]
	   modalForWindow:[self window]
	    modalDelegate:self
	   didEndSelector:@selector(extensionsEditorDidEnd:returnCode:contextInfo:)
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
static NSImage *advancedPref_iconForPath(NSString *sourcePath)
{
	NSImage	*icon_ = [[NSWorkspace sharedWorkspace] iconForFile:sourcePath];
	[icon_ setSize:NSMakeSize(16, 16)];
	return icon_;
}

- (void)updateHelperAppUI
{
	NSString	*fullPathTip = [[self preferences] linkDownloaderDestination];
	NSString	*title = [[NSFileManager defaultManager] displayNameAtPath:fullPathTip];
	id<NSMenuItem>	theItem = [[self dlFolderBtn] itemAtIndex:0];

	[theItem setTitle:title];
	[theItem setToolTip:fullPathTip];
	[theItem setImage:advancedPref_iconForPath(fullPathTip)];

	[[self dlFolderBtn] selectItem:nil];
	[[self dlFolderBtn] synchronizeTitleAndSelectedItem];
}

- (void)updateUIComponents
{
	[self updateHelperAppUI];
}

- (void)setupUIComponents
{
	if (!_contentView) return;
	[self updateUIComponents];
}
@end

@implementation AdvancedPrefController(Toolbar)
- (NSString *) identifier
{
	return PPAdvancedPreferencesIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(@"Help_Advanced");
}
- (NSString *) label
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) paletteLabel
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) toolTip
{
	return PPLocalizedString(kToolTipKey);
}
- (NSString *) imageName
{
	return kImageName;
}
@end

