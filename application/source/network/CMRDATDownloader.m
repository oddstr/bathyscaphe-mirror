//
//  CMRDATDownloader.m
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "CMRDATDownloader.h"
#import "ThreadTextDownloader_p.h"
#import "CMRServerClock.h"
#import "CMRHostHandler.h"


// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"

NSString *const CMRDATDownloaderDidDetectDatOchiNotification = @"CMRDATDownloaderDidDetectDatOchiNotification";


@implementation CMRDATDownloader
+ (BOOL) canInitWithURL : (NSURL *) url
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL : url];
	return handler_ ? [handler_ canReadDATFile] : NO;
}

- (NSURL *) threadURL
{
	CMRHostHandler	*handler_;
	
	UTILAssertNotNil([self threadSignature]);
	
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	return [handler_ readURLWithBoard:[self boardURL] datName:[[self threadSignature] identifier]];
}
- (NSURL *) resourceURL
{
	CMRHostHandler	*handler_;
	
	UTILAssertNotNil([self threadSignature]);
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	return [handler_ datURLWithBoard:[self boardURL] datName:[[self threadSignature] datFilename]];
}

- (void) cancelDownloadWithDetectingDatOchi
{
	[self cancelDownloadWithPostingNotificationName : CMRDATDownloaderDidDetectDatOchiNotification];
}
@end


@implementation CMRDATDownloader(PrivateAccessor)
- (void) setupRequestHeaders : (NSMutableDictionary *) mdict
{
	[super setupRequestHeaders : mdict];

	if ([self pertialContentsRequested]) {
		NSNumber	*byteLenNum_;
		NSDate		*lastDate_;
		int			bytelen;
		NSString	*rangeString;
		
		byteLenNum_ = [[self localThreadsDict] objectForKey : ThreadPlistLengthKey];
		UTILAssertNotNil(byteLenNum_);
		lastDate_ = [[self localThreadsDict] objectForKey : CMRThreadModifiedDateKey];

//		[mdict removeObjectForKey : HTTP_ACCEPT_ENCODING_KEY];
		[mdict setObject:@"identity" forKey:HTTP_ACCEPT_ENCODING_KEY];

		bytelen = [byteLenNum_ intValue];
		bytelen -= 1; // Get Extra 1 byte, then check received data. if 1st byte is not \n, it's error.
		rangeString = [NSString stringWithFormat:@"bytes=%d-", bytelen];
		[mdict setNoneNil:rangeString forKey:HTTP_RANGE_KEY];
		[mdict setNoneNil:[lastDate_ descriptionAsRFC1123] forKey:HTTP_IF_MODIFIED_SINCE_KEY];
	}
}
@end



//@implementation CMRDATDownloader(w2chConnectDelegate)
// ----------------------------------------
// Partial contents
// ----------------------------------------
/*- (void) handlePartialContentsCheck_ : (SGHTTPConnector *) theConnect
{
	SGHTTPResponse	*res = [theConnect response];
	NSData			*avail = [theConnect availableResourceData];
	const char		*p = NULL;
	
	UTIL_DEBUG_METHOD;
	UTIL_DEBUG_WRITE1(@"  dataLength:%u", [avail length]);
	if (nil == res) {	// why?
		NSLog(
			@"%@ called, but server response was nil.",
			UTIL_HANDLE_FAILURE_IN_METHOD);
		return;
	}
	
	switch ([res statusCode]) {
	case HTTP_PERTIAL:
		break;
	case HTTP_NOT_MODIFIED:
		return;
		break;
	case HTTP_RANGE_NOT_SATISFIABLE:  // Requested Range Not Satisfiable
		NSLog(@"Server Response: %@", [res statusLine]);
		[self cancelDownloadWithInvalidPartial];
		return;
		break;
	case HTTP_FOUND: // Maybe Dat Ochi
		NSLog(@"302 - Maybe Dat Ochi");
		[self cancelDownloadWithDetectingDatOchi];
		return;
		break;
	default:
		NSLog(@"Unexpected status:%u", [res statusCode]);
		return;
		break;
	}
	
	// check terminater
	if (nil == avail || 0 == [avail length])
		return;
	
	p = (const char*)[avail bytes];
	if (*p != '\n') {
		NSLog(@"Last terminater must be %c, but was %c.", '\n', *p);
		[self cancelDownloadWithInvalidPartial];
	}
}*/
/*- (void) URLHandle               : (NSURLHandle *) sender
  resourceDataDidBecomeAvailable : (NSData      *) newBytes
{
	[super URLHandle:sender resourceDataDidBecomeAvailable:newBytes];
	NSData				*data;
	SGHTTPConnector		*con;
	
	con  = [self HTTPConnectorCastURLHandle : sender];
	if ([self isFirstArrivalWithURLHandle : con resourceDataDidBecomeAvailable : newBytes])
	{
		[self synchronizeServerClock : con];

		data = [con availableResourceData];
		if ([self pertialContentsRequested]) {
			[self handlePartialContentsCheck_ : [self HTTPConnectorCastURLHandle : sender]];
			return;
		}
		if ([self shouldCancelWithFirstArrivalData : data]) {
			[self cancelDownloadWithPostingNotificationName :
								CMRDownloaderNotFoundNotification];
			return;
		}
	}
}*/
//@end



@implementation CMRDATDownloader(LoadingResourceData)
- (BOOL) dataProcess : (NSData *) resourceData
       withConnector : (NSURLConnection *) connector
{
//	NSData				*ungzipped_;
	NSString			*datContents_;
//	unsigned			contentLength_;
	
	if (nil == resourceData || 0 == [resourceData length]) {
//		if (0 == [[HTTPConnector_ response] statusCode]) {
/*
			[HTTPConnector_ removeClient : self];
			[self setCurrentConnector : nil];
			UTILNotifyName(ThreadTextDownloaderInvalidPerticalContentsNotification);
*/
//		}
		NSLog(@"Zero!!!");
		return NO;
	}

	if ([self pertialContentsRequested]) {
		const char		*p = NULL;
		p = (const char*)[resourceData bytes];
		if (*p != '\n') {
			NSLog(@"Hogeeeee!!!");
			[self cancelDownloadWithInvalidPartial];
			UTILNotifyName(ThreadTextDownloaderInvalidPerticalContentsNotification);
			return NO;
		}
	}
	
//	ungzipped_ = SGUtilUngzipIfNeeded(resourceData);
//	if (nil == ungzipped_ || 0 == [ungzipped_ length])
//		return NO;
	// ----------------------------------------
	// Final Check
	// ----------------------------------------
//	if ([self shouldCancelWithFirstArrivalData : ungzipped_]) {
	if ([self shouldCancelWithFirstArrivalData:resourceData]) {
		UTILNotifyName(CMRDownloaderNotFoundNotification);
		return NO;
	}
	
//	datContents_ = [self contentsWithData : ungzipped_];
	datContents_ = [self contentsWithData:resourceData];
//	contentLength_ = [HTTPConnector_ readContentLength];
	
	return [self synchronizeLocalDataWithContents : datContents_
	                                   dataLength : [resourceData length]];
//	                                   dataLength : [ungzipped_ length]];
}
@end
