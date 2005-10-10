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

#import "AppDefaults.h"

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
}

#pragma mark Accessors

- (NSButton *) openWithBrowserBtn
{
	return m_openWithBrowserBtn;
}

- (NSImageView *) imageView
{
	return m_imageView;
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
	[[NSWorkspace sharedWorkspace] openURL : [self sourceURL] inBackGround : [CMRPref openInBg]];
}

- (BOOL) showImageWithURL : (NSURL *) imageURL
{
	if (![[self window] isVisible])
		[self showWindow : self];

	[self setSourceURL : imageURL]; // あとは Binding 任せ

	return YES;
}
@end
