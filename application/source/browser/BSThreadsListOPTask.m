//
//  BSThreadsListOPTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSThreadsListOPTask.h"

#import "BSDownloadTask.h"
#import "BSDBThreadsListUpdateTask.h"
#import "BSDBThreadsListDBUpdateTask2.h"

#import "CMRTaskManager.h"
#import "CMXWorkerContext.h"
#import "AppDefaults.h"
#import "BoardManager.h"
#import "CMRHostHandler.h"

static CMXWorkerContext *sDLWorker;
static CMXWorkerContext *sUpWorker;

@implementation BSThreadsListOPTask

+ (void)initialize
{
	static BOOL isFirst = YES;
	if(isFirst) {
		isFirst = NO;
		if(!sDLWorker) {
			sDLWorker = [[CMXWorkerContext alloc] initWithUsingDrawingThread:YES];
			[sDLWorker run];
		}
		if(!sUpWorker) {
			sUpWorker = [[CMXWorkerContext alloc] initWithUsingDrawingThread:YES];
			[sUpWorker run];
		}
	}
}

+ (id)taskWithBBSName:(NSString *)name forceDownload:(BOOL)forceDownload
{
	return [[[[self class] alloc] initWithBBSName:name forceDownload:forceDownload] autorelease];
}
- (id)initWithBBSName:(NSString *)name forceDownload:(BOOL)forceDownload
{
	if(self = [super init]) {
		if(!name || ![name isKindOfClass:[NSString class]]) goto fail;
		
		id u = [[BoardManager defaultManager] URLForBoardName:name];
		u = [NSURL URLWithString : CMRAppSubjectTextFileName
				   relativeToURL : u];
		if(!u) goto fail;
		
		bbsName = [name retain];
		statusLock = [[NSLock alloc] init];
		[self setURL:u];
		status = BSThreadsListOPTaskStart;
		forceDL = forceDownload;
	}
	
	return self;
	
fail:{
	[self release];
	return nil;
}
}

- (void)dealloc
{
	[statusLock release];
	[targetURL release];
	[dlTask release];
	[dbloadTask release];
	[dbupTask release];
	[downloadData release];
	[bbsName release];
	
	[super dealloc];
}

#pragma mark-
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
- (void)addStatus:(int)stat
{
	[statusLock lock];
	status |= stat;
	[statusLock unlock];
}
- (void)setStatus:(int)stat
{
	[statusLock lock];
	status = stat;
	[statusLock unlock];
}
- (int)status
{
	return status;
}

#pragma mark-
- (id)makeDownloadTask
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	dlTask = [[BSDownloadTask alloc] initWithURL:[self url]];
	[nc addObserver:self
		   selector:@selector(dlDidFinishDownlocadNotification:)
			   name:BSDownloadTaskFinishDownloadNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlDidFinishDownlocadNotification:)
			   name:BSDownloadTaskInternalErrorNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlDidFinishDownlocadNotification:)
			   name:BSDownloadTaskAbortDownloadNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlDidFinishDownlocadNotification:)
			   name:BSDownloadTaskFailDownloadNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlCancelDownlocadNotification:)
			   name:BSDownloadTaskCanceledNotification
			 object:dlTask];
	
	return dlTask;
}
- (id)makeUpdateTask
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	dbloadTask = [[BSDBThreadsListUpdateTask alloc] initWithBBSName:bbsName];
	[nc addObserver:self
		   selector:@selector(dbloadDidFinishUpdateNotification:)
			   name:BSDBThreadsListUpdateTaskDidFinishNotification
			 object:dbloadTask];
	
	return dbloadTask;
}

#pragma mark-
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[self setStatus:BSThreadsListOPTaskStart];
	
//	CMRTaskManager *tm = [CMRTaskManager defaultManager];
	
	if([CMRPref isOnlineMode] || forceDL) {
		dlTask = [self makeDownloadTask];
		
//		[tm addTask:dlTask];
		[sDLWorker push:dlTask];
	} else {
		[self addStatus:BSThreadsListOPTaskFinishDL];
	}
	dbloadTask = [self makeUpdateTask];
	//	[tm addTask:dlTask];
	[sUpWorker push:dbloadTask];
	
	// 双方の処理が終わるまで待つ。
	while(BSThreadsListOPTaskFinishAll != [self status]) {
		[self checkIsInterrupted];
	}
	
	if([CMRPref isOnlineMode] || forceDL) {
		//
		if(downloadData && [downloadData length] != 0) {
			[self setStatus:BSThreadsListOPTaskStart];
			dbupTask = [[BSDBThreadsListDBUpdateTask2 alloc] initWithBBSName:bbsName
																		data:downloadData];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(dbloadDidFinishUpdateDBNotification:)
														 name:BSDBThreadsListDBUpdateTask2DidFinishNotification
													   object:dbupTask];
			
			[sUpWorker push:dbupTask];
			
			while( !(BSThreadsListOPTaskFinishUpdateDB & [self status]) ) {
				[self checkIsInterrupted];
			}
			
			
			// 再表示
			[self setStatus:BSThreadsListOPTaskStart];
			//	[tm addTask:dlTask];
			[sUpWorker push:dbloadTask];
			
			while( !(BSThreadsListOPTaskFinishUp & [self status]) ) {
				[self checkIsInterrupted];
			}
		}
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) finalizeWhenInterrupted
{
	[dlTask cancel:self];
	[dbloadTask cancel:self];
	[dbupTask cancel:self];
}
	
	
- (void)dlDidFinishDownlocadNotification:(id)notification
{
	downloadData = [[[notification object] receivedData] retain];
	
	[self addStatus:BSThreadsListOPTaskFinishDL];
}
- (void)dbloadDidFinishUpdateNotification:(id)notification
{
	[self addStatus:BSThreadsListOPTaskFinishUp];
}
-(void)dlCancelDownlocadNotification:(id)notification
{
	[dlTask release];
	dlTask = nil;
	[self setIsInterrupted:YES];
}
- (void)dbloadDidFinishUpdateDBNotification:(id)notification
{
	[self addStatus:BSThreadsListOPTaskFinishUpdateDB];
}

#pragma mark-
- (id)identifier
{
	return [NSString stringWithFormat:@"%@-%p", self, self];
}
- (NSString *)title
{
	return [NSString stringWithFormat:NSLocalizedString(@"Update threads list. %@", @"Update threads list."),
		bbsName];
}
- (NSString *) messageInProgress
{
	return [NSString stringWithFormat:NSLocalizedString(@"Update threads list. %@", @"Update threads list for %@."),
		bbsName];
}
/*
- (double)amount
{
	return -1;
}
*/
-(IBAction)cancel:(id)sender
{
	[dlTask cancel:self];
	[dbloadTask cancel:self];
	[self setStatus:BSThreadsListOPTaskFinishAll];
	
	[super cancel:sender];
}

@end
