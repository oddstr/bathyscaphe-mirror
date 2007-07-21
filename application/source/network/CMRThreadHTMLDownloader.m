//: CMRThreadHTMLDownloader.m
/**
  * $Id: CMRThreadHTMLDownloader.m,v 1.5 2007/07/21 19:32:55 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRThreadHTMLDownloader.h"
#import "ThreadTextDownloader_p.h"
#import "CMRHostHandler.h"

@class BSHostLivedoorHandler;

@implementation CMRThreadHTMLDownloader
+ (BOOL) canInitWithURL : (NSURL *) url
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL : url];
	return handler_ ? (NO == [handler_ canReadDATFile]) : NO;
}

- (NSURL *) threadURL
{
	NSURL				*boardURL_;
	NSURL				*threadURL_;
	CMRHostHandler		*handler_;
	unsigned			nextIndex;
	
	boardURL_ = [self boardURL];
	UTILAssertNotNil(boardURL_);
	handler_ = [CMRHostHandler hostHandlerForURL : boardURL_];
	nextIndex = ([self nextIndex] != NSNotFound) ? [self nextIndex] : 0;
	
	threadURL_ = [handler_ rawmodeURLWithBoard : boardURL_
							datName : [[self threadSignature] identifier]
							start : nextIndex +1
							end : NSNotFound
							nofirst : (nextIndex != 0)];
	
	return threadURL_;
}
- (NSURL *) resourceURL
{
	return [self threadURL];
}
//- (BOOL) dataProcess : (NSData      *) resourceData
//       withConnector : (NSURLHandle *) connector
- (BOOL) dataProcess : (NSData *) resourceData
       withConnector : (NSURLConnection *) connector
{
	NSString				*inputSource_;
	id						thread_;
	CMRHostHandler			*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	inputSource_ = [self contentsWithData : resourceData];
	thread_ = [[[NSMutableString alloc] init] autorelease];

	if (nil == resourceData) {
		NSLog(@"No data. -- BathyScaphe 1.3.1 CMRThreadHTMLDownloader");
		return YES;
	}
	
	if(nil == inputSource_){
		NSLog(@"\n"
			@"*** WARNING ***\n\t"
			@"Can't convert the bytes into Unicode characters\n\t"
			@"so can't convert string to thread.");
		return NO;
	}
	
	thread_ = [handler_ parseHTML : inputSource_
							 with : thread_
							count : [self nextIndex]];
	if(nil == thread_ || [thread_ isEmpty])
		return YES;
	
	return [self synchronizeLocalDataWithContents:thread_ dataLength:0];
}
- (BOOL) shouldCancelWithFirstArrivalData : (NSData *) theData
{
	CMRHostHandler *handler_;
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];

	if ([handler_ isKindOfClass: [BSHostLivedoorHandler class]]) return NO;

	return NO;//!CHECK_HTML([theData bytes], [theData length]);
}
@end



@implementation CMRThreadHTMLDownloader(HTTPRequestHeader)
+ (NSMutableDictionary *) defaultRequestHeaders
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys :
				@"no-cache",				HTTP_CACHE_CONTROL_KEY,
				@"no-cache",				HTTP_PRAGMA_KEY,
				@"Close",					HTTP_CONNECTION_KEY,
//				[self monazillaUserAgent],	HTTP_USER_AGENT_KEY,
				[NSBundle monazillaUserAgent],	HTTP_USER_AGENT_KEY,
				@"text/html",				HTTP_ACCEPT_KEY,
				@"ja",						HTTP_ACCEPT_LANGUAGE_KEY,
				nil];
}

@end
