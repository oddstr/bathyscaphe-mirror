/*
 * $Id: BSImagePreviewInspector-Tb.m,v 1.11.2.12 2006/12/09 20:00:50 tsawada2 Exp $
 * BathyScaphe
 *
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 */

#import "BSImagePreviewInspector.h"
#import "BSIPIActionBtnTbItem.h"
#import "BSIPIToken.h"
#import <SGFoundation/NSDictionary-SGExtensions.h>
#import <SGFoundation/NSMutableDictionary-SGExtensions.h>
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
static NSString *const kIPIToobarId				= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Toolbar";
static NSString *const kIPIAlwaysKeyWindowKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Always Key Window";
static NSString *const kIPISaveDirectoryKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Save Directory";
static NSString *const kIPIAlphaValueKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Window Alpha Value";
static NSString *const kIPIOpaqueWhenKeyWindowKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Opaque When Key Window";
static NSString *const kIPIResetWhenHideWindowKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Reset When Hide Window";
static NSString *const kIPIFloatingWindowKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Floating Window";
static NSString *const kIPIPreferredViewTypeKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Preferred View";
static NSString *const kIPILastShownViewTagKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Last Shown View";
//static NSString *const kIPIRedirBehaviorKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Redirection Behavior";
static NSString *const kIPILeaveFailedTokenKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Leave Failed Tokens";

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
		
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(deleteCachedImage:)];
	
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
		
		attachMenuItem_ = [[[NSMenuItem alloc] initWithTitle: [self localizedStrForKey : @"Actions"] action: NULL keyEquivalent: @""] autorelease];
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
									  kIPITbCancelBtnId, nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects: kIPITbNaviBtnId, kIPITbPaneBtnId, kIPITbActionBtnId, kIPITbCancelBtnId, kIPITbDeleteBtnId, kIPITbBrowserBtnId,
									  kIPITbPreviewBtnId, kIPITbFullscreenBtnId, kIPITbSettingsBtnId, NSToolbarCustomizeToolbarItemIdentifier,
									  NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier,
									  NSToolbarSeparatorItemIdentifier, nil];
}

#pragma mark Validation
- (BOOL) validateToolbarItem : (NSToolbarItem *) toolbarItem
{
	NSString *identifier_ = [toolbarItem itemIdentifier];
	NSArrayController	*cube_ = [self tripleGreenCubes];
	
	if ([identifier_ isEqualToString: kIPITbDeleteBtnId]) {
		return [cube_ canRemove];
	}

	unsigned	idx_ = [cube_ selectionIndex];
	BOOL		selected = (idx_ != NSNotFound);

	if ([identifier_ isEqualToString : kIPITbBrowserBtnId] || [identifier_ isEqualToString: kIPITbFullscreenBtnId]) {
		return selected;
	} else if ([identifier_ isEqualToString : kIPITbCancelBtnId]) {
		if (!selected) return NO;
		if ([[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsDownloadingTokenAtIndexes: [cube_ selectionIndexes]]) {
			[toolbarItem setLabel : [self localizedStrForKey : @"Stop"]];
			[toolbarItem setToolTip: [self localizedStrForKey : @"StopTip"]];
			[toolbarItem setImage: [NSImage imageNamed: @"stopSign"]];
			[toolbarItem setTarget : self];
			[toolbarItem setAction : @selector(cancelDownload:)];
			return YES;
		} else {
			[toolbarItem setLabel : [self localizedStrForKey : @"Save"]];
			[toolbarItem setToolTip: [self localizedStrForKey : @"SaveTip"]];
			[toolbarItem setImage: [self imageResourceWithName: @"Save"]];
			[toolbarItem setTarget : self];
			[toolbarItem setAction : @selector(saveImage:)];
			return ([[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsNotNullObjectAtIndexes: [cube_ selectionIndexes]]);
		}
	} else if ([identifier_ isEqualToString: kIPITbPreviewBtnId]) {
		return (selected && [[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsNotNullObjectAtIndexes: [cube_ selectionIndexes]]);
	}
    return YES;
}

- (BOOL) validateActionBtnTbItem: (BSIPIActionBtnTbItem *) aTbItem
{
	return YES;
}

// action button's menu
- (BOOL) validateMenuItem: (id <NSMenuItem>) menuItem
{
	NSArrayController	*cube_ = [self tripleGreenCubes];
	int tag_ = [menuItem tag];
	if (tag_ == 571) {
		return [cube_ canSelectPrevious];
	} else if (tag_ == 572) {
		return [cube_ canSelectNext];
	} else if (tag_ == 577) {
		return [cube_ canRemove];
	}

	unsigned	idx_ = [cube_ selectionIndex];
	BOOL		selected = (idx_ != NSNotFound);

	if (tag_ == 573) {
		return selected;
	} else if (tag_ == 575) {
		return (selected && [[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsNotNullObjectAtIndexes: [cube_ selectionIndexes]]);
	} else if (tag_ == 576) {
		return (selected && ([[cube_ selectionIndexes] count] == 1) && 
				[[[self historyItems] objectAtIndex: idx_] downloadedFilePath] != nil);
	} else if (tag_ == 574) {
		if (!selected) return NO;
		if ([[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsDownloadingTokenAtIndexes: [cube_ selectionIndexes]]) {
			[menuItem setTitle: [self localizedStrForKey: @"StopMenu"]];
			[menuItem setAction: @selector(cancelDownload:)];
			return YES;
		} else {
			[menuItem setTitle: [self localizedStrForKey: @"SaveMenu"]];
			[menuItem setAction: @selector(saveImage:)];
			return ([[BSIPIHistoryManager sharedManager] cachedTokensArrayContainsNotNullObjectAtIndexes: [cube_ selectionIndexes]]);
		}
	}
	
	if ([menuItem action] == @selector(resetCache:)) {
		return ([[self historyItems] count] > 0);
	}
	return YES;
}

- (BOOL) segCtrlTbItem: (BSSegmentedControlTbItem *) item
	   validateSegment: (int) segment
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

@implementation BSImagePreviewInspector(Settings)
- (NSMutableDictionary *) prefsDict
{
	return [[self preferences] imagePreviewerPrefsDict];
}

- (BOOL) alwaysBecomeKey
{
	return [[self prefsDict] boolForKey: kIPIAlwaysKeyWindowKey defaultValue: YES];
}
- (void) setAlwaysBecomeKey : (BOOL) alwaysKey
{
	[[self prefsDict] setBool: alwaysKey forKey: kIPIAlwaysKeyWindowKey];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded: (NO == alwaysKey)];
}

- (NSString *) saveDirectory
{
	return [[self prefsDict] objectForKey: kIPISaveDirectoryKey
							defaultObject: [NSHomeDirectory() stringByAppendingPathComponent: @"Desktop"]];
}

- (void) setSaveDirectory : (NSString *) aString
{
	[[self prefsDict] setObject: aString forKey: kIPISaveDirectoryKey];
}

- (float) alphaValue
{
	return [[self prefsDict] floatForKey: kIPIAlphaValueKey defaultValue: 1.0];
}

- (void) setAlphaValue : (float) newValue
{
	[[self prefsDict] setFloat: newValue forKey: kIPIAlphaValueKey];
	[[self window] setAlphaValue: newValue];
}

- (BOOL) opaqueWhenKey
{
	return [[self prefsDict] boolForKey: kIPIOpaqueWhenKeyWindowKey defaultValue: NO];
}

- (void) setOpaqueWhenKey : (BOOL) opaqueWhenKey
{
	[[self prefsDict] setBool: opaqueWhenKey forKey: kIPIOpaqueWhenKeyWindowKey];
}

- (BOOL) resetWhenHide
{
	return [[self prefsDict] boolForKey: kIPIResetWhenHideWindowKey defaultValue: NO];
}

- (void) setResetWhenHide : (BOOL) reset
{
	[[self prefsDict] setBool: reset forKey: kIPIResetWhenHideWindowKey];
}


- (BOOL) floating
{
	return [[self prefsDict] boolForKey: kIPIFloatingWindowKey defaultValue: YES];
}

- (void) setFloating: (BOOL) floatOrNot
{
	[[self prefsDict] setBool: floatOrNot forKey: kIPIFloatingWindowKey];
	[(NSPanel *)[self window] setFloatingPanel: floatOrNot];
}

- (int) preferredView
{
	return [[self prefsDict] integerForKey: kIPIPreferredViewTypeKey defaultValue: 0];
}

- (void) setPreferredView: (int) aType
{
	[[self prefsDict] setInteger: aType forKey: kIPIPreferredViewTypeKey];
}

- (int) lastShownViewTag
{
	return [[self prefsDict] integerForKey: kIPILastShownViewTagKey defaultValue: 0];
}

- (void) setLastShownViewTag: (int) aTag
{
	[[self prefsDict] setInteger: aTag forKey: kIPILastShownViewTagKey];
}
/*
- (BSIPIRedirectionBehavior) redirectionBehavior
{
	return [[self prefsDict] integerForKey: kIPIRedirBehaviorKey defaultValue: BSIPIAlwaysAsk];
}
- (void) setRedirectionBehavior: (BSIPIRedirectionBehavior) aTag;
{
	[[self prefsDict] setInteger: aTag forKey: kIPIRedirBehaviorKey];
}*/

- (BOOL) leaveFailedToken
{
	return [[self prefsDict] boolForKey: kIPILeaveFailedTokenKey defaultValue: NO];
}

- (void) setLeaveFailedToken: (BOOL) leave
{
	[[self prefsDict] setBool: leave forKey: kIPILeaveFailedTokenKey];
}
@end
