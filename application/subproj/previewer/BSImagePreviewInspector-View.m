//
//  $Id: BSImagePreviewInspector-View.m,v 1.3.2.2 2006/08/07 19:19:24 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/15.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSImagePreviewInspector.h"
#import "BSIPIHistoryManager.h"
#import "BSIPITextFieldCell.h"
#import "BSIPIImageView.h"
#import "BSIPIAppKitExtensions.h"

@class BSIPIDownload;

static NSString *const kIPIFrameAutoSaveNameKey	= @"BathyScaphe:ImagePreviewInspector Panel Autosave";
static NSString *const kIPIMenuItemForOldBSKey	= @"IPIWindowsMenuItemForOldBS";

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

- (BSIPIDownload *) currentDownload
{
	return _currentDownload;
}
- (void) setCurrentDownload : (BSIPIDownload *) aDownload
{
	[aDownload retain];
	[_currentDownload release];
	_currentDownload = aDownload;
}

- (TemporaryFolder *) dlFolder
{
	if (_dlFolder == nil) {
		_dlFolder = [[TemporaryFolder alloc] init];
	}
	return _dlFolder;
}

#pragma mark -
- (void) clearAttributes
{
	if(_currentDownload) {
		[_currentDownload cancel];
		[self setCurrentDownload : nil];
		[self stopProgressIndicator];
	}
	
	[self setSourceURL: nil];
	[[self infoField] setStringValue: @""];
	[[self imageView] setImage: nil];
	[self synchronizeImageAndSelectedRow];
}

- (void) synchronizeImageAndSelectedRow
{
	unsigned idx = [[BSIPIHistoryManager sharedManager] indexOfURL: [self sourceURL]];
	if (idx == NSNotFound) {
		[[[self nameColumn] tableView] deselectAll: nil];
	} else {
		[[[self nameColumn] tableView] selectRowIndexes: [NSIndexSet indexSetWithIndex: idx] byExtendingSelection: NO];
		[[[self nameColumn] tableView] scrollRowToVisible: idx];
	}
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

// WARNING: ONLY FOR BATHYSCAPHE 1.1.x - 1.2.x
- (void) setupMenu
{
	NSMenuItem	*cometBlasterItem;
	NSMenu		*windowsMenu;

	cometBlasterItem = [[[NSMenuItem alloc] initWithTitle: [self localizedStrForKey: kIPIMenuItemForOldBSKey]
												   action: @selector(togglePreviewPanel:)
											keyEquivalent: @"y"] autorelease];
	[cometBlasterItem setTarget: self];
	//[cometBlasterItem setKeyEquivalentModifierMask: (NSCommandKeyMask|NSAlternateKeyMask)];
	
	windowsMenu = [[[NSApp mainMenu] itemWithTag: 6] submenu];
	[windowsMenu insertItem: cometBlasterItem atIndex: 6];
}

- (void) setupMenuIfNeeded
{
	NSBundle *bathyScaphe_ = [NSBundle mainBundle];
	if (!bathyScaphe_) return;
	
	NSString *version_ = [bathyScaphe_ objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
	
	if ([version_ hasPrefix: @"1.2"] || [version_ hasPrefix: @"1.1"]) {
		// install menu item into Windows Menu
		[self setupMenu];
	}
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
	
	[(BSIPIImageView *)[self imageView] setDelegate: self];
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
	[self setupMenuIfNeeded];
	[self setupTableView];
	[self setupControls];
	[self setupVersionInfoField];
	[self setupToolbar];
}
@end
