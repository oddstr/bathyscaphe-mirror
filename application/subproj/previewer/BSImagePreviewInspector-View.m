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
#import "BSIPIDefaults.h"
#import <SGFoundation/NSDictionary-SGExtensions.h>
#import <SGFoundation/NSMutableDictionary-SGExtensions.h>
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
	[(NSPanel *)window_ setBecomesKeyOnlyIfNeeded:(![[BSIPIDefaults sharedIPIDefaults] alwaysBecomeKey])];
	[(NSPanel *)window_ setFloatingPanel:[[BSIPIDefaults sharedIPIDefaults] floating]];
	[window_ setAlphaValue:[[BSIPIDefaults sharedIPIDefaults] alphaValue]];
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
	[(BSIPIImageView *)[self imageView] setBackgroundColor:[NSColor lightGrayColor]];
	
	int	tabIndex = [[BSIPIDefaults sharedIPIDefaults] preferredView];
	if (tabIndex == -1) {
		tabIndex = [[BSIPIDefaults sharedIPIDefaults] lastShownViewTag];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == kBSIPIDefaultsContext) {
		if ([keyPath isEqualToString:@"alwaysBecomeKey"]) {
			BOOL newFlag = [change boolForKey:NSKeyValueChangeNewKey];
			[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:!newFlag];
			return;
		} else if ([keyPath isEqualToString:@"floating"]) {
			BOOL newFlag = [change boolForKey:NSKeyValueChangeNewKey];
			[(NSPanel *)[self window] setFloatingPanel:newFlag];
			return;
		} else if ([keyPath isEqualToString:@"alphaValue"]) {
			float newValue = [change floatForKey:NSKeyValueChangeNewKey];
			[[self window] setAlphaValue:newValue];
			return;
		}
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
@end
