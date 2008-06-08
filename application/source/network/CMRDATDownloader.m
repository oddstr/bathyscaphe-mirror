//
//  CMRDATDownloader.m
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
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
+ (BOOL)canInitWithURL:(NSURL *)url
{
	CMRHostHandler	*handler_;

	handler_ = [CMRHostHandler hostHandlerForURL:url];
	return handler_ ? [handler_ canReadDATFile] : NO;
}

- (NSURL *)threadURL
{
	CMRHostHandler	*handler_;
	NSURL			*boardURL_ = [self boardURL];

	UTILAssertNotNil([self threadSignature]);

	handler_ = [CMRHostHandler hostHandlerForURL:boardURL_];
	return [handler_ readURLWithBoard:boardURL_ datName:[[self threadSignature] identifier]];
}

- (NSURL *)resourceURL
{
	CMRHostHandler	*handler_;
	NSURL			*boardURL_ = [self boardURL];

	UTILAssertNotNil([self threadSignature]);

	handler_ = [CMRHostHandler hostHandlerForURL:boardURL_];
	return [handler_ datURLWithBoard:boardURL_ datName:[[self threadSignature] datFilename]];
}

- (void)cancelDownloadWithDetectingDatOchi
{
	NSArray			*recoveryOptions;
	NSDictionary	*dict;
	NSError			*error;

	recoveryOptions = [NSArray arrayWithObjects:[self localizedString:@"ErrorRecoveryCancel"], [self localizedString:@"DatOchiRetry"], nil];
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
				recoveryOptions, NSLocalizedRecoveryOptionsErrorKey,
				[NSString stringWithFormat:[self localizedString:@"DatOchiDescription"], [self threadTitle]], NSLocalizedDescriptionKey,
				[self localizedString:@"DatOchiSuggestion"], NSLocalizedRecoverySuggestionErrorKey,
				NULL];
	error = [NSError errorWithDomain:BSBathyScapheErrorDomain code:BSDATDownloaderThreadNotFoundError userInfo:dict];
	UTILNotifyInfo3(CMRDATDownloaderDidDetectDatOchiNotification, error, @"Error");
}
@end


@implementation CMRDATDownloader(PrivateAccessor)
- (void)setupRequestHeaders:(NSMutableDictionary *)mdict
{
	[super setupRequestHeaders:mdict];

	if ([self partialContentsRequested]) {
		NSNumber	*byteLenNum_;
		NSDate		*lastDate_;
		int			bytelen;
		NSString	*rangeString;
		
		byteLenNum_ = [[self localThreadsDict] objectForKey:ThreadPlistLengthKey];
		UTILAssertNotNil(byteLenNum_);
		lastDate_ = [[self localThreadsDict] objectForKey:CMRThreadModifiedDateKey];

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


@implementation CMRDATDownloader(LoadingResourceData)
- (BOOL)dataProcess:(NSData *)resourceData withConnector:(NSURLConnection *)connector
{
	NSString			*datContents_;
	
	if (!resourceData || [resourceData length] == 0) {
		return NO;
	}

	if ([self partialContentsRequested]) {
		const char		*p = NULL;
		p = (const char*)[resourceData bytes];
		if (*p != '\n') {
			[self cancelDownloadWithInvalidPartial];
			return NO;
		}
	}
	
	datContents_ = [self contentsWithData:resourceData];	
	return [self synchronizeLocalDataWithContents:datContents_ dataLength:[resourceData length]];
}
@end
