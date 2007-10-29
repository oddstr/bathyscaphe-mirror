//
//  $Id: BSImagePreviewInspector.m,v 1.24 2007/10/29 05:54:46 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import "BSImagePreviewInspector.h"

#import "BSIPIFullScreenController.h"
#import "BSIPIPathTransformer.h"
#import "BSIPIImageView.h"
#import "BSIPIToken.h"
//#import <SGNetwork/BSIPIDownload.h>
#import <CocoMonar/CMRPropertyKeys.h>

@class BSIPITableView;
@class BSIPIFullScreenWindow;

static NSString *const kIPINibFileNameKey		= @"BSImagePreviewInspector";

@implementation BSImagePreviewInspector
- (id) initWithPreferences: (AppDefaults *) prefs
{
	if (self = [super initWithWindowNibName: kIPINibFileNameKey]) {
		NSNotificationCenter	*dnc = [NSNotificationCenter defaultCenter];
		[self setPreferences: prefs];

		id transformer = [[[BSIPIPathTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer: transformer forName: @"BSIPIPathTransformer"];

		id anotherTransformer = [[[BSIPIImageIgnoringDPITransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer: anotherTransformer forName: @"BSIPIImageIgnoringDPITransformer"];

		[dnc addObserver: self
				selector: @selector(applicationWillTerminate:)
					name: NSApplicationWillTerminateNotification
				  object: NSApp];
		[dnc addObserver: self
				selector: @selector(applicationWillReset:)
					name: CMRApplicationWillResetNotification
				  object: nil];
		[dnc addObserver: self
				selector: @selector(keyWindowChanged:)
					name: NSWindowDidBecomeKeyNotification
				  object: nil];
		[dnc addObserver: self
				selector: @selector(tokenDidFailDownload:)
					name: BSIPITokenDownloadErrorNotification
				  object: nil];
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[_preferences release];
	[super dealloc];
}

- (AppDefaults *) preferences
{
	return _preferences;
}
- (void) setPreferences : (AppDefaults *) prefs
{
	id		tmp;
	
	tmp = _preferences;
	_preferences = [prefs retain];
	[tmp release];
}

- (NSMutableArray *) historyItems
{
	return [[BSIPIHistoryManager sharedManager] historyBacket];
}

- (IBAction) togglePreviewPanel : (id) sender
{
	if ([[self window] isVisible]) {
		// orderOut: では windowWillClose: はもちろん呼ばれない。
		if ([self resetWhenHide]) [[self tripleGreenCubes] setSelectionIndex: NSNotFound];
		[[self window] orderOut : sender];
	} else {
		[self showWindow : sender];
	}
}

#pragma mark Actions
- (IBAction) copyURL : (id) sender
{
	[[BSIPIHistoryManager sharedManager] appendDataForTokenAtIndexes: [[self tripleGreenCubes] selectionIndexes]
														toPasteboard: [NSPasteboard generalPasteboard]
											 withFilenamesPboardType: NO];
}

- (IBAction) beginSettingsSheet : (id) sender
{
	[self updateDirectoryChooser];
	[NSApp beginSheet : [self settingsPanel]
	   modalForWindow : [self window]
		modalDelegate : self
	   didEndSelector : nil
		  contextInfo : nil];
}

- (IBAction) forceRunTbCustomizationPalette: (id) sender
{
	[[self window] runToolbarCustomizationPalette: self];
}

- (IBAction) openImage : (id) sender
{
	[[BSIPIHistoryManager sharedManager] openURLForTokenAtIndexes: [[self tripleGreenCubes] selectionIndexes]
													 inBackground: [[self preferences] openInBg]];
}

- (IBAction) openImageWithPreviewApp : (id) sender
{
	[[BSIPIHistoryManager sharedManager] openCachedFileForTokenAtIndexesWithPreviewApp: [[self tripleGreenCubes] selectionIndexes]];
}

- (IBAction) startFullscreen : (id) sender
{
	m_shouldRestoreKeyWindow = [[self window] isKeyWindow];

	NSIndexSet *tmp_ = [[self tripleGreenCubes] selectionIndexes];
	if ([tmp_ count] > 1) {
		[[self tripleGreenCubes] setSelectionIndex: [tmp_ firstIndex]];
	}

	[[BSIPIFullScreenController sharedInstance] setDelegate: self];
	[[BSIPIFullScreenController sharedInstance] setArrayController: [self tripleGreenCubes]];

	[[BSIPIFullScreenController sharedInstance] startFullScreen: [[self window] screen]];
}

- (IBAction) saveImage : (id) sender
{
	[[BSIPIHistoryManager sharedManager] copyCachedFileForTokenAtIndexes: [[self tripleGreenCubes] selectionIndexes]
															  intoFolder: [self saveDirectory]];
}

- (IBAction) saveImageAs: (id) sender
{
	m_shouldRestoreKeyWindow = [[self window] isKeyWindow];

	[[BSIPIHistoryManager sharedManager] saveCachedFileForTokenAtIndex: [[self tripleGreenCubes] selectionIndex]
											   savePanelAttachToWindow: [self window]];
}

- (IBAction) cancelDownload : (id) sender
{
	[[BSIPIHistoryManager sharedManager] makeTokensCancelDownloadAtIndexes: [[self tripleGreenCubes] selectionIndexes]];
}

- (IBAction)retryDownload:(id)sender
{
	[[BSIPIHistoryManager sharedManager] makeTokensRetryDownloadAtIndexes:[[self tripleGreenCubes] selectionIndexes]];
}

- (IBAction) showPrevImage: (id) sender
{
	[[self tripleGreenCubes] selectPrevious: sender];
}

- (IBAction) showNextImage: (id) sender
{
	[[self tripleGreenCubes] selectNext: sender];
}

- (IBAction) historyNavigationPushed: (id) sender
{
	int segNum = [sender selectedSegment];
	if (segNum == 0) {
		[self showPrevImage: sender];
	} else if (segNum == 1) {
		[self showNextImage: sender];
	}
}

- (IBAction) changePane: (id) sender
{
	if ([sender isKindOfClass: [NSSegmentedControl class]]) {
		[[self tabView] selectTabViewItemAtIndex: [sender selectedSegment]];
	} else {
		int current_ = [[self tabView] indexOfTabViewItem: [[self tabView] selectedTabViewItem]];
		[[self tabView] selectTabViewItemAtIndex: (current_ == 0) ? 1 : 0];
		[[self paneChangeBtn] setSelectedSegment: (current_ == 0) ? 1 : 0];
	}
}

- (IBAction) changePaneAndShow: (id) sender
{
	unsigned	modifier_ = [[NSApp currentEvent] modifierFlags];
	if (modifier_ & NSAlternateKeyMask) {
		[self startFullscreen: sender];
		return;
	}
	[[self tabView] selectTabViewItemAtIndex: 0];
	[[self paneChangeBtn] setSelectedSegment: 0];
}

- (IBAction) deleteCachedImage: (id) sender
{
	[self willChangeValueForKey: @"historyItems"];
	[[BSIPIHistoryManager sharedManager] removeTokenAtIndexes: [[self tripleGreenCubes] selectionIndexes]];
	[self didChangeValueForKey: @"historyItems"];
}

- (IBAction) resetCache: (id) sender
{
	[self willChangeValueForKey: @"historyItems"];
	[[BSIPIHistoryManager sharedManager] flushCache];
	[self didChangeValueForKey: @"historyItems"];
}

- (BOOL) showImageWithURL : (NSURL *) imageURL
{
	/* showWindow:
	   If the window is an NSPanel object and has its becomesKeyOnlyIfNeeded flag set to YES, the window is displayed in front of
	   all other windows but is not made key; otherwise it is displayed in front and is made key. This method is useful for menu actions.
	*/
	[self showWindow : self];
	unsigned	index = [[BSIPIHistoryManager sharedManager] cachedTokenIndexForURL: imageURL];
	if (index == NSNotFound) {
		[self willChangeValueForKey: @"historyItems"];
		[[BSIPIHistoryManager sharedManager] addTokenForURL: imageURL];
		[self didChangeValueForKey: @"historyItems"];
		[[self tripleGreenCubes] setSelectionIndex: [[self historyItems] count] -1];
	} else {
		[[self tripleGreenCubes] setSelectionIndex: index];
	}
	return YES;
}

- (BOOL)showImagesWithURLs:(NSArray *)urls
{
	[self showWindow:self];
	NSEnumerator	*iter = [urls objectEnumerator];
	NSURL			*url;
	unsigned		index;

	[self willChangeValueForKey:@"historyItems"];
	while (url = [iter nextObject]) {
		index = [[BSIPIHistoryManager sharedManager] cachedTokenIndexForURL:url];
		if (index == NSNotFound) {
			[[BSIPIHistoryManager sharedManager] addTokenForURL:url];
		}
	}
	[self didChangeValueForKey:@"historyItems"];
	if (index != NSNotFound) {
		[[self tripleGreenCubes] setSelectionIndex:index];
	} else {
		[[self tripleGreenCubes] setSelectionIndex:[[self historyItems] count]-1];
	}
	return YES;
}

- (BOOL) validateLink: (NSURL *) anURL
{
	NSString	*extension = [[[anURL path] pathExtension] lowercaseString];
	if(!extension) return NO;
		
	return [[NSImage imageFileTypes] containsObject: extension];
}

#pragma mark Notifications
- (void) applicationWillTerminate : (NSNotification *) notification
{		
	[[BSIPIHistoryManager sharedManager] flushCache];

	[[NSNotificationCenter defaultCenter] removeObserver : self];
}

- (void) applicationWillReset: (NSNotification *) aNotification
{
	[self resetCache: nil];
}

- (void) keyWindowChanged : (NSNotification *) aNotification
{
	NSWindow	*window_ = [self window];
	if([self opaqueWhenKey] && [window_ isVisible]) {
		if([aNotification object] == window_) {
			[window_ setAlphaValue : 1.0];
		} else {
			[window_ setAlphaValue : [self alphaValue]];
		}
	}
}

- (void) windowWillClose : (NSNotification *) aNotification
{
	if ([self resetWhenHide]) [[self tripleGreenCubes] setSelectionIndex: NSNotFound];
}

- (void) windowWillBeginSheet: (NSNotification *) aNotification
{
	NSWindow *window_ = [aNotification object];
	m_shouldRestoreKeyWindow = [window_ isKeyWindow];
}

- (void) windowDidEndSheet: (NSNotification *) aNotification
{
	if (m_shouldRestoreKeyWindow) {
		[[aNotification object] makeKeyWindow];
	}
	m_shouldRestoreKeyWindow = NO;
}

- (void) fullScreenDidEnd: (NSWindow *) fullScreenWindow
{
	if (m_shouldRestoreKeyWindow) {
		[[self window] makeKeyWindow];
	}
	m_shouldRestoreKeyWindow = NO;
}

- (void) tokenDidFailDownload: (NSNotification *) aNotification
{
	if (NO == [self leaveFailedToken]) {
		[self willChangeValueForKey: @"historyItems"];
		[[BSIPIHistoryManager sharedManager] removeToken: [aNotification object]];
		[self didChangeValueForKey: @"historyItems"];
		[[self tripleGreenCubes] setSelectionIndex: NSNotFound];
	}
}

#pragma mark NSTableView Delegate
- (BOOL) tableView: (BSIPITableView *) aTableView shouldPerformKeyEquivalent: (NSEvent *) theEvent
{
	if ([aTableView selectedRow] == -1) return NO;
	
	int whichKey_ = [theEvent keyCode];

	if (whichKey_ == 51) { // delete key
		[self deleteCachedImage: aTableView];
		return YES;
	}
	
	if (whichKey_ == 36) { // return key, option-return ro start fullscreen
		[self changePaneAndShow: aTableView];
		return YES;
	}
	return NO;
}

#pragma mark NSTabView Delegate
- (void) tabView: (NSTabView *) tabView willSelectTabViewItem: (NSTabViewItem *) tabViewItem
{
	NSIndexSet *tmp_ = [[self tripleGreenCubes] selectionIndexes];
	if ([tmp_ count] > 1) {
		[[self tripleGreenCubes] setSelectionIndex: [tmp_ firstIndex]];
	}
	[self setLastShownViewTag: [tabView indexOfTabViewItem: tabViewItem]];
}

#pragma mark BSIPIImageView Delegate
- (BOOL) imageView: (BSIPIImageView *) aImageView writeSomethingToPasteboard: (NSPasteboard *) pboard
{
	return [[BSIPIHistoryManager sharedManager] appendDataForTokenAtIndexes: [[self tripleGreenCubes] selectionIndexes]
															   toPasteboard: pboard
													withFilenamesPboardType: YES];
}

- (void) imageView: (BSIPIImageView *) aImageView mouseDoubleClicked: (NSEvent *) theEvent
{
	if ([aImageView image])
		[self startFullscreen: aImageView];
}

- (BOOL) imageView: (BSIPIImageView *) aImageView shouldPerformKeyEquivalent: (NSEvent *) theEvent
{
	NSString	*pressedKey = [theEvent charactersIgnoringModifiers];
	int whichKey_ = [theEvent keyCode];

	if (whichKey_ == 51) { // delete key
		[self deleteCachedImage: aImageView];
		return YES;
	}
	
	if ((whichKey_ == 36) && [aImageView image]) { // return key
		[self startFullscreen: aImageView];
		return YES;
	}
	
	if ([pressedKey isEqualToString: [NSString stringWithFormat: @"%C", NSLeftArrowFunctionKey]] && [[self tripleGreenCubes] canSelectPrevious]) {
		[self showPrevImage: aImageView];
		return YES;
	}
	
	if ([pressedKey isEqualToString: [NSString stringWithFormat: @"%C", NSRightArrowFunctionKey]] && [[self tripleGreenCubes] canSelectNext]) {
		[self showNextImage: aImageView];
		return YES;
	}
	return NO;
}
@end
