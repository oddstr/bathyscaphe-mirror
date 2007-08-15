//
//  CMRDownloader.m
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "CMRDownloader_p.h"
#import "AppDefaults.h"


// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


NSString *const CMRDownloaderNotFoundNotification	= @"CMRDownloaderNotFoundNotification";


@implementation CMRDownloader
- (void) dealloc
{
	[m_data release];
	[_identifier release];
	[m_connector release];
	[m_statusMessage release];
	[super dealloc];
}

- (NSDictionary *) requestHeaders
{
	NSMutableDictionary		*defaultHeaders_;
	
	defaultHeaders_ = [[self class] defaultRequestHeaders];
	UTILAssertNotNil(defaultHeaders_);
	
	[self setupRequestHeaders : defaultHeaders_];
	return defaultHeaders_;
}

- (NSURLConnection *)currentConnector
{
	return m_connector;
}

- (id) identifier
{
	return _identifier;
}

- (void) setIdentifier : (id) anIdentifier
{
	id		tmp;
	
	tmp = _identifier;
	_identifier = [anIdentifier retain];
	[tmp release];
}

- (NSURL *) resourceURL
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (NSString *) filePathToWrite
{
	UTILAbstractMethodInvoked;
	return nil;
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

- (NSURL *) boardURL
{
	UTILAbstractMethodInvoked;
	return nil;
}

#pragma mark CMRTask
- (NSString *) title
{
	return [NSString stringWithFormat : [self localizedTitleFormat],
										[self categoryDescription],
										[self simpleDescription]];
}

- (NSString *) message
{
	if (!m_statusMessage) {
		m_statusMessage = [[self localizedNotLoaded] retain];
	}
	return m_statusMessage;
}

- (void)setMessage:(NSString *)msg
{
	[msg retain];
	[m_statusMessage release];
	m_statusMessage = msg;
}

- (BOOL) isInProgress
{
	return [self isDownloadInProgress];
}

// from 0.0 to 100.0
- (double) amount
{
	return m_amount;
}

- (void)setAmount:(double)doubleValue
{
	m_amount = doubleValue;
}

- (IBAction) cancel : (id) sender
{
	[self cancelDownload];
}

#pragma mark For SubClasses
- (void) cancelDownloadWithInvalidPartial
{
}
- (void) cancelDownloadWithDetectingDatOchi
{
}
@end


@implementation CMRDownloader(HTTPRequestHeader)
+ (NSMutableDictionary *) defaultRequestHeaders
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
@end


@implementation CMRDownloader(PrivateAccessor)
- (void)setCurrentConnector:(NSURLConnection *)connection
{
	[connection retain];
	[m_connector release];
	m_connector = connection;
}
- (void) setupRequestHeaders : (NSMutableDictionary *) mdict
{
	NSURL				*resourceURL_;
	
	UTILAssertNotNilArgument(mdict, @"Default Request Headers");
	resourceURL_ = [self resourceURL];
	UTILAssertNotNil(mdict);
	[mdict setObject : [resourceURL_ host]
			  forKey : HTTP_HOST_KEY];
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

- (NSURL *) resourceURLForWebBrowser
{
	return [self resourceURL];
}
@end


@implementation CMRDownloader(LoadingResourceData)
- (void) loadInBackground
{
	NSURLConnection *con;
	NSURL			*resourceURL = [self resourceURL];
	
	/* check */
	if ([[CMRNetGrobalLock sharedInstance] has : resourceURL]) {
		UTIL_DEBUG_WRITE1(
			@"  Loading URL(%@) was in progress...",
			[resourceURL stringValue]);
		[self setMessage:[self localizedCanceledString]];
		return;
	}
	
	[[CMRNetGrobalLock sharedInstance] add : resourceURL];
	con = [self makeHTTPURLConnectionWithURL:resourceURL];
	
	UTILAssertNotNil(con);
	[self setIsDownloadInProgress:YES];
	/* --- Retain --- */
	[self retain];
	[self setCurrentConnector : con];
	/* -------------- */
	
	[self postTaskWillStartNotification];
}

- (void) didFinishLoading:(NSURLConnection *)connector;
{
	NSURL			*resourceURL = [self resourceURL];
	
	[self setIsDownloadInProgress:NO];
	[self postTaskDidFinishNotification];

    [[CMRNetGrobalLock sharedInstance] remove : resourceURL];

	[self setCurrentConnector:nil];
	[self setResourceData:nil];
	[self autorelease];
}

- (BOOL) dataProcess : (NSData *) resourceData
       withConnector : (NSURLConnection *) connector
{
	UTILAbstractMethodInvoked;
	return NO;
}
@end


@implementation CMRDownloader(ResourceManagement)
/*- (BOOL) isFirstArrivalWithURLHandle : (NSURLHandle *) URLHandle
	  resourceDataDidBecomeAvailable : (NSData      *) newBytes
{
	NSData *avail = [URLHandle availableResourceData];
	
	return ([newBytes length] == [avail length]);
}*/
- (BOOL) shouldCancelWithFirstArrivalData : (NSData *) theData
{
	return NO;//CHECK_HTML([theData bytes], [theData length]);
}

- (void) cancelDownloadWithPostingNotificationName : (NSString *) name
{
	[self retain];
	[self cancelDownload];
	UTILNotifyName(name);
	[self autorelease];
}

/* synchronize computer time with server. */
- (void)synchronizeServerClock:(NSHTTPURLResponse *)response
{
	NSLog(@"-[CMRDownloader synchrozineServerClock:] called.");
	UTILAssertKindOfClass(response, NSHTTPURLResponse);

	NSString *dateString;
	NSDate *date;

	dateString = [[response allHeaderFields] stringForKey:HTTP_DATE_KEY];
	date = [NSCalendarDate dateWithHTTPTimeRepresentation:dateString];

	[[CMRServerClock sharedInstance] updateClock:date forURL:[response URL]];
	[[CMRServerClock sharedInstance] setLastAccessedDate:date forURL:[self resourceURL]];
}
@end


@implementation CMRDownloader(NSURLConnectionDelegate)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
	int status = [http statusCode];
	m_expectedLength = [http expectedContentLength];
	UTIL_DEBUG_WRITE1(@"HTTP Status: %i", status);

	[self synchronizeServerClock:http];

    switch (status) {
    case 200:
//		[self synchronizeServerClock:http];
		[self setMessage:[NSString stringWithFormat:[self localizedMessageFormat], [[self resourceURL] absoluteString]]];
        break;
    case 206:
//		[self synchronizeServerClock:http];
		[self setMessage:[NSString stringWithFormat:[self localizedMessageFormat], [[self resourceURL] absoluteString]]];
        break;
    case 304:
		[connection cancel];
		[self setMessage:[self localizedCanceledString]];
		[self didFinishLoading:connection];
		break;
	case 302:
		[self cancelDownloadWithDetectingDatOchi]; // Note: no break
	case 416:
		[self cancelDownloadWithInvalidPartial]; // Note: no break
	default:
		[connection cancel];
		[self setMessage:[self localizedCanceledString]];
		[self didFinishLoading:connection];
        break;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self setMessage:[self localizedSucceededString]];
	[self dataProcess:[self resourceData] withConnector:connection];
	[self didFinishLoading:connection];
}
/*- (void) URLHandle               : (NSURLHandle *) sender
  resourceDataDidBecomeAvailable : (NSData      *) newBytes
{
	NSData				*data;
	SGHTTPConnector		*con;
	
	con  = [self HTTPConnectorCastURLHandle : sender];
	if (NO == [self isFirstArrivalWithURLHandle : con
	             resourceDataDidBecomeAvailable : newBytes])
	{ return; }
	
	
	[self synchronizeServerClock : con];
	
	data = [con availableResourceData];
	if ([self shouldCancelWithFirstArrivalData : data]) {
		[self cancelDownloadWithPostingNotificationName :
							CMRDownloaderNotFoundNotification];
		return;
	}	
}*/
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	double foo = -1;
	[[self resourceData] appendData:data];
	if (m_expectedLength != -1) {
		foo = [[self resourceData] length]/m_expectedLength*100.0;
		if (foo > 100.0) foo = 100.0;
	}
	[self setAmount: foo];
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
	[self didFinishLoading:connection];
}
@end
