/**
  * $Id: CMRNetRequestQueue.m,v 1.1.1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * CMRNetRequestQueue.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRNetRequestQueue.h"
#import "CocoMonar_Prefix.h"

#import "CMXInternalMessaging.h"
#import <SGNetwork/SGNetwork.h>



// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"



@implementation CMRNetRequest
- (id) initWithURL : (NSURL *) anURL
{
	UTIL_DEBUG_METHOD;
	if (self = [super init]) {
		[self setRequestURL : anURL];
	}
	return self;
}
- (void) dealloc
{
	[self setRequestURL : nil];
	[super dealloc];
}
- (NSURL *) requestURL
{
	return _requestURL;
}
- (void) setRequestURL : (NSURL *) aRequestURL
{
	id		tmp;
	
	tmp = _requestURL;
	_requestURL = [aRequestURL retain];
	[tmp release];
}


+ (NSString *) userAgent
{
	return [NSString stringWithFormat :
						@"%@/%@",
						[NSBundle applicationName],
						[NSBundle applicationVersion]];
}
- (NSDictionary *) requestHeaderWithURL : (NSURL *) anURL
{
#define HTTP_ACCEPT_VALUE	@"text/*"
	return [NSDictionary dictionaryWithObjectsAndKeys :
				[anURL host],				HTTP_HOST_KEY,
				@"no-cache",				HTTP_CACHE_CONTROL_KEY,
				@"no-cache",				HTTP_PRAGMA_KEY,
				@"Close",					HTTP_CONNECTION_KEY,
				[[self class] userAgent],	HTTP_USER_AGENT_KEY,
				HTTP_ACCEPT_VALUE,			HTTP_ACCEPT_KEY,
				@"ja",						HTTP_ACCEPT_LANGUAGE_KEY,
				nil];
}

static NSMutableData *kSharedBuffer;
- (void) beginLoading
{
	if (nil == kSharedBuffer)
		kSharedBuffer = [[NSMutableData alloc] init];
	
}
- (void) endLoading
{
	CMRDebugWriteObject(kSharedBuffer, @"debug1");
}

- (void) didLoadBytes : (UInt8 *) aBytes
			   length : (size_t ) aLength
{
	[kSharedBuffer appendBytes:aBytes length:aLength];
}

#define BUF_SIZE	1024
- (void) run
{
	SGHTTPStream	*wrapper;
	CFReadStreamRef	stream;
	NSDictionary	*requestHeader;
	SGHTTPResponse	*response = nil;
	
	UTIL_DEBUG_METHOD;
	UTIL_DEBUG_WRITE1(@"URL = %@", [self requestURL]);
	
	[self beginLoading];
	requestHeader = [self requestHeaderWithURL : [self requestURL]];
	wrapper = [SGHTTPStream connectorWithURL: [self requestURL]
				requestMethod: HTTP_METHOD_GET];
	[wrapper writePropertiesFromDictionary : requestHeader];
	UTIL_DEBUG_WRITE1(@"request = %@", [wrapper request]);
	
	stream = [wrapper getCFReadStreamRef];
	UTILAssertNotNil(stream);
	UTIL_DEBUG_WRITE(@"Open and read HTTP stream");
	
	if (false == CFReadStreamOpen(stream)) {
		CFStreamError error;
		
		error = CFReadStreamGetError(stream);
		NSLog(@"ERROR: CFReadStreamOpen(%d)", error);
		
		return;
	}
	
	while (1) {
		UInt8   buffer[BUF_SIZE];
		CFIndex bytesRead;
		
		bytesRead = CFReadStreamRead(stream, buffer, BUF_SIZE);
		if (bytesRead < 0) {
			CFStreamError error;
			
			error = CFReadStreamGetError(stream);
			NSLog(@"ERROR: CFReadStreamRead(%d)", error);
			break;
		} else if (bytesRead == 0) {
			// [work around bug in MacOS X 10.1]
			// ÅŒã‚Ü‚Å“Ç‚Ýž‚ñ‚Å‚¢‚È‚­‚Ä‚àA0‚ð•Ô‚·ê‡‚ª‚ ‚é
			if (kCFStreamStatusAtEnd == CFReadStreamGetStatus(stream)) {
				break;
			}
		} else {
			[self didLoadBytes:buffer length:bytesRead];
			UTIL_DEBUG_WRITE1(@"loadBytes:%d", bytesRead);
			if (nil == response) {
				response = [SGHTTPResponse responseFromLoadedStream : stream];
				UTIL_DEBUG_WRITE1(@"response:%@", response);
			}
 		}
	}
	[self endLoading];
}

- (void) cancel : (id) sender {}
@end



@implementation CMRNetRequestQueue
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultQueue);

- (id) init 
{
	UTIL_DEBUG_METHOD;
	if (self = [super init]) {
		_worker = [[CMXWorkerContext alloc] initWithUsingDrawingThread : NO];
		[_worker run];
	}
	return self;
}
- (CMXWorkerContext *) workerContext { return _worker; }

- (void) enqueueRequest : (CMRNetRequest *) aRequest
{
	UTIL_DEBUG_METHOD;
	UTIL_DEBUG_WRITE1(@" enqueue request: %@", aRequest);
	
	UTILAssertNotNilArgument(aRequest, @"aRequest");
	UTILAssertNotNilArgument([self workerContext], @"[self workerContext]");
	[[self workerContext] push : aRequest];
}
@end
