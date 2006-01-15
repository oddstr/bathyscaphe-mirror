/*
 * %Id$
 * BathyScaphe
 *
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 */

#import "BSImagePreviewInspector.h"
#import "BSIPIActionBtnTbItem.h"

static NSString *const kIPITbActionBtnId		= @"Actions";
static NSString *const kIPITbSettingsBtnId		= @"Settings";
static NSString *const kIPITbPreviewBtnId		= @"OpenWithPreview";
static NSString *const kIPITbFullscreenBtnId	= @"StartFullscreen";
static NSString *const kIPIToobarId				= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Toolbar";

@implementation BSImagePreviewInspector(Toolbar)
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

- (NSString *) calcImageSize : (NSImage *) image_
{
	int	wi, he;
	NSArray	*ary_ = [image_ representations];
	NSImageRep	*tmp_ = [ary_ objectAtIndex : 0];
	NSString *msg_;
	
	wi = [tmp_ pixelsWide];
	he = [tmp_ pixelsHigh];
	
	// ignore DPI
	[tmp_ setSize : NSMakeSize(wi, he)];
	
	msg_ = [NSString stringWithFormat : [self localizedStrForKey : @"%i*%i pixel"], wi, he];
	
	/*if ([tmp_ isKindOfClass : [NSBitmapImageRep class]]) {
		id	exifData_ = [tmp_ valueForProperty : NSImageEXIFData];
		if (exifData_)NSLog(@"%@", [exifData_ description]);
	}*/
	return msg_;
}
	
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
	
    } else if([itemIdent isEqual: kIPITbActionBtnId]) {
        toolbarItem = [[[BSIPIActionBtnTbItem alloc] initWithItemIdentifier: itemIdent] autorelease];

		[toolbarItem setLabel: [self localizedStrForKey : @"Actions"]];
		[toolbarItem setPaletteLabel: [self localizedStrForKey : @"Actions"]];
		[toolbarItem setToolTip: [self localizedStrForKey : @"ActionsTip"]];
		
		[toolbarItem setView: [self actionBtn]];
		[toolbarItem setMinSize:[[self actionBtn] bounds].size];
		[toolbarItem setMaxSize:[[self actionBtn] bounds].size];

		[toolbarItem setTarget : self];
    } else {
		toolbarItem = nil;
    }
    return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers : (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects:	kIPITbActionBtnId, 
					kIPITbCancelBtnId, NSToolbarFlexibleSpaceItemIdentifier, 
					kIPITbSettingsBtnId, nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects: 	kIPITbActionBtnId, kIPITbCancelBtnId, kIPITbPreviewBtnId, kIPITbFullscreenBtnId, kIPITbSettingsBtnId,
					NSToolbarCustomizeToolbarItemIdentifier,
					NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
}


- (BOOL) validateToolbarItem : (NSToolbarItem *) toolbarItem
{
	NSString *identifier_ = [toolbarItem itemIdentifier];
	if ([identifier_ isEqualToString : kIPITbCancelBtnId]) {
		if ((_currentDownload == nil) && ([toolbarItem action] == @selector(cancelDownload:)))
			return NO;
	} else if ([identifier_ isEqualToString : kIPITbPreviewBtnId]) {
			return ((_currentDownload == nil) && ([self downloadedFileDestination] != nil));
	} else if ([identifier_ isEqualToString : kIPITbFullscreenBtnId]) {
			return ((_currentDownload == nil) && ([[self imageView] image] != nil));
	}
    return YES;
}
@end
