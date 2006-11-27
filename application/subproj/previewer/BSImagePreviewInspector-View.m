//
//  $Id: BSImagePreviewInspector-View.m,v 1.3.2.6 2006/11/27 16:16:15 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/15.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSImagePreviewInspector.h"
#import "BSIPITextFieldCell.h"
#import "BSIPIImageView.h"
#import <SGAppKit/NSCell-SGExtensions.h>

static NSString *const kIPIFrameAutoSaveNameKey	= @"BathyScaphe:ImagePreviewInspector Panel Autosave";

@implementation BSImagePreviewInspector(ViewAccessor)
- (NSPopUpButton *) actionBtn
{
	return m_actionBtn;
}

- (NSTextField *) infoField
{
	return m_infoField;
}

- (NSImageView *) imageView
{
	return m_imageView;
}

- (NSProgressIndicator *) progIndicator
{
	return m_progIndicator;
}

- (NSPanel *) settingsPanel
{
	return m_settingsPanel;
}

- (NSSegmentedControl *) cacheNavigationControl
{
	return m_cacheNaviBtn;
}

- (NSTabView *) tabView
{
	return m_tabView;
}
- (NSSegmentedControl *) paneChangeBtn
{
	return m_paneChangeBtn;
}
- (NSTableColumn *) nameColumn
{
	return m_nameColumn;
}
- (NSPopUpButton *) directoryChooser
{
	return m_directoryChooser;
}
- (NSTextField *) versionInfoField
{
	return m_versionInfoField;
}
- (NSMenu *) cacheNaviMenuFormRep
{
	return m_cacheNaviMenuFormRep;
}
- (NSSegmentedControl *) preferredViewSelector
{
	return m_preferredViewSelector;
}
- (NSArrayController *) tripleGreenCubes
{
	return m_tripleGreenCubes;
}

#pragma mark -
static NSImage *bsIPI_iconForPath(NSString *sourcePath)
{
	NSImage	*icon_ = [[NSWorkspace sharedWorkspace] iconForFile : sourcePath];
	[icon_ setSize : NSMakeSize(16, 16)];
	return icon_;
}

- (void) updateDirectoryChooser
{
	NSString	*fullPathTip = [self saveDirectory];
	NSString	*title = [[NSFileManager defaultManager] displayNameAtPath: fullPathTip];
	id<NSMenuItem>	theItem = [[self directoryChooser] itemAtIndex : 0];
	
	[theItem setTitle : title];
	[theItem setToolTip: fullPathTip];
	[theItem setImage : bsIPI_iconForPath(fullPathTip)];

	[[self directoryChooser] selectItem : nil];
	[[self directoryChooser] synchronizeTitleAndSelectedItem];
}

- (void) setupWindow
{
	NSWindow	*window_ = [self window];
	
	[window_ setFrameAutosaveName : kIPIFrameAutoSaveNameKey];
	[window_ setDelegate : self];
	[(NSPanel *)window_ setBecomesKeyOnlyIfNeeded : (NO == [self alwaysBecomeKey])];
	[(NSPanel *)window_ setFloatingPanel: [self floating]];
	[window_ setAlphaValue : [self alphaValue]];
	[window_ useOptimizedDrawing: YES];
}

- (void) setupTableView
{
	BSIPITextFieldCell	*cell;

	cell = [[BSIPITextFieldCell alloc] initTextCell: @""];
	[cell setAttributesFromCell: [[self nameColumn] dataCell]];
	[[self nameColumn] setDataCell: cell];
	[cell release];

	[[[self nameColumn] tableView] setDataSource: [BSIPIHistoryManager sharedManager]];
	[[[self nameColumn] tableView] setDoubleAction: @selector(changePaneAndShow:)];
}

- (void) setupControls
{
	id<NSMenuItem>	iter;

	iter = [[[self actionBtn] menu] itemAtIndex : 0];
	[iter setImage : [self imageResourceWithName: @"Gear"]];

	[[self paneChangeBtn] setLabel: nil forSegment: 0];
	[[self paneChangeBtn] setLabel: nil forSegment: 1];
	[[self cacheNavigationControl] setLabel: nil forSegment: 0];
	[[self cacheNavigationControl] setLabel: nil forSegment: 1];
	[[self preferredViewSelector] setLabel: nil forSegment: 0];
	[[self preferredViewSelector] setLabel: nil forSegment: 1];
	
	[(BSIPIImageView *)[self imageView] setDelegate: self];

	int	tabIndex = [self preferredView];
	if (tabIndex == -1)
		tabIndex = [self lastShownViewTag];

	[[self tabView] selectTabViewItemAtIndex: tabIndex];
	[[self paneChangeBtn] setSelectedSegment: tabIndex];
}

- (void) setupVersionInfoField
{
	NSBundle *myself = [NSBundle bundleForClass: [self class]];
	if (!myself) return;
	
	NSString *versionNum = [myself objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
	if (!versionNum) return;
	
	[[self versionInfoField] setStringValue: versionNum];
}

- (void) awakeFromNib
{
	[self setupWindow];
	[self setupTableView];
	[self setupControls];
	[self setupVersionInfoField];
	[self setupToolbar];
}
@end
