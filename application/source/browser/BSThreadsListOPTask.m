//
//  BSThreadsListOPTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSThreadsListOPTask.h"

#import "CMRThreadsList_p.h"

#import "BSDownloadTask.h"
#import "BSDBThreadsListDBUpdateTask2.h"

#import "CMRTaskManager.h"
#import "CMXWorkerContext.h"
#import "AppDefaults.h"
#import "BoardManager.h"
#import "CMRHostHandler.h"


#import "ThreadsListDownloader.h"

NSString *const ThreadsListDownloaderShouldRetryUpdateNotification = @"ThreadsListDownloaderShouldRetryUpdateNotification";

@implementation BSThreadsListOPTask
+ (id)taskWithThreadList:(BSDBThreadList *)list forceDownload:(BOOL)forceDownload
{
	return [[[[self class] alloc] initWithThreadList:list forceDownload:forceDownload] autorelease];
}
- (id)initWithThreadList:(BSDBThreadList *)list forceDownload:(BOOL)forceDownload
{
	if(self = [super init]) {
		targetList = list; //[list retain];
		forceDL = forceDownload;
		[self setBoardName:[list boardName]];
		
		if(![self boardName]) goto fail;
	}
	
	return self;
fail:
	[self release];
	return nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[targetURL release];
	[dlTask release];
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
- (void)setBoardName:(NSString *)name
{
	id u = [[BoardManager defaultManager] URLForBoardName:name];
	u = [NSURL URLWithString : CMRAppSubjectTextFileName
			   relativeToURL : u];
	if(!u) return;
	
	id temp = bbsName;
	bbsName = [name retain];
	[temp release];
	
	[self setURL:u];
}
- (NSString *)boardName
{
	return bbsName;
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
		   selector:@selector(dlAbortDownlocadNotification:)
			   name:BSDownloadTaskInternalErrorNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlAbortDownlocadNotification:)
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

- (void)tryToDetectMovedBoardOnMainThread:(id)dummy
{
	BoardManager *bm = [BoardManager defaultManager];
	if([bm tryToDetectMovedBoard:[self boardName]]) {
		UTILNotifyName(ThreadsListDownloaderShouldRetryUpdateNotification);
	} else {
		NSString *message = [NSString stringWithFormat:
			NSLocalizedStringFromTable(APP_TLIST_NOT_FOUND_MSG_FMT, @"ThreadsList", nil),
			[targetURL absoluteString]];
		
		NSBeep();
		NSRunAlertPanel(
						NSLocalizedStringFromTable(APP_TLIST_NOT_FOUND_TITLE, @"ThreadsList", nil),
						message,
						nil,
						nil,
						nil);
	}
}
- (void)tryToDetectMovedBoard
{
	[self performSelectorOnMainThread:@selector(tryToDetectMovedBoardOnMainThread:)
						   withObject:nil
						waitUntilDone:NO];
}
#pragma mark-
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[self checkIsInterrupted];
	if([CMRPref isOnlineMode] || forceDL) {
		dlTask = [self makeDownloadTask];
		[dlTask run];
		
		id temp = dlTask;
		dlTask = nil;
		[temp release];
		
		[self checkIsInterrupted];
		if(downloadData && [downloadData length] != 0) {
			dbupTask = [[BSDBThreadsListDBUpdateTask2 alloc] initWithBBSName:bbsName
																		data:downloadData];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(dbloadDidFinishUpdateDBNotification:)
														 name:BSDBThreadsListDBUpdateTask2DidFinishNotification
													   object:dbupTask];
			[dbupTask run];
			
			[self checkIsInterrupted];
		} else {
			[self tryToDetectMovedBoard];
		}
	}
	
	[targetList updateCursor];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) finalizeWhenInterrupted
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
	
- (void)dlDidFinishDownlocadNotification:(id)notification
{
	downloadData = [[[notification object] receivedData] retain];
}
-(void)dlCancelDownlocadNotification:(id)notification
{
	[self setIsInterrupted:YES];
}
-(void)dlAbortDownlocadNotification:(id)notification
{
	downloadData = nil;
}
- (void)dbloadDidFinishUpdateDBNotification:(id)notification
{
	//
}

#pragma mark-
- (id)identifier
{
	return [NSString stringWithFormat:@"%@-%p", self, self];
}
- (NSString *)title
{
	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Update threads list. %@", @"ThreadsList", @""),
		bbsName];
}
- (NSString *) messageInProgress
{
	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Update threads list. %@", @"ThreadsList", @""),
		bbsName];
}

-(IBAction)cancel:(id)sender
{
	[dlTask cancel:self];
	targetList = nil;
	
	[super cancel:sender];
}

@end
