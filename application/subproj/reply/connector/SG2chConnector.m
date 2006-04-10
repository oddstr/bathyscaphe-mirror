//:SG2chConnector.m
/**
  *
  * @see w2chAuthenticater.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/08/31  5:04:45 PM)
  *
  */
#import "SG2chConnector_p.h"

#import "SG2chConnector.h"
#import "w2chReply_be2ch.h"
#import "w2chReply_2ch.h"
#import "w2chReply_shita.h"



// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"


/*static NSString *dumpString(NSString *s)
{
	int i;
    NSMutableString *m = [NSMutableString string];
    for (i = 0; i < [s length]; i++) {
        [m appendFormat : @"0x%x ", [s characterAtIndex : i]];
    }
    return m;
}*/

@interface NSObject(ProxySettingsStub)
// Proxy
- (BOOL) usesProxy;
- (BOOL) usesSystemConfigProxy;

- (void) getProxy:(NSString**)host port:(CFIndex*)port;
- (CFIndex) proxyPort;
- (NSString *) proxyHost;
@end



@implementation SG2chConnector
+ (Class *) classClusters
{
	static Class classes[4] = {Nil, };
	
	if (Nil == classes[0]) {
		classes[0] = [(id)[w2chReply_be2ch class] retain];
		classes[1] = [(id)[w2chReply_2ch class] retain];
		classes[2] = [(id)[w2chReply_shita class] retain];
		classes[3] = Nil;
	}
	
	return classes;
}
+ (id) connectorWithURL : (NSURL        *) anURL
   additionalProperties : (NSDictionary *) properties
{
	return [[[[self class] alloc] initWithURL : anURL
					     additionalProperties : properties]
											   autorelease];
}
+ (Class) connectorClass
{
	double version_ = floor(NSAppKitVersionNumber);
	
/*
	[Runtime Version Check]
	in Mac OS X 10.1.x and earlier, CFStream generates invalid 
	request header for bbs.cgi. so we use plain socket API.
	
	NOTE:
	since SGHTTPSocketHandle uses socket, and NSFileHandle, it did
	not support proxy.
*/
	return (version_ <= NSAppKitVersionNumber10_1) 
			? [SGHTTPSocketHandle class]
			: [SGHTTPStream class];
}

- (id) initClusterWithURL : (NSURL        *) anURL
      additionalProperties : (NSDictionary *) properties
{
	if (self = [super init]) {
		SGHTTPConnector			*connector_;
		NSMutableDictionary		*headers_;
		Class					klass;
		
		klass = [[self class] connectorClass];
		UTILAssertNotNil(klass);
		
		connector_ = [[klass alloc] initWithURL : anURL
					requestMethod : HTTP_METHOD_POST];
		
		[self setConnector : connector_];
		[connector_ release];
		
		headers_ = [[self requestHeaders] mutableCopy];
		[headers_ addEntriesFromDictionary : properties];
		
		if (NO == [self isRequestHeadersComplete : headers_]) {
			[self autorelease];
			return nil;
		}
		
		[[self HTTPConnector] writePropertiesFromDictionary : headers_];
		[headers_ release];
		headers_ = nil;
	}
	return self;
}
- (id)     initWithURL : (NSURL        *) anURL
  additionalProperties : (NSDictionary *) properties
{
	Class			*p;
	SG2chConnector	*messenger_ = nil;
	
	for (p = [[self class] classClusters]; *p != Nil; p++) {
		if ([*p canInitWithURL : anURL]) {
			messenger_ = [[*p alloc] initClusterWithURL : anURL
							additionalProperties : properties];
			break;
		}
	}
    // 対応するクラスがない場合も利便性を優先して、
    // デフォルトで 2ch のものを返す。
    if (messenger_ == nil) {
        messenger_ = [[w2chReply_2ch alloc] initClusterWithURL : anURL
                      additionalProperties : properties];
    }
    
	[self release];
	return messenger_;
}

- (void) dealloc
{
	[m_connector release];
	[m_delegate release];
	[super dealloc];
}

+ (BOOL) canInitWithURL : (NSURL *) anURL
{
	Class			*p;
	
	for (p = [self classClusters]; *p != Nil; p++) {
		if ([*p canInitWithURL : anURL])
			return YES;
	}
    // 対応するクラスがない場合も利便性を優先して、
    // デフォルトで 2ch のものを返す。
	return YES;
}
+ (NSString *) userAgent
{
	return [w2chAuthenticater userAgent];
}

- (BOOL) writeForm : (NSDictionary *) forms
{
	NSString		*params_;
	NSString		*length_;
	NSData			*selialized_;
	
	if (nil == forms || 0 == [forms count]) return NO;
	
	params_ = [self parameterWithForm : forms];
	if (nil == params_) return NO;
	
/*
	UTILMethodLog;
	UTILDescription([self requestURL]);
	UTILDescription([[self requestURL] absoluteString]);
	UTILDescription(params_);
*/
	// すでにURLエンコードされていることを期待
	selialized_ = [params_ dataUsingEncoding : NSASCIIStringEncoding
						allowLossyConversion : YES];
	
	length_ = [[NSNumber numberWithInt : [selialized_ length]] stringValue];
	if (nil == selialized_ || nil == length_) return NO;
	
	[[self connector] writeProperty : HTTP_CONTENT_URL_ENCODED_TYPE
					         forKey : HTTP_CONTENT_TYPE_KEY];
	[[self connector] writeProperty : length_
					         forKey : HTTP_CONTENT_LENGTH_KEY];
	
	return [self writeData : selialized_];
}
// zero-terminated list
+ (const CFStringEncoding *) availableURLEncodings
{
	UTILAbstractMethodInvoked;
	return NULL;
}
- (id) stringWithObject : (id) obj
 usingAvailableURLEncodings : (id(*)(id, NSStringEncoding)) func
{
	NSString				*converted_   = nil;
	const CFStringEncoding	*available_ = NULL;
	
	if (nil == obj) return nil;
	
	available_ = [[self class] availableURLEncodings];
	if (NULL == available_) return nil;
	
	for (; *available_ != 0; available_++) {
		converted_ = func(obj, CF2NSEncoding(*available_));
		if (converted_ != nil) break;
	}
	
	return converted_;
}

static id fnc_dataUsigngEncoding(id obj, NSStringEncoding enc)
{
	return [NSString stringWithData:obj encoding:enc];
}
static id fnc_stringByURLEncodingUsingEncoding(id obj, NSStringEncoding enc)
{
	return [obj stringByURLEncodingUsingEncoding : enc];
}
- (NSString *) stringWithDataUsingAvailableURLEncodings : (NSData *) data
{
	return [self stringWithObject:data usingAvailableURLEncodings:fnc_dataUsigngEncoding];
}
- (NSString *) stringByURLEncodedWithString : (NSString *) str
{
	return [self stringWithObject:str usingAvailableURLEncodings:fnc_stringByURLEncodingUsingEncoding];
}



#define FAIL_URLENCODING_TITLE_KEY			@"FailURLEncoding_title"
#define FAIL_URLENCODING_MSG_KEY			@"FailURLEncoding_msg"
#define FAIL_URLENCODING_HELP_KEY			@"FailURLEncoding_help"

- (int) runAlertPanelWithFailURLEncoding : (NSString *) originalString
{
	NSAlert	*alert_ = [[NSAlert alloc] init];
	int		result_;
	
	[alert_ setAlertStyle : NSWarningAlertStyle];
	[alert_ setMessageText : w2chLocalizedAlertMessageString(FAIL_URLENCODING_TITLE_KEY)];
	[alert_ setInformativeText : [NSString stringWithFormat:w2chLocalizedAlertMessageString(FAIL_URLENCODING_MSG_KEY),originalString]];
	//[alert_ setHelpAnchor : w2chLocalizedAlertMessageString(FAIL_URLENCODING_HELP_KEY)];
	//[alert_ setShowsHelp : YES];
	[alert_ addButtonWithTitle : @"OK"];
	
	result_ = [alert_ runModal];
	
	[alert_ release];

	return result_;
/*	return NSRunAlertPanel(
			w2chLocalizedAlertMessageString(FAIL_URLENCODING_TITLE_KEY),
			[NSString stringWithFormat:w2chLocalizedAlertMessageString(FAIL_URLENCODING_MSG_KEY),originalString],
			@"OK",
			nil,
			nil);
*/
}
- (NSString *) parameterWithForm : (NSDictionary *) forms
{
    NSMutableString        *params_;
    NSEnumerator        *iter_;
    NSString            *key_;
    
    if (nil == forms || 0 == [forms count]) return nil;
    
    params_ = [NSMutableString string];
    iter_ = [forms keyEnumerator];
    while (key_ = [iter_ nextObject]) {
        NSString        *value_                    = nil;
        NSString        *encoded_                = nil;
        
        value_ = [forms objectForKey : key_];
        UTILAssertKindOfClass(value_, NSString);
        // UTILDebugWright(@"%@", dumpString(value_));
        encoded_ = [self stringByURLEncodedWithString : value_];
        if (nil == encoded_) {
            [self runAlertPanelWithFailURLEncoding : value_];
            return nil;
        }
        
        [params_ appendFormat : @"%@=%@&",
                                key_,
                                encoded_];
    }
    if ([params_ length] > 0)
        [params_ deleteCharactersInRange : NSMakeRange([params_ length]-1, 1)];
    
    return params_;
}

/////////////////////////////////////////////////////////////////////
////////////////////////// [ Accessor ] /////////////////////////////
/////////////////////////////////////////////////////////////////////
- (SGHTTPConnector*) HTTPConnector
{
	return [self connector];
}
- (w2chConnectMode) mode
{
	return kw2chConnectPOSTMessageMode;
}
- (SGHTTPConnector *) connector
{
	return m_connector;
}
- (void) setConnector : (SGHTTPConnector *) aConnector
{
	[aConnector retain];
	[m_connector release];
	m_connector = aConnector;
}
- (id) delegate
{
	return m_delegate;
}
- (void) setDelegate : (id) newDelegate
{
	[newDelegate retain];
	[m_delegate release];
	m_delegate = newDelegate;
}

/////////////////////////////////////////////////////////////////////
/////////////////////// [ SGHTTPConnector ] /////////////////////////
/////////////////////////////////////////////////////////////////////
- (NSData *) availableResourceData
{
	NSData				*theData;
	
	theData = [[self connector] availableResourceData];
	if (nil == theData || 0 == [theData length]) 
		return theData;
	
	return SGUtilUngzipIfNeeded(theData);
}
- (NSData *) resourceData
{
	return [[self connector] resourceData];
}

- (void) setUpProxy
{
	id		pref;
	
	pref = [NSClassFromString(@"AppDefaults") sharedInstance];
	UTILAssertNotNil(pref);
	UTILAssertRespondsTo(pref, @selector(getProxy:port:));
	
	// proxy
	if ([pref usesProxy]) {
		NSString	*host;
		CFIndex		port;
		
		[pref getProxy:&host port:&port];
		[[self connector] setProxy:host port:port];
		UTILDebugWrite3(
			@"  using proxy (Host:%@ Port:%d)\n\t"
			@"  for %@", host, port, [[self requestURL] stringValue]);
	}
}
- (NSData *) loadInForeground
{
	[self setUpProxy];
	return [[self connector] loadInForeground];
}
- (void) loadInBackground
{
	[self setUpProxy];
	[[self connector] addClient : self];
	[[self connector] loadInBackground];
}
- (void) cancelLoadInBackground
{
	[[self connector] endLoadInBackground];
}
- (BOOL) writeData : (NSData *) data
{
	return [[self connector] writeData : data];
}
- (NSDictionary *) responseHeaders
{
	return [[self connector] properties];
}
- (NSString *) headerFieldValueForKey : (NSString *) field
{
	return [[self connector] propertyForKeyIfAvailable : field];
}
- (unsigned) statusCode
{
	return [[[self connector] response] statusCode];
}
- (NSString *) statusLine
{
	return [[[self connector] response] statusLine];
}
- (NSURL *) requestURL
{
	return [[self connector] requestURL];
}
- (NSString *) requestMethod
{
	return [[self connector] requestMethod];
}



/////////////////////////////////////////////////////////////////////
/////////////////////// [ NSURLHanldeClient ] ///////////////////////
/////////////////////////////////////////////////////////////////////
- (void)               URLHandle : (NSURLHandle *) sender
  resourceDataDidBecomeAvailable : (NSData      *) newBytes
{
	SEL delegate_;
	
	if (nil == [self delegate]) return;
	
	delegate_ = @selector(connector:resourceDataDidBecomeAvailable:);
	if (NO == [[self delegate] respondsToSelector : delegate_]) return;
	
	//データが0のときはデリゲートを呼ばない
	if (nil == newBytes || 0 == [newBytes length]) return;
	[[self delegate] connector : self
	resourceDataDidBecomeAvailable : newBytes];
}

- (void) URLHandleResourceDidBeginLoading : (NSURLHandle *) sender
{
	SEL delegate_;
	
	if (nil == [self delegate]) return;
	
	delegate_ = @selector(connectorResourceDidBeginLoading:);
	if (NO == [[self delegate] respondsToSelector : delegate_]) return;
	
	[[self delegate] connectorResourceDidBeginLoading : self];
}


// Finish Loading...
- (void) URLHandleResourceDidFinishLoading : (NSURLHandle *) sender
{
	id<w2chErrorHandling>		handler_;
	NSData						*resourceData_;
	NSString					*contents_;
	SG2chServerError			error_;
	SEL							delegateSEL = NULL;
	//id							debugWriteObj = nil;
	
	/* Resource data */
	resourceData_ = [[self connector] availableResourceData];
	contents_ = [self stringWithDataUsingAvailableURLEncodings : resourceData_];
	
	//debugWriteObj = resourceData_ ? (id)resourceData_ : 
	//	(id)@"<!-- Generated by CocoMonar. Server's response contains no data. -->";
	//CMRDebugWriteObject(debugWriteObj, @"response.html");
	
	/* Error handling */
	handler_ = [SG2chErrorHandler handlerWithURL : [self requestURL]];
	error_ = [handler_ handleErrorWithContents : contents_
										 title : NULL
									   message : NULL];
	
	delegateSEL = (handler_ && error_.type != k2chNoneErrorType)
						? @selector(connector:resourceDidFailLoadingWithError:)
						: @selector(connectorResourceDidFinishLoading:);
	
	[[self connector] removeClient : self];
	if (nil == [self delegate]) return;
	if (NO == [[self delegate] respondsToSelector : delegateSEL]) return;
	
	if (handler_ && error_.type != k2chNoneErrorType) 
		[[self delegate] connector:self resourceDidFailLoadingWithError:handler_];
	else 
		[[self delegate] connectorResourceDidFinishLoading : self];
}

//Cancel Loading...
- (void) URLHandleResourceDidCancelLoading : (NSURLHandle *) sender
{
	SEL delegate_;
	
	[[self connector] removeClient : self];
	if (nil == [self delegate]) return;
	
	delegate_ = @selector(connectorResourceDidCancelLoading:);
	if (NO == [[self delegate] respondsToSelector : delegate_]) return;
	
	[[self delegate] connectorResourceDidCancelLoading : self];
}

- (void)                 URLHandle : (NSURLHandle *) sender
  resourceDidFailLoadingWithReason : (NSString    *) reason
{
	SEL delegate_;
	
	[[self connector] removeClient : self];
	if (nil == [self delegate]) return;

	delegate_ = @selector(connector:resourceDidFailLoadingWithReason:);
	if (NO == [[self delegate] respondsToSelector : delegate_]) return;
	
	[[self delegate] connector : self
	resourceDidFailLoadingWithReason : reason];
}
@end



@implementation SG2chConnector(RequestHeaders)
- (NSDictionary *) requestHeaders
{
	UTILAbstractMethodInvoked;
	return nil;
}
- (BOOL) isRequestHeadersComplete : (NSDictionary *) headers
{
	UTILAbstractMethodInvoked;
	return NO;
}
@end
