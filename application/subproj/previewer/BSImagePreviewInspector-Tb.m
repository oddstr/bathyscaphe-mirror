/*
 * $Id: BSImagePreviewInspector-Tb.m,v 1.18 2007/11/13 01:58:39 tsawada2 Exp $
 * BathyScaphe
 *
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 */

#import "BSImagePreviewInspector.h"
#import "BSIPIActionBtnTbItem.h"
#import "BSIPIToken.h"
#import <SGAppKit/BSSegmentedControlTbItem.h>
#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import <CocoMonar/CMRFileManager.h>

static NSString *const kIPITbActionBtnId		= @"Actions";
static NSString *const kIPITbSettingsBtnId		= @"Settings";
static NSString *const kIPITbCancelBtnId		= @"CancelAndSave";
static NSString *const kIPITbPreviewBtnId		= @"OpenWithPreview";
static NSString *const kIPITbFullscreenBtnId	= @"StartFullscreen";
static NSString *const kIPITbBrowserBtnId		= @"OpenWithBrowser";
static NSString *const kIPITbNaviBtnId			= @"History";
static NSString *const kIPITbPaneBtnId			= @"Panes";
static NSString *const kIPITbDeleteBtnId		= @"Delete";
static NSString *const kIPITbSaveBtnId			= @"Save";

static NSString *const kIPIToobarId				= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Toolbar";

@implementation BSImagePreviewInspector(ToolbarAndUtils)
#pragma mark Utilities
- (NSString *) localizedStrForKey : (NSString *) key
{
	NSBundle *selfBundle = [NSBundle bundleForClass : [self class]];
	return [selfBundle localizedStringForKey : key value : key table : nil];
}

- (NSImage *) imageResourceWithName : (NSString *) name
{
	NSBundle *bundle_;
	NSString *filepath_;
	bundle_ = [NSBundle bundleForClass : [self class]];
	filepath_ = [bundle_ pathForImageResource : name];
	
	if(nil == filepath_) return nil;
	
	return [[[NSImage alloc] initWithContentsOfFile : filepath_] autorelease];
}

#pragma mark Toolbars	
- (void) setupToolbar
{
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: kIPIToobarId] autorelease];
    
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconOnly];
	[toolbar setSizeMode : NSToolbarSizeModeSmall];
    
    [toolbar setDelegate: self];
    
    [[self window] setToolbar: toolbar];
}

- (NSToolbarItem *) toolbar : (NSToolbar *) toolbar
	  itemForItemIdentifier : (NSString *) itemIdent
  willBeInsertedIntoToolbar : (BOOL) willBeInserted
{
    NSToolbarItem *toolbarItem = nil;
    
    if ([itemIdent isEqual: kIPITbSettingsBtnId]) {
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		[toolbarItem setLabel: [self localizedStrForKey : @"Settings"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey : @"Settings"]];
		[toolbarItem setToolTip: [self localizedStrForKey : @"SettingsTip"]];
		[toolbarItem setImage: [self imageResourceWithName: @"Settings"]];
		
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(beginSettingsSheet:)];

	} else if ([itemIdent isEqual: kIPITbCancelBtnId]) {
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		[toolbarItem setLabel: [self localizedStrForKey : @"Stop"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey : @"Stop/Save"]];
		[toolbarItem setToolTip: [self localizedStrForKey : @"StopTip"]];
		[toolbarItem setImage: [NSImage imageNamed: @"stopSign"]];
		
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(cancelDownload:)];

	} else if ([itemIdent isEqual:kIPITbSaveBtnId]) {
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdent] autorelease];

		[toolbarItem setLabel:[self localizedStrForKey:@"Save"]];
		[toolbarItem setPaletteLabel:[self localizedStrForKey:@"Save"]];
		[toolbarItem setToolTip:[self localizedStrForKey:@"SaveTip"]];
		[toolbarItem setImage:[self imageResourceWithName:@"Save"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(saveImage:)];

	} else if ([itemIdent isEqual: kIPITbPreviewBtnId]) {
		NSString *previewPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier : @"com.apple.Preview"];
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		[toolbarItem setLabel: [self localizedStrForKey : @"Preview"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey : @"OpenWithPreview"]];
		[toolbarItem setToolTip: [self localizedStrForKey : @"PreviewTip"]];
		[toolbarItem setImage: [[NSWorkspace sharedWorkspace] iconForFile : previewPath]];
		
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(openImageWithPreviewApp:)];
	
	} else if ([itemIdent isEqual: kIPITbFullscreenBtnId]) {
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		[toolbarItem setLabel: [self localizedStrForKey : @"FullScreen"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey : @"StartFullScreen"]];
		[toolbarItem setToolTip: [self localizedStrForKey : @"FullScreenTip"]];
		[toolbarItem setImage: [self imageResourceWithName: @"FullScreen"]];
		
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(startFullscreen:)];
	
	} else if ([itemIdent isEqual: kIPITbBrowserBtnId]) {
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		[toolbarItem setLabel: [self localizedStrForKey : @"Browser"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey : @"OpenWithBrowser"]];
		[toolbarItem setToolTip: [self localizedStrForKey : @"BrowserTip"]];
		[toolbarItem setImage: [[NSWorkspace sharedWorkspace] iconForDefaultWebBrowser]];
		
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(openImage:)];
	
	} else if ([itemIdent isEqual: kIPITbDeleteBtnId]) {
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
		[toolbarItem setLabel: [self localizedStrForKey : @"Delete"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey : @"Delete"]];
		[toolbarItem setToolTip: [self localizedStrForKey : @"DeleteTip"]];
		[toolbarItem setImage: [[NSWorkspace sharedWorkspace] systemIconForType: kToolbarDeleteIcon]];
		
		[toolbarItem setTarget:[self tripleGreenCubes]];// self];
		[toolbarItem setAction:@selector(remove:)];// @selector(deleteCachedImage:)];
	
    } else if([itemIdent isEqual: kIPITbActionBtnId]) {
		NSSize	size_;
		NSView	*tmp_;
		NSMenuItem	*attachMenuItem_;
		NSMenu		*attachMenu_;
        toolbarItem = [[[BSIPIActionBtnTbItem alloc] initWithItemIdentifier: itemIdent] autorelease];

		[toolbarItem setLabel: [self localizedStrForKey : @"Actions"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey : @"Actions"]];
		[toolbarItem setToolTip: [self localizedStrForKey : @"ActionsTip"]];

		tmp_ = [[self actionBtn] retain]; // 2006-02-24 added
		
		attachMenuItem_ = [[[NSMenuItem alloc] initWithTitle:[self localizedStrForKey:@"Actions"] action:NULL keyEquivalent:@""] autorelease];
		[attachMenuItem_ setImage : [self imageResourceWithName: @"Gear"]];
		attachMenu_ = [[[self actionBtn] menu] copy];
		[attachMenu_ removeItemAtIndex: 0];
		[attachMenuItem_ setSubmenu: [attachMenu_ autorelease]];

		[toolbarItem setView: tmp_];
		[toolbarItem setMenuFormRepresentation: attachMenuItem_];
		size_ = [tmp_ bounds].size;
		[toolbarItem setMinSize: size_];
		[toolbarItem setMaxSize: size_];

		[toolbarItem setTarget : self];
		[(BSIPIActionBtnTbItem *)toolbarItem setDelegate: self]; // 2006-07-05 added

    } else if ([itemIdent isEqual: kIPITbNaviBtnId]) {
		NSSize	size_;
		NSView	*tmp_;
		NSMenuItem	*attachMenuItem_;
		toolbarItem = [[[BSSegmentedControlTbItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		[toolbarItem setLabel: [self localizedStrForKey: @"History"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey: @"History"]];
		[toolbarItem setToolTip: [self localizedStrForKey: @"HistoryTip"]];
		
		tmp_ = [[self cacheNavigationControl] retain];
		
		attachMenuItem_ = [[[NSMenuItem alloc] initWithTitle: [self localizedStrForKey: @"HistoryTextOnly"]
													  action: NULL
											   keyEquivalent: @""] autorelease];
		[attachMenuItem_ setImage: [self imageResourceWithName: @"HistoryFolder"]];
		[attachMenuItem_ setSubmenu: [self cacheNaviMenuFormRep]];
		
		[toolbarItem setView: tmp_];
		[toolbarItem setMenuFormRepresentation: attachMenuItem_];
		size_ = [tmp_ bounds].size;
		[toolbarItem setMinSize: size_];
		[toolbarItem setMaxSize: size_];
		[(BSSegmentedControlTbItem *)toolbarItem setDelegate: self];
		
    } else if ([itemIdent isEqual: kIPITbPaneBtnId]) {
		NSSize	size_;
		NSView	*tmp_;
		NSMenuItem	*attachMenuItem_;
		toolbarItem = [[[BSSegmentedControlTbItem alloc] initWithItemIdentifier: itemIdent] autorelease];
		
		[toolbarItem setLabel: [self localizedStrForKey: @"Panes"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey: @"Panes"]];
		[toolbarItem setToolTip: [self localizedStrForKey: @"PanesTip"]];
		
		tmp_ = [[self paneChangeBtn] retain];
		attachMenuItem_ = [[[NSMenuItem alloc] initWithTitle: [self localizedStrForKey : @"PanesTextOnly"]
													  action: @selector(changePane:)
											   keyEquivalent: @""] autorelease];
		[attachMenuItem_ setTarget: self];
		[attachMenuItem_ setImage : [self imageResourceWithName: @"imageView"]];
											   
		[toolbarItem setView: tmp_];
		[toolbarItem setMenuFormRepresentation: attachMenuItem_];
		size_ = [tmp_ bounds].size;
		[toolbarItem setMinSize: size_];
		[toolbarItem setMaxSize: size_];
		[(BSSegmentedControlTbItem *)toolbarItem setDelegate: self];

	}

    return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers : (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects: kIPITbNaviBtnId, kIPITbPaneBtnId, kIPITbActionBtnId, NSToolbarFlexibleSpaceItemIdentifier,
									  kIPITbCancelBtnId, kIPITbSaveBtnId, nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects:kIPITbNaviBtnId, kIPITbPaneBtnId, kIPITbActionBtnId, kIPITbCancelBtnId, kIPITbDeleteBtnId,
									 kIPITbSaveBtnId, kIPITbBrowserBtnId, kIPITbPreviewBtnId, kIPITbFullscreenBtnId, kIPITbSettingsBtnId,
									 NSToolbarCustomizeToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
									 NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
}

#pragma mark Validation
- (BOOL) validateToolbarItem : (NSToolbarItem *) toolbarItem
{
	NSString *identifier_ = [toolbarItem itemIdentifier];
	NSArrayController	*cube_ = [self tripleGreenCubes];
	
	if ([identifier_ isEqualToString: kIPITbDeleteBtnId]) {
		return [cube_ canRemove];
	}

	NSIndexSet	*indexes = [cube_ selectionIndexes];
	BOOL		selected = ([indexes count] > 0);

	if ([identifier_ isEqualToString:kIPITbBrowserBtnId] || [identifier_ isEqualToString:kIPITbFullscreenBtnId]) {
		return selected;
	} else if ([identifier_ isEqualToString:kIPITbCancelBtnId]) {
		if (!selected) return NO;
		BSIPIHistoryManager *manager = [BSIPIHistoryManager sharedManager];
		if ([manager cachedTokensArrayContainsDownloadingTokenAtIndexes:indexes]) {
			[toolbarItem setLabel : [self localizedStrForKey : @"Stop"]];
			[toolbarItem setToolTip: [self localizedStrForKey : @"StopTip"]];
			[toolbarItem setImage: [NSImage imageNamed: @"stopSign"]];
			[toolbarItem setTarget : self];
			[toolbarItem setAction : @selector(cancelDownload:)];
		} else {
			[toolbarItem setLabel:[self localizedStrForKey:@"Retry"]];
			[toolbarItem setToolTip:[self localizedStrForKey:@"RetryTip"]];
			[toolbarItem setImage:[NSImage imageNamed: @"ReloadThread"]];
			[toolbarItem setTarget:self];
			[toolbarItem setAction:@selector(retryDownload:)];
		}
		return YES;
	} else if ([identifier_ isEqualToString:kIPITbPreviewBtnId] || [identifier_ isEqualToString:kIPITbSaveBtnId]) {
		return (selected && [[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsNotNullObjectAtIndexes:indexes]);
	}
    return YES;
}

- (BOOL) validateActionBtnTbItem: (BSIPIActionBtnTbItem *) aTbItem
{
	return YES;
}

// action button's menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	NSArrayController	*cube_ = [self tripleGreenCubes];
	int tag_ = [menuItem tag];
	NSIndexSet	*indexes = [cube_ selectionIndexes];
	BOOL		selected = ([indexes count] > 0);

	if (tag_ == 573) {
		return selected;
	} else if (tag_ == 575) {
		return (selected && [[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsNotNullObjectAtIndexes:indexes]);
	} else if (tag_ == 576) {
		return (selected && ([indexes count] == 1) && [[[cube_ selectedObjects] objectAtIndex:0] valueForKey:@"downloadedFilePath"]);
	} else if (tag_ == 574) {
		if (!selected) return NO;
		BSIPIHistoryManager *manager = [BSIPIHistoryManager sharedManager];
		if ([manager cachedTokensArrayContainsDownloadingTokenAtIndexes:indexes]) {
			[menuItem setTitle: [self localizedStrForKey: @"StopMenu"]];
			[menuItem setAction: @selector(cancelDownload:)];
		} else {
			[menuItem setTitle: [self localizedStrForKey: @"RetryMenu"]];
			[menuItem setAction: @selector(retryDownload:)];
		}
		return YES;
	}

	return YES;
}

- (BOOL) segCtrlTbItem:(BSSegmentedControlTbItem *)item validateSegment:(int)segment
{
	if ([item view] == [self paneChangeBtn]) return YES;

	NSArrayController *cube_ = [self tripleGreenCubes];

	if (segment == 0) {
		return [cube_ canSelectPrevious];
	} else if (segment == 1) {
		return [cube_ canSelectNext];
	}
	return NO;
}
@end
