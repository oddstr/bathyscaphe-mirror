//
//  $Id: BSImagePreviewInspector.m,v 1.19.2.1 2006/07/31 12:43:13 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import "BSImagePreviewInspector.h"

#import "TemporaryFolder.h"
#import "BSIPIFullScreenController.h"
#import "BSIPIPathTransformer.h"
#import "BSIPIDownload.h"
#import "BSIPIImageView.h"
#import "BSIPIAppKitExtensions.h"

@class BSIPITableView;
@class BSIPIFullScreenWindow;

static NSString *const kIPINibFileNameKey		= @"BSImagePreviewInspector";

@implementation BSImagePreviewInspector
- (id) initWithPreferences : (AppDefaults *) prefs
{
	if (self = [super initWithWindowNibName : kIPINibFileNameKey]) {
		[self setPreferences : prefs];
		_dlFolder = [[TemporaryFolder alloc] init];

		id transformer = [[[BSIPIPathTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer: transformer forName: @"BSIPIPathTransformer"];

		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(applicationWillTerminate:)
					    name : NSApplicationWillTerminateNotification
					  object : NSApp];
		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(keyWindowChanged:)
					    name : NSWindowDidBecomeKeyNotification
					  object : nil];
	}
	return self;
}

- (void) dealloc
{
	[_preferences release];
	[_currentDownload release];
	[_dlFolder release];
	[_sourceURL release];
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

#pragma mark For Cocoa Binding
- (NSURL *) sourceURL
{
	return _sourceURL;
}

- (void) setSourceURL : (NSURL *) newURL
{
	[newURL retain];
	[_sourceURL release];
	_sourceURL = newURL;
}

- (NSMutableArray *) historyItems
{
	return [[BSIPIHistoryManager sharedManager] historyBacket];
}


#pragma mark Actions
- (IBAction) copyURL : (id) sender
{
	[[BSIPIHistoryManager sharedManager] appendDataForURL: [self sourceURL]
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

- (IBAction) endSettingsSheet : (id) sender
{
	NSWindow *sheet_ = [sender window];
	[NSApp endSheet : sheet_
		 returnCode : NSOKButton];

	[sheet_ close];
}

- (IBAction) openOpenPanel : (id) sender
{
	NSOpenPanel	*panel_ = [NSOpenPanel openPanel];
	[panel_ setCanChooseFiles : NO];
	[panel_ setCanChooseDirectories : YES];
	[panel_ setResolvesAliases : YES];
	if([panel_ runModalForTypes : nil] == NSOKButton)
		[self setSaveDirectory : [panel_ directory]];

	[self updateDirectoryChooser];
}

- (IBAction) forceRunTbCustomizationPalette: (id) sender
{
	[[self window] runToolbarCustomizationPalette: self];
}

- (IBAction) openImage : (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL : [self sourceURL] inBackGround : [[self preferences] openInBg]];
}

- (IBAction) openImageWithPreviewApp : (id) sender
{
	[[BSIPIHistoryManager sharedManager] openCachedFileForURLWithPreviewApp: [self sourceURL]];
}

- (IBAction) startFullscreen : (id) sender
{
	m_shouldRestoreKeyWindow = [[self window] isKeyWindow];
	[[BSIPIFullScreenController sharedInstance] setDelegate: self];
	[[BSIPIFullScreenController sharedInstance] setImage : [[self imageView] image]];

	[[BSIPIFullScreenController sharedInstance] startFullScreen: [[self window] screen]];
}

- (IBAction) saveImage : (id) sender
{
	[[BSIPIHistoryManager sharedManager] copyCachedFileForURL: [self sourceURL] intoFolder: [self saveDirectory]];
}

- (IBAction) cancelDownload : (id) sender
{
	[self clearAttributes];
}

- (IBAction) togglePreviewPanel : (id) sender
{
	if ([[self window] isVisible]) {
		// orderOut: では windowWillClose: はもちろん呼ばれない。
		if ([self resetWhenHide]) [self clearAttributes];
		[[self window] orderOut : sender];
	} else {
		[self showWindow : sender];
	}
}

- (void) showPrevImage: (id) sender
{
	NSString *filePath_;
	filePath_ = [[BSIPIHistoryManager sharedManager] cachedPrevFilePathForURL: [self sourceURL]];
	
	if (filePath_ != nil) {
		[self setSourceURL: [[BSIPIHistoryManager sharedManager] cachedURLForFilePath: filePath_]];
		[self showCachedImageWithPath: filePath_];
	} else {
		NSBeep();
		return;
	}
	
	if ([sender isKindOfClass: [BSIPIFullScreenWindow class]]) {
		[[BSIPIFullScreenController sharedInstance] setImage: [[self imageView] image]];
	}
}

- (void) showNextImage: (id) sender
{
	NSString *filePath_;
	filePath_ = [[BSIPIHistoryManager sharedManager] cachedNextFilePathForURL: [self sourceURL]];

	if (filePath_ != nil) {
		[self setSourceURL: [[BSIPIHistoryManager sharedManager] cachedURLForFilePath: filePath_]];
		[self showCachedImageWithPath: filePath_];
	} else {
		NSBeep();
		return;
	}
	
	if ([sender isKindOfClass: [BSIPIFullScreenWindow class]]) {
		[[BSIPIFullScreenController sharedInstance] setImage: [[self imageView] image]];
	}
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
	[[self tabView] selectTabViewItemAtIndex: [sender selectedSegment]];
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
	[[BSIPIHistoryManager sharedManager] removeItemOfURL: [self sourceURL]];
	[self didChangeValueForKey: @"historyItems"];

	[self clearAttributes];
}

- (BOOL) downloadImageInBkgnd : (NSURL *) anURL
{
	BSIPIDownload *newDownload_;

	if(_currentDownload) {
		[_currentDownload cancel];
		[self setCurrentDownload: nil];
	}

	newDownload_ = [[BSIPIDownload alloc] initWithURLIdentifier: anURL delegate: self destination: [[self dlFolder] path]];
	if (newDownload_) {
		[self setCurrentDownload: newDownload_];
		[newDownload_ release];
		[self startProgressIndicator];
		return YES;
	}
	
	return NO;
}

- (BOOL) showCachedImageWithPath: (NSString *) path
{
	NSImage *img = [[[NSImage alloc] initWithContentsOfFile : path] autorelease];

	if (img) {
		[[self infoField] setStringValue : [self calcImageSize : img]];
		[[self imageView] setImage : img];
		[self synchronizeImageAndSelectedRow];
		return YES;
	} else {
		NSLog(@"Can't load from temp file");
		[self synchronizeImageAndSelectedRow];
		return NO;
	}
}

- (BOOL) showImageWithURL : (NSURL *) imageURL
{
	NSString *cachedFilePath;
	/* showWindow:
	   If the window is an NSPanel object and has its becomesKeyOnlyIfNeeded flag set to YES, the window is displayed in front of
	   all other windows but is not made key; otherwise it is displayed in front and is made key. This method is useful for menu actions.
	*/
	//if (![[self window] isVisible]) {
		[self showWindow : self];
	//} else {
	//	if ([self alwaysBecomeKey]) [[self window] makeKeyAndOrderFront: self];
	//}

	cachedFilePath = [[BSIPIHistoryManager sharedManager] cachedFilePathForURL : imageURL];

	[self clearAttributes];
	[self setSourceURL : imageURL];

	return (cachedFilePath != nil) ? [self showCachedImageWithPath: cachedFilePath] : [self downloadImageInBkgnd: imageURL];
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
	[_dlFolder release];
	_dlFolder = nil;

	[[NSNotificationCenter defaultCenter] removeObserver : self];
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
	if ([self resetWhenHide]) [self clearAttributes];
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
	[[BSIPIFullScreenController sharedInstance] setImage: nil];
	if (m_shouldRestoreKeyWindow) {
		[[self window] makeKeyWindow];
	}
	m_shouldRestoreKeyWindow = NO;
}

#pragma mark BSIPIDownload Delegate
- (void) bsIPIdownload: (BSIPIDownload *) aDownload willDownloadContentOfSize: (double) expectedLength
{
	NSProgressIndicator	*bar_ =[self progIndicator];

	[bar_ setIndeterminate : NO];
	[bar_ setMinValue : 0];
	[bar_ setMaxValue : expectedLength];
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didDownloadContentOfSize: (double) downloadedLength
{
	[[self progIndicator] setDoubleValue: downloadedLength];
}

- (void) bsIPIdownloadDidFinish: (BSIPIDownload *) aDownload
{
	NSString *downloadedFilePath_;
	[self stopProgressIndicator];	

	downloadedFilePath_ = [aDownload downloadedFilePath];

	[self willChangeValueForKey:@"historyItems"];
	[[BSIPIHistoryManager sharedManager] addItemOfURL : [self sourceURL] andPath : downloadedFilePath_];
	[self didChangeValueForKey:@"historyItems"];

	[self showCachedImageWithPath: downloadedFilePath_];
	[self setCurrentDownload: nil];
}


- (BOOL) bsIPIdownload: (BSIPIDownload *) aDownload didRedirectToURL: (NSURL *) newURL
{
	return [self validateLink: newURL];
}

- (void) bsIPIdownloadDidAbortRedirection: (BSIPIDownload *) aDownload
{
	NSLog(@"Redirection Aborted, so we try to open URL with Web browser");
	[self openImage: self];

	[self clearAttributes];
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didFailWithError: (NSError *) aError
{
	NSBeep();
	NSLog(@"%@",[aError localizedDescription]);

	[self clearAttributes];
}

#pragma mark NSTableView Delegate
- (void) tableViewSelectionDidChange: (NSNotification *) aNotification
{
	int row_ = [[aNotification object] selectedRow];
	if (row_ == -1) {
		[self clearAttributes];
		return;
	}

	NSString *fPath_ = [[[BSIPIHistoryManager sharedManager] arrayOfPaths] objectAtIndex: row_];
	NSURL	*url_ = [[BSIPIHistoryManager sharedManager] cachedURLForFilePath: fPath_];

	if (![url_ isEqual: [self sourceURL]]) {
		[self setSourceURL: url_];
		[self showCachedImageWithPath: fPath_];
	}
}

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

- (BOOL) selectionShouldChangeInTableView: (NSTableView *) aTableView
{
	return (_currentDownload == nil);
}

#pragma mark BSIPIImageView Delegate
- (BOOL) imageView: (BSIPIImageView *) aImageView writeSomethingToPasteboard: (NSPasteboard *) pboard
{
	return [[BSIPIHistoryManager sharedManager] appendDataForURL: [self sourceURL]
													toPasteboard: pboard
										 withFilenamesPboardType: YES];
}
@end
