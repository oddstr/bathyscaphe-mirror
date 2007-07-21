//
//  CMRDownloader.h
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMRTask.h"

@interface CMRDownloader : NSObject<CMRTask>
{
	@private
	id					_identifier;
	NSURLConnection		*m_connector;
	NSMutableData		*m_data;
	NSString			*m_statusMessage;
	BOOL				m_isInProgress;
	double				m_amount;
	double				m_expectedLength;
}

- (NSDictionary *) requestHeaders;
- (NSURLConnection *)currentConnector;

- (id) identifier;
- (void) setIdentifier : (id) anIdentifier;
- (NSURL *) boardURL;
- (NSURL *) resourceURL;
- (NSString *) filePathToWrite;

- (NSMutableData *)resourceData;
- (void)setResourceData:(NSMutableData *)data;

- (void)setMessage:(NSString *)msg;
- (void)setAmount:(double)doubleValue;
@end


@interface CMRDownloader(LoadingResourceData)
- (void) loadInBackground;
- (BOOL)dataProcess:(NSData *)resourceData withConnector:(NSURLConnection *)connector;
- (void)didFinishLoading:(NSURLConnection *)connector;
@end


@interface CMRDownloader(CMRDownloader)
- (void) startLoadInBackground;
- (void) cancelDownload;
- (BOOL) isDownloadInProgress;
- (void)setIsDownloadInProgress:(BOOL)inProgress;
@end

extern NSString *const CMRDownloaderNotFoundNotification;

// UserInfo
#define CMRDownloaderUserInfoContentsKey		@"Contents"
#define CMRDownloaderUserInfoResourceURLKey		@"ResourceURL"
#define CMRDownloaderUserInfoIdentifierKey		@"Identifier"
// for thread only.
#define CMRDownloaderUserInfoNextIndexKey		@"NextIndex"
