/**
  * $Id: CMRDownloader.h,v 1.1.1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * CMRDownloader.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRTask.h"

@class		SGHTTPConnector;
@protocol	w2chConnect;



@interface CMRDownloader : NSObject <CMRTask>
{
	@private
	id					_identifier;
	SGHTTPConnector		*_connector;
}

- (NSDictionary *) requestHeaders;
- (SGHTTPConnector *) currentConnector;

- (id) identifier;
- (void) setIdentifier : (id) anIdentifier;
- (NSURL *) boardURL;
- (NSURL *) resourceURL;
- (NSString *) filePathToWrite;
- (NSData *) resourceData;
@end



@interface CMRDownloader(LoadingResourceData)
- (void) loadInBackground;
- (BOOL) dataProcess : (NSData      *) resourceData
       withConnector : (NSURLHandle *) connector;
- (void) didFinishLoading : (NSURLHandle *) connector;
@end



@interface CMRDownloader(URLHandleClient)<NSURLHandleClient>
- (SGHTTPConnector *) HTTPConnectorCastURLHandle : (NSURLHandle *) handler;
@end



@interface CMRDownloader(CMRDownloader)
- (void) startLoadInBackground;
- (void) cancelDownload;
- (BOOL) isCanceledLoadInBackground;
- (BOOL) isDownloadInProgress;
- (NSURLHandleStatus) downloadStatus;
@end



//////////////////////////////////////////////////////////////////////
////////////////////// [ íËêîÇ‚É}ÉNÉçíuä∑ ] //////////////////////////
//////////////////////////////////////////////////////////////////////
extern NSString *const CMRDownloaderNotFoundNotification;

// UserInfo
#define CMRDownloaderUserInfoContentsKey		@"Contents"
#define CMRDownloaderUserInfoResourceURLKey		@"ResourceURL"
#define CMRDownloaderUserInfoIdentifierKey		@"Identifier"
// for thread only.
#define CMRDownloaderUserInfoNextIndexKey		@"NextIndex"
