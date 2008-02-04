//
//  BS2chQuickLookObject.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/03.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSQuickLookObject_p.h"

@implementation BS2chQuickLookObject
+ (BOOL)canInitWithURL:(NSURL *)url
{
	CMRHostHandler	*handler_;

	handler_ = [CMRHostHandler hostHandlerForURL:url];
	if (!handler_) return NO;

	return [handler_ canReadDATFile];
}

- (NSURL *)resourceURL
{
	CMRHostHandler	*handler_;
	NSURL			*boardURL_ = [self boardURL];

	handler_ = [CMRHostHandler hostHandlerForURL:boardURL_];
	return [handler_ datURLWithBoard:boardURL_ datName:[[self threadSignature] datFilename]];
}

- (NSURLRequest *)requestForDownloadingQLContent
{
	NSMutableURLRequest	*request;
    request = [NSMutableURLRequest requestWithURL:[self resourceURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    
	[request setValue:[NSBundle monazillaUserAgent] forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[request setValue:@"bytes=0-4095" forHTTPHeaderField:@"Range"];

	return request;
}

- (CMRThreadMessage *)threadMessageFromString:(NSString *)source
{
	NSArray *datLines = [source componentsSeparatedByString:@"\n"];
	NSString *datLine = [datLines objectAtIndex:0];
	return [CMXTextParser messageWithDATLine:datLine];
}
@end
