//
//  BSHTMLQuickLookObject.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/03.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSQuickLookObject_p.h"

@implementation BSHTMLQuickLookObject
+ (BOOL)canInitWithURL:(NSURL *)url
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL:url];
	if (!handler_) return NO;

	return ![handler_ canReadDATFile];
}

- (NSURL *)resourceURL
{
	CMRHostHandler	*handler_;
	NSURL			*boardURL_ = [self boardURL];

	handler_ = [CMRHostHandler hostHandlerForURL:boardURL_];
	return [handler_ rawmodeURLWithBoard:boardURL_ datName:[[self threadSignature] identifier] start:1 end:1 nofirst:NO];
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

- (CMRThreadMessage *)threadMessageFromString:(NSString *)source
{
	CMRHostHandler *handler_ = [CMRHostHandler hostHandlerForURL:[self boardURL]];
	NSMutableString *datString = [[[NSMutableString alloc] init] autorelease];

	datString = [handler_ parseHTML:source with:datString count:0];

	return [CMXTextParser messageWithDATLine:datString];
}
@end
