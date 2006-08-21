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
	}
	
	return self;
}

- (void)dealloc
{
	[item release];
	
	[super dealloc];
}

#pragma mark-
- (id)identifier
{
	return [NSString stringWithFormat:@"%@-%p", self, self];
}
- (NSString *)title
{
	NSString *format = NSLocalizedString(@"Checking SmartBoard(%@).", @"ProgressBoardListItemHEADCheck.");
	return [NSString stringWithFormat:format, [item name]];
}
- (void)setAmountString:(NSString *)str
{
	id temp = amountString;
	amountString = [str retain];
	[temp release];
}
- (NSString *)amountString
{
	return amountString;
}
- (void)setDescString:(NSString *)str
{
	id temp = descString;
	descString = [str retain];
	[temp release];
}
- (NSString *)descString
{
	return descString;
}
- (NSString *) messageInProgress
{
	if([self descString] && [self amountString]) {
		return [NSString stringWithFormat:@"%@ (%@)", [self descString], [self amountString]];
	} else if([self descString]) {
		return [self descString];
	}
	return [NSString stringWithFormat:NSLocalizedString(@"ProgressBoardListItemHEADCheck.", "ProgressBoardListItemHEADCheck.")];
}
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[self setDescString:NSLocalizedString(@"Collectiong infomation of thread", @"")];
	[self updateNewCreate];
	[self updateHEADChecked];
	
	NSArray *threads = [self threadInfomations];
	NSEnumerator *threadsEnum;
	id thread;
	NSMutableArray *updatedThreads = [NSMutableArray array];
	id nsnull = [NSNull null];
	
//	[self checkHOGE];
	
	int numberOfAllTarget = [threads count];
	int numberOfFinishCheck = 0;
	int numberOfSkip = 0;
	[self setAmountString:[NSString stringWithFormat:@"%d/%d (%d skiped)", numberOfFinishCheck, numberOfAllTarget, numberOfSkip]];
	[self setDescString:NSLocalizedString(@"Checking thread", @"")];
	
	threadsEnum = [threads objectEnumerator];
	while(thread = [threadsEnum nextObject]) {
		id pool = [[NSAutoreleasePool alloc] init];
		
		id dl;
		id response;
		id newMod;
		
		[self checkIsInterrupted];
		[self setAmountString:[NSString stringWithFormat:@"%d/%d (%d skiped)", ++numberOfFinishCheck, numberOfAllTarget, numberOfSkip]];
		
		if(!shouldCheckItemHeader(thread)) {
			[pool release];
			numberOfSkip++;
			continue;
		}
		
		NSString *boardName = [thread valueForColumn:BoardNameColumn];
		NSString *threadID = [thread valueForColumn:ThreadIDColumn];
		NSString *modDate = [thread valueForColumn:ModifiedDateColumn];
		
		if(!boardName || !threadID  || !modDate) {
			[pool release];
			numberOfSkip++;
			continue;
		}
		if(boardName == nsnull || threadID == nsnull || modDate == nsnull) {
			[pool release];
			numberOfSkip++;
			continue;
		}
		
		NSURL *url = urlForBoardNameAndThredID(boardName, threadID);
		dl = [self sendHEADMethod:url];
		response = [dl response];
		
		if([response statusCode] == 200) {
			newMod = [[response allHeaderFields] objectForKey:BSFavHEADerLMKey];
			NSCalendarDate	*dateLastMod = [NSCalendarDate dateWithHTTPTimeRepresentation : newMod];
			NSDate *prevMod = [NSDate dateWithTimeIntervalSince1970:[modDate intValue]];
			if([prevMod isAfterDate:dateLastMod]) {
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


/*  同一の板に存在するスレッドが 50 以上あれば、 subject.txt での更新作業に切り替えるべきかな？？？ */
/* ってことでとりあえず作ってみた。 */
- (NSDictionary *)checkHOGE
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	SQLiteDB *db;
	NSString *table = [item query];
	if(!table) return nil;
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if(db && [db beginTransaction]) {
		NSString *query = [NSString stringWithFormat:
			@"SELECT DISTINCT %@ FROM (%@)",
			BoardIDColumn,
			table];
		
		id cursor = [db cursorForSQL:query];
		if(!cursor) goto abort;
		
		query = [NSString stringWithFormat:
			@"SELECT count(%@) AS %@ FROM (%@) WHERE %@ = ?",
			BoardIDColumn, @"c",
			table,
			BoardIDColumn];
		id r = [SQLiteReservedQuery sqliteReservedQueryWithQuery:query usingSQLiteDB:db];
		if(!r) goto abort;
		
		int c, i;
		id b;
		for(i=0,c=[cursor rowCount];i<c;i++) {
			id pool = [[NSAutoreleasePool alloc] init];
			
			id p;
			b = [cursor valueForColumn:BoardIDColumn atRow:i];
			if(!b) {
				[pool release];
				goto abort;
			}
			
			p = [r cursorForBindValues:[NSArray arrayWithObject:b]];
			if(!p) {
				[pool release];
				goto abort;
			}
			
			id v = [p valueForColumn:@"c" atRow:0];
			if(!v) goto abort;
			
			if(50 < [v intValue]) {
				[result setObject:v forKey:b];
			}
			
			[pool release];
		}
		
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
	BSDownloadTask *dlTask = [[BSDownloadTask alloc] initWithURL:url method:@"HEAD"];
	[dlTask doExecuteWithLayout:nil];
	
	return dlTask;
}
- (void)updateNewCreate
{
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if(db && [db beginTransaction]) {
		NSString *query = [NSString stringWithFormat:
			@"UPDATE %@ "
			@"SET %@ = %d "
			@"WHERE %@ = %d "
			@"AND "
			@"%@.ROWID IN (SELECT %@.ROWID FROM (%@))",
			ThreadInfoTableName,
			ThreadStatusColumn, ThreadNoCacheStatus,
			ThreadStatusColumn, ThreadNewCreatedStatus,
			ThreadInfoTableName, ThreadInfoTableName, [item query]];
		[db performQuery:query];
		
		[db commitTransaction];
	}
}
- (void)updateHEADChecked
{
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if(db && [db beginTransaction]) {
		NSString *query = [NSString stringWithFormat:
			@"UPDATE %@ "
			@"SET %@ = %d "
			@"WHERE %@ = %d "
			@"AND "
			@"%@.ROWID IN (SELECT %@.ROWID FROM (%@))",
			ThreadInfoTableName,
			ThreadStatusColumn, ThreadLogCachedStatus,
			ThreadStatusColumn, ThreadHeadModifiedStatus,
			ThreadInfoTableName, ThreadInfoTableName, [item query]];
		[db performQuery:query];
		
		[db commitTransaction];
	}
}
- (void)updateDB:(id)threads
{
	if(!threads || [threads count] == 0) return;
	
	int numberOfAllTarget = [threads count];
	int numberOfFinishCheck = 0;
	[self setAmountString:[NSString stringWithFormat:@"%d/%d", numberOfFinishCheck, numberOfAllTarget]];
	[self setDescString:NSLocalizedString(@"Updating database", @"")];
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if(db && [db beginTransaction]) {
		id threadsEnum = [threads objectEnumerator];
		id thread;
		
		while(thread = [threadsEnum nextObject]) {
			[self checkIsInterrupted];
			[self setAmountString:[NSString stringWithFormat:@"%d/%d", ++numberOfFinishCheck, numberOfAllTarget]];
			
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
	}
	
}
- (void)dlDidAbortDownlocadNotification:(id)notification
{
	//
}
- (void)dlCancelDownlocadNotification:(id)notification
{
	//
}

@end
