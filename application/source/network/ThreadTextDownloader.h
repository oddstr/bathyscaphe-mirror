/**
  * $Id: ThreadTextDownloader.h,v 1.3 2007/01/30 14:04:11 tsawada2 Exp $
  * 
  * ThreadTextDownloader.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRDownloader.h"

@class CMRThreadSignature;

@interface ThreadTextDownloader : CMRDownloader
{
	@private
	unsigned			_nextIndex;
	NSDictionary		*_localThreadsDict;
	NSString			*_threadTitle;
}
+ (id) downloaderWithIdentifier : (CMRThreadSignature *) signature
					threadTitle : (NSString           *) aTitle
					  nextIndex : (unsigned int        ) aNextIndex;
- (id) initWithIdentifier : (CMRThreadSignature *) signature
			  threadTitle : (NSString           *) aTitle
				nextIndex : (unsigned int        ) aNextIndex;

- (unsigned) nextIndex;
- (void) setNextIndex : (unsigned) aNextIndex;

+ (BOOL) canInitWithURL : (NSURL *) url;
- (NSStringEncoding) encodingForLoadedData;
- (NSString *) contentsWithData : (NSData *) theData;

- (CMRThreadSignature *) threadSignature;
- (NSString *) threadTitle;
- (NSURL *) threadURL;
- (NSDictionary *) localThreadsDict;

// ----------------------------------------
// Partial contents
// ----------------------------------------
- (BOOL) pertialContentsRequested;
// Called by URLHandle:resourceDataDidBecomeAvailable:
// to cancel any background loading, cause partial contents was invalid.
- (void) cancelDownloadWithInvalidPartial;
@end



// ----------------------------------------
//  N o t i f i c a t i o n
// ----------------------------------------
extern NSString *const ThreadTextDownloaderDidFinishLoadingNotification;
extern NSString *const ThreadTextDownloaderUpdatedNotification;
// some messages has beed aboned?
extern NSString *const ThreadTextDownloaderInvalidPerticalContentsNotification;

// Available in Starlight Breaker.
extern NSString *const CMRDownloaderUserInfoAdditionalInfoKey;
