//
//  BSHTMLQuickLookObject.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/03.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CocoMonar_Prefix.h"
#import "BSHTMLQuickLookObject.h"
#import "CMRHostHandler.h"
#import "CMXTextParser.h"

@implementation BSHTMLQuickLookObject
+ (BOOL)canInitWithURL:(NSURL *)url
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL:url];
	return handler_ ? (NO == [handler_ canReadDATFile]) : NO;
}

- (NSURL *)resourceURL
{
	CMRHostHandler	*handler_;
	NSURL			*boardURL_ = [self boardURL];

	handler_ = [CMRHostHandler hostHandlerForURL:boardURL_];
	return [handler_ rawmodeURLWithBoard:boardURL_
								 datName:[[self threadSignature] identifier]
								   start:1
									 end:1
								 nofirst:NO];
}

- (NSURLRequest *)requestForDownloadingQLContent
{
	NSMutableURLRequest	*request;
    request = [NSMutableURLRequest requestWithURL:[self resourceURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    
	[request setValue:[NSBundle monazillaUserAgent] forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"no-cache" forHTTPHeaderField:HTTP_CACHE_CONTROL_KEY];
	[request setValue:@"no-cache" forHTTPHeaderField:HTTP_PRAGMA_KEY];
	[request setValue:@"Close" forHTTPHeaderField:HTTP_CONNECTION_KEY];
	[request setValue:@"text/html" forHTTPHeaderField:HTTP_ACCEPT_KEY];
	[request setValue:@"ja" forHTTPHeaderField:HTTP_ACCEPT_LANGUAGE_KEY];

	return request;
}

- (CMRThreadMessage *)messageFromData
{
	NSString *inputSource_ = [self contentsWithData:m_receivedData];
	CMRHostHandler *handler_ = [CMRHostHandler hostHandlerForURL:[self boardURL]];
	NSMutableString *thread_ = [[[NSMutableString alloc] init] autorelease];
	
	thread_ = [handler_ parseHTML:inputSource_ with:thread_ count:0];

	return [CMXTextParser messageWithDATLine:thread_];
}
@end
