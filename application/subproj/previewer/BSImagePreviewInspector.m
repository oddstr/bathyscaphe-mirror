//
//  $Id: BSImagePreviewInspector.m,v 1.7.2.4 2006/02/27 17:31:50 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSImagePreviewInspector.h"

#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import <SGFoundation/NSDictionary-SGExtensions.h>
#import <SGFoundation/NSMutableDictionary-SGExtensions.h>
#import "TemporaryFolder.h"
#import "BSIPIHistoryManager.h"
#import "BSIPIFullScreenController.h"

NSString *const kIPITbCancelBtnId		= @"CancelAndSave";

static NSString *const kIPINibFileNameKey		= @"BSImagePreviewInspector";
static NSString *const kIPIFrameAutoSaveNameKey	= @"BathyScaphe:ImagePreviewInspector Panel Autosave";
static NSString *const kIPIAlwaysKeyWindowKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Always Key Window";
static NSString *const kIPISaveDirectoryKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Save Directory";
static NSString *const kIPIAlphaValueKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Window Alpha Value";
static NSString *const kIPIOpaqueWhenKeyWindowKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Opaque When Key Window";

@implementation BSImagePreviewInspector
- (id) initWithPreferences : (AppDefaults *) prefs
{
	if (self = [super initWithWindowNibName : kIPINibFileNameKey]) {
		[self setPreferences : prefs];
		_dlFolder = [[TemporaryFolder alloc] init];
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
	[_downloadedFileDestination release];
	[_dlFolder release];
	[_sourceURL release];
	[super dealloc];
}

- (void) awakeFromNib
{
	id<NSMenuItem>	iter;
	[[self window] setFrameAutosaveName : kIPIFrameAutoSaveNameKey];
	[[self window] setDelegate : self];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded : (NO == [self alwaysBecomeKey])];
	[[self window] setAlphaValue : [self alphaValue]];

	iter = [[[self actionBtn] menu] itemAtIndex : 0];
	[iter setImage : [self imageResourceWithName: @"Gear"]];
	
	[self setupToolbar];
	[[self window] useOptimizedDrawing : YES];
}

#pragma mark Accessors
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

- (NSURLDownload *) currentDownload
{
	return _currentDownload;
}
- (void) setCurrentDownload : (NSURLDownload *) aDownload
{
	id		tmp;
	
	tmp = _currentDownload;
	_currentDownload = [aDownload retain];
	[tmp release];
}

- (TemporaryFolder *) dlFolder
{
	if (_dlFolder == nil) {
		_dlFolder = [[TemporaryFolder alloc] init];
	}
	return _dlFolder;
}

- (NSString *) downloadedFileDestination
{
	return _downloadedFileDestination;
}

- (void) setDownloadedFileDestination : (NSString *) aPath
{
	[aPath retain];
	[_downloadedFileDestination release];
	_downloadedFileDestination = aPath;
}

#pragma mark For Cocoa Binding
- (NSString *) sourceURLAsString
{
	return [[[self sourceURL] absoluteString] lastPathComponent];
}

- (NSURL *) sourceURL
{
	return _sourceURL;
}
- (void) setSourceURL : (NSURL *) newURL
{
	[self willChangeValueForKey:@"sourceURLAsString"];

	[newURL retain];
	[_sourceURL release];
	_sourceURL = newURL;

	[self didChangeValueForKey:@"sourceURLAsString"];
}

- (BOOL) alwaysBecomeKey
{
	return [[[self preferences] imagePreviewerPrefsDict] boolForKey : kIPIAlwaysKeyWindowKey
													   defaultValue : YES];
}
- (void) setAlwaysBecomeKey : (BOOL) alwaysKey
{
	[[[self preferences] imagePreviewerPrefsDict] setBool : alwaysKey forKey : kIPIAlwaysKeyWindowKey];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded : (NO == alwaysKey)];
}

- (NSString *) saveDirectory
{
	return [[[self preferences] imagePreviewerPrefsDict] objectForKey : kIPISaveDirectoryKey
														defaultObject : [NSHomeDirectory() stringByAppendingPathComponent : @"Desktop"]];
}

- (void) setSaveDirectory : (NSString *) aString
{
	[[[self preferences] imagePreviewerPrefsDict] setObject : aString forKey : kIPISaveDirectoryKey];
}

- (float) alphaValue
{
	return [[[self preferences] imagePreviewerPrefsDict] floatForKey : kIPIAlphaValueKey
														defaultValue : 1.0];
}

- (void) setAlphaValue : (float) newValue
{
	[[[self preferences] imagePreviewerPrefsDict] setFloat : newValue forKey : kIPIAlphaValueKey];
	[[self window] setAlphaValue : newValue];
}

- (BOOL) opaqueWhenKey
{
	return [[[self preferences] imagePreviewerPrefsDict] boolForKey : kIPIOpaqueWhenKeyWindowKey
													   defaultValue : NO];
}

- (void) setOpaqueWhenKey : (BOOL) opaqueWhenKey
{
	[[[self preferences] imagePreviewerPrefsDict] setBool : opaqueWhenKey forKey : kIPIOpaqueWhenKeyWindowKey];
}

#pragma mark Actions
- (IBAction) copyURL : (id) sender
{
	NSPasteboard	*pboard_   = [NSPasteboard generalPasteboard];
	NSArray			*types_;

	types_ = [NSArray arrayWithObjects : 
				NSURLPboardType,
				NSStringPboardType,
				nil];
	
	[pboard_ declareTypes:types_ owner:nil];
	
	[[self sourceURL] writeToPasteboard : pboard_];
	[pboard_ setString : [[self sourceURL] absoluteString] forType : NSStringPboardType];
}

- (IBAction) beginSettingsSheet : (id) sender
{
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
}

- (IBAction) openImage : (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL : [self sourceURL] inBackGround : [[self preferences] openInBg]];
}

- (IBAction) openImageWithPreviewApp : (id) sender
{
	[[NSWorkspace sharedWorkspace] openFile : [self downloadedFileDestination] withApplication : @"Preview.app"];
}

- (IBAction) startFullscreen : (id) sender
{
	[[BSIPIFullScreenController sharedInstance] showPanelWithImage : [[self imageView] image]];
}

- (IBAction) saveImage : (id) sender
{
	NSFileManager	*fm_ = [NSFileManager defaultManager];
	NSString		*fPath_ = [self downloadedFileDestination];
	NSString		*dest_ = [[self saveDirectory] stringByAppendingPathComponent : [fPath_ lastPathComponent]];

	if (![fm_ fileExistsAtPath : dest_]) {
		[fm_ copyPath : fPath_ toPath : dest_ handler : nil];
	} else {
		NSBeep();
		NSLog(@"Could not save the file %@ because same file already exists.", [fPath_ lastPathComponent]);
	}
}

- (IBAction) cancelDownload : (id) sender
{
	if(_currentDownload) {
		[_currentDownload cancel];
		[self setCurrentDownload : nil];

		[[self progIndicator] stopAnimation : self];
		[[self progIndicator] setHidden : YES];
		[self setSourceURL : nil];
		[[self imageView] setImage : nil];
	}
}

- (void) switchActionToCancelMode : (BOOL) toCancelMode
{
	NSArray	*itemArray_ = [[[self window] toolbar] items];
	NSEnumerator *enum_ = [itemArray_ objectEnumerator];

	id	each_;
	NSToolbarItem *targetBtn = nil;
	while (each_ = [enum_ nextObject]) {
		if ([[each_ itemIdentifier] isEqualToString : kIPITbCancelBtnId])
			targetBtn = each_;
	}
	if(targetBtn == nil) return;
	if (toCancelMode) {
		[targetBtn setLabel : [self localizedStrForKey : @"Stop"]];
		[targetBtn setToolTip: [self localizedStrForKey : @"StopTip"]];
		[targetBtn setImage: [NSImage imageNamed: @"stopSign"]];
		[targetBtn setTarget : self];
		[targetBtn setAction : @selector(cancelDownload:)];
	} else {
		[targetBtn setLabel : [self localizedStrForKey : @"Save"]];
		[targetBtn setToolTip: [self localizedStrForKey : @"SaveTip"]];
		[targetBtn setImage: [self imageResourceWithName: @"Save"]];
		[targetBtn setTarget : self];
		[targetBtn setAction : @selector(saveImage:)];
	}
}

- (BOOL) downloadImageInBkgnd : (NSURL *) anURL
{
	NSURLRequest	*theRequest = [NSURLRequest requestWithURL : anURL];

	if(_currentDownload)
		[_currentDownload cancel];

	_currentDownload  = [[NSURLDownload alloc] initWithRequest : theRequest
													  delegate : self ];

	if([[self imageView] image] != nil)
		[[self imageView] setImage : nil];

	[[self infoField] setStringValue : @""];
	[self setSourceURL : anURL];
	[[self progIndicator] setIndeterminate : YES];
	[[self progIndicator] setHidden : NO];
	[[self progIndicator] startAnimation : self];

	[self switchActionToCancelMode : YES];
	return YES;
}

- (BOOL) showCachedImage : (NSString *) path ofURL : (NSURL *) anURL
{
	if(_currentDownload) {
		[_currentDownload cancel];
		[self setCurrentDownload : nil];
	}	

	NSImageView	*imageView_ = [self imageView];
	if([imageView_ image] != nil)
		[imageView_ setImage : nil];

	[[self infoField] setStringValue : @""];
	[self setSourceURL : anURL];

	[[self progIndicator] setIndeterminate : YES];
	[[self progIndicator] setHidden : NO];
	[[self progIndicator] startAnimation : self];

	[self switchActionToCancelMode : YES];
	[self setDownloadedFileDestination : path];
	NSImage *img = [[[NSImage alloc] initWithContentsOfFile : path] autorelease];

	[[self progIndicator] stopAnimation : self];
	[[self progIndicator] setHidden : YES];

	if (img) {
		//NSLog(@"Load from temporary (already downloaded) file.");
		[[self infoField] setStringValue : [self calcImageSize : img]];
		[self switchActionToCancelMode : NO];
		[imageView_ setImage : img];
		return YES;
	} else {
		NSLog(@"Can't load from temp file, so download it again.");
		return [self downloadImageInBkgnd : anURL];
	}
}

- (BOOL) showImageWithURL : (NSURL *) imageURL
{
	NSString *cachedFilePath;
	if (![[self window] isVisible])
		[self showWindow : self];

	cachedFilePath = [[BSIPIHistoryManager sharedManager] cachedFilePathForURL : imageURL];
	return (cachedFilePath != nil) ? [self showCachedImage : cachedFilePath ofURL : imageURL] : [self downloadImageInBkgnd : imageURL];
}

- (BOOL) validateLink : (NSURL *) anURL
{
	// from MosaicPreview
	NSArray		*imageExtensions;
	NSString	*extension;
	
	extension = [[[anURL path] pathExtension] lowercaseString];
	if(!extension) return NO;
	
	imageExtensions = [NSImage imageFileTypes];
	
	return [imageExtensions containsObject : extension];
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

#pragma mark NSWindow Delegate
- (void) windowWillClose : (NSNotification *) aNotification
{
	if ([self sourceURL] != nil) {
		[self setSourceURL : nil];
		[[self imageView] setImage : nil];
	}
}
	
#pragma mark NSURLDownload Delegate

- (void)  download : (NSURLDownload *) dl didReceiveResponse : (NSURLResponse *) response
{
	NSProgressIndicator	*bar_ =[self progIndicator];
	lExLength = [response expectedContentLength];

	if (lExLength != NSURLResponseUnknownLength) {
		[bar_ setIndeterminate : NO];
		[bar_ setMinValue : 0];
		[bar_ setMaxValue : lExLength];
	}

	lDlLength = 0;
}

- (NSURLRequest *) download : (NSURLDownload *) download willSendRequest : (NSURLRequest *) request
		   redirectResponse : (NSURLResponse *) redirectResponse
{
	if(![self validateLink : [request URL]]) {
		NSLog(@"Redirection blocked");
		return nil;
	}
	return request;
}

- (void) download : (NSURLDownload *) dl decideDestinationWithSuggestedFilename : (NSString *) filename
{
	NSString *savePath;
	savePath = [[[self dlFolder] path] stringByAppendingPathComponent : filename];

	[dl setDestination : savePath allowOverwrite : YES];
}

- (void) download : (NSURLDownload *) dl didCreateDestination : (NSString *) asDstPath
{
	[self setDownloadedFileDestination : asDstPath];
}

- (void) download : (NSURLDownload *) dl didReceiveDataOfLength : (unsigned) len
{
	NSProgressIndicator	*bar_ = [self progIndicator];

	lDlLength += len;

	if (lExLength != NSURLResponseUnknownLength)
		[bar_ setDoubleValue : lExLength];
}

- (void) downloadDidFinish : (NSURLDownload *) dl
{
	[[self progIndicator] stopAnimation : self];
	[[self progIndicator] setHidden : YES];
	
	[self setCurrentDownload : nil];

	NSImage *img = [[[NSImage alloc] initWithContentsOfFile : [self downloadedFileDestination]] autorelease];
	if (img) {
		[[self infoField] setStringValue : [self calcImageSize : img]];

		[[BSIPIHistoryManager sharedManager] addItemOfURL : [self sourceURL] andPath : [self downloadedFileDestination]];
		[self switchActionToCancelMode : NO];
		[[self imageView] setImage : img];
	} else {
		[self setSourceURL : nil];
	}
}

- (void) download : (NSURLDownload *) dl didFailWithError : (NSError *) err
{
	NSBeep();
	NSLog(@"%@",[err localizedDescription]);
	
	[self setCurrentDownload : nil];

	[[self progIndicator] stopAnimation : self];
	[[self progIndicator] setHidden : YES];
	[self setSourceURL : nil];
}
@end
