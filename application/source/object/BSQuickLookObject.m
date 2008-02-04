//
//  BSQuickLookObject.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/02.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSQuickLookObject_p.h"

#import "BoardManager.h"

NSString *const BSQuickLookErrorDomain = @"jp.tsawada2.BathyScaphe.BSQuickLookObject";

@implementation BSQuickLookObject
+ (Class *)classClusters
{
	static Class classes[3] = {Nil, };
	
	if (Nil == classes[0]) {
		classes[0] = [(id)[BS2chQuickLookObject class] retain];
		classes[1] = [(id)[BSHTMLQuickLookObject class] retain];
		classes[2] = Nil;
	}
	
	return classes;
}
// do not release!
+ (id)allocWithZone:(NSZone *)zone
{
	if ([self isEqual:[BSQuickLookObject class]]) {
		static id instance_;
		
		if (!instance_) {
			instance_ = [super allocWithZone:zone];
		}
		return instance_;
	}
	return [super allocWithZone:zone];
}

- (id)initClusterWithThreadTitle:(NSString *)title signature:(CMRThreadSignature *)signature
{
	if (self = [super init]) {
		[self setThreadTitle:title];
		[self setThreadSignature:signature];

		if ([[NSFileManager defaultManager] fileExistsAtPath:[signature threadDocumentPath]]) {
			[self loadFromContentsOfFile];
		} else {
			[self startDownloadingQLContent];
		}
	}
	return self;
}

- (id)initWithThreadTitle:(NSString *)title signature:(CMRThreadSignature *)signature
{
	Class			*p;
	id				instance_;
	NSURL			*boardURL_;
	
	instance_ = nil;
	boardURL_ = [[BoardManager defaultManager] URLForBoardName:[signature boardName]];
	UTILRequireCondition(boardURL_, return_instance);
	
	for (p = [[self class] classClusters]; *p != Nil; p++) {
		if ([*p canInitWithURL:boardURL_]) {
			instance_ = [[*p alloc] initClusterWithThreadTitle:title signature:signature];
			break;
		}
	}
	
return_instance:
	return instance_;
}

- (void)dealloc
{
	NSAssert2(
		NO == [(id)[self class] isEqual:(id)[BSQuickLookObject class]],
		@"%@<%p> was place holder instance, do not release!!",
		NSStringFromClass([BSQuickLookObject class]),
		self);

	[m_receivedData release];
	m_receivedData = nil;

	[self setLastError:nil];
	[self setCurrentConnection:nil];
	[self setThreadMessage:nil];
	[self setThreadSignature:nil];
	[self setThreadTitle:nil];

	[super dealloc];
}

- (NSURL *)boardURL
{
	return [[BoardManager defaultManager] URLForBoardName:[[self threadSignature] boardName]];
}

- (void)cancelDownloading
{
	[[self currentConnection] cancel];
}

- (NSString *)threadTitle
{
	return m_threadTitle;
}

- (CMRThreadSignature *)threadSignature
{
	return m_threadSignature;
}

- (CMRThreadMessage *)threadMessage
{
	return m_threadMessage;
}

- (BOOL)isLoading
{
	return m_isLoading;
}

- (NSError *)lastError
{
	return m_lastError;
}

#pragma mark For Subclass
+ (BOOL)canInitWithURL:(NSURL *)url
{
	UTILAbstractMethodInvoked;
	return NO;
}

- (NSURL *)resourceURL
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (NSURLRequest *)requestForDownloadingQLContent
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (CMRThreadMessage *)threadMessageFromString:(NSString *)source
{
	UTILAbstractMethodInvoked;
	return nil;
}

#pragma mark NSURLConnection Delegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	if (!redirectResponse) return request;

	[connection cancel];
	[self setCurrentConnection:nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Quick Look DEKIMASEN 1", @"") forKey:NSLocalizedDescriptionKey];
	NSError *error = [NSError errorWithDomain:BSQuickLookErrorDomain code:[(NSHTTPURLResponse *)redirectResponse statusCode] userInfo:dict];
	[self setLastError:error];
	[self setIsLoading:NO];
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)resp
{
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)resp;
	int status = [http statusCode];

    switch (status) {
    case 200:
        break;
    case 206:
        break;
    default:
		[connection cancel];
		[self setCurrentConnection:nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Quick Look DEKIMASEN 2", @"") forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:BSQuickLookErrorDomain code:status userInfo:dict];
		[self setLastError:error];
		[self setIsLoading:NO];
        break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [m_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self setCurrentConnection:nil];
	[self setLastError:error];
	[self setIsLoading:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self setCurrentConnection:nil];
	[self setThreadMessage:[self threadMessageFromReceivedData]];
	[self setIsLoading:NO];
}
@end


@implementation BSQuickLookObject(PrivateAccessors)
- (void)setThreadTitle:(NSString *)title
{
	[title retain];
	[m_threadTitle release];
	m_threadTitle = title;
}

- (void)setThreadSignature:(CMRThreadSignature *)signature
{
	[signature retain];
	[m_threadSignature release];
	m_threadSignature = signature;
}

- (void)setThreadMessage:(CMRThreadMessage *)message
{
	[message retain];
	[m_threadMessage release];
	m_threadMessage = message;
}

- (NSURLConnection *)currentConnection
{
	return m_currentConnection;
}

- (void)setCurrentConnection:(NSURLConnection *)connection
{
	[connection retain];
	[m_currentConnection release];
	m_currentConnection = connection;
}

- (void)setIsLoading:(BOOL)flag
{
	m_isLoading = flag;
}

- (void)setLastError:(NSError *)error
{
	[error retain];
	[m_lastError release];
	m_lastError = error;
}

- (CFStringEncoding)encodingForData
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL:[self boardURL]];
	return handler_ ? [handler_ threadEncoding] : 0;
}

- (void)loadFromContentsOfFile
{
	NSDictionary *localDict;
	CMRThreadMessage *bar;
	[self setIsLoading:YES];
	localDict = [NSDictionary dictionaryWithContentsOfFile:[[self threadSignature] threadDocumentPath]];

	NSArray *array = [localDict objectForKey:ThreadPlistContentsKey];
	NSDictionary *foo = [array objectAtIndex:0];

	bar = [CMRThreadMessage objectWithPropertyListRepresentation:foo];
	if (!bar) {
		NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Quick Look DEKIMASEN 3",@"") forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:BSQuickLookErrorDomain code:1001 userInfo:dict];
		[self setLastError:error];
	} else {
		[self setThreadMessage:bar];
	}
	[self setIsLoading:NO];
}

- (void)startDownloadingQLContent
{
	NSURLConnection *connection;

	m_receivedData = [[NSMutableData alloc] init];

    connection = [[NSURLConnection alloc] initWithRequest:[self requestForDownloadingQLContent] delegate:self];
	[self setCurrentConnection:connection];
	[connection release];
	[self setIsLoading:YES];
}

- (CMRThreadMessage *)threadMessageFromReceivedData
{
	CFStringEncoding	enc;
	NSString			*src = nil;

	if (!m_receivedData || [m_receivedData length] == 0) return nil;
	
	enc = [self encodingForData];
	src = [CMXTextParser stringWithData:m_receivedData CFEncoding:enc];
	
	if (!src) {
		src = [[[NSString alloc] initWithDataUsingTEC:m_receivedData encoding:enc] autorelease];
	}

	if (!src) return nil;

	return [self threadMessageFromString:src];
}
@end
