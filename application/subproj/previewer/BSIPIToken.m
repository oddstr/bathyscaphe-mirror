//
//  BSIPIToken.m
//  BathyScaphe ImagePreviewer 2.5
//
//  Created by Tsutomu Sawada on 06/11/26.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIToken.h"
#import <SGNetwork/BSIPIDownload.h>
#import <SGAppKit/NSWorkspace-SGExtensions.h>

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
		ipit_curDownload = [[BSIPIDownload alloc] initWithURLIdentifier: anURL delegate: self destination: aPath];
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

- (BSIPIDownload *) currentDownload
{
	return ipit_curDownload;
}

- (void) setCurrentDownload: (BSIPIDownload *) aDownload
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

- (void) cancelDownload
{
	BSIPIDownload *curDl = [self currentDownload];
	if (curDl != nil) {
		[[self currentDownload] cancel];
		[self setCurrentDownload: nil];
		[self setThumbnail: [[NSWorkspace sharedWorkspace] systemIconForType: kQuestionMarkIcon]];
		[self setStatusMessage: [self localizedStrForKey: @"Download Canceled"]];
	}
}

- (double) contentSize
{
	return ipit_contentSize;
}

- (double) downloadedSize
{
	return ipit_downloadedSize;
}

#pragma mark BSIPIDownload Delegates
- (void) bsIPIdownload: (BSIPIDownload *) aDownload willDownloadContentOfSize: (double) expectedLength
{
	[self setStatusMessage: [self localizedStrForKey: @"Downloading..."]];
	[self willChangeValueForKey: @"shouldIndeterminate"];
	shouldIndeterminate = NO;
	[self didChangeValueForKey: @"shouldIndeterminate"];
	[self willChangeValueForKey: @"contentSize"];
	ipit_contentSize = expectedLength;
	[self didChangeValueForKey: @"contentSize"];
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didDownloadContentOfSize: (double) downloadedLength
{
	[self willChangeValueForKey: @"downloadedSize"];
	ipit_downloadedSize = downloadedLength;
	[self didChangeValueForKey: @"downloadedSize"];
}

- (void) bsIPIdownloadDidFinish: (BSIPIDownload *) aDownload
{
	[self setDownloadedFilePath: [aDownload downloadedFilePath]];
	[self setCurrentDownload: nil];
	[self createThumbnailAndCalcImgSizeForPath: [self downloadedFilePath]];
}


- (BOOL) bsIPIdownload: (BSIPIDownload *) aDownload didRedirectToURL: (NSURL *) newURL
{
	return NO;
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didAbortRedirectionToURL: (NSURL *) anURL
{
//	[self setCurrentDownload: nil];
	[self cancelDownload];
	[self setStatusMessage: [self localizedStrForKey: @"Redirection Aborted"]];
}
/*
- (void) redirectionAlertDidEnd: (NSAlert *) alert returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
}
*/
- (void) bsIPIdownload: (BSIPIDownload *) aDownload didFailWithError: (NSError *) aError
{
	NSBeep();

	[self setStatusMessage: [NSString stringWithFormat: [self localizedStrForKey: @"Download Error (%i)"], [aError code]]];
	[self setThumbnail: [[NSWorkspace sharedWorkspace] systemIconForType: kAlertCautionIcon]];
	[self setCurrentDownload: nil];
}
@end
