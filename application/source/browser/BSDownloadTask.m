//
//  BSDownloadTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSDownloadTask.h"

NSString *BSDownloadTaskFinishDownloadNotification = @"BSDownloadTaskFinishDownloadNotification";
NSString *BSDownloadTaskReceiveResponceNotification = @"BSDownloadTaskReceiveResponceNotification";
NSString *BSDownloadTaskCanceledNotification = @"BSDownloadTaskCanceledNotification";
NSString *BSDownloadTaskInternalErrorNotification = @"BSDownloadTaskInternalErrorNotification";
NSString *BSDownloadTaskAbortDownloadNotification = @"BSDownloadTaskAbortDownloadNotification";
NSString *BSDownloadTaskServerResponseKey = @"BSDownloadTaskServerResponseKey"; // NSURLResponse
NSString *BSDownloadTaskStatusCodeKey = @"BSDownloadTaskStatusCodeKey"; // NSNumber (int)
NSString *BSDownloadTaskFailDownloadNotification = @"BSDownloadTaskFailDownloadNotification";


@implementation BSDownloadTask
+ (id)taskWithURL:(NSURL *)url
{
	return [[[self alloc] initWithURL:url] autorelease];
}

- (id) initWithURL:(NSURL *)url
{
	if(self = [super init]) {
		//
		[self setURL:url];
	}
	
	return self;
}

+ (id)taskWithURL:(NSURL *)url method:(NSString *)method
{
	return [[[self alloc] initWithURL:url method:method] autorelease];
}

- (id)initWithURL:(NSURL *)url method:(NSString *)inMethod
{
	if(self = [self initWithURL:url]) {
		method = [inMethod retain];
	}
	
	return self;
}

- (void)dealloc
{
	[self setURL:nil];
	[con release];
	[receivedData release];
	[method release];
	[_response release];
	
	[super dealloc];
}

#pragma mark Accessors
- (void)setURL:(NSURL *)url
{
	id temp = m_targetURL;
	m_targetURL = [url retain];
	[temp release];
}

- (NSURL *)url
{
	return m_targetURL;
}

- (void)setCurrentLength:(double)doubleValue
{
	m_currentLength = doubleValue;
}

- (double)currentLength
{
	return m_currentLength;
}

- (void)setContLength:(double)i
{
	m_contLength = i;
}

- (double)contLength
{
	return m_contLength;
}

- (NSData *)receivedData
{
	return receivedData;
}

- (void)setResponse:(id)response
{
	id temp = _response;
	_response = [response retain];
	[temp release];
}

- (id)response
{
	return _response;
}

#pragma mark Overrides
/*- (void)createURLConnection:(id)request
{
	con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(!con) {
		[self postNotificationWithName:BSDownloadTaskInternalErrorNotification];
		return;
	}
}*/

- (void)doExecuteWithLayout:(CMRThreadLayout *)layout
{
	NSRunLoop *loop = [NSRunLoop currentRunLoop];
		
	[receivedData release];
	receivedData = nil;
	[self setCurrentLength:0];
	[self setContLength:0];
	[self setAmount:-1];

	NSMutableURLRequest *request;
	
	request = [NSMutableURLRequest requestWithURL:[self url]];
	if(!request) {
		[self postNotificationWithName:BSDownloadTaskInternalErrorNotification];
		return;
	}
	[request setValue:[NSBundle monazillaUserAgent] forHTTPHeaderField:@"User-Agent"];
	if (method) {
		[request setHTTPMethod:method];
	}

	con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(!con) {
		[self postNotificationWithName:BSDownloadTaskInternalErrorNotification];
		return;
	}
	
	while(!m_isFinished) {
		id pool = [[NSAutoreleasePool alloc] init];
		@try {
			[loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
		@catch(id ex) {
			// do nothing.
			@throw;
		}
		@finally {
			[pool release];
		}
	}
}

#pragma mark CMRTask
- (IBAction)cancel:(id)sender
{
	[con cancel];
	[self postNotificationWithName:BSDownloadTaskCanceledNotification];
	
	[super cancel:sender];
}

- (id)identifier
{
	return [NSString stringWithFormat:@"%@-%p", self, self];
}

- (NSString *)title
{
	return NSLocalizedStringFromTable(@"Download.", @"Downloader", @"");
}

- (NSString *) messageInProgress
{
	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Download url(%@) (%.0fk of %.0fk)", @"Downloader", @""),
									  [self url], (float)[self currentLength]/1024, (float)[self contLength]/1024];
}

- (double) amount
{
	return m_taskAmount;
}

- (void)setAmount:(double)doubleValue
{
	m_taskAmount = doubleValue;
}
@end


@implementation BSDownloadTask(NSURLConnectionDelegate)
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
{
	/*
	if( [(NSHTTPURLResponse *)response statusCode] == 302 ) {
		// dat落ち？
		[self postNotificaionWithResponse:response];
	}
	 */
	[self setResponse:response];
	[self postNotificaionWithResponse:response];
	[connection cancel];
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	BOOL disconnect = NO;
	
	[self setResponse:response];
	
	switch([(NSHTTPURLResponse *)response statusCode]) {
		case 200:
		case 206:
			break;
		case 304:
			NSLog(@"Contents is not modifiered.");
			disconnect = YES;
			break;
		case 404:
			NSLog(@"Contents has not found.");
			disconnect = YES;
			break;
		case 416:
			NSLog(@"Range is missmatch.");
			disconnect = YES;
			break;
		default:
			NSLog(@"Unknown error.");
			disconnect = YES;
			break;
	}
	if(disconnect) {
		[connection cancel];
		[self postNotificaionWithResponse:response];
		
		return;
	}
	
	[self postNotificaionWithResponseDontFinish:response];
	
	[self setContLength:[response expectedContentLength]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(!receivedData) {
		receivedData = [[NSMutableData alloc] init];
	}

	if(!receivedData) {
		// abort
		[connection cancel];
		[self postNotificationWithName:BSDownloadTaskInternalErrorNotification];
		
		return;
	}
	
	[receivedData appendData:data];
	[self setCurrentLength:[receivedData length]];

	if ([self contLength] != -1) {
		double bar = [self currentLength]/[self contLength]*100.0;
		[self setAmount:bar];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//	NSLog(@"-->%@",[[[NSString alloc] initWithData:receivedData encoding:NSShiftJISStringEncoding] autorelease]);	
	[self postNotificationWithName:BSDownloadTaskFinishDownloadNotification];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// abort
	id userInfo = [[error retain] autorelease];
	[[NSNotificationCenter defaultCenter] postNotificationName:BSDownloadTaskFailDownloadNotification object:self userInfo:userInfo];
	m_isFinished = YES;
}
@end


@implementation BSDownloadTask(TaskNotification)
- (void)postNotificationWithName:(NSString *)name
{
	NSNotificationCenter	*nc;
	
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:name object:self];
	
	m_isFinished = YES;
}

- (void)postNotificaionWithResponse:(NSURLResponse *)response
{
	NSNotificationCenter	*nc;
	NSDictionary			*info;
	
	nc = [NSNotificationCenter defaultCenter];
	info = [NSDictionary dictionaryWithObjectsAndKeys:response, BSDownloadTaskServerResponseKey,
					[NSNumber numberWithInt:[(NSHTTPURLResponse *)response statusCode]], BSDownloadTaskStatusCodeKey,
					nil];
	[nc postNotificationName:BSDownloadTaskAbortDownloadNotification object:self userInfo:info];

	m_isFinished = YES;
}

- (void)postNotificaionWithResponseDontFinish:(NSURLResponse *)response
{
	NSNotificationCenter	*nc;
	NSDictionary			*info;
	
	nc = [NSNotificationCenter defaultCenter];
	info = [NSDictionary dictionaryWithObjectsAndKeys:response, BSDownloadTaskServerResponseKey,
					[NSNumber numberWithInt:[(NSHTTPURLResponse *)response statusCode]], BSDownloadTaskStatusCodeKey,
					nil];

	[nc postNotificationName:BSDownloadTaskReceiveResponceNotification object:self userInfo:info];
}
@end
