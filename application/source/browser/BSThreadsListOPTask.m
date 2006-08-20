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

@implementation BSThreadsListOPTask

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
		[self setURL:u];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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
	dbloadTask = [self makeUpdateTask];
	[dbloadTask run];
	
	[self checkIsInterrupted];
	if([CMRPref isOnlineMode] || forceDL) {
		dlTask = [self makeDownloadTask];
		[dlTask run];
		
		id temp = dlTask;
		dlTask = nil;
		[temp release];
	}
	
	[self checkIsInterrupted];
	if([CMRPref isOnlineMode] || forceDL) {
		if(downloadData && [downloadData length] != 0) {
			dbupTask = [[BSDBThreadsListDBUpdateTask2 alloc] initWithBBSName:bbsName
																		data:downloadData];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(dbloadDidFinishUpdateDBNotification:)
														 name:BSDBThreadsListDBUpdateTask2DidFinishNotification
													   object:dbupTask];
			[dbupTask run];
			
			[self checkIsInterrupted];
			
			// 再表示
			[dbloadTask run];
		}
	}
	
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
- (void)dbloadDidFinishUpdateNotification:(id)notification
{
	//
}
-(void)dlCancelDownlocadNotification:(id)notification
{
	[dlTask release];
	dlTask = nil;
	[self setIsInterrupted:YES];
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
	return [NSString stringWithFormat:NSLocalizedString(@"Update threads list. %@", @"Update threads list."),
		bbsName];
}
- (NSString *) messageInProgress
{
	return [NSString stringWithFormat:NSLocalizedString(@"Update threads list. %@", @"Update threads list for %@."),
		bbsName];
}

-(IBAction)cancel:(id)sender
{
	[dlTask cancel:self];
	[dbloadTask cancel:self];
	
	[super cancel:sender];
}

@end
