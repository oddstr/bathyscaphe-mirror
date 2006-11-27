//
//  BSIPIToken.h
//  BathyScaphe ImagePreviewer 2.5
//
//  Created by Tsutomu Sawada on 06/11/26.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BSIPIDownload;

@interface BSIPIToken : NSObject {
	@private
	NSURL		*ipit_sourceURL;
	NSString	*ipit_downloadedFilePath;
	NSImage		*ipit_thumbnail;
	NSString	*ipit_statusMsg;
	BSIPIDownload	*ipit_curDownload;
	
	long long	ipit_contentSize;
	long long	ipit_downloadedSize;
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

- (BSIPIDownload *) currentDownload;

- (BOOL) isFileExists;
- (BOOL) isDownloading;

- (double) contentSize;
- (double) downloadedSize;

- (void) cancelDownload;
@end
