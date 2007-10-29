//
//  BSIPIToken.h
//  BathyScaphe ImagePreviewer 2.5
//
//  Created by Tsutomu Sawada on 06/11/26.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BSURLDownload;

@interface BSIPIToken : NSObject {
	@private
	NSURL		*ipit_sourceURL;
	NSString	*ipit_downloadedFilePath;
	NSImage		*ipit_thumbnail;
	NSString	*ipit_statusMsg;
	BSURLDownload	*ipit_curDownload;
	
	double		ipit_contentSize;
	double		ipit_downloadedSize;
	BOOL		shouldIndeterminate;
}

- (id) initWithURL: (NSURL *) anURL destination: (NSString *) aPath;

- (NSURL *) sourceURL;
- (void) setSourceURL: (NSURL *) anURL;
- (NSString *) downloadedFilePath;
- (void) setDownloadedFilePath: (NSString *) aString;
- (NSImage *) thumbnail;
- (void) setThumbnail: (NSImage *) anImage;
- (NSString *) statusMessage;
- (void) setStatusMessage: (NSString *) aString;

- (BSURLDownload *) currentDownload;

- (BOOL) isFileExists;
- (BOOL) isDownloading;

- (double) contentSize;
- (double) downloadedSize;

- (void) cancelDownload;
- (void)retryDownload:(id)destination; // Available in 2.6.1 and later.
@end

extern NSString *const BSIPITokenDownloadErrorNotification;
