//
//  CMRThreadHTMLDownloader.m
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/08/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "CMRThreadHTMLDownloader.h"
#import "ThreadTextDownloader_p.h"
#import "CMRHostHandler.h"


@implementation CMRThreadHTMLDownloader
+ (NSMutableDictionary *)defaultRequestHeaders
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys :
				@"no-cache",				HTTP_CACHE_CONTROL_KEY,
				@"no-cache",				HTTP_PRAGMA_KEY,
				@"Close",					HTTP_CONNECTION_KEY,
				[NSBundle monazillaUserAgent],	HTTP_USER_AGENT_KEY,
				@"text/html",				HTTP_ACCEPT_KEY,
				@"ja",						HTTP_ACCEPT_LANGUAGE_KEY,
				nil];
}

+ (BOOL)canInitWithURL:(NSURL *)url
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL:url];
	return handler_ ? (NO == [handler_ canReadDATFile]) : NO;
}

- (NSURL *)threadURL
{
	NSURL				*boardURL_;
	NSURL				*threadURL_;
	CMRHostHandler		*handler_;
	unsigned			nextIndex;
	
	boardURL_ = [self boardURL];
	UTILAssertNotNil(boardURL_);
	handler_ = [CMRHostHandler hostHandlerForURL:boardURL_];
	nextIndex = ([self nextIndex] != NSNotFound) ? [self nextIndex] : 0;

	threadURL_ = [handler_ rawmodeURLWithBoard:boardURL_
									   datName:[[self threadSignature] identifier]
										 start:nextIndex +1
										   end:NSNotFound
									   nofirst:(nextIndex != 0)];

	return threadURL_;
}

- (NSURL *)resourceURL
{
	return [self threadURL];
}

- (BOOL)dataProcess:(NSData *)resourceData withConnector:(NSURLConnection *)connector
{
	NSString				*inputSource_;
	id						thread_;
	CMRHostHandler			*handler_;
	
	if (!resourceData) {
		return YES;
	}
	
	handler_ = [CMRHostHandler hostHandlerForURL:[self boardURL]];
	inputSource_ = [self contentsWithData:resourceData];
	thread_ = [[[NSMutableString alloc] init] autorelease];

	if (!inputSource_) {
		NSLog(@"\n"
			@"*** WARNING ***\n\t"
			@"Can't convert the bytes into Unicode characters\n\t"
			@"so can't convert string to thread.");
		return NO;
	}
	
	thread_ = [handler_ parseHTML:inputSource_ with:thread_ count:[self nextIndex]];
	if (!thread_ || [thread_ isEmpty]) {
		return YES;
	}
	return [self synchronizeLocalDataWithContents:thread_ dataLength:0];
}
/*- (BOOL) shouldCancelWithFirstArrivalData : (NSData *) theData
{
	CMRHostHandler *handler_;
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];

	if ([handler_ isKindOfClass: [BSHostLivedoorHandler class]]) return NO;

	return !CHECK_HTML([theData bytes], [theData length]);
}*/
@end
