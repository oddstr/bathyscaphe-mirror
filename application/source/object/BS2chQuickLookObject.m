//
//  BS2chQuickLookObject.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/03.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CocoMonar_Prefix.h"
#import "BS2chQuickLookObject.h"
#import "CMRThreadSignature.h"
#import "CMRHostHandler.h"
#import "CMXTextParser.h"

@implementation BS2chQuickLookObject
+ (BOOL)canInitWithURL:(NSURL *)url
{
	CMRHostHandler	*handler_;

	handler_ = [CMRHostHandler hostHandlerForURL:url];
	return handler_ ? [handler_ canReadDATFile] : NO;
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

- (CMRThreadMessage *)messageFromData
{
	NSString *s_string = [self contentsWithData:m_receivedData];
	NSArray *bar = [s_string componentsSeparatedByString:@"\n"];
	NSString *foo = [bar objectAtIndex:0];
	return [CMXTextParser messageWithDATLine:foo];
}
@end
