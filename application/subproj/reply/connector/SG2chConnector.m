//
//  SG2chConnector.m
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "SG2chConnector_p.h"

@class w2chReply_be2ch;
@class w2chReply_2ch;
@class w2chReply_shita;


// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"

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

+ (id)connectorWithURL:(NSURL *)anURL additionalProperties:(NSDictionary *)properties
{
	return [[[[self class] alloc] initWithURL:anURL additionalProperties:properties] autorelease];
}

- (id)initClusterWithURL:(NSURL *)anURL additionalProperties:(NSDictionary *)properties
{
	if (self = [super init]) {
		NSMutableURLRequest	*req;
		NSMutableDictionary	*headers_;

		req = [[NSMutableURLRequest alloc] initWithURL:anURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
		[req setHTTPMethod:HTTP_METHOD_POST];
		[req setHTTPShouldHandleCookies:NO];
		[self setRequest:req];
		[req release];

		headers_ = [[self requestHeaders] mutableCopy];
		[headers_ addEntriesFromDictionary:properties];
		
		if (![self isRequestHeadersComplete:headers_]) {
			[self autorelease];
			return nil;
		}

		[[self request] setAllHTTPHeaderFields:headers_];

		[headers_ release];
		headers_ = nil;
	}
	return self;
}

- (id)initWithURL:(NSURL *)anURL additionalProperties:(NSDictionary *)properties
{
	Class			*p;
	SG2chConnector	*messenger_ = nil;
	
	for (p = [[self class] classClusters]; *p != Nil; p++) {
		if ([*p canInitWithURL:anURL]) {
			messenger_ = [[*p alloc] initClusterWithURL:anURL additionalProperties:properties];
			break;
		}
	}
    // 対応するクラスがない場合も利便性を優先して、
    // デフォルトで 2ch のものを返す。
    if (!messenger_) {
        messenger_ = [[w2chReply_2ch alloc] initClusterWithURL:anURL additionalProperties:properties];
    }

	[self release];
	return messenger_;
}

- (void)dealloc
{
	[m_data release];
	[m_response release];
	[m_req release];
	[m_connector release];
	[m_delegate release];
	[super dealloc];
}

+ (BOOL)canInitWithURL:(NSURL *)anURL
{
	Class			*p;
	
	for (p = [self classClusters]; *p != Nil; p++) {
		if ([*p canInitWithURL:anURL])
			return YES;
	}
    // 対応するクラスがない場合も利便性を優先して、
    // デフォルトで 2ch のものを返す。
	return YES;
}

+ (NSString *)userAgent
{
//	return [w2chAuthenticater userAgent];
	return [NSBundle monazillaUserAgent];
}

- (void)loadInBackground
{
	NSURLConnection *con;
	con = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self];
	[self setConnector:con];
	[con release];
}

#pragma mark Form, Encodings
- (BOOL)writeForm:(NSDictionary *)forms
{
	NSString		*params_;
	NSString		*length_;
	NSData			*selialized_;
	NSMutableURLRequest	*req = [self request];
	
	if (!forms || [forms count] == 0) return NO;
	
	params_ = [self parameterWithForm:forms];
	if (!params_) return NO;

	UTILMethodLog;
	UTILDescription([self requestURL]);
	UTILDescription([[self requestURL] absoluteString]);
	UTILDescription(params_);

	// すでにURLエンコードされていることを期待
	selialized_ = [params_ dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	length_ = [[NSNumber numberWithInt:[selialized_ length]] stringValue];
	if (!selialized_ || !length_) return NO;
	
	[req setValue:HTTP_CONTENT_URL_ENCODED_TYPE forHTTPHeaderField:HTTP_CONTENT_TYPE_KEY];
	[req setValue:length_ forHTTPHeaderField:HTTP_CONTENT_LENGTH_KEY];
	[req setHTTPBody:selialized_];
	return YES;
}
// zero-terminated list
+ (const CFStringEncoding *)availableURLEncodings
{
	UTILAbstractMethodInvoked;
	return NULL;
}

- (id)stringWithObject:(id)obj usingAvailableURLEncodings:(id(*)(id, NSStringEncoding))func
{
	NSString				*converted_   = nil;
	const CFStringEncoding	*available_ = NULL;
	
	if (!obj) return nil;
	
	available_ = [[self class] availableURLEncodings];
	if (NULL == available_) return nil;
	
	for (; *available_ != 0; available_++) {
		converted_ = func(obj, CF2NSEncoding(*available_));
		if (converted_) break;
	}
	
	return converted_;
}

static id fnc_dataUsigngEncoding(id obj, NSStringEncoding enc)
{
	return [NSString stringWithData:obj encoding:enc];
}

static id fnc_stringByURLEncodingUsingEncoding(id obj, NSStringEncoding enc)
{
	return [obj stringByURLEncodingUsingEncoding:enc];
}

- (NSString *)stringWithDataUsingAvailableURLEncodings:(NSData *)data
{
	return [self stringWithObject:data usingAvailableURLEncodings:fnc_dataUsigngEncoding];
}

- (NSString *)stringByURLEncodedWithString:(NSString *)str
{
	return [self stringWithObject:str usingAvailableURLEncodings:fnc_stringByURLEncodingUsingEncoding];
}

- (NSString *)parameterWithForm:(NSDictionary *)forms
{
    NSMutableString	*params_;
    NSEnumerator	*iter_;
    NSString		*key_;
    
    if (!forms || [forms count] == 0) return nil;
    
    params_ = [NSMutableString string];
    iter_ = [forms keyEnumerator];
    while (key_ = [iter_ nextObject]) {
        NSString        *value_ = nil;
        NSString        *encoded_ = nil;
        
        value_ = [forms objectForKey:key_];
        UTILAssertKindOfClass(value_, NSString);
        encoded_ = [self stringByURLEncodedWithString:value_];
        if (!encoded_) {
			id delegate_ = [self delegate];
			if (delegate_ && [delegate_ respondsToSelector:@selector(connector:didFailURLEncoding:)]) {
				[delegate_ connector:self didFailURLEncoding:[NSArray arrayWithObjects:key_, value_, nil]];
			}
            return nil;
        }
        
        [params_ appendFormat:@"%@=%@&", key_, encoded_];
    }

    if ([params_ length] > 0) {
        [params_ deleteCharactersInRange:NSMakeRange([params_ length]-1, 1)];
    }
    return params_;
}

#pragma mark Accessors
- (NSURLConnection *)connector
{
	return m_connector;
}

- (void)setConnector:(NSURLConnection *)aConnector
{
	[aConnector retain];
	[m_connector release];
	m_connector = aConnector;
}

- (NSMutableURLRequest *)request
{
	return m_req;
}

- (void)setRequest:(NSMutableURLRequest *)aRequest
{
	[aRequest retain];
	[m_req release];
	m_req = aRequest;
}

- (NSURLResponse *)response
{
	return m_response;
}

- (void)setResponse:(NSURLResponse *)response
{
	[response retain];
	[m_response release];
	m_response = response;
}

- (id)delegate
{
	return m_delegate;
}

- (void)setDelegate:(id)newDelegate
{
	[newDelegate retain];
	[m_delegate release];
	m_delegate = newDelegate;
}

- (NSMutableData *)availableResourceData
{
	if (!m_data) {
		m_data = [[NSMutableData alloc] init];
	}
	return m_data;
}

- (void)setAvailableResourceData:(NSMutableData *)data
{
	[data retain];
	[m_data release];
	m_data = data;
}

- (NSURL *)requestURL
{
	return [[self request] URL];
}

#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self setResponse:response];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	id<w2chErrorHandling>	handler_;
	NSString				*contents_;
	NSError					*error_;
	SEL						delegateSEL = NULL;
	BOOL	hoge;

	contents_ = [self stringWithDataUsingAvailableURLEncodings:[self availableResourceData]];

	// Error handling
	handler_ = [SG2chErrorHandler handlerWithURL:[self requestURL]];
	error_ = [handler_ handleErrorWithContents:contents_];
	hoge = (handler_ && [[error_ domain] isEqualToString:SG2chErrorHandlerErrorDomain] && [error_ code] != k2chNoneErrorType);
	delegateSEL =  hoge ? @selector(connector:resourceDidFailLoadingWithErrorHandler:)
						: @selector(connectorResourceDidFinishLoading:);

	if (![self delegate]) return;
	if (![[self delegate] respondsToSelector:delegateSEL]) return;
	
	if (hoge) {
		[[self delegate] connector:self resourceDidFailLoadingWithErrorHandler:handler_];
	} else { 
		[[self delegate] connectorResourceDidFinishLoading:self];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[[self availableResourceData] appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	id delegate_ = [self delegate];
	if (delegate_ && [delegate_ respondsToSelector:@selector(connector:resourceDidFailLoadingWithError:)]) {
		[delegate_ connector:self resourceDidFailLoadingWithError:error];
	}
}
@end


@implementation SG2chConnector(RequestHeaders)
- (NSDictionary *)requestHeaders
{
	UTILAbstractMethodInvoked;
	return nil;
}
- (BOOL)isRequestHeadersComplete:(NSDictionary *)headers
{
	UTILAbstractMethodInvoked;
	return NO;
}
@end
