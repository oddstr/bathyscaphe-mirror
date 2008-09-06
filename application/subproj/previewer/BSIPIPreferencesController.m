//
//  BSIPIPreferencesController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/08/31.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSIPIPreferencesController.h"
#import "BSIPIDefaults.h"
#import <CocoMonar/CMRSingletonObject.h>


@implementation BSIPIPreferencesController
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedPreferencesController);

- (id)init
{
	if (self = [super initWithWindowNibName:@"BSIPIPreferences"]) {
		;
	}
	return self;
}

- (NSPopUpButton *)directoryChooser
{
	return m_directoryChooser;
}

- (NSSegmentedControl *)preferredViewSelector
{
	return m_preferredViewSelector;
}

- (NSMatrix *)fullScreenSettingMatrix
{
	return m_fullScreenSettingMatrix;
}

- (void)didEndChooseFolderSheet:(NSOpenPanel *)panel_ returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		[[BSIPIDefaults sharedIPIDefaults] setSaveDirectory:[panel_ directory]];
	}
	[self updateDirectoryChooser];
}

- (IBAction)openOpenPanel:(id)sender
{
	NSOpenPanel	*panel_ = [NSOpenPanel openPanel];
	[panel_ setCanChooseFiles:NO];
	[panel_ setCanChooseDirectories:YES];
	[panel_ setResolvesAliases:YES];
	[panel_ setAllowsMultipleSelection:NO];
	[panel_ beginSheetForDirectory:nil
							  file:nil
							 types:nil
					modalForWindow:[self window]
					 modalDelegate:self
					didEndSelector:@selector(didEndChooseFolderSheet:returnCode:contextInfo:)
					   contextInfo:nil];
}

static NSImage *bsIPI_iconForPath(NSString *sourcePath)
{
	NSImage	*icon_ = [[NSWorkspace sharedWorkspace] iconForFile:sourcePath];
	[icon_ setSize:NSMakeSize(16, 16)];
	return icon_;
}

- (void)updateDirectoryChooser
{
	NSString	*fullPathTip = [[BSIPIDefaults sharedIPIDefaults] saveDirectory];
	NSString	*title = [[NSFileManager defaultManager] displayNameAtPath:fullPathTip];
	NSMenuItem	*theItem = [[self directoryChooser] itemAtIndex:0];
	
	[theItem setTitle:title];
	[theItem setToolTip:fullPathTip];
	[theItem setImage:bsIPI_iconForPath(fullPathTip)];

	[[self directoryChooser] selectItem:nil];
	[[self directoryChooser] synchronizeTitleAndSelectedItem];
}

- (void)setupSettingsPanel
{
	if (floor(NSAppKitVersionNumber) <= 824) {
		[[self fullScreenSettingMatrix] setEnabled:NO];
	}

	[[self preferredViewSelector] setLabel:nil forSegment:0];
	[[self preferredViewSelector] setLabel:nil forSegment:1];
}

- (void)awakeFromNib
{
	[m_defaultsController setContent:[BSIPIDefaults sharedIPIDefaults]];
	[self updateDirectoryChooser];
	[self setupSettingsPanel];
}
@end
