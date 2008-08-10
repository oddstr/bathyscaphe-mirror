//
//  BSImagePreviewInspector-Tb.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/08/03.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSImagePreviewInspector.h"
#import <SGAppKit/BSSegmentedControlTbItem.h>
#import <SGAppKit/NSWorkspace-SGExtensions.h>

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
- (NSString *)localizedStrForKey:(NSString *)key
{
	NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
	return [selfBundle localizedStringForKey:key value:key table:nil];
}

- (NSImage *)imageResourceWithName:(NSString *)name
{
	NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
	NSString *path;
	path = [selfBundle pathForImageResource:name];
	
	if (!path) return nil;
	
	return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
}

- (NSToolbarItem *)tbItemForId:(NSString *)identifier
						 label:(NSString *)label
				  paletteLabel:(NSString *)pLabel
					   toolTip:(NSString *)toolTip
						action:(SEL)action
{
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
	[item setLabel:[self localizedStrForKey:label]];
	[item setPaletteLabel:[self localizedStrForKey:pLabel]];
	[item setToolTip:[self localizedStrForKey:toolTip]];
	[item setTarget:self];
	if (action != NULL) [item setAction:action];
	return item;
}

#pragma mark Toolbars
- (void)setupToolbar
{
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:kIPIToobarId] autorelease];

    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
	[toolbar setSizeMode:NSToolbarSizeModeSmall];
    
    [toolbar setDelegate:self];
    
    [[self window] setToolbar:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
    NSToolbarItem *item = nil;

    if ([itemIdent isEqual:kIPITbSettingsBtnId]) {
        item = [self tbItemForId:itemIdent label:@"Settings" paletteLabel:@"Settings" toolTip:@"SettingsTip" action:@selector(showPreviewerPreferences:)];
		[item setImage:[self imageResourceWithName:@"Settings"]];

	} else if ([itemIdent isEqual:kIPITbCancelBtnId]) {
        item = [self tbItemForId:itemIdent label:@"Stop" paletteLabel:@"Stop/Save" toolTip:@"StopTip" action:@selector(cancelDownload:)];
		[item setImage:[NSImage imageNamed:@"stopSign"]];
		[item setTag:574];

	} else if ([itemIdent isEqual:kIPITbSaveBtnId]) {
        item = [self tbItemForId:itemIdent label:@"Save" paletteLabel:@"Save" toolTip:@"SaveTip" action:@selector(saveImage:)];
		if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_4) {
			[item setImage:[self imageResourceWithName:@"Save_Leopard"]];
		} else {
			[item setImage:[self imageResourceWithName:@"Save"]];
		}
		[item setTag:575];

	} else if ([itemIdent isEqual:kIPITbPreviewBtnId]) {
		item = [self tbItemForId:itemIdent label:@"Preview" paletteLabel:@"OpenWithPreview" toolTip:@"PreviewTip" action:@selector(openImageWithPreviewApp:)];
		NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
		NSString *previewPath = [workspace absolutePathForAppBundleWithIdentifier:@"com.apple.Preview"];
		[item setImage:[workspace iconForFile:previewPath]];
		[item setTag:575];
	
	} else if ([itemIdent isEqual:kIPITbFullscreenBtnId]) {
		item = [self tbItemForId:itemIdent label:@"FullScreen" paletteLabel:@"StartFullScreen" toolTip:@"FullScreenTip" action:@selector(startFullscreen:)];
		[item setImage:[self imageResourceWithName:@"FullScreen"]];
		[item setTag:573];
	
	} else if ([itemIdent isEqual:kIPITbBrowserBtnId]) {
        item = [self tbItemForId:itemIdent label:@"Browser" paletteLabel:@"OpenWithBrowser" toolTip:@"BrowserTip" action:@selector(openImage:)];
		[item setImage:[[NSWorkspace sharedWorkspace] iconForDefaultWebBrowser]];
		[item setTag:573];
	
	} else if ([itemIdent isEqual:kIPITbDeleteBtnId]) {
		item = [self tbItemForId:itemIdent label:@"Delete" paletteLabel:@"Delete" toolTip:@"DeleteTip" action:@selector(remove:)];
		[item setTarget:[self tripleGreenCubes]];
		[item setImage:[[NSWorkspace sharedWorkspace] systemIconForType:kToolbarDeleteIcon]];

    } else if([itemIdent isEqual:kIPITbActionBtnId]) {
		item = [self tbItemForId:itemIdent label:@"Actions" paletteLabel:@"Actions" toolTip:@"ActionsTip" action:NULL];

		NSSize		size;
		NSView		*actionBtn;
		NSMenuItem	*menuFormRep;
		NSMenu		*menuFormRepSubmenu;

		actionBtn = [[self actionBtn] retain];
		
		menuFormRep = [[[NSMenuItem alloc] initWithTitle:[self localizedStrForKey:@"Actions"] action:NULL keyEquivalent:@""] autorelease];
		[menuFormRep setImage:[self imageResourceWithName:@"Gear"]];

		menuFormRepSubmenu = [[[self actionBtn] menu] copy];
		[menuFormRepSubmenu removeItemAtIndex:0];
		[menuFormRep setSubmenu:[menuFormRepSubmenu autorelease]];

		[item setView:actionBtn];
		[item setMenuFormRepresentation:menuFormRep];
		size = [actionBtn bounds].size;
		[item setMinSize:size];
		[item setMaxSize:size];

    } else if ([itemIdent isEqual:kIPITbNaviBtnId]) {
		NSSize	size_;
		NSView	*tmp_;
		NSMenuItem	*attachMenuItem_;
		item = [[[BSSegmentedControlTbItem alloc] initWithItemIdentifier:itemIdent] autorelease];
		
		[item setLabel:[self localizedStrForKey:@"History"]];
		[item setPaletteLabel:[self localizedStrForKey:@"History"]];
		[item setToolTip:[self localizedStrForKey:@"HistoryTip"]];
		
		tmp_ = [[self cacheNavigationControl] retain];
		
		attachMenuItem_ = [[[NSMenuItem alloc] initWithTitle:[self localizedStrForKey:@"HistoryTextOnly"]
													  action:NULL
											   keyEquivalent:@""] autorelease];
		[attachMenuItem_ setImage:[self imageResourceWithName:@"HistoryFolder"]];
		[attachMenuItem_ setSubmenu:[self cacheNaviMenuFormRep]];
		
		[item setView:tmp_];
		[item setMenuFormRepresentation:attachMenuItem_];
		size_ = [tmp_ bounds].size;
		[item setMinSize:size_];
		[item setMaxSize:size_];
		[(BSSegmentedControlTbItem *)item setDelegate:self];
		
    } else if ([itemIdent isEqual:kIPITbPaneBtnId]) {
		NSSize	size_;
		NSView	*tmp_;
		NSMenuItem	*attachMenuItem_;
		item = [[[BSSegmentedControlTbItem alloc] initWithItemIdentifier:itemIdent] autorelease];
		
		[item setLabel:[self localizedStrForKey:@"Panes"]];
		[item setPaletteLabel:[self localizedStrForKey:@"Panes"]];
		[item setToolTip:[self localizedStrForKey:@"PanesTip"]];
		
		tmp_ = [[self paneChangeBtn] retain];
		attachMenuItem_ = [[[NSMenuItem alloc] initWithTitle:[self localizedStrForKey:@"PanesTextOnly"]
													  action:@selector(changePane:)
											   keyEquivalent:@""] autorelease];
		[attachMenuItem_ setTarget:self];
		[attachMenuItem_ setImage:[self imageResourceWithName:@"imageView"]];
											   
		[item setView:tmp_];
		[item setMenuFormRepresentation:attachMenuItem_];
		size_ = [tmp_ bounds].size;
		[item setMinSize:size_];
		[item setMaxSize:size_];
		[(BSSegmentedControlTbItem *)item setDelegate:self];

	}

    return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:kIPITbNaviBtnId, kIPITbPaneBtnId, kIPITbActionBtnId, NSToolbarFlexibleSpaceItemIdentifier,
									 kIPITbCancelBtnId, kIPITbSaveBtnId, nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:kIPITbNaviBtnId, kIPITbPaneBtnId, kIPITbActionBtnId, kIPITbCancelBtnId, kIPITbDeleteBtnId,
									 kIPITbSaveBtnId, kIPITbBrowserBtnId, kIPITbPreviewBtnId, kIPITbFullscreenBtnId, kIPITbSettingsBtnId,
									 NSToolbarCustomizeToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
									 NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
}

#pragma mark Validation
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
	NSArrayController	*cube_ = [self tripleGreenCubes];
	int tag_ = [toolbarItem tag];

	NSIndexSet	*indexes = [cube_ selectionIndexes];
	BOOL		selected = ([indexes count] > 0);

	if (tag_ == 573) {
		return selected;
	} else if (tag_ == 575) {
		return (selected && [[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsNotNullObjectAtIndexes:indexes]);
	} else if (tag_ == 574) {
		if (!selected) return NO;
		BSIPIHistoryManager *manager = [BSIPIHistoryManager sharedManager];
		if ([manager cachedTokensArrayContainsDownloadingTokenAtIndexes:indexes]) {
			[toolbarItem setLabel:[self localizedStrForKey:@"Stop"]];
			[toolbarItem setToolTip:[self localizedStrForKey:@"StopTip"]];
			[toolbarItem setImage:[NSImage imageNamed:@"stopSign"]];
			[toolbarItem setAction:@selector(cancelDownload:)];
		} else {
			[toolbarItem setLabel:[self localizedStrForKey:@"Retry"]];
			[toolbarItem setToolTip:[self localizedStrForKey:@"RetryTip"]];
			[toolbarItem setImage:[NSImage imageNamed:@"ReloadThread"]];
			[toolbarItem setAction:@selector(retryDownload:)];
		}
		return YES;
	}

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
			[menuItem setTitle:[self localizedStrForKey: @"StopMenu"]];
			[menuItem setAction:@selector(cancelDownload:)];
		} else {
			[menuItem setTitle:[self localizedStrForKey: @"RetryMenu"]];
			[menuItem setAction:@selector(retryDownload:)];
		}
		return YES;
	}

	return YES;
}

- (BOOL)segCtrlTbItem:(BSSegmentedControlTbItem *)item validateSegment:(int)segment
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
