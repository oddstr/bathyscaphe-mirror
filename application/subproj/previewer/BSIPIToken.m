//
//  BSIPIToken.m
//  BathyScaphe ImagePreviewer 2.8
//
//  Created by Tsutomu Sawada on 06/11/26.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSIPIToken.h"
#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import <ApplicationServices/ApplicationServices.h>

NSString *const BSIPITokenDownloadErrorNotification = @"BSIPITokenDownloadErrorNotification";

@interface BSIPIToken(Private)
+ (NSImage *)loadingIndicator;
- (BOOL)createThumbnailAndCalcImgSizeForPath:(NSString *)filePath;
- (NSString *)localizedStrForKey:(NSString *)key;
@end


@implementation BSIPIToken(Private)
+ (NSImage *)loadingIndicator
{
	static NSImage *loadingImage = nil;
	if (!loadingImage) {
		NSBundle *bundle_ = [NSBundle bundleForClass:self];
		NSString *filepath_ = [bundle_ pathForImageResource:@"Loading"];

		loadingImage = [[NSImage alloc] initWithContentsOfFile:filepath_];
	}
	return loadingImage;
}

- (NSString *)createExifInfoStringFromImageRep:(NSBitmapImageRep *)imageRep
{
	NSDictionary *dict = [imageRep valueForProperty:NSImageEXIFData];
	if (!dict) return nil;

	NSString *focalLengthStr, *fNumberStr, *exposureTimeStr, *isoSpeedStr;

	NSNumber *focalLengthObj = [dict objectForKey:(NSString *)kCGImagePropertyExifFocalLength];
	focalLengthStr = focalLengthObj ? [focalLengthObj stringValue] : @"(N/A)";

	NSNumber *fNumberObj = [dict objectForKey:(NSString *)kCGImagePropertyExifFNumber];
	fNumberStr = fNumberObj ? [fNumberObj stringValue] : @"(N/A)";

	NSNumber *exposureTimeObj = (NSNumber *)[dict objectForKey:(NSString *)kCGImagePropertyExifExposureTime];
	exposureTimeStr = exposureTimeObj ? [NSString stringWithFormat:@"1/%.0f", (1/[exposureTimeObj floatValue])] : @"(N/A)";
	
	NSArray *isoSpeedObj = [dict objectForKey:(NSString *)kCGImagePropertyExifISOSpeedRatings];
	isoSpeedStr = isoSpeedObj ? [[isoSpeedObj objectAtIndex:0] stringValue] : @"(N/A)";

	return [NSString stringWithFormat:@"%@mm, F%@, %@, ISO%@", focalLengthStr, fNumberStr, exposureTimeStr, isoSpeedStr];
}

- (BOOL)createThumbnailAndCalcImgSizeForPath:(NSString *)filePath
{
	float initX, initY, thumbX;
	NSImageRep	*imageRep_ = [NSImageRep imageRepWithContentsOfFile:filePath];
	if (!imageRep_) {
		[self setStatusMessage:[self localizedStrForKey:@"Can't get imageRep"]];
		[self setThumbnail:[[NSWorkspace sharedWorkspace] systemIconForType:kQuestionMarkIcon]];
		return NO;
	} else {
		if ([imageRep_ isKindOfClass:[NSBitmapImageRep class]]) {
			NSString *str = [self createExifInfoStringFromImageRep:(NSBitmapImageRep *)imageRep_];
			[self setExifInfoString:str];
		}
	}
	initX = [imageRep_ pixelsWide];
	initY = [imageRep_ pixelsHigh];
		
	[self setStatusMessage:[NSString stringWithFormat:[self localizedStrForKey:@"%.0f*%.0f pixel"], initX, initY]];

	thumbX = 32.0 * initX / initY;
	[imageRep_ setSize:NSMakeSize(thumbX, 32.0)];
	
	NSImage *image_ = [[NSImage alloc] initWithSize:NSMakeSize(thumbX, 32.0)];
	[image_ addRepresentation:imageRep_];
	[image_ setDataRetained:NO];

	[self setThumbnail:image_];
	[image_ release];
	return YES;
}

- (NSString *)localizedStrForKey:(NSString *)key
{
	NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
	return [selfBundle localizedStringForKey:key value:key table:nil];
}
@end


@implementation BSIPIToken
- (id)initWithURL:(NSURL *)anURL destination:(NSString *)aPath
{
	if (self = [super init]) {
		ipit_curDownload = [[BSURLDownload alloc] initWithURL:anURL delegate:self destination:aPath];
		if (!ipit_curDownload) return nil;

		[self setSourceURL:anURL];
		[self setThumbnail:[[self class] loadingIndicator]];
		[self setStatusMessage:[self localizedStrForKey:@"Start Downloading..."]];
		ipit_downloadedSize = 0;
		ipit_contentSize = 0;
		shouldIndeterminate = YES;
	}
	return self;
}

- (void)dealloc
{
	[ipit_curDownload release];
	[ipit_statusMsg release];
	[ipit_thumbnail release];
	[ipit_downloadedFilePath release];
	[ipit_sourceURL release];
	[super dealloc];
}

- (NSURL *)sourceURL
{
	return ipit_sourceURL;
}

- (void)setSourceURL:(NSURL *)anURL
{
	[anURL retain];
	[ipit_sourceURL release];
	ipit_sourceURL = anURL;
}

- (NSString *)downloadedFilePath
{
	return ipit_downloadedFilePath;
}

- (void)setDownloadedFilePath:(NSString *)aString
{
	[aString retain];
	[ipit_downloadedFilePath release];
	ipit_downloadedFilePath = aString;
}

- (NSImage *)thumbnail
{
	return ipit_thumbnail;
}

- (void)setThumbnail:(NSImage *)anImage
{
	[anImage retain];
	[ipit_thumbnail release];
	ipit_thumbnail = anImage;
}

- (NSString *)statusMessage
{
	return ipit_statusMsg;
}

- (void)setStatusMessage:(NSString *)aString
{
	[aString retain];
	[ipit_statusMsg release];
	ipit_statusMsg = aString;
}

- (NSString *)exifInfoString
{
	return ipit_exifInfoStr;
}

- (void)setExifInfoString:(NSString *)aString
{
	[aString retain];
	[ipit_exifInfoStr release];
	ipit_exifInfoStr = aString;
}

- (BSURLDownload *)currentDownload
{
	return ipit_curDownload;
}

- (void)setCurrentDownload:(BSURLDownload *)aDownload
{
	[self willChangeValueForKey:@"isDownloading"];
	[aDownload retain];
	[ipit_curDownload release];
	ipit_curDownload = aDownload;
	[self didChangeValueForKey:@"isDownloading"];
}

- (BOOL)isFileExists
{
	return ([self downloadedFilePath] != nil);
}

- (BOOL)isDownloading
{
	return ([self currentDownload] != nil);
}

- (void)postErrorNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:BSIPITokenDownloadErrorNotification object:self];
}

- (void)cancelDownload
{
	BSURLDownload *curDl = [self currentDownload];
	if (curDl) {
		[[self currentDownload] cancel];
		[self setCurrentDownload:nil];
		[self setThumbnail:[[NSWorkspace sharedWorkspace] systemIconForType:kQuestionMarkIcon]];
		[self setStatusMessage:[self localizedStrForKey:@"Download Canceled"]];
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

- (double)contentSize
{
	return ipit_contentSize;
}

- (double)downloadedSize
{
	return ipit_downloadedSize;
}

#pragma mark BSURLDownload Delegates
- (void)bsURLDownload:(BSURLDownload *)aDownload willDownloadContentOfSize:(double)expectedLength
{
	[self setStatusMessage:[self localizedStrForKey:@"Downloading..."]];
	[self willChangeValueForKey:@"shouldIndeterminate"];
	shouldIndeterminate = NO;
	[self didChangeValueForKey:@"shouldIndeterminate"];
	[self willChangeValueForKey:@"contentSize"];
	ipit_contentSize = expectedLength;
	[self didChangeValueForKey:@"contentSize"];
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didDownloadContentOfSize:(double)downloadedLength
{
	NSString *tmp;
	[self willChangeValueForKey:@"downloadedSize"];
	ipit_downloadedSize = downloadedLength;
	[self didChangeValueForKey:@"downloadedSize"];
	tmp = [NSString stringWithFormat:@"%.0f KB / %.0f KB", ipit_downloadedSize/1024, ipit_contentSize/1024];
	[self setStatusMessage:tmp];
}

- (void)bsURLDownloadDidFinish:(BSURLDownload *)aDownload
{
	[self setDownloadedFilePath:[aDownload downloadedFilePath]];
	[self setCurrentDownload:nil];
	if (![self createThumbnailAndCalcImgSizeForPath:[self downloadedFilePath]]) {
		[self postErrorNotification];
	}
}

- (BOOL)bsURLDownload:(BSURLDownload *)aDownload shouldRedirectToURL:(NSURL *)newURL
{
	CFStringRef extensionRef = CFURLCopyPathExtension((CFURLRef)newURL);
	if (!extensionRef) {
		return NO;
	}

	NSString *extension = [(NSString *)extensionRef lowercaseString];
	CFRelease(extensionRef);
		
	return [[NSImage imageFileTypes] containsObject:extension];
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didAbortRedirectionToURL:(NSURL *)anURL
{
	NSBeep();

	[self setStatusMessage:[self localizedStrForKey:@"Download Canceled"]];
	[self setThumbnail:[[NSWorkspace sharedWorkspace] systemIconForType:kQuestionMarkIcon]];
	[self setCurrentDownload:nil];
	[self setStatusMessage:[self localizedStrForKey:@"Redirection Aborted"]];
	[self postErrorNotification];
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didFailWithError:(NSError *)aError
{
	NSBeep();

	[self setStatusMessage:[aError localizedDescription]];
	[self setThumbnail:[[NSWorkspace sharedWorkspace] systemIconForType:kAlertCautionIcon]];
	[self setCurrentDownload:nil];
	[self postErrorNotification];
}
@end
