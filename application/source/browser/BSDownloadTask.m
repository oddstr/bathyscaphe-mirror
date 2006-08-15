//
//  BSDownloadTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSDownloadTask.h"

NSString *BSDownloadTaskFinishDownloadNotification = @"BSDownloadTaskFinishDownloadNotification";
NSString *BSDownloadTaskReceiveResponceNotification = @"BSDownloadTaskReceiveResponceNotification";
NSString *BSDownloadTaskCanceledNotification = @"BSDownloadTaskCanceledNotification";
NSString *BSDownloadTaskInternalErrorNotification = @"BSDownloadTaskInternalErrorNotification";
NSString *BSDownloadTaskAbortDownloadNotification = @"BSDownloadTaskAbortDownloadNotification";
NSString	*BSDownloadTaskServerResponseKey = @"BSDownloadTaskServerResponseKey";	// NSURLResponse
NSString	*BSDownloadTaskStatusCodeKey = @"BSDownloadTaskStatusCodeKey";	// NSNumber (int)
NSString	*BSDownloadTaskFailDownloadNotification = @"BSDownloadTaskFailDownloadNotification";


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
	
	[super dealloc];
}
- (void)setURL:(NSURL *)url
{
	id temp = targetURL;
	targetURL = [url retain];
	[temp release];
}
- (NSURL *)url
{
	return targetURL;
}
- (void)setCurrentLength:(unsigned)i
{
	currentLength = i;
}
- (unsigned)currentLength
{
	return currentLength;
}
- (NSData *)receivedData
{
	return receivedData;
}
- (void)setResponse:(id)response
{
	_response = [response retain];
}
- (id)response
{
	return _response;
}

- (void)createURLConnection:(id)request
{
	con = [[NSURLConnection alloc] initWithRequest:request
										  delegate:self];
	if(!con) {
		[self postNotificationWithName:BSDownloadTaskInternalErrorNotification];
		return;
	}
}
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	NSRunLoop *loop = [NSRunLoop currentRunLoop];
		
	[receivedData release];
	receivedData = nil;
	[self setCurrentLength:0];
	
	NSMutableURLRequest *request;
	
	request = [NSMutableURLRequest requestWithURL:[self url]];
	if(!request) {
		[self postNotificationWithName:BSDownloadTaskInternalErrorNotification];
		return;
	}
	[request setValue:@"Monazilla/1.0 (BS Another Story/0.3)"
   forHTTPHeaderField:@"User-Agent"];
	if(method) {
		[request setHTTPMethod : method];
	}

#if 0
	[self performSelectorOnMainThread:@selector(createURLConnection:)
						   withObject:request
						waitUntilDone:YES];
	
	if(con) {
		NSLog(@"con created.");
	} else {
		NSLog(@"con NOT created.");
	}
#else	
	con = [[NSURLConnection alloc] initWithRequest:request
										  delegate:self];
	if(!con) {
		[self postNotificationWithName:BSDownloadTaskInternalErrorNotification];
		return;
	}
	
//	-[CMRTaskManager taskWillProgressProcessing:] がこのrun loopでfireされて、落ちるので断念。
//	それが回避できたら復帰したいので、削除でなくコメントアウト。
	while(!isFinished) {
		[loop runMode:NSDefaultRunLoopMode
		   beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
#endif
}

- (IBAction)cancel:(id)sender
{
	[con cancel];
	[self postNotificationWithName:BSDownloadTaskCanceledNotification];
	
	[super cancel:sender];
}

#pragma mark-
- (id)identifier
{
	return [NSString stringWithFormat:@"%@-%p", self, self];
}
- (NSString *)title
{
	return NSLocalizedString(@"Download.", @"Download.");
}
- (NSString *) messageInProgress
{
	return [NSString stringWithFormat:NSLocalizedString(@"Download url(%@) (%.2fk)", "Download url(%@) (%.2fk)"),
		[self url], [self currentLength] / 1024.0];
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
	
	[self setCurrentLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(!receivedData) {
		if(currentLength) {
			receivedData = [[NSMutableData alloc] initWithCapacity:currentLength];
		} else {
			receivedData = [[NSMutableData alloc] init];
		}
	}
	if(!receivedData) {
		// abort
		[connection cancel];
		[self postNotificationWithName:BSDownloadTaskInternalErrorNotification];
		
		return;
	}
	
	[receivedData appendData:data];
	[self setCurrentLength:[self currentLength] + [data length]];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//	NSLog(@"-->%@",[[[NSString alloc] initWithData:receivedData encoding:NSShiftJISStringEncoding] autorelease]);
	
	[self postNotificationWithName:BSDownloadTaskFinishDownloadNotification];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// abort
	
	[self postNotificationWithName:BSDownloadTaskFailDownloadNotification];
}
@end

@implementation BSDownloadTask(TaskNotification)
- (void) postNotificationWithName:(NSString *)name
{
	NSNotificationCenter	*nc_;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : name
					   object : self];
	
	isFinished = YES;
}
- (void) postNotificaionWithResponse:(NSURLResponse *)response
{
	NSNotificationCenter	*nc_;
	NSDictionary *info;
	
	nc_ = [NSNotificationCenter defaultCenter];
	
	info = [NSDictionary dictionaryWithObjectsAndKeys:response, BSDownloadTaskServerResponseKey,
		[NSNumber numberWithInt:[(NSHTTPURLResponse *)response statusCode]], BSDownloadTaskStatusCodeKey,
		nil];
	[nc_ postNotificationName : BSDownloadTaskAbortDownloadNotification
					   object : self
					 userInfo : info];
	
	isFinished = YES;
}
- (void) postNotificaionWithResponseDontFinish:(NSURLResponse *)response
{
	NSNotificationCenter	*nc_;
	NSDictionary *info;
	
	nc_ = [NSNotificationCenter defaultCenter];
	
	info = [NSDictionary dictionaryWithObjectsAndKeys:response, BSDownloadTaskServerResponseKey,
		[NSNumber numberWithInt:[(NSHTTPURLResponse *)response statusCode]], BSDownloadTaskStatusCodeKey,
		nil];
	[nc_ postNotificationName : BSDownloadTaskReceiveResponceNotification
					   object : self
					 userInfo : info];
}

@end
