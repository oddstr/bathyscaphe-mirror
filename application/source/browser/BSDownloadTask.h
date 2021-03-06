//
//  BSDownloadTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRTask.h"
#import "CMXWorkerContext.h"

#import "CMRThreadLayoutTask.h"

@interface BSDownloadTask : CMRThreadLayoutConcreateTask
{
	NSURL *m_targetURL;
//	BOOL m_isFinished;
	
	double	m_contLength;
	double	m_currentLength;
//	double	m_taskAmount;

	NSMutableData *receivedData;
	NSURLConnection *con;
	id _response;

	NSString *method;
}

+ (id)taskWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;
+ (id)taskWithURL:(NSURL *)url method:(NSString *)method;
- (id)initWithURL:(NSURL *)url method:(NSString *)method;

- (void)setURL:(NSURL *)url;
- (NSData *)receivedData;
- (id)response;
@end

@interface BSDownloadTask(TaskNotification)
- (void)postNotificationWithName:(NSString *)name;
- (void)postNotificaionWithResponse:(NSURLResponse *)response;
- (void)postNotificaionWithResponseDontFinish:(NSURLResponse *)response;
@end


extern NSString *BSDownloadTaskFinishDownloadNotification;
extern NSString *BSDownloadTaskCanceledNotification;
extern NSString *BSDownloadTaskInternalErrorNotification;
extern NSString *BSDownloadTaskReceiveResponceNotification;
extern NSString *BSDownloadTaskAbortDownloadNotification;
extern NSString	*BSDownloadTaskFailDownloadNotification;

extern NSString *BSDownloadTaskServerResponseKey;	// NSURLResponse
extern NSString	*BSDownloadTaskStatusCodeKey;	// NSNumber (int)
