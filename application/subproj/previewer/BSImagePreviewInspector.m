//
//  BSImagePreviewInspector.m
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

static NSString *const kIPINibFileNameKey		= @"BSImagePreviewInspector";
static NSString *const kIPIFrameAutoSaveNameKey	= @"BathyScaphe:ImagePreviewInspector Panel Autosave";
static NSString *const kIPIAlwaysKeyWindowKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Always Key Window";
static NSString *const kIPISaveDirectoryKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Save Directory";

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
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded : (NO == [self alwaysBecomeKey])];
	[[self window] setFrameAutosaveName : kIPIFrameAutoSaveNameKey];
	[[self window] setDelegate : self];
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

- (NSButton *) saveButton
{
	return m_saveButton;
}

- (NSImageView *) imageView
{
	return m_imageView;
}

- (NSProgressIndicator *) progIndicator
{
	return m_progIndicator;
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

- (TemporaryFolder *) dlFolder
{
	if (_dlFolder == nil) {
		_dlFolder = [[TemporaryFolder alloc] init];
	}
	return _dlFolder;
}

- (NSPanel *) settingsPanel
{
	return m_settingsPanel;
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
													   defaultValue : NO];
}
- (void) setAlwaysBecomeKey : (BOOL) alwaysKey
{
	[[[self preferences] imagePreviewerPrefsDict] setBool : alwaysKey forKey : kIPIAlwaysKeyWindowKey];
}

- (NSString *) saveDirectory
{
	return [[[self preferences] imagePreviewerPrefsDict] objectForKey : kIPISaveDirectoryKey
														defaultObject : [NSString stringWithFormat : @"%@/%@", NSHomeDirectory(), @"Desktop"]];
}

- (void) setSaveDirectory : (NSString *) aString
{
	[[[self preferences] imagePreviewerPrefsDict] setObject : aString forKey : kIPISaveDirectoryKey];
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
	[pboard_ setString:[[self sourceURL] absoluteString] forType:NSStringPboardType];
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
	[NSApp endSheet : [sender window]
		 returnCode : NSOKButton];
	[[sender window] close];
}

- (IBAction) openOpenPanel : (id) sender
{
	NSOpenPanel	*panel_;
	panel_ = [NSOpenPanel openPanel];
	[panel_ setCanChooseFiles : NO];
	[panel_ setCanChooseDirectories : YES];
	[panel_ setResolvesAliases : YES];
	if([panel_ runModalForTypes : nil] == NSOKButton) {
		[self setSaveDirectory : [panel_ directory]];
	}
}

- (IBAction) openImage : (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL : [self sourceURL] inBackGround : [[self preferences] openInBg]];
}

- (IBAction) openImageWithPreviewApp : (id) sender
{
	[[NSWorkspace sharedWorkspace] openFile : [self downloadedFileDestination] withApplication : @"Preview.app"];
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
	}
}

- (IBAction) cancelDownload : (id) sender
{
	if(_currentDownload) {
		id	tmp;
		[_currentDownload cancel];

		tmp = _currentDownload;
		_currentDownload = nil;
		[tmp release];

		[[self progIndicator] stopAnimation : self];
		[self setSourceURL : nil];
		[[self imageView] setImage : nil];
	}
}

- (void) switchActionToCancelMode : (BOOL) toCancelMode
{
	NSButton *targetBtn = [self saveButton];

	if (toCancelMode) {
		[targetBtn setTitle : [[NSBundle bundleForClass : [self class]] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil]];
		[targetBtn setTarget : self];
		[targetBtn setAction : @selector(cancelDownload:)];
		[[self actionBtn] setEnabled : NO];
	} else {
		[targetBtn setTitle : [[NSBundle bundleForClass : [self class]] localizedStringForKey:@"Save" value:@"Save" table:nil]];
		[targetBtn setTarget : self];
		[targetBtn setAction : @selector(saveImage:)];
		[[self actionBtn] setEnabled : YES];
	}
}

- (BOOL) downloadImageInBkgnd : (NSURL *) anURL
{
	NSURLRequest	*theRequest = [NSURLRequest requestWithURL : anURL];
	if(_currentDownload) {
		[_currentDownload cancel];
	}

	_currentDownload  = [[NSURLDownload alloc] initWithRequest : theRequest
													  delegate : self ];

	[self setSourceURL : anURL];
	[self switchActionToCancelMode : YES];
	return YES;
}

- (BOOL) showImageWithURL : (NSURL *) imageURL
{
	if (![[self window] isVisible])
		[self showWindow : self];

	return [self downloadImageInBkgnd : imageURL];
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

#pragma mark NSWindow Delegate

- (void) applicationWillTerminate : (NSNotification *) notification
{		
	[_dlFolder release];
	_dlFolder = nil;

	[[NSNotificationCenter defaultCenter] removeObserver : self];
}

#pragma mark Notification

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
	if (![[response MIMEType] hasPrefix : @"image/"])
		[dl cancel];
}

- (void) download : (NSURLDownload *) dl decideDestinationWithSuggestedFilename : (NSString *) filename
{
	NSString *savePath;
	savePath = [NSString stringWithFormat : @"%@/%@", [[self dlFolder] path], filename];

	[dl setDestination : savePath allowOverwrite : YES];
}

- (void) download : (NSURLDownload *) dl didCreateDestination : (NSString *) asDstPath
{
	[self setDownloadedFileDestination : asDstPath];
}

- (void) download : (NSURLDownload *) dl didReceiveDataOfLength : (unsigned) len
{
	[[self progIndicator] startAnimation : self];
}

- (void) downloadDidFinish : (NSURLDownload *) dl
{
	id tmp;

	NSImage *img = [[[NSImage alloc] initWithContentsOfFile : [self downloadedFileDestination]] autorelease];
	[[self progIndicator] stopAnimation : self];
	
	tmp = _currentDownload;
	_currentDownload = nil;
	[tmp release];

	[self switchActionToCancelMode : NO];
	[[self imageView] setImage : img];
}

- (void) download : (NSURLDownload *) dl didFailWithError : (NSError *) err
{
	id tmp;

	NSBeep();
	NSLog(@"%@",[err localizedDescription]);
	
	tmp = _currentDownload;
	_currentDownload = nil;
	[tmp release];

	[[self progIndicator] stopAnimation : self];
}
@end
