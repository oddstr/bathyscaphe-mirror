//
//  BSIPIToken.m
//  BathyScaphe ImagePreviewer 2.5
//
//  Created by Tsutomu Sawada on 06/11/26.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIToken.h"
//#import <SGNetwork/BSIPIDownload.h>
#import <SGAppKit/NSWorkspace-SGExtensions.h>

NSString *const BSIPITokenDownloadErrorNotification = @"BSIPITokenDownloadErrorNotification";

@interface BSIPIToken(Private)
+ (NSImage *) loadingIndicator;
- (void) createThumbnailAndCalcImgSizeForPath: (NSString *) filePath;
- (NSString *) localizedStrForKey : (NSString *) key;
@end

@implementation BSIPIToken(Private)
+ (NSImage *) loadingIndicator
{
	static NSImage *loadingImage = nil;
	if (loadingImage == nil) {
		NSBundle *bundle_ = [NSBundle bundleForClass: self];
		NSString *filepath_ = [bundle_ pathForImageResource: @"Loading"];

		loadingImage = [[NSImage alloc] initWithContentsOfFile: filepath_];
	}
	return loadingImage;
}

- (void) createThumbnailAndCalcImgSizeForPath: (NSString *) filePath
{
	float initX, initY, thumbX;
	NSImageRep	*imageRep_ = [NSImageRep imageRepWithContentsOfFile: filePath];
	
	initX = [imageRep_ pixelsWide];
	initY = [imageRep_ pixelsHigh];
		
	[self setStatusMessage: [NSString stringWithFormat: [self localizedStrForKey: @"%.0f*%.0f pixel"], initX, initY]];

	thumbX = 32.0 * initX / initY;
	[imageRep_ setSize: NSMakeSize(thumbX, 32.0)];
	
	NSImage *image_ = [[NSImage alloc] initWithSize: NSMakeSize(thumbX, 32.0)];
	[image_ addRepresentation: imageRep_];
	[image_ setDataRetained: NO];
	
	[self setThumbnail: image_];
	[image_ release];
}

- (NSString *) localizedStrForKey : (NSString *) key
{
	NSBundle *selfBundle = [NSBundle bundleForClass: [self class]];
	return [selfBundle localizedStringForKey: key value: key table: nil];
}
@end

@implementation BSIPIToken
- (id) initWithURL: (NSURL *) anURL destination: (NSString *) aPath
{
	self = [super init];
	if (self != nil) {
		ipit_curDownload = [[BSURLDownload alloc] initWithURL:anURL delegate:self destination:aPath];
		if (ipit_curDownload == nil) return nil;

		[self setSourceURL: anURL];
		[self setThumbnail: [[self class] loadingIndicator]];
		[self setStatusMessage: [self localizedStrForKey: @"Start Downloading..."]];
		ipit_downloadedSize = 0;
		ipit_contentSize = 0;
		shouldIndeterminate = YES;
	}
	return self;
}

- (void) dealloc
{
	[ipit_curDownload release];
	[ipit_statusMsg release];
	[ipit_thumbnail release];
	[ipit_downloadedFilePath release];
	[ipit_sourceURL release];
	[super dealloc];
}

- (NSURL *) sourceURL
{
	return ipit_sourceURL;
}

- (void) setSourceURL: (NSURL *) anURL
{
	[anURL retain];
	[ipit_sourceURL release];
	ipit_sourceURL = anURL;
}

- (NSString *) downloadedFilePath
{
	return ipit_downloadedFilePath;
}

- (void) setDownloadedFilePath: (NSString *) aString
{
	[aString retain];
	[ipit_downloadedFilePath release];
	ipit_downloadedFilePath = aString;
}

- (NSImage *) thumbnail
{
	return ipit_thumbnail;
}

- (void) setThumbnail: (NSImage *) anImage
{
	[anImage retain];
	[ipit_thumbnail release];
	ipit_thumbnail = anImage;
}

- (NSString *) statusMessage
{
	return ipit_statusMsg;
}

- (void) setStatusMessage: (NSString *) aString
{
	[aString retain];
	[ipit_statusMsg release];
	ipit_statusMsg = aString;
}

- (BSURLDownload *) currentDownload
{
	return ipit_curDownload;
}

- (void) setCurrentDownload: (BSURLDownload *) aDownload
{
	[self willChangeValueForKey: @"isDownloading"];
	[aDownload retain];
	[ipit_curDownload release];
	ipit_curDownload = aDownload;
	[self didChangeValueForKey: @"isDownloading"];
}

- (BOOL) isFileExists
{
	return ([self downloadedFilePath] != nil);
}

- (BOOL) isDownloading
{
	return ([self currentDownload] != nil);
}

- (void) postErrorNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName: BSIPITokenDownloadErrorNotification object: self];
}

- (void) cancelDownload
{
	BSURLDownload *curDl = [self currentDownload];
	if (curDl != nil) {
		[[self currentDownload] cancel];
		[self setCurrentDownload: nil];
		[self setThumbnail: [[NSWorkspace sharedWorkspace] systemIconForType: kQuestionMarkIcon]];
		[self setStatusMessage: [self localizedStrForKey: @"Download Canceled"]];
		[self postErrorNotification];
	}
}

- (void)retryDownload:(id)destination
{
	if ([self currentDownload]) return;
/*
	NSString *downloadedFilePathIfExists = [self downloadedFilePath];
	if (downloadedFilePathIfExists && [[NSFileManager defaultManager] fileExistsAtPath:downloadedFilePathIfExists]) {
		[[NSFileManager defaultManager] removeFileAtPath:downloadedFilePathIfExists handler:nil];
	}
*/
	[self setCurrentDownload:[[[BSURLDownload alloc] initWithURL:[self sourceURL] delegate:self destination:destination] autorelease]];
	[self setThumbnail:[[self class] loadingIndicator]];
	[self setStatusMessage:[self localizedStrForKey:@"Start Downloading..."]];
	ipit_downloadedSize = 0;
	ipit_contentSize = 0;
	shouldIndeterminate = YES;
}

- (double) contentSize
{
	return ipit_contentSize;
}

- (double) downloadedSize
{
	return ipit_downloadedSize;
}

#pragma mark BSURLDownload Delegates
- (void)bsURLDownload:(BSURLDownload *)aDownload willDownloadContentOfSize:(double)expectedLength
{
	[self setStatusMessage: [self localizedStrForKey: @"Downloading..."]];
	[self willChangeValueForKey: @"shouldIndeterminate"];
	shouldIndeterminate = NO;
	[self didChangeValueForKey: @"shouldIndeterminate"];
	[self willChangeValueForKey: @"contentSize"];
	ipit_contentSize = expectedLength;
	[self didChangeValueForKey: @"contentSize"];
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didDownloadContentOfSize:(double)downloadedLength
{
	NSString *tmp;
	[self willChangeValueForKey: @"downloadedSize"];
	ipit_downloadedSize = downloadedLength;
	[self didChangeValueForKey: @"downloadedSize"];
	tmp = [NSString stringWithFormat:@"%.0f KB / %.0f KB", ipit_downloadedSize/1024, ipit_contentSize/1024];
	[self setStatusMessage:tmp];
}

- (void)bsURLDownloadDidFinish:(BSURLDownload *)aDownload
{
	[self setDownloadedFilePath: [aDownload downloadedFilePath]];
	[self setCurrentDownload: nil];
	[self createThumbnailAndCalcImgSizeForPath: [self downloadedFilePath]];
}

- (BOOL)bsURLDownload:(BSURLDownload *)aDownload shouldRedirectToURL:(NSURL *)newURL
{
	NSString	*extension = [[[newURL path] pathExtension] lowercaseString];
	if(!extension) return NO;
		
	return [[NSImage imageFileTypes] containsObject: extension];
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didAbortRedirectionToURL:(NSURL *)anURL
{
	NSBeep();

	[self setStatusMessage: [self localizedStrForKey: @"Download Canceled"]];
	[self setThumbnail: [[NSWorkspace sharedWorkspace] systemIconForType: kQuestionMarkIcon]];
	[self setCurrentDownload: nil];
	[self setStatusMessage: [self localizedStrForKey: @"Redirection Aborted"]];
	[self postErrorNotification];
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didFailWithError:(NSError *)aError
{
	NSBeep();

	[self setStatusMessage: [NSString stringWithFormat: [self localizedStrForKey: @"Download Error (%i)"], [aError code]]];
	[self setThumbnail: [[NSWorkspace sharedWorkspace] systemIconForType: kAlertCautionIcon]];
	[self setCurrentDownload: nil];
	[self postErrorNotification];
}
@end
