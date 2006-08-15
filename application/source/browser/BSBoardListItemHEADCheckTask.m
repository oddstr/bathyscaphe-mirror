//
//  BSBoardListItemHEADCheckTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/13.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSBoardListItemHEADCheckTask.h"

#import "DatabaseManager.h"
#import "BoardManager.h"
#import "CMRHostHandler.h"
#import "BSDownloadTask.h"
#import "BSDBThreadsListUpdateTask.h"

static NSString *const BSFavHEADerLMKey	= @"Last-Modified";

static NSURL *urlForBoardNameAndThredID(NSString *boardName, NSString *threadID);
static BOOL shouldCheckItemHeader(id dict);

@interface BSBoardListItemHEADCheckTask(Private)
- (NSArray *)threadInfomations;
- (BSDownloadTask *)sendHEADMethod:(NSURL *)url;
- (void)updateDB:(id)threads;
@end

@implementation BSBoardListItemHEADCheckTask

+ (id)taskWithBoardListItem:(BoardListItem *)inItem
{
	return [[[self alloc] initWithBoardListItem:inItem] autorelease];
}
- (id)initWithBoardListItem:(BoardListItem *)inItem
{
	if(self = [super init]) {
		item = [inItem retain];
		downloadTaskNum = 0;
		finishdDLTaskNum = 0;
		tasks = [[NSMutableArray array] retain];
	}
	
	return self;
}

- (void)dealloc
{
	[item release];
	[tasks release];
	
	[super dealloc];
}

#pragma mark-
- (id)identifier
{
	return [NSString stringWithFormat:@"%@-%p", self, self];
}
- (NSString *)title
{
	return NSLocalizedString(@"ProgressBoardListItemHEADCheck.", @"ProgressBoardListItemHEADCheck.");
}
- (NSString *) messageInProgress
{
	return [NSString stringWithFormat:NSLocalizedString(@"ProgressBoardListItemHEADCheck.", "ProgressBoardListItemHEADCheck.")];
}
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	NSArray *threads = [self threadInfomations];
	NSEnumerator *threadsEnum;
	id thread;
	NSMutableArray *updatedThreads = [NSMutableArray array];
	
	id nsnull = [NSNull null];
	
	threadsEnum = [threads objectEnumerator];
	while(thread = [threadsEnum nextObject]) {
		id pool = [[NSAutoreleasePool alloc] init];
		
		id dl;
		id response;
		id newMod;
		
		if(!shouldCheckItemHeader(thread)) {
			[pool release];
			NSLog(@"skip %@", thread);
			continue;
		}
		
		NSString *boardName = [thread valueForColumn:BoardNameColumn];
		NSString *threadID = [thread valueForColumn:ThreadIDColumn];
		NSString *modDate = [thread valueForColumn:ModifiedDateColumn];
		
		if(!boardName || !threadID  || !modDate) {
			[pool release];
			continue;
		}
		if(boardName == nsnull || threadID == nsnull || modDate == nsnull) {
			[pool release];
			continue;
		}
		
		NSURL *url = urlForBoardNameAndThredID(boardName, threadID);
		dl = [self sendHEADMethod:url];
		response = [dl response];
		
		if([response statusCode] == 200) {
			newMod = [[response allHeaderFields] objectForKey:BSFavHEADerLMKey];
			NSCalendarDate	*dateLastMod = [NSCalendarDate dateWithHTTPTimeRepresentation : newMod];
			NSDate *prevMod = [NSDate dateWithTimeIntervalSince1970:[modDate floatValue]];
			if([dateLastMod isAfterDate:prevMod]) {
				NSLog(@"Board(%@) Thread(%@) is updated!", boardName, threadID);
				[updatedThreads addObject:thread];
			}
		}
		[pool release];
	}
	
	[self updateDB:updatedThreads];
	
	BSDBThreadsListUpdateTask *dbloadTask = [[BSDBThreadsListUpdateTask alloc] initWithBBSName:nil];
	[dbloadTask run];
	
}
// - (void) finalizeWhenInterrupted;

- (NSArray *)threadInfomations
{
	NSArray *result;
	SQLiteDB *db;
	NSString *table = [item query];
	if(!table) return nil;
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if(db && [db beginTransaction]) {
		NSString *query = [NSString stringWithFormat:
			@"SELECT %@, %@, %@, %@, %@, %@ FROM (%@)",
			BoardIDColumn, BoardNameColumn, ThreadIDColumn, NumberOfAllColumn, ThreadStatusColumn, ModifiedDateColumn,
			table];
		
		id cursor = [db cursorForSQL:query];
		if(!cursor) goto abort;
		
		result = [cursor arrayForTableView];
		
		[db commitTransaction];
	}
	
	return result;
	
abort:
	[db rollbackTransaction];
	return nil;
}

static BOOL shouldCheckItemHeader(id dict)
{
	id obj;
	int s;
	
	obj = [dict valueForColumn:NumberOfAllColumn];
	if(!obj || [obj intValue] > 1000) return NO;
	
	obj = [dict valueForColumn:ThreadStatusColumn];
	if(!obj) return NO;
	
	s = [obj intValue];
	if( !(s | ThreadLogCachedStatus)) return NO;
	
	return YES;
}

static NSURL *urlForBoardNameAndThredID(NSString *boardName, NSString *threadID)
{
	NSURL *boardURL;
	CMRHostHandler *handler;
	
	boardURL = [[BoardManager defaultManager] URLForBoardName:boardName];
	handler = [CMRHostHandler hostHandlerForURL:boardURL];
	
	return [handler datURLWithBoard:boardURL datName:[threadID stringByAppendingPathExtension:@"dat"]];
}

- (BSDownloadTask *)sendHEADMethod:(NSURL *)url
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	BSDownloadTask *dlTask = [[BSDownloadTask alloc] initWithURL:url method:@"HEAD"];
//	[nc addObserver:self
//		   selector:@selector(dlDidFinishDownlocadNotification:)
//			   name:BSDownloadTaskFinishDownloadNotification
//			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlDidAbortDownlocadNotification:)
			   name:BSDownloadTaskInternalErrorNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlDidAbortDownlocadNotification:)
			   name:BSDownloadTaskAbortDownloadNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlDidAbortDownlocadNotification:)
			   name:BSDownloadTaskFailDownloadNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlCancelDownlocadNotification:)
			   name:BSDownloadTaskCanceledNotification
			 object:dlTask];
	[nc addObserver:self
		   selector:@selector(dlDidFinishDownlocadNotification:)
			   name:BSDownloadTaskReceiveResponceNotification
			 object:dlTask];
	
	[tasks addObject:dlTask];
//	[dlTask run];
	[dlTask doExecuteWithLayout:nil];
	downloadTaskNum++;
	
	return dlTask;
}

- (void)updateDB:(id)threads
{
	if(!threads || [threads count] == 0) return;
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if(db && [db beginTransaction]) {
		id threadsEnum = [threads objectEnumerator];
		id thread;
		
		while(thread = [threadsEnum nextObject]) {
			NSString *query = [NSString stringWithFormat:
				@"UPDATE %@ "
				@"SET %@ = %d "
				@"WHERE %@ = %@ AND %@ = %@",
				ThreadInfoTableName,
				ThreadStatusColumn, ThreadHeadModifiedStatus,
				BoardIDColumn, [thread valueForColumn:BoardIDColumn],
				ThreadIDColumn, [thread valueForColumn:ThreadIDColumn]];
			[db performQuery:query];
		}
		
		[db commitTransaction];
	}
}
@end

@implementation BSBoardListItemHEADCheckTask(Notification)
- (void)dlDidFinishDownlocadNotification:(id)notification
{
	id obj = [[notification userInfo] objectForKey:BSDownloadTaskServerResponseKey];
	
	if([obj isKindOfClass:[NSHTTPURLResponse class]]) {
		NSLog(@"%@", [obj allHeaderFields]);
	}
	
	finishdDLTaskNum++;
}
- (void)dlDidAbortDownlocadNotification:(id)notification
{
	//
	finishdDLTaskNum++;
}
- (void)dlCancelDownlocadNotification:(id)notification
{
	//
	finishdDLTaskNum++;
}

@end
