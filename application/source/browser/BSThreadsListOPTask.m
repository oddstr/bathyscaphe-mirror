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
		m_targetList = list; //[list retain];
		m_forceDL = forceDownload;
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
	[m_downloadData release];
	[m_downloadError release];
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
	u = [NSURL URLWithString:CMRAppSubjectTextFileName relativeToURL:u];
	if (!u) return;

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
		   selector:@selector(dlDidFinishDownloadNotification:)
			   name:BSDownloadTaskFinishDownloadNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlAbortDownloadNotification:)
			   name:BSDownloadTaskInternalErrorNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlAbortDownloadNotification:)
			   name:BSDownloadTaskAbortDownloadNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlDidFailDownloadNotification:)
			   name:BSDownloadTaskFailDownloadNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlCancelDownloadNotification:)
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

		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:NSLocalizedStringFromTable(APP_TLIST_NOT_FOUND_TITLE, @"ThreadsList", nil)];
		[alert setInformativeText:message];
		
		[alert addButtonWithTitle:@"OK"];

		NSBeep();
		[alert runModal];
	}
}

- (void)tryToDetectMovedBoard
{
	[self performSelectorOnMainThread:@selector(tryToDetectMovedBoardOnMainThread:)
						   withObject:nil
						waitUntilDone:NO];
}

- (void)showDownloadErrorAlert
{
	[self performSelectorOnMainThread:@selector(showDownloadErrorAlertOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)showDownloadErrorAlertOnMainThread
{
	UTILAssertNotNil(m_downloadError);

	NSString *message = [NSString stringWithFormat:
		NSLocalizedStringFromTable(APP_TLIST_NOT_FOUND_MSG_FMT, @"ThreadsList", nil),
		[targetURL absoluteString]];

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:[m_downloadError localizedDescription]];
	[alert setInformativeText:message];
	
	[alert addButtonWithTitle:@"OK"];

	NSBeep();
	[alert runModal];
}

#pragma mark-
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[self checkIsInterrupted];
	if([CMRPref isOnlineMode] || m_forceDL) {
		dlTask = [self makeDownloadTask];
		[dlTask run];
		
		id temp = dlTask;
		dlTask = nil;
		[temp release];
		
		[self checkIsInterrupted];
		if(m_downloadData && [m_downloadData length] != 0) {
			dbupTask = [[BSDBThreadsListDBUpdateTask2 alloc] initWithBBSName:bbsName
																		data:m_downloadData];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(dbloadDidFinishUpdateDBNotification:)
														 name:BSDBThreadsListDBUpdateTask2DidFinishNotification
													   object:dbupTask];
			[dbupTask run];
			
			[self checkIsInterrupted];
		} else if (m_downloadError) {
			[self showDownloadErrorAlert];
		} else {
			[self tryToDetectMovedBoard];
		}
	}
	
	[m_targetList updateCursor];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) finalizeWhenInterrupted
{
	[m_targetList updateCursor];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super finalizeWhenInterrupted]; // 2008-03-11
}
	
- (void)dlDidFinishDownloadNotification:(id)notification
{
	m_downloadData = [[[notification object] receivedData] retain];
}

- (void)dlDidFailDownloadNotification:(NSNotification *)notification
{
	UTILAssertNotNil([notification userInfo]);
	UTILAssertKindOfClass([notification userInfo], NSError);

	m_downloadError = [[notification userInfo] retain];
}

-(void)dlCancelDownloadNotification:(id)notification
{
	[self setIsInterrupted:YES];
}
-(void)dlAbortDownloadNotification:(id)notification
{
	m_downloadData = nil;
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
	m_targetList = nil;
	
	[super cancel:sender];
}

@end
