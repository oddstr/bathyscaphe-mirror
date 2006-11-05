/**
  * $Id: CMRDownloader.m,v 1.2 2006/11/05 12:53:48 tsawada2 Exp $
  * 
  * CMRDownloader.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRDownloader_p.h"
#import "AppDefaults.h"
//#import "string_utils.h"
#import <AppKit/NSPanel.h>



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



//////////////////////////////////////////////////////////////////////
//////////// [ D e f i n e d / C o n s t a n t s ] ///////////////////
//////////////////////////////////////////////////////////////////////
NSString *const CMRDownloaderNotFoundNotification	= @"CMRDownloaderNotFoundNotification";




@implementation CMRDownloader
- (void) dealloc
{
	[_identifier release];
	[_connector release];
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
- (SGHTTPConnector *) currentConnector
{
	return _connector;
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
- (NSData *) resourceData
{
	return [[self currentConnector] availableResourceData];
}
- (NSURL *) boardURL
{
	UTILAbstractMethodInvoked;
	return nil;
}

// CMRTask
// - (id) identifier;
- (NSString *) title
{
	return [NSString stringWithFormat : [self localizedTitleFormat],
										[self categoryDescription],
										[self simpleDescription]];
}

- (NSString *) message
{
	if (nil == [[self currentConnector] requestURL])
		return [[self resourceURL] description];
	
	if ([self isCanceledLoadInBackground])
		return [self localizedCanceledString];
	
	switch([self downloadStatus]) {
	case NSURLHandleLoadInProgress:
		return [NSString stringWithFormat : 
				[self localizedMessageFormat],
				//[[[self currentConnector] requestURL] absoluteString],
				[self resourceName],
				[self amountString]];
		break;
	case NSURLHandleNotLoaded:
		return [self localizedNotLoaded];
		break;
	case NSURLHandleLoadFailed:
		return [self localizedErrorString];
		break;
	case NSURLHandleLoadSucceeded:
		return [self localizedSucceededString];
		break;
	default:
		UTILUnknownSwitchCase([self downloadStatus]);
		break;
	}
	return @"";
}

- (BOOL) isInProgress
{
	return [self isDownloadInProgress];
}

// from 0.0 to 100.0
- (double) amount
{
	unsigned		contentLength_	= 0;
	unsigned		bytesLength_	= 0;
	
	UTILRequireCondition(
		[self isInProgress],
		error_amount);
	
	contentLength_ = [[self currentConnector] readContentLength];
	UTILRequireCondition(
		(contentLength_ != NSNotFound && contentLength_ != 0),
		error_amount);
	
	bytesLength_ = [[self currentConnector] loadedBytesLength];
	UTILRequireCondition(
		(bytesLength_ != 0), 
		error_amount);
	
	return ((double)bytesLength_ / (double)contentLength_) * 100.0;
	
	error_amount:
	{
		return 0.0;
	}
}

- (IBAction) cancel : (id) sender
{
	[self cancelDownload];
}
@end



@implementation CMRDownloader(HTTPRequestHeader)
+ (NSMutableDictionary *) defaultRequestHeaders
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys :
				@"no-cache",				HTTP_CACHE_CONTROL_KEY,
				@"no-cache",				HTTP_PRAGMA_KEY,
				@"Close",					HTTP_CONNECTION_KEY,
				[self monazillaUserAgent],	HTTP_USER_AGENT_KEY,
				@"text/plain",				HTTP_ACCEPT_KEY,
				@"gzip",					HTTP_ACCEPT_ENCODING_KEY,
				@"ja",						HTTP_ACCEPT_LANGUAGE_KEY,
				nil];
}

+ (NSString *) applicationUserAgent
{
	return [NSString stringWithFormat :
						@"%@/%@",
						[NSBundle applicationName],
						[NSBundle applicationVersion]];
}

+ (NSString *) monazillaUserAgent
{
	const long	dolibVersion_ = (1 << 16);
		
	// monazilla.org (02.01.20)
	return [NSString stringWithFormat :
					@"Monazilla/%d.%02d (%@)",
					dolibVersion_ >> 16,
					dolibVersion_ & 0xffff,
					[self applicationUserAgent]];
}
@end



@implementation CMRDownloader(PrivateAccessor)
- (void) setCurrentConnector : (SGHTTPConnector *) aCurrentConnector
{
	id tmp;
	
	tmp = _connector;
	_connector = [aCurrentConnector retain];
	[tmp release];
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

- (SGHTTPConnector *) makeHTTPConnectorWithURL : (NSURL *) anURL 
{
	SGHTTPConnector		*connector_;
	NSDictionary		*requestHeaders_;
	
	anURL = [self resourceURL];
	UTILAssertNotNil(anURL);
	
	connector_ = [SGHTTPStream connectorWithURL : [self resourceURL]
								  requestMethod : HTTP_METHOD_GET];

	requestHeaders_ = [self requestHeaders];
	UTILAssertNotNil(requestHeaders_);
	[connector_ writePropertiesFromDictionary : requestHeaders_];
	
	// proxy
	/*if ([CMRPref usesProxy] && NO == [CMRPref usesProxyOnlyWhenPOST]) {
		NSString	*host;
		CFIndex		port;
		
		[CMRPref getProxy:&host port:&port];
		[connector_ setProxy:host port:port];
		UTILDebugWrite3(
			@"  using proxy (Host:%@ Port:%d)\n\t"
			@"  for %@", host, port, [[self resourceURL] stringValue]);
	}*/
	if ([CMRPref usesOwnProxy]) {
		NSLog(@"WARNING: You are using BathyScaphe's own proxy settings, but this feature will be deprecated in the future.");
		NSString	*host;
		CFIndex		port;
		[CMRPref getOwnProxy: &host port: &port];
		[connector_ setProxy: host port: port];
	} else {
		[connector_ setProxyIfNeeded];
	}
	return connector_;
}


- (NSURL *) resourceURLForWebBrowser
{
	return [self resourceURL];
}
@end






@implementation CMRDownloader(LoadingResourceData)

- (void) loadInBackground
{
	SGHTTPConnector	*con;
	NSURL			*resourceURL = [self resourceURL];
	
	/* check */
	if ([[CMRNetGrobalLock sharedInstance] has : resourceURL]) {
		UTIL_DEBUG_WRITE1(
			@"  Loading URL(%@) was in progress...",
			[resourceURL stringValue]);
		
		return;
	}
	
	[[CMRNetGrobalLock sharedInstance] add : resourceURL];
	con = [self makeHTTPConnectorWithURL : resourceURL];
	
	UTILAssertNotNil(con);
	/* --- Retain --- */
	[self retain];
	[self setCurrentConnector : con];
	[con addClient : self];
	/* -------------- */
	
	[con loadInBackground];
	[self postTaskWillStartNotification];
}
- (void) didFinishLoading : (NSURLHandle *) aConnect;
{
	NSURL			*resourceURL = [self resourceURL];
	
	UTILAssertNotNil(aConnect);
	[self postTaskDidFinishNotification];
	
	UTIL_DEBUG_WRITE1(@"%@", [aConnect description]);
	
    [[CMRNetGrobalLock sharedInstance] remove : resourceURL];
	[aConnect removeClient : self];
	[self setCurrentConnector : nil];
	[self autorelease];
}
- (BOOL) dataProcess : (NSData      *) resourceData
       withConnector : (NSURLHandle *) connector
{
	UTILAbstractMethodInvoked;
	return NO;
}
@end



@implementation CMRDownloader(ResourceManagement)
- (BOOL) isFirstArrivalWithURLHandle : (NSURLHandle *) URLHandle
	  resourceDataDidBecomeAvailable : (NSData      *) newBytes
{
	NSData *avail = [URLHandle availableResourceData];
	
	return ([newBytes length] == [avail length]);
}
- (BOOL) shouldCancelWithFirstArrivalData : (NSData *) theData
{
	return CHECK_HTML([theData bytes], [theData length]);
}

- (void) cancelDownloadWithPostingNotificationName : (NSString *) name
{
	[self retain];
	[self cancelDownload];
	UTILNotifyName(name);
	[self autorelease];
}

/* synchronize computer time with server. */
- (void) synchronizeServerClock : (SGHTTPConnector *) connector
{
	NSString		*cdate_str_;
	NSDate			*cdate_;
	
	cdate_str_ = [[connector response] 
					headerFieldValueForKey : HTTP_DATE_KEY];
	
	cdate_ = [NSCalendarDate dateWithHTTPTimeRepresentation : cdate_str_];
	
	[[CMRServerClock sharedInstance] updateClock:cdate_ forURL:[connector requestURL]];
}

@end



@implementation CMRDownloader(URLHandleClient)
- (SGHTTPConnector *) HTTPConnectorCastURLHandle : (NSURLHandle *) handler
{
	UTILAssertNotNil(handler);
	UTILAssertKindOfClass(handler, SGHTTPConnector);
	
	return (SGHTTPConnector *)handler;
}
- (void) URLHandleResourceDidBeginLoading : (NSURLHandle *) sender
{
	
}

- (void) URLHandleResourceDidCancelLoading : (NSURLHandle *) sender
{
	[self didFinishLoading : sender];
}

- (void) URLHandleResourceDidFinishLoading : (NSURLHandle *) sender
{
	[self dataProcess : [sender availableResourceData]
		withConnector : sender];
	[self didFinishLoading : sender];
}

- (void) URLHandle               : (NSURLHandle *) sender
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
	
}

- (void) URLHandle                 : (NSURLHandle *) sender
  resourceDidFailLoadingWithReason : (NSString    *) reason
{
	NSString		*title_;
	NSString		*msg_;

	title_ = [self localizedString : APP_DOWNLOADER_FAIL_LOADING_STR];
	msg_ = [NSString stringWithFormat : 
					[self localizedString : APP_DOWNLOADER_FAIL_LOADING_FMT],
					[[self resourceURL] absoluteString]];
	
	NSLog(
		@"<Downloader %p> in %@"
		@"----------------------------------------\n"
		@"  Sender = %@ \n"
		@"  Reason = %@",
		self, NSStringFromSelector(_cmd),
		sender, reason);
	
	NSRunAlertPanel(
		title_,
		msg_,
		nil,
		nil,
		nil);
	
	[self didFinishLoading : sender];
}
@end
