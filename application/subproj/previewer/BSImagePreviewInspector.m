//
//  BSImagePreviewInspector.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSImagePreviewInspector.h"
#import "BSIPIArrayController.h"
#import "BSIPIFullScreenController.h"
#import "BSIPIPathTransformer.h"
#import "BSIPIImageView.h"
#import "BSIPIToken.h"
#import "BSIPIDefaults.h"
#import "BSIPIPreferencesController.h"
#import <CocoMonar/CMRPropertyKeys.h>

@class BSIPITableView;
@class BSIPIFullScreenWindow;

static NSString *const kIPINibFileNameKey		= @"BSImagePreviewInspector";
static NSString *const kIPIPrefsNibFileNameKey	= @"BSIPIPreferences";

@implementation BSImagePreviewInspector
- (id)initWithPreferences:(AppDefaults *)prefs
{
	if (self = [super initWithWindowNibName:kIPINibFileNameKey]) {
		NSNotificationCenter	*dnc = [NSNotificationCenter defaultCenter];

		[[BSIPIDefaults sharedIPIDefaults] setAppDefaults:prefs];

		id transformer = [[[BSIPIPathTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"BSIPIPathTransformer"];

		id anotherTransformer = [[[BSIPIImageIgnoringDPITransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:anotherTransformer forName:@"BSIPIImageIgnoringDPITransformer"];

		[dnc addObserver:self
				selector:@selector(applicationWillTerminate:)
					name:NSApplicationWillTerminateNotification
				  object:NSApp];
		[dnc addObserver:self
				selector:@selector(applicationWillReset:)
					name:CMRApplicationWillResetNotification
				  object:nil];
		[dnc addObserver:self
				selector:@selector(keyWindowChanged:)
					name:NSWindowDidBecomeKeyNotification
				  object:nil];
		[dnc addObserver:self
				selector:@selector(tokenDidFailDownload:)
					name:BSIPITokenDownloadErrorNotification
				  object:nil];

		[[BSIPIDefaults sharedIPIDefaults] addObserver:self forKeyPath:@"alwaysBecomeKey" options:NSKeyValueObservingOptionNew context:kBSIPIDefaultsContext];
		[[BSIPIDefaults sharedIPIDefaults] addObserver:self forKeyPath:@"floating" options:NSKeyValueObservingOptionNew context:kBSIPIDefaultsContext];
		[[BSIPIDefaults sharedIPIDefaults] addObserver:self forKeyPath:@"alphaValue" options:NSKeyValueObservingOptionNew context:kBSIPIDefaultsContext];
	}
	return self;
}

- (void)dealloc
{
	[[BSIPIDefaults sharedIPIDefaults] removeObserver:self forKeyPath:@"alphaValue"];
	[[BSIPIDefaults sharedIPIDefaults] removeObserver:self forKeyPath:@"floating"];
	[[BSIPIDefaults sharedIPIDefaults] removeObserver:self forKeyPath:@"alwaysBecomeKey"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (AppDefaults *)preferences
{
	return nil;
}

- (void)setPreferences:(AppDefaults *)prefs
{
	;
}

- (id)historyManager
{
	return [BSIPIHistoryManager sharedManager];
}

- (IBAction)togglePreviewPanel:(id)sender
{
	if ([[self window] isVisible]) {
		// orderOut: では windowWillClose: はもちろん呼ばれない。
		if ([[BSIPIDefaults sharedIPIDefaults] resetWhenHide]) [[self tripleGreenCubes] setSelectionIndex:NSNotFound];
		[[self window] orderOut:sender];
	} else {
		[self showWindow:sender];
	}
}

#pragma mark Actions
- (IBAction)showPreviewerPreferences:(id)sender
{
	[[BSIPIPreferencesController sharedPreferencesController] showWindow:sender];
}

- (IBAction)forceRunTbCustomizationPalette:(id)sender
{
	[[self window] runToolbarCustomizationPalette:self];
}

- (IBAction)copyURL:(id)sender
{
	[[self historyManager] appendDataForTokenAtIndexes:[[self tripleGreenCubes] selectionIndexes]
										  toPasteboard:[NSPasteboard generalPasteboard]
							   withFilenamesPboardType:NO];
}

- (IBAction)openImage:(id)sender
{
	[[self historyManager] openURLForTokenAtIndexes:[[self tripleGreenCubes] selectionIndexes]
									   inBackground:[[self preferences] openInBg]];
}

- (IBAction)openImageWithPreviewApp:(id)sender
{
	[[self historyManager] openCachedFileForTokenAtIndexesWithPreviewApp:[[self tripleGreenCubes] selectionIndexes]];
}

- (IBAction)startFullscreen:(id)sender
{
	static BOOL	isBinded = NO;

	if ([[BSIPIDefaults sharedIPIDefaults] useIKSlideShowOnLeopard]) {
		NSString *helperBundleFullPath = [[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:@"BSIPILeopardSlideshowHelper.plugin"];
		NSBundle *helperBundle = [NSBundle bundleWithPath:helperBundleFullPath];
		if (!helperBundle) {
			NSLog(@"ERROR - Could not load BSIPILeopardSlideshowHelper.plugin...");
			return;
		}
		Class helper = [helperBundle principalClass];
		id instance = [helper sharedInstance];
		[instance setArrayController:[self tripleGreenCubes]];
		[instance startSlideshow];
	} else {
		m_shouldRestoreKeyWindow = [[self window] isKeyWindow];

		NSIndexSet *tmp_ = [[self tripleGreenCubes] selectionIndexes];
		if ([tmp_ count] > 1) {
			[[self tripleGreenCubes] setSelectionIndex:[tmp_ firstIndex]];
		}

		[[BSIPIFullScreenController sharedInstance] setDelegate:self];

		if (!isBinded) {
			[[BSIPIFullScreenController sharedInstance] bind:@"windowBackgroundColor"
													toObject:[BSIPIDefaults sharedIPIDefaults]
												 withKeyPath:@"fullScreenBgColorData"
													 options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
																						 forKey:NSValueTransformerNameBindingOption]];
			isBinded = YES;
		}

		[[BSIPIFullScreenController sharedInstance] setArrayController:[self tripleGreenCubes]];
		[[BSIPIFullScreenController sharedInstance] startFullScreen:[[self window] screen]];
	}
}

- (IBAction)saveImage:(id)sender
{
	[[self historyManager] copyCachedFileForTokenAtIndexes:[[self tripleGreenCubes] selectionIndexes]
												intoFolder:[[BSIPIDefaults sharedIPIDefaults] saveDirectory]];
}

- (IBAction)saveImageAs:(id)sender
{
	m_shouldRestoreKeyWindow = [[self window] isKeyWindow];

	[[self historyManager] saveCachedFileForTokenAtIndex:[[self tripleGreenCubes] selectionIndex]
								 savePanelAttachToWindow:[self window]];
}

- (IBAction)cancelDownload:(id)sender
{
	[[self historyManager] makeTokensCancelDownloadAtIndexes:[[self tripleGreenCubes] selectionIndexes]];
}

- (IBAction)retryDownload:(id)sender
{
	[[self historyManager] makeTokensRetryDownloadAtIndexes:[[self tripleGreenCubes] selectionIndexes]];
}

- (IBAction)historyNavigationPushed:(id)sender
{
	int segNum = [sender selectedSegment];
	if (segNum == 0) {
		[[self tripleGreenCubes] selectPrevious:sender];
	} else if (segNum == 1) {
		[[self tripleGreenCubes] selectNext:sender];
	}
}

- (IBAction)changePane:(id)sender
{
	if ([sender isKindOfClass:[NSSegmentedControl class]]) {
		[[self tabView] selectTabViewItemAtIndex:[sender selectedSegment]];
	} else {
		int current_ = [[self tabView] indexOfTabViewItem:[[self tabView] selectedTabViewItem]];
		[[self tabView] selectTabViewItemAtIndex:(current_ == 0) ? 1 : 0];
		[[self paneChangeBtn] setSelectedSegment:(current_ == 0) ? 1 : 0];
	}
}

- (IBAction)changePaneAndShow:(id)sender
{
	unsigned	modifier_ = [[NSApp currentEvent] modifierFlags];
	if (modifier_ & NSAlternateKeyMask) {
		[self startFullscreen:sender];
		return;
	}
	[[self tabView] selectTabViewItemAtIndex:0];
	[[self paneChangeBtn] setSelectedSegment:0];
}

- (BOOL)showImageWithURL:(NSURL *)imageURL
{
	/* showWindow:
	   If the window is an NSPanel object and has its becomesKeyOnlyIfNeeded flag set to YES, the window is displayed in front of
	   all other windows but is not made key; otherwise it is displayed in front and is made key. This method is useful for menu actions.
	*/
	[self showWindow:self];
	unsigned	index = [[self historyManager] cachedTokenIndexForURL:imageURL];
	if (index == NSNotFound) {
		BSIPIToken *token = [[BSIPIToken alloc] initWithURL:imageURL destination:[[self historyManager] dlFolderPath]];
		[[self tripleGreenCubes] addObject:token];
		[token release];
	} else {
		[[self tripleGreenCubes] setSelectionIndex:index];
	}
	return YES;
}

- (BOOL)showImagesWithURLs:(NSArray *)urls
{
	[self showWindow:self];
	NSEnumerator	*iter = [urls objectEnumerator];
	BSIPIArrayController *controller = [self tripleGreenCubes];
	NSURL			*url;
	unsigned		index = NSNotFound;

	[controller setSelectsInsertedObjects:NO];
	while (url = [iter nextObject]) {
		index = [[self historyManager] cachedTokenIndexForURL:url];
		if (index == NSNotFound) {
			BSIPIToken *token = [[BSIPIToken alloc] initWithURL:url destination:[[self historyManager] dlFolderPath]];
			[controller addObject:token];
			[token release];
		}
	}
	if (index != NSNotFound) {
		[controller setSelectionIndex:index];
	} else {
		[controller selectLast:nil];
	}
	[controller setSelectsInsertedObjects:YES];
	return YES;
}

- (BOOL)validateLink:(NSURL *)anURL
{
	CFStringRef extensionRef = CFURLCopyPathExtension((CFURLRef)anURL);
	if (!extensionRef) {
		return NO;
	}

	NSString *extension = [(NSString *)extensionRef lowercaseString];
	CFRelease(extensionRef);

	return [[NSImage imageFileTypes] containsObject:extension];
/*	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:anURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
	[req setHTTPMethod:@"HEAD"];
	NSURLResponse *rep;
	NSError *err;
	if ([NSURLConnection sendSynchronousRequest:req returningResponse:&rep error:&err]) {
		return [[rep MIMEType] hasPrefix:@"image"];
	} else {
		[[NSAlert alertWithError:err] runModal];
		return NO;
	}*/
}

#pragma mark Notifications
- (void)applicationWillTerminate:(NSNotification *)aNotification
{		
	[[self historyManager] flushCache];
	[[BSIPIDefaults sharedIPIDefaults] removeObserver:self forKeyPath:@"alphaValue"];
	[[BSIPIDefaults sharedIPIDefaults] removeObserver:self forKeyPath:@"floating"];
	[[BSIPIDefaults sharedIPIDefaults] removeObserver:self forKeyPath:@"alwaysBecomeKey"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillReset:(NSNotification *)aNotification
{
	[[self tripleGreenCubes] removeAll:nil];
}

- (void)keyWindowChanged:(NSNotification *)aNotification
{
	NSWindow	*window = [self window];
	if([[BSIPIDefaults sharedIPIDefaults] opaqueWhenKey] && [window isVisible]) {
		if([aNotification object] == window) {
			[window setAlphaValue:1.0];
		} else {
			[window setAlphaValue:[[BSIPIDefaults sharedIPIDefaults] alphaValue]];
		}
	}
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	if ([[BSIPIDefaults sharedIPIDefaults] resetWhenHide]) [[self tripleGreenCubes] setSelectionIndex:NSNotFound];
}

- (void)windowWillBeginSheet:(NSNotification *)aNotification
{
	NSWindow *window_ = [aNotification object];
	m_shouldRestoreKeyWindow = [window_ isKeyWindow];
	[window_ setAlphaValue:1.0];
}

- (void)windowDidEndSheet:(NSNotification *)aNotification
{
	NSWindow *window_ = [aNotification object];
	[window_ setAlphaValue:[[BSIPIDefaults sharedIPIDefaults] alphaValue]];
	if (m_shouldRestoreKeyWindow) {
		[window_ makeKeyWindow];
	}
	m_shouldRestoreKeyWindow = NO;
}

- (void)fullScreenDidEnd:(NSWindow *)fullScreenWindow
{
	if (m_shouldRestoreKeyWindow) {
		[[self window] makeKeyWindow];
	}
	m_shouldRestoreKeyWindow = NO;
}

- (void)tokenDidFailDownload:(NSNotification *)aNotification
{
	if (![[BSIPIDefaults sharedIPIDefaults] leaveFailedToken]) {
		[[self tripleGreenCubes] removeObject:[aNotification object]];
		[[self tripleGreenCubes] setSelectionIndex:NSNotFound];
	}
}

#pragma mark NSTableView Delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSTableView *tableView = [aNotification object];
	[tableView scrollRowToVisible:[tableView selectedRow]];
}

- (BOOL)tableView:(BSIPITableView *)aTableView shouldPerformKeyEquivalent:(NSEvent *)theEvent
{
	if ([aTableView selectedRow] == -1) return NO;
	
	int whichKey_ = [theEvent keyCode];

	if (whichKey_ == 51) { // delete key
		[[self tripleGreenCubes] remove:aTableView];
		return YES;
	}
	
	if (whichKey_ == 36) { // return key, option-return ro start fullscreen
		[self changePaneAndShow: aTableView];
		return YES;
	}
	return NO;
}

- (NSString *)tableView:(NSTableView *)aTableView
		 toolTipForCell:(NSCell *)aCell
				   rect:(NSRectPointer)rect
			tableColumn:(NSTableColumn *)aTableColumn
					row:(int)row
		  mouseLocation:(NSPoint)mouseLocation
{
	return [[self historyManager] toolTipStringAtIndex:row];
}

#pragma mark NSTabView Delegate
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSIndexSet *tmp_ = [[self tripleGreenCubes] selectionIndexes];
	if ([tmp_ count] > 1) {
		[[self tripleGreenCubes] setSelectionIndex:[tmp_ firstIndex]];
	}
	[[BSIPIDefaults sharedIPIDefaults] setLastShownViewTag:[tabView indexOfTabViewItem:tabViewItem]];
}

#pragma mark BSIPIImageView Delegate
- (BOOL)imageView:(BSIPIImageView *)aImageView writeSomethingToPasteboard:(NSPasteboard *)pboard
{
	return [[self historyManager] appendDataForTokenAtIndexes:[[self tripleGreenCubes] selectionIndexes]
												 toPasteboard:pboard
									  withFilenamesPboardType:YES];
}

- (void)imageView:(BSIPIImageView *)aImageView mouseDoubleClicked:(NSEvent *)theEvent
{
	if ([aImageView image]) [self startFullscreen:aImageView];
}

- (BOOL)imageView:(BSIPIImageView *)aImageView shouldPerformKeyEquivalent:(NSEvent *)theEvent
{
	BSIPIArrayController *controller = [self tripleGreenCubes];
	int modFlags = [theEvent modifierFlags];

	NSString	*pressedKey = [theEvent charactersIgnoringModifiers];
	unichar		keyChar = 0;

	unsigned int length = [pressedKey length];
	if (length != 1) {
		return NO;
	}

	keyChar = [pressedKey characterAtIndex:0];

	if (keyChar == NSLeftArrowFunctionKey) {
		if (modFlags & NSAlternateKeyMask) {
			[controller selectFirst:aImageView];
			return YES;
		} else if ([controller canSelectPrevious]) {
			[controller selectPrevious:aImageView];
			return YES;
		}
	}
	
	if (keyChar == NSRightArrowFunctionKey) {
		if (modFlags & NSAlternateKeyMask) {
			[controller selectLast:aImageView];
			return YES;
		} else if ([controller canSelectNext]) {
			[controller selectNext:aImageView];
			return YES;
		}
	}
	
	if (keyChar == NSDeleteCharacter) {
		[controller remove:aImageView];
		return YES;
	}

	if (keyChar == NSCarriageReturnCharacter) {
		if ([aImageView image]) {
			[self startFullscreen:aImageView];
			return YES;
		}
	}

	return NO;
}
@end
