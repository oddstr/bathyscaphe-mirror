/**
  * $Id: SGHTTPStream.m,v 1.1.1.1.4.2 2006/09/01 13:46:58 masakih Exp $
  * 
  * SGHTTPStream.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGHTTPStream.h"

#import "FrameworkDefines.h"
#import "SGHTTPRequest.h"
#import "SGHTTPResponse.h"


#define BUF_SIZE             4096
#define BUNDLE_CFNETWORK_ID  (CFSTR("com.apple.CFNetwork"))



// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"



@interface SGHTTPStream(Private)
- (CFReadStreamRef) readStreamRef;
- (void) setReadStreamRef : (CFReadStreamRef) aReadStreamRef;
- (void) bgLoadDidFailWithCFReadStream_ : (CFReadStreamRef) stream
                            errorDomain : (NSString      *) errDomain;
@end


// Return the CFNetwork bundle (executable loaded.)
static CFBundleRef GetCFNetworkBundle(void);


// ----------------------------------------
// CFStream, NSURLHandle stuff
// ----------------------------------------
/*
typedef enum {
    NSURLHandleNotLoaded = 0,
    NSURLHandleLoadSucceeded,
    NSURLHandleLoadInProgress,
    NSURLHandleLoadFailed
} NSURLHandleStatus;
*/
/*static NSString *NSURLHandleStatusToString_(NSURLHandleStatus s)
{
    static NSString *desc[] = {
        @"NSURLHandleNotLoaded",
        @"NSURLHandleLoadSucceeded",
        @"NSURLHandleLoadInProgress",
        @"NSURLHandleLoadFailed"
    };
    
    if (s < NSURLHandleNotLoaded || NSURLHandleLoadFailed < s) {
        return @"[Unknown status]";
    }
    
    return desc[s];
}*/

/*
CFStreamErrorDomain:

http://developer.apple.com/documentation/Networking/Conceptual/CFNetwork/Chapter_3/chapter_4_section_114.html

*/

/* Undefined symbol aliases */
// MAC_OS_X_VERSION_10_2
static SInt32 *myCFStreamErrorDomainNetServices;
static SInt32 *myCFStreamErrorDomainMach;
static SInt32 *myCFStreamErrorDomainSOCKS;
// MAC_OS_X_VERSION_10_3
static SInt32 *myCFStreamErrorDomainFTP;
static SInt32 *myCFStreamErrorDomainNetDB;
static SInt32 *myCFStreamErrorDomainSystemConfiguration;


static void loadErrorDomainSymbols(void)
{
    static Boolean isFirst = true;
    
    const char *symNames[] = {
                    "kCFStreamErrorDomainNetServices",
                    "kCFStreamErrorDomainMach",
                    "kCFStreamErrorDomainSOCKS",
                    "kCFStreamErrorDomainFTP",
                    "kCFStreamErrorDomainNetDB",
                    "kCFStreamErrorDomainSystemConfiguration",
                    NULL };
    SInt32 **syms[] = {
                    &myCFStreamErrorDomainNetServices,
                    &myCFStreamErrorDomainMach,
                    &myCFStreamErrorDomainSOCKS,
                    &myCFStreamErrorDomainFTP,
                    &myCFStreamErrorDomainNetDB,
                    &myCFStreamErrorDomainSystemConfiguration,
                    NULL };
    CFBundleRef   bundle = NULL;
    SInt32        *sym;
    const char    **p;
    SInt32        ***psym;
    
    if (false == isFirst) {
        return;
    }
    isFirst = false;
    
    NSCAssert(
        UTILNumberOfCArray(symNames) == UTILNumberOfCArray(syms),
        @"symNames count == syms count");
    
    if (NULL == (bundle = GetCFNetworkBundle())) 
        return;

    for (p = symNames, psym = syms; *p != NULL; p++, psym++) {
        NSString *name = [NSString stringWithUTF8String:(*p)];
        
        sym = (SInt32*)CFBundleGetDataPointerForName(bundle, (CFStringRef)name);
        UTILDebugWrite1(@"  load symbol %@", name);
        
        **psym = sym;
    }
}



static void CFStreamErrorGetDescription_(CFStreamError err, NSString **pDomainDesc, NSString **pErrDesc)
{
    CFStreamErrorDomain domain     = err.domain;
    SInt32              code       = err.error;
    NSString            *desc      = @"";
    NSString            *code_desc = nil;
    
    
    loadErrorDomainSymbols();
    /*** defined in CFStream.h ***/
    if (kCFStreamErrorDomainCustom == domain) {
        /* custom to the kind of stream in question */
        desc = @"kCFStreamErrorDomainCustom";
    } else if (kCFStreamErrorDomainPOSIX == domain) {
        /* POSIX errno; interpret using <sys/errno.h> */
        desc = @"kCFStreamErrorDomainPOSIX";
    } else if (kCFStreamErrorDomainMacOSStatus == domain) {
        /* OSStatus type from Carbon APIs; interpret using <MacTypes.h> */
        desc = @"kCFStreamErrorDomainMacOSStatus";

    /*** defined in CFHTTPStream.h ***/
    } else if (kCFStreamErrorDomainHTTP == domain) {
        desc = @"kCFStreamErrorDomainHTTP";
        /* CFStreamErrorHTTP */
        switch (code) {
        case kCFStreamErrorHTTPParseFailure:
            code_desc = @"kCFStreamErrorHTTPParseFailure";
            break;
        case kCFStreamErrorHTTPRedirectionLoop:
            code_desc = @"kCFStreamErrorHTTPRedirectionLoop";
            break;
        case kCFStreamErrorHTTPBadURL:
            code_desc = @"kCFStreamErrorHTTPBadURL";
            break;
        default :
            break;
        }
    /* These symbols can be undefined... */
    } else if (myCFStreamErrorDomainNetServices != NULL && *myCFStreamErrorDomainNetServices == domain) 
    {
        desc = @"kCFStreamErrorDomainNetServices";
    } else if (myCFStreamErrorDomainMach != NULL && *myCFStreamErrorDomainMach == domain) 
    {
        desc = @"kCFstreamErrorDomainMach";
    } else if (myCFStreamErrorDomainSOCKS != NULL && *myCFStreamErrorDomainSOCKS == domain) 
    {
        desc = @"kCFStreamErrorDomainSOCKS";
    } else if (myCFStreamErrorDomainFTP != NULL && *myCFStreamErrorDomainFTP == domain) 
    {
        desc = @"kCFStreamErrorDomainFTP";
    } else if (myCFStreamErrorDomainNetDB != NULL && *myCFStreamErrorDomainNetDB == domain) 
    {
        desc = @"kCFStreamErrorDomainNetDB";
    } else if (myCFStreamErrorDomainSystemConfiguration != NULL && *myCFStreamErrorDomainSystemConfiguration == domain) 
    {
        desc = @"kCFStreamErrorDomainSystemConfiguration";
    } else {
        desc = [NSString stringWithFormat : 
            @"[UNKNOWN CFStreamErrorDomain: %d",
            domain];
    }
    
    if (nil == code_desc) {
        code_desc = [[NSNumber numberWithLong : code] stringValue];
    }

    if (pDomainDesc != NULL) *pDomainDesc = desc;
    if (pErrDesc != NULL) *pErrDesc = code_desc;
}


// ----------------------------------------
// CFStreamClientContext
// ----------------------------------------
static void *_clientContextRetain(void *info)
{
	UTIL_DEBUG_FUNCTION;
/*
	SGHTTPStream *httpStream_;
	
	httpStream_ = info;
	if (info != NULL) [httpStream_ retain];

*/
	return info;
}

static void _clientContextRelease(void *info)
{
	UTIL_DEBUG_FUNCTION;
/*
	SGHTTPStream *httpStream_;
	
	httpStream_ = info;
	if (info != NULL) [httpStream_ release];
*/
}

static CFStringRef _clientContextCopyDescription(void *info)
{
	SGHTTPStream *httpStream_;
	
	UTIL_DEBUG_FUNCTION;
	httpStream_ = info;
	return (CFStringRef)[[httpStream_ description] copy];
}

static void assignResponseToHTTPStreamWithLoadedStream(	SGHTTPStream    *Self,
														CFReadStreamRef  stream)
{
	UTIL_DEBUG_FUNCTION;
	if (nil == Self || NULL == stream)
		return;
	
	if (nil == [Self response]) {
		[Self setResponse : [SGHTTPResponse responseFromLoadedStream : stream]];
	}
}

static void processReadStreamReadingEnd(CFReadStreamRef stream,
										SGHTTPStream   *Self, 
										BOOL            isErrorOccurred)
{
	NSURLHandleStatus	status;
	
	UTIL_DEBUG_FUNCTION;
	UTILCAssertNotNil(stream);
	UTILCAssertNotNil(Self);
	
	status = [Self status];
	//UTIL_DEBUG_WRITE2(@"Self status:%@(%d)", 
	//	NSURLHandleStatusToString_(status),
	//	status);
	
	if (status != NSURLHandleLoadInProgress && 
		status != NSURLHandleNotLoaded)
	{ /* すでに一度、呼ばれているはず*/ return; }
	
	if (isErrorOccurred) {
		/*
		書き込み送信時にエラー (Bug:1079696997/62)
		----------------------------------------
		- 書き込めているときもある。
		kCFStreamErrorDomainHTTP
		*/
		[Self bgLoadDidFailWithCFReadStream_ : stream
								 errorDomain : @"Read"];
	} else {
		[Self didLoadBytes : nil
			  loadComplete : YES];
	}
	
	
	if (stream == [Self readStreamRef]) {
		CFReadStreamUnscheduleFromRunLoop(stream,
											CFRunLoopGetCurrent(), 
											kCFRunLoopCommonModes);
		CFReadStreamClose(stream);
	} else {
		CFReadStreamClose(stream);
		CFRelease(stream);
	}
}

static inline BOOL readStreamIsAtEnd_(CFReadStreamRef s)
{
	return kCFStreamStatusAtEnd == CFReadStreamGetStatus(s);
}

static void readStreamClientCallBack_( CFReadStreamRef   stream,
									   CFStreamEventType type,
									   void              *info)
{
	SGHTTPStream *httpStream_;
	
	UTIL_DEBUG_FUNCTION;
	httpStream_ = info;

	switch (type) {
		case kCFStreamEventNone:
			UTIL_DEBUG_WRITE(@"kCFStreamEventNone");
			break;
		case kCFStreamEventOpenCompleted:
			UTIL_DEBUG_WRITE(@"kCFStreamEventOpenCompleted");
			break;
		case kCFStreamEventCanAcceptBytes:
			UTIL_DEBUG_WRITE(@"kCFStreamEventCanAcceptBytes");
			break;
		case kCFStreamEventHasBytesAvailable: {
			UInt8   buffer[BUF_SIZE];
			CFIndex bytesRead_;
			
			UTIL_DEBUG_WRITE(@"kCFStreamEventHasBytesAvailable");
			bytesRead_ = CFReadStreamRead(stream, buffer, BUF_SIZE);
			
			if (bytesRead_ > 0) {
				NSData *data_;
				
				assignResponseToHTTPStreamWithLoadedStream(httpStream_, stream);
				data_ = [NSData dataWithBytes : buffer
									   length : bytesRead_];
				[httpStream_ didLoadBytes:data_ loadComplete:NO];
				if (readStreamIsAtEnd_(stream)) {
					UTIL_DEBUG_WRITE1(@"bytesRead:%d readStreamIsAtEnd_", bytesRead_);
					processReadStreamReadingEnd(stream, httpStream_, NO);
				}
				
			} else if (0 == bytesRead_) {
				// [work around bug in MacOS X 10.1]
				// 最後まで読み込んでいなくても、0を返す場合がある
				if (readStreamIsAtEnd_(stream)) {
					// すべて読み込んだあとでもここに来る。
					if (NSURLHandleLoadInProgress != [httpStream_ status]) {
						/*UTIL_DEBUG_WRITE3(
							@"kCFStreamEventHasBytesAvailable but bytesRead:0 \n"
							@"status: %@(%d) \n"
							@"but NSURLHandleLoadInProgress: %d",
							NSURLHandleStatusToString_([httpStream_ status]),
							[httpStream_ status], 
							NSURLHandleLoadInProgress);*/
						break;
					}
					UTIL_DEBUG_WRITE1(@"[CFStream] END::bytesRead: %d", bytesRead_);
					processReadStreamReadingEnd(stream, httpStream_, NO);
				}
			} else {
				UTIL_DEBUG_WRITE1(@"[CFStream] END::bytesRead: %d", bytesRead_);
				processReadStreamReadingEnd(stream, httpStream_, YES);
			}
			break;
		}
		case kCFStreamEventErrorOccurred: {
			// オープンできなかった場合も kCFStreamEventErrorOccurred になる。
			UTIL_DEBUG_WRITE(@"[CFStream] kCFStreamEventErrorOccurred:");
			if (NSURLHandleLoadInProgress != [httpStream_ status]) {
				UTIL_DEBUG_WRITE3(
					@"kCFStreamEventHasBytesAvailable but bytesRead:0 \n"
					@"status: %@(%d) \n"
					@"expected NSURLHandleLoadInProgress: %d",
					NSURLHandleStatusToString_([httpStream_ status]),
					[httpStream_ status], 
					NSURLHandleLoadInProgress);
				break;
			}
			
			processReadStreamReadingEnd(stream, httpStream_, YES);
			break;
		}
		case kCFStreamEventEndEncountered: {
			UTIL_DEBUG_WRITE(@"[CFStream] kCFStreamEventEndEncountered:");
			assignResponseToHTTPStreamWithLoadedStream(httpStream_, stream);
			processReadStreamReadingEnd(stream, httpStream_, NO);
			break;
		}
		default:
			UTIL_DEBUG_WRITE1(@"*** Unknown CFEventType: %d ***", type);
			break;
	}
}

/**
  * [関数：fnc_readStreamCopyData]
  * 
  * ストリームを開き、データを受信。
  * 受信したデータを返す。
  * この関数はストリームを閉じない。
  * 
  * @param    stream    ストリーム
  */
static NSData *HTTPStreamOpenAndRead(CFReadStreamRef stream)
{
	NSMutableData *result;
	
	UTIL_DEBUG_FUNCTION;
	result = [NSMutableData data];
	if (NULL == stream) return result;
	
	//ストリームを開く
	if (FALSE == CFReadStreamOpen(stream)) {
		CFStreamError error;
		
		error = CFReadStreamGetError(stream);
		
		return result;
	}
	

	while (1) {
		UInt8   buffer[BUF_SIZE];
		CFIndex bytesRead;
		
		bytesRead = CFReadStreamRead(stream, buffer, BUF_SIZE);
		if (bytesRead < 0) {
			CFStreamError error;
			
			error = CFReadStreamGetError(stream);
			break;
		} else if (bytesRead == 0) {
			// [work around bug in MacOS X 10.1]
			// 最後まで読み込んでいなくても、0を返す場合がある
			if (kCFStreamStatusAtEnd == CFReadStreamGetStatus(stream)) {
				break;
			}
		} else {
			[result appendBytes : buffer
						 length : bytesRead];
 		}
	}
	
	return result;
}

@implementation SGHTTPStream
- (void) dealloc
{
	[self setReadStreamRef : NULL];
	[super dealloc];
}

- (CFReadStreamRef) getCFReadStreamRef
{ return [self readStreamRef]; }



/*** Loading ***/
- (NSData *) loadInForeground
{
	CFReadStreamRef		readStream_;
	NSData				*resourceData_;
	SGHTTPResponse		*response_;
	
	UTIL_DEBUG_METHOD;
	/* create stream */
	if (NULL == (readStream_ = [self getCFReadStreamRef]))
		return nil;
	
	
	/* recieve data and response from server */
	resourceData_ = HTTPStreamOpenAndRead(readStream_);
	response_ = [self response];
	if (nil == response_) 
		response_ = [SGHTTPResponse responseFromLoadedStream : readStream_];
		
	
	[self setResponse : response_];
	
	/* cleanup */
	CFReadStreamClose(readStream_);
	[self setReadStreamRef : NULL];
	readStream_ = NULL;
	
	return resourceData_;
}


- (void) loadInBackground
{
	CFReadStreamRef				readStream_;
	CFStreamClientContext		clientContext_;
	CFStreamEventType			availEventType_;
	
	UTIL_DEBUG_METHOD;
	[super loadInBackground];
	
	readStream_ = [self readStreamRef];
	if (NULL == readStream_) {
		[self backgroundLoadDidFailWithReason : @"Stream didnot exists."];
		return;
	}
	
	//CallBack時の情報を設定
	clientContext_.version         = 0;
	clientContext_.info            = self;
	clientContext_.retain          = _clientContextRetain;
	clientContext_.release         = _clientContextRelease;
	clientContext_.copyDescription = _clientContextCopyDescription;
	
	// CallBackさせるイベントのタイプを設定。
	availEventType_ = kCFStreamEventNone | 
					  kCFStreamEventOpenCompleted | 
					  kCFStreamEventCanAcceptBytes | 
					  kCFStreamEventHasBytesAvailable | 
					  kCFStreamEventErrorOccurred | 
					  kCFStreamEventEndEncountered;
	
	// Clientを設定
	if (FALSE == CFReadStreamSetClient(readStream_,
									  availEventType_,
									  readStreamClientCallBack_,
									  &clientContext_)) {
		//ストリームがイベントドリブン型をサポートしていない。
		[self setReadStreamRef : NULL];
		[self bgLoadDidFailWithCFReadStream_ : readStream_
								 errorDomain : @"SetCallback"];
		return;
	} else {
		CFReadStreamScheduleWithRunLoop(readStream_,
										CFRunLoopGetCurrent(), 
										kCFRunLoopCommonModes);
	}
	// ストリームを開き、イベント発生(-->Callback)まで待機
	if (FALSE == CFReadStreamOpen(readStream_)) {
		[self bgLoadDidFailWithCFReadStream_ : readStream_
								 errorDomain : @"Open"];
		[self setReadStreamRef : NULL];
		return;
	}
}

- (void) cancelLoadInBackground
{
	UTIL_DEBUG_METHOD;
	if (NULL != [self readStreamRef]) {
		CFReadStreamUnscheduleFromRunLoop([self readStreamRef],
											CFRunLoopGetCurrent(), 
											kCFRunLoopCommonModes);
		CFReadStreamClose([self readStreamRef]);
		[self setReadStreamRef : NULL];
	}
	[super cancelLoadInBackground];
}
- (void) endLoadInBackground
{
	UTIL_DEBUG_METHOD;
	[super endLoadInBackground];
}

@end



@implementation SGHTTPStream(Attributes)
static CFStringRef localCFStreamPropertyHTTPProxy;		/* kCFStreamPropertyHTTPProxy */
static CFStringRef localCFStreamPropertyHTTPProxyHost;	/* kCFStreamPropertyHTTPProxyHost */
static CFStringRef localCFStreamPropertyHTTPProxyPort;	/* kCFStreamPropertyHTTPProxyPort */
static Boolean localCFStreamPropertyInit(void)
{
    static Boolean isFirst = true;
    
    const char *symNames[] = {
                    "kCFStreamPropertyHTTPProxy",
                    "kCFStreamPropertyHTTPProxyHost",
                    "kCFStreamPropertyHTTPProxyPort",
                    NULL };
    CFStringRef *syms[] = {
                    &localCFStreamPropertyHTTPProxy,
                    &localCFStreamPropertyHTTPProxyHost,
                    &localCFStreamPropertyHTTPProxyPort,
                    NULL };
    
    CFBundleRef        bundle = NULL;
    CFStringRef        *sym;
    const char        **p;
    CFStringRef        **psym;
    
    if (false == isFirst) {
        goto RET_LOADED;
    }
    isFirst = false;
    
    NSCAssert(
        UTILNumberOfCArray(symNames) == UTILNumberOfCArray(syms),
        @"symNames count == syms count");
    
    if (NULL == (bundle = GetCFNetworkBundle())) 
        goto RET_LOADED;
    for (p = symNames, psym = syms; *p != NULL; p++, psym++) {
        NSString *name = [NSString stringWithUTF8String:(*p)];
        
        sym = (CFStringRef*)CFBundleGetDataPointerForName(
                                    bundle, (CFStringRef)name);
        UTILDebugWrite1(@"  load symbol %@", name);
        
        **psym = *sym;
    }

RET_LOADED:
    return (localCFStreamPropertyHTTPProxy != NULL);
}
- (void) setUpProxyUsingSetProperty : (NSString *) proxy
							   port : (CFIndex   ) port
{
	CFDictionaryRef		property;
	
	if (NULL == proxy) return;
	if (false == localCFStreamPropertyInit()) return;
	
	property = (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys :
					proxy,
					localCFStreamPropertyHTTPProxyHost,
					[NSNumber numberWithInt : port],
					localCFStreamPropertyHTTPProxyPort,
					nil];
	
	if (NULL == property) return;
	
	UTILDebugWrite2(@"  CFReadStreamSetProperty:%@ :%@",
		(NSString*)localCFStreamPropertyHTTPProxy,
		[(id)property description]);
	CFReadStreamSetProperty(
		[self readStreamRef],
		localCFStreamPropertyHTTPProxy,
		property);
}

- (void) setProxy : (NSString *) proxy
			 port : (CFIndex   ) port
{
	//double version = floor(NSAppKitVersionNumber);

	/*
	in version 10.2 and later in CoreServices.framework,
	CFHTTPReadStreamSetProxy is deprecated;
	call SetProperty(kCFStreamPropertyHTTPProxy) instead
	*/
	
	/*if (version <= NSAppKitVersionNumber10_1) {
		CFHTTPReadStreamSetProxy(
			[self readStreamRef],
			(CFStringRef)proxy,
			port);
	} else {*/
		[self setUpProxyUsingSetProperty:proxy port:port];
	//}
}
@end



@implementation SGHTTPStream(Private)
- (CFReadStreamRef) readStreamRef
{
	if (NULL == _readStreamRef) {
		CFHTTPMessageRef		request_;
		
		request_ = [[self request] HTTPMessageRef];
		_readStreamRef = CFReadStreamCreateForHTTPRequest(
										CFAllocatorGetDefault(),
										request_);
	}
	return _readStreamRef;
}
- (void) setReadStreamRef : (CFReadStreamRef) aReadStreamRef
{
	CFReadStreamRef tmp;
	
	UTIL_DEBUG_METHOD;
	
	tmp = _readStreamRef;
	if (aReadStreamRef != NULL) CFRetain(aReadStreamRef);
	_readStreamRef = aReadStreamRef;
	
	if (NULL == tmp) return;
	CFRelease(tmp);
}

- (void) bgLoadDidFailWithCFReadStream_ : (CFReadStreamRef) stream
                            errorDomain : (NSString      *) errDomain
{
	CFStreamError	streamError = CFReadStreamGetError(stream);
	NSString		*reason = nil;
	NSString		*domainDesc, *errDesc;
	
	if (nil == errDomain || 0 == [errDomain length])
		errDomain = @"HTTPStream";
	
	CFStreamErrorGetDescription_(streamError, &domainDesc, &errDesc);
		reason = [NSString stringWithFormat : 
				@"[%@] CFStreamError:\n"
				@"----------------------------------------\n"
				@"  domain: %@\n"
				@"  error : %@",
				errDomain,
				domainDesc,
				errDesc];

	[self backgroundLoadDidFailWithReason : reason];
}
@end



static CFBundleRef GetCFNetworkBundle(void)
{
    static BOOL isFirst = YES;
    static CFBundleRef kCFNetworkBundle = NULL;
    
    if (isFirst) {
        CFBundleRef bundle = NULL;
        
        isFirst = NO;
        bundle = CFBundleGetBundleWithIdentifier(BUNDLE_CFNETWORK_ID);
        if (NULL == bundle) {
            NSLog(@"[WARN] Can't find bundle with identifier:%@",
                (NSString*)BUNDLE_CFNETWORK_ID);
            goto RET_BUNDLE;
        }
        
        if (false == CFBundleLoadExecutable(bundle)) {
            NSLog(@"[WARN] Can't load executable code from %@",
                (NSString*)BUNDLE_CFNETWORK_ID);
            goto RET_BUNDLE;
        }
        kCFNetworkBundle = bundle;
        CFRetain(kCFNetworkBundle);
    }
RET_BUNDLE:
    return kCFNetworkBundle;
}
