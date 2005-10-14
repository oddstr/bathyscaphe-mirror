//
//  BSImagePreviewInspector.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSImagePreviewInspector.h"

#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import <SGAppKit/NSWorkspace-SGExtensions.h>

static NSString *const kIPINibFileNameKey		= @"BSImagePreviewInspector";
static NSString *const kIPIFrameAutoSaveNameKey	= @"BathyScaphe:ImagePreviewInspector Panel Autosave";

@implementation BSImagePreviewInspector
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

- (id) init
{
	if (self = [self initWithWindowNibName : kIPINibFileNameKey]) {
		//
	}
	return self;
}

- (void) dealloc
{
	[_sourceURL release];
	[super dealloc];
}

- (void) awakeFromNib
{
	[(NSPanel*)[self window] setBecomesKeyOnlyIfNeeded : YES];
	[(NSPanel*)[self window] setFrameAutosaveName : kIPIFrameAutoSaveNameKey];
	[[self window] setDelegate : self];
}

#pragma mark Accessors

- (NSButton *) openWithBrowserBtn
{
	return m_openWithBrowserBtn;
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

#pragma mark For Cocoa Binding
- (NSString *) sourceURLAsString
{
	return [[self sourceURL] stringValue];
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

#pragma mark Actions
- (IBAction) openImage : (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL : [self sourceURL] inBackGround : NO];//[CMRPref openInBg]];
}

- (IBAction) saveImage : (id) sender
{
	NSURLRequest	*theRequest = [NSURLRequest requestWithURL : [self sourceURL]];
	NSURLDownload	*dlTask  = [[NSURLDownload alloc] initWithRequest : theRequest
															 delegate : self ];
	[dlTask autorelease];
}

- (BOOL) showImageWithURL : (NSURL *) imageURL
{
	if (![[self window] isVisible])
		[self showWindow : self];

	[self setSourceURL : imageURL]; // あとは Binding 任せ

	return YES;
}

#pragma mark NSWindow Delegate

- (void) windowWillClose : (NSNotification *) aNotification
{
	if ([self sourceURL] != nil) {
		[self setSourceURL : nil];
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
	// とりあえずデスクトップに保存
	savePath = [NSString stringWithFormat : @"%@/Desktop/%@", NSHomeDirectory(), filename];
	// NSLog(@"%@", savePath);

	[dl setDestination : savePath allowOverwrite : NO];
}

- (void) download : (NSURLDownload *) dl didReceiveDataOfLength : (unsigned) len
{
	// ダウンロードが短時間で終わる場合、プログレスインジケータが見えないまま終わってしまうほど。
	// NSImageView に表示した時点でどこかにデータがキャッシュされてるのかなぁ。
	[[self progIndicator] startAnimation : self];
}

- (void) downloadDidFinish : (NSURLDownload *) dl
{
	[[self progIndicator] stopAnimation : self];
}

- (void) download : (NSURLDownload *) dl didFailWithError : (NSError *) err
{
	NSBeep();
	NSLog(@"%@",[err localizedDescription]);
	[[self progIndicator] stopAnimation : self];
}
@end
