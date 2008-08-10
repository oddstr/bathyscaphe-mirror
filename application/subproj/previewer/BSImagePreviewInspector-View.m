//
//  BSImagePreviewInspector-View.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/15.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSImagePreviewInspector.h"
#import "BSIPITextFieldCell.h"
#import "BSIPIImageView.h"
#import <SGAppKit/NSCell-SGExtensions.h>

static NSString *const kIPIFrameAutoSaveNameKey	= @"BathyScaphe:ImagePreviewInspector Panel Autosave";

@implementation BSImagePreviewInspector(ViewAccessor)
- (NSPopUpButton *)actionBtn
{
	return m_actionBtn;
}

- (NSTextField *)infoField
{
	return m_infoField;
}

- (NSImageView *)imageView
{
	return m_imageView;
}

- (NSProgressIndicator *)progIndicator
{
	return m_progIndicator;
}

- (NSSegmentedControl *)cacheNavigationControl
{
	return m_cacheNaviBtn;
}

- (NSTabView *)tabView
{
	return m_tabView;
}

- (NSSegmentedControl *)paneChangeBtn
{
	return m_paneChangeBtn;
}

- (NSTableColumn *)nameColumn
{
	return m_nameColumn;
}

- (NSMenu *)cacheNaviMenuFormRep
{
	return m_cacheNaviMenuFormRep;
}

- (BSIPIArrayController *)tripleGreenCubes
{
	return m_tripleGreenCubes;
}

#pragma mark Setup UIs
- (void)setupWindow
{
	NSWindow	*window_ = [self window];

	[window_ setFrameAutosaveName:kIPIFrameAutoSaveNameKey];
	[window_ setDelegate:self];
	[(NSPanel *)window_ setBecomesKeyOnlyIfNeeded:(![self alwaysBecomeKey])];
	[(NSPanel *)window_ setFloatingPanel:[self floating]];
	[window_ setAlphaValue:[self alphaValue]];
	[window_ useOptimizedDrawing:YES];
}

- (void)setupTableView
{
	BSIPITextFieldCell	*cell;
	NSTableView	*tableView = [[self nameColumn] tableView];

	cell = [[BSIPITextFieldCell alloc] initTextCell:@""];
	[cell setAttributesFromCell:[[self nameColumn] dataCell]];
	[[self nameColumn] setDataCell:cell];
	[cell release];

	[tableView setDataSource:[BSIPIHistoryManager sharedManager]];
	[tableView setDoubleAction:@selector(changePaneAndShow:)];
	[tableView setVerticalMotionCanBeginDrag:NO];
}

- (void)setupControls
{
	NSMenuItem	*iter;

	iter = [[[self actionBtn] menu] itemAtIndex:0];
	[iter setImage:[self imageResourceWithName:@"Gear"]];

	[[[self actionBtn] cell] setUsesItemFromMenu:YES];

	// Leopard
	if ([iter respondsToSelector:@selector(setHidden:)]) {
		[iter setHidden:YES];
	}

	[[self paneChangeBtn] setLabel:nil forSegment:0];
	[[self paneChangeBtn] setLabel:nil forSegment:1];

	[[self cacheNavigationControl] setLabel:nil forSegment:0];
	[[self cacheNavigationControl] setLabel:nil forSegment:1];
	
	[(BSIPIImageView *)[self imageView] setFocusRingType:NSFocusRingTypeNone];
	[(BSIPIImageView *)[self imageView] setDelegate:self];
	[(BSIPIImageView *)[self imageView] setBackgroundColor:[NSColor blackColor]];
	
	int	tabIndex = [self preferredView];
	if (tabIndex == -1) {
		tabIndex = [self lastShownViewTag];
	}
	[[self tabView] selectTabViewItemAtIndex:tabIndex];
	[[self paneChangeBtn] setSelectedSegment:tabIndex];
}

- (void)windowDidLoad
{
	[self setupWindow];
	[self setupTableView];
	[self setupControls];
	[self setupToolbar];
}
@end

@implementation BSImagePreviewInspector(Preferences)
- (NSPanel *)settingsPanel
{
	return m_settingsPanel;
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
		[self setSaveDirectory:[panel_ directory]];
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
					modalForWindow:[self settingsPanel]
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
	NSString	*fullPathTip = [self saveDirectory];
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
	if ([self settingsPanel]) {
		[self setupSettingsPanel];
	}
}
@end
