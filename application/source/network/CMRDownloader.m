//
//  CMRDownloader.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRDownloader_p.h"
#import "AppDefaults.h"


// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


NSString *const CMRDownloaderNotFoundNotification	= @"CMRDownloaderNotFoundNotification";


@implementation CMRDownloader
- (id)init
{
	if (self = [super init]) {
		[self setMessage:[self localizedNotLoaded]];
	}
	return self;
}

- (void)dealloc
{
	[m_data release];
	[m_identifier release];
	[m_connector release];
	[m_statusMessage release];
	[super dealloc];
}

+ (NSMutableDictionary *)defaultRequestHeaders
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys :
				@"no-cache",				HTTP_CACHE_CONTROL_KEY,
				@"no-cache",				HTTP_PRAGMA_KEY,
				@"Close",					HTTP_CONNECTION_KEY,
				[NSBundle monazillaUserAgent],	HTTP_USER_AGENT_KEY,
				@"text/plain",				HTTP_ACCEPT_KEY,
				@"gzip",					HTTP_ACCEPT_ENCODING_KEY,
				@"ja",						HTTP_ACCEPT_LANGUAGE_KEY,
				nil];
}

- (NSDictionary *)requestHeaders
{
	NSMutableDictionary		*defaultHeaders_;
	
	defaultHeaders_ = [[self class] defaultRequestHeaders];
	UTILAssertNotNil(defaultHeaders_);
	
	[self setupRequestHeaders:defaultHeaders_];
	return defaultHeaders_;
}

- (NSURLConnection *)currentConnector
{
	return m_connector;
}

- (NSMutableData *)resourceData
{
	return m_data;
}

- (void)setResourceData:(NSMutableData *)data
{
	[data retain];
	[m_data release];
	m_data = data;
}

- (NSURL *)boardURL
{
	UTILAbstractMethodInvoked;
	return nil;
}

#pragma mark CMRTask
- (id)identifier
{
	return m_identifier;
}

- (NSString *)title
{
	return [NSString stringWithFormat:[self localizedTitleFormat], [self categoryDescription], [self simpleDescription]];
}

- (NSString *)message
{
	return m_statusMessage;
}

- (void)setMessage:(NSString *)msg
{
	[msg retain];
	[m_statusMessage release];
	m_statusMessage = msg;
}

- (BOOL)isInProgress
{
	return m_isInProgress;
}

- (void)setIsInProgress:(BOOL)inProgress
{
	m_isInProgress = inProgress;
}

- (double)amount
{
	return m_amount;
}

- (void)setAmount:(double)doubleValue
{
	m_amount = doubleValue;
}

- (IBAction)cancel:(id)sender
{
	[self cancelDownload];
}

#pragma mark For SubClasses
- (NSURL *)resourceURL
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (NSString *)filePathToWrite
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (void)cancelDownloadWithInvalidPartial
{
	// Subclass should override this method.
}

- (void)cancelDownloadWithDetectingDatOchi
{
	// Subclass should override this method.
}
@end


@implementation CMRDownloader(PrivateAccessor)
- (void)setIdentifier:(id)anIdentifier
{
	[anIdentifier retain];
	[m_identifier release];
	m_identifier = anIdentifier;
}

- (void)setCurrentConnector:(NSURLConnection *)connection
{
	[connection retain];
	[m_connector release];
	m_connector = connection;
}
- (void)setupRequestHeaders:(NSMutableDictionary *)mdict
{
	NSURL				*resourceURL_;

	UTILAssertNotNilArgument(mdict, @"Default Request Headers");
	resourceURL_ = [self resourceURL];
	UTILAssertNotNil(mdict);
	[mdict setObject:[resourceURL_ host] forKey:HTTP_HOST_KEY];
}

- (NSURLConnection *)makeHTTPURLConnectionWithURL:(NSURL *)anURL
{
	NSURLConnection *connection;
	NSDictionary		*requestHeaders_;
	NSMutableURLRequest	*request;
	
	anURL = [self resourceURL];
	UTILAssertNotNil(anURL);

	requestHeaders_ = [self requestHeaders];
	UTILAssertNotNil(requestHeaders_);

	[self setResourceData:[NSMutableData data]];

	request = [NSMutableURLRequest requestWithURL:anURL];
	UTILAssertNotNil(request);
	[request setHTTPMethod:HTTP_METHOD_GET];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData]; // Important
	[request setAllHTTPHeaderFields:requestHeaders_];
	[request setTimeoutInterval:30.0];
	[request setHTTPShouldHandleCookies:NO];

	connection = [NSURLConnection connectionWithRequest:request delegate:self];

	return connection;
}

- (NSURL *)resourceURLForWebBrowser
{
	return [self resourceURL];
}
@end


@implementation CMRDownloader(LoadingResourceData)
- (void)loadInBackground
{
	NSURLConnection *con;
	NSURL			*resourceURL = [self resourceURL];
	NSLog(@"loadInBakground cakked");
	
	/* check */
	if ([[CMRNetGrobalLock sharedInstance] has:resourceURL]) {
		UTIL_DEBUG_WRITE1(
			@"  Loading URL(%@) was in progress...",
			[resourceURL stringValue]);
		[self setMessage:[self localizedCanceledString]];
		return;
	}
	
	[[CMRNetGrobalLock sharedInstance] add:resourceURL];
	con = [self makeHTTPURLConnectionWithURL:resourceURL];
	
	UTILAssertNotNil(con);
	[self setIsInProgress:YES];
	[self setAmount:-1];
	/* --- Retain --- */
//	[self retain];
	[self setCurrentConnector:con];
	/* -------------- */
	[self postTaskWillStartNotification];
}

- (void)didFinishLoading
{
	NSURL			*resourceURL = [self resourceURL];
	
	[self setIsInProgress:NO];

    [[CMRNetGrobalLock sharedInstance] remove:resourceURL];

	[self setCurrentConnector:nil];
	[self setResourceData:nil];

	[self postTaskDidFinishNotification];
}

- (BOOL)dataProcess:(NSData *)resourceData withConnector:(NSURLConnection *)connector
{
	UTILAbstractMethodInvoked;
	return NO;
}
@end


@implementation CMRDownloader(ResourceManagement)
- (void)cancelDownload
{
	if (![self isInProgress]) return;

	[[self currentConnector] cancel];
	[self setMessage:[self localizedUserCanceledString]];
	[self didFinishLoading];
}

/* synchronize computer time with server. */
- (void)synchronizeServerClock:(NSHTTPURLResponse *)response
{
	UTILAssertKindOfClass(response, NSHTTPURLResponse);
	CMRServerClock *clock = [CMRServerClock sharedInstance];
	NSString *dateString;
	NSDate *date;

	dateString = [[response allHeaderFields] stringForKey:HTTP_DATE_KEY];
	date = [[BSHTTPDateFormatter sharedHTTPDateFormatter] dateFromString:dateString];

	[clock updateClock:date forURL:[response URL]];
	[clock setLastAccessedDate:date forURL:[self resourceURL]];
}
@end


@implementation CMRDownloader(NSURLConnectionDelegate)
// Leopard
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	if (!redirectResponse) {
		return request;
	}
	if ([(NSHTTPURLResponse *)redirectResponse statusCode] == 302) {
		[connection cancel];
		[self setMessage:[self localizedDetectingDatOchiString]];
		[self cancelDownloadWithDetectingDatOchi];

		[self didFinishLoading];
	}
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
	int status = [http statusCode];
	m_expectedLength = [http expectedContentLength];
	NSLog(@"expected length: %.2f", m_expectedLength);
	UTIL_DEBUG_WRITE1(@"HTTP Status: %i", status);

	[self synchronizeServerClock:http];

    switch (status) {
	case 200:
    case 206:
		[self setMessage:[NSString stringWithFormat:[self localizedMessageFormat], [[self resourceURL] absoluteString]]];
        break;
	case 302:
		[connection cancel];
		[self setMessage:[self localizedDetectingDatOchiString]];
		[self cancelDownloadWithDetectingDatOchi];

		[self didFinishLoading];
		break;
    case 304:
		[connection cancel];
		[self setMessage:[self localizedNotModifiedString]];

		[self didFinishLoading];
		break;
	case 416:
		[connection cancel];
		[self setMessage:[self localizedCanceledString]];
		[self cancelDownloadWithInvalidPartial];

		[self didFinishLoading];
		break;
	default:
		[connection cancel];
		[self setMessage:[self localizedCanceledString]];

		[self didFinishLoading];
        break;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self setMessage:[self localizedSucceededString]];
	[self dataProcess:[self resourceData] withConnector:connection];
	[self didFinishLoading];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"connection:didReceiveData:");
	double foo = -1;
	[[self resourceData] appendData:data];
	if (m_expectedLength != -1) {
		foo = [[self resourceData] length]/m_expectedLength*100.0;
		if (foo > 100.0) foo = 100.0;
	}
	NSLog(@"%.2f", foo);
	[self setAmount:foo];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSString *title_;
	NSString *msg_;
	NSAlert *alert_;

	title_ = [error localizedDescription];
	if (!title_ || [title_ length] == 0) {
		title_ = @"Download Error Occurred";
	}
	msg_ = [NSString stringWithFormat:[self localizedString:APP_DOWNLOADER_FAIL_LOADING_FMT],[[self resourceURLForWebBrowser] absoluteString]];

	NSLog(
		@"<Downloader %p> in %@"
		@"----------------------------------------\n"
		@"  Sender = %@ \n"
		@"  Reason = %@",
		self, NSStringFromSelector(_cmd),
		connection, [error description]);

	alert_ = [[[NSAlert alloc] init] autorelease];
	[alert_ setAlertStyle:NSWarningAlertStyle];
	[alert_ setInformativeText:msg_];
	[alert_ setMessageText:title_];
	[alert_ runModal];

	[self setMessage:[self localizedErrorString]];	
	[self didFinishLoading];
}
@end
