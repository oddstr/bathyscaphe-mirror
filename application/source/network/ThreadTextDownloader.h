//
//  ThreadTextDownloader.h
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMRDownloader.h"

@class CMRThreadSignature;

@interface ThreadTextDownloader : CMRDownloader
{
	@private
	unsigned			m_nextIndex;
	NSDictionary		*m_localThreadsDict;
	NSString			*m_threadTitle;
	NSDate	*m_lastDateStore;
}

+ (id) downloaderWithIdentifier : (CMRThreadSignature *) signature
					threadTitle : (NSString           *) aTitle
					  nextIndex : (unsigned int        ) aNextIndex;
- (id) initWithIdentifier : (CMRThreadSignature *) signature
			  threadTitle : (NSString           *) aTitle
				nextIndex : (unsigned int        ) aNextIndex;

- (unsigned) nextIndex;
- (void) setNextIndex : (unsigned) aNextIndex;

- (NSDate *)lastDate;
- (void)setLastDate:(NSDate *)date;

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
- (BOOL) partialContentsRequested;
- (void) cancelDownloadWithInvalidPartial;
@end

extern NSString *const ThreadTextDownloaderDidFinishLoadingNotification;
// some messages has beed aboned?
extern NSString *const ThreadTextDownloaderInvalidPerticalContentsNotification;

// Available in Starlight Breaker.
extern NSString *const CMRDownloaderUserInfoAdditionalInfoKey;
