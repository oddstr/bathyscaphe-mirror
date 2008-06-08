//
//  BSBoardListItemHEADCheckTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/13.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSBoardListItemHEADCheckTask.h"

#import "DatabaseManager.h"
#import "BoardManager.h"
#import "CMRHostHandler.h"
#import "BSDownloadTask.h"
#import "AppDefaults.h"

static NSString *const BSFavHEADerLMKey	= @"Last-Modified";

static NSURL *urlForBoardNameAndThredID(NSString *boardName, NSString *threadID);
static BOOL shouldCheckItemHeader(id dict);

@interface BSBoardListItemHEADCheckTask(Private)
- (NSArray *)threadInfomations;
- (BSDownloadTask *)sendHEADMethod:(NSURL *)url;
- (void)resetNewStatus;
- (void)updateDB:(id)threads;
@end

@implementation BSBoardListItemHEADCheckTask
+ (id)taskWithThreadList:(BSDBThreadList *)list
{
	return [[[self alloc] initWithThreadList:list] autorelease];
}
- (id)initWithThreadList:(BSDBThreadList *)list
{
	if(self = [super init]) {
		targetList = list; //[list retain];
		item = [[list boardListItem] retain];
	}
	
	return self;
}

- (void)dealloc
{
//	[targetList release];
	[item release];
	[amountString release];
	[descString release];
	
	[super dealloc];
}

#pragma mark-
- (id)identifier
{
	return [NSString stringWithFormat:@"%@-%p", self, self];
}
- (NSString *)title
{
	NSString *format = NSLocalizedStringFromTable(@"Checking SmartBoard(%@).", @"ThreadsList", @"");
	return [NSString stringWithFormat:format, [item name]];
}
- (void)setAmountString:(NSString *)str
{
	id temp = amountString;
	@synchronized(self) {
		[self willChangeValueForKey:@"message"];
		amountString = [str retain];
		[self didChangeValueForKey:@"message"];
	}
	[temp release];
}
- (NSString *)amountString
{
	id result;
	@synchronized(self) {
		result = [[amountString retain] autorelease];
	}
	return result;
}
- (void)setDescString:(NSString *)str
{
	id temp = descString;
	@synchronized(self) {
		[self willChangeValueForKey:@"message"];
		descString = [str retain];
		[self didChangeValueForKey:@"message"];
	}
	[temp release];
}
- (NSString *)descString
{
	id result;
	@synchronized(self) {
		result = [[descString retain] autorelease];
	}
	return result;
}
- (NSString *)message
//- (NSString *) messageInProgress
{
	NSString *descStr = [self descString];
	NSString *amountStr = [self amountString];
	
	if(descStr && amountStr) {
		return [NSString stringWithFormat:@"%@ (%@)", descStr, amountStr];
	} else if(descStr) {
		return descStr;
	}
	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"ProgressBoardListItemHEADCheck.", @"ThreadsList", @"")];
}
- (void)playFinishSoundIsUpdate:(BOOL)isUpDate
{
	NSSound *finishedSound_ = nil;
	NSString *soundName_ = [CMRPref HEADCheckNewArrivedSound];
	
	if (isUpDate && ![soundName_ isEqualToString : @""]) {
		finishedSound_ = [NSSound soundNamed :soundName_];
	} else {
		soundName_ = [CMRPref HEADCheckNoUpdateSound];
		if (![soundName_ isEqualToString : @""])
			finishedSound_ = [NSSound soundNamed : soundName_];
	}
	[finishedSound_ play];
}
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[self resetNewStatus];
	
	NSArray *threads = [self threadInfomations];
	NSEnumerator *threadsEnum;
	id thread;
	NSMutableArray *updatedThreads = [NSMutableArray array];
	
//	[self checkHOGE];
	
	int numberOfAllTarget = [threads count];
	int numberOfFinishCheck = 0;
	int numberOfSkip = 0;
	int numberOFChecked = 0; // HEAD を送信した回数
	NSString *amoutFormat = NSLocalizedStringFromTable(@"%d/%d (%d skiped)", @"ThreadsList", @"");

	[self setAmountString:[NSString stringWithFormat:amoutFormat,
						   numberOfFinishCheck, numberOfAllTarget, numberOfSkip]];
	[self setDescString:NSLocalizedStringFromTable(@"Checking thread", @"ThreadsList", @"")];
	
	threadsEnum = [threads objectEnumerator];
	while(thread = [threadsEnum nextObject]) {
		id pool = [[NSAutoreleasePool alloc] init];
		
		id dl;
		id response;
		id newMod;
				
		[self checkIsInterrupted];
		[self setAmountString:[NSString stringWithFormat:amoutFormat,
							   ++numberOfFinishCheck, numberOfAllTarget, numberOfSkip]];
		
		if(!shouldCheckItemHeader(thread)) {
			[pool release];
			numberOfSkip++;
			continue;
		}
		
		NSString *boardName = [thread valueForColumn:BoardNameColumn];
		NSString *threadID = [thread valueForColumn:ThreadIDColumn];
		NSString *modDate = [thread valueForColumn:ModifiedDateColumn];
		
		NSURL *url = urlForBoardNameAndThredID(boardName, threadID);
		dl = [self sendHEADMethod:url];
		response = [dl response];
		
		if([response statusCode] == 200) {
			newMod = [[response allHeaderFields] objectForKey:BSFavHEADerLMKey];
//			NSCalendarDate	*dateLastMod = [NSCalendarDate dateWithHTTPTimeRepresentation : newMod];
			NSDate *dateLastMod = [[BSHTTPDateFormatter sharedHTTPDateFormatter] dateFromString:newMod];
			NSDate *prevMod = [NSDate dateWithTimeIntervalSince1970:[modDate intValue]];
			if([dateLastMod isAfterDate:prevMod]) {
				[updatedThreads addObject:thread];
			}
		}
		[pool release];
	}
	
	[self updateDB:updatedThreads];
	
	numberOFChecked = numberOfAllTarget - numberOfSkip;
	[self playFinishSoundIsUpdate:([updatedThreads count] > 0)];
	
	if(numberOFChecked > 0) {
		[CMRPref setLastHEADCheckedDate : [NSDate date]];
	}
	
	[targetList updateCursor];
	
}
// - (void) finalizeWhenInterrupted;

- (NSArray *)threadInfomations
{
	NSArray *result = nil;
	SQLiteDB *db;
	NSString *table = [item query];
	if(!table) return nil;
	
	[self setDescString:NSLocalizedStringFromTable(@"Collecting infomation of thread", @"ThreadsList", @"")];
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if(db && [db beginTransaction]) {
		NSString *query = [NSString stringWithFormat:
						   @"SELECT %@, %@, %@, %@, %@, %@, %@ FROM (%@)",
						   BoardIDColumn, BoardNameColumn, ThreadIDColumn,
						   NumberOfAllColumn, ThreadStatusColumn, ModifiedDateColumn,
						   IsDatOchiColumn, 
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
const int minimumThreadCount = 50;
- (NSDictionary *)checkHOGE
{
	NSString *countColumn = @"count";
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
			BoardIDColumn, countColumn,
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
			
			id v = [p valueForColumn:countColumn atRow:0];
			if(!v) goto abort;
			
			if(minimumThreadCount < [v intValue]) {
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
	id nsnull = [NSNull null];
	
	obj = [dict valueForColumn:IsDatOchiColumn];
	if(!obj || [obj boolValue]) return NO;
	
	obj = [dict valueForColumn:NumberOfAllColumn];
	if(!obj || [obj intValue] > 1000) return NO;
	
	obj = [dict valueForColumn:ThreadStatusColumn];
	if(!obj) return NO;
	
	s = [obj intValue];
	if( !(s | ThreadLogCachedStatus)) return NO;
	
	obj = [dict valueForColumn:BoardNameColumn];
	if(!obj || obj == nsnull) return NO;
	
	obj = [dict valueForColumn:ThreadIDColumn];
	if(!obj || obj == nsnull) return NO;
	
	obj = [dict valueForColumn:ModifiedDateColumn];
	if(!obj || obj == nsnull) return NO;
	
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
	
	return [dlTask autorelease];;
}
- (void)resetNewStatus
{
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	[self setDescString:NSLocalizedStringFromTable(@"Reseting new threads status.", @"ThreadsList", @"")];
	
	if(db && [db beginTransaction]) {
		id cursor = nil;
		NSString *query = [NSString stringWithFormat:
			@"SELECT %@, %@ FROM (%@) WHERE %@ = %d",
			BoardIDColumn, ThreadIDColumn,
			[item query], ThreadStatusColumn, ThreadNewCreatedStatus];
		cursor = [db performQuery:query];
		if([cursor rowCount] == 0) {
			[db commitTransaction];
			return;
		}
		
		query = [NSString stringWithFormat:
			@"UPDATE %@ "
			@"SET %@ = %d "
			@"WHERE %@ = ? AND %@ = ?",
			ThreadInfoTableName,
			ThreadStatusColumn, ThreadNoCacheStatus,
			BoardIDColumn, ThreadIDColumn];
		id statment = [db reservedQuery:query];
		
		unsigned i, count;
		for(i = 0, count = [cursor rowCount]; i < count; i++) {
			[statment cursorForBindValues:
				[NSArray arrayWithObjects:
					[cursor valueForColumn:BoardIDColumn atRow:i],
					[cursor valueForColumn:ThreadIDColumn atRow:i],
					nil]];
		}
		
		[db commitTransaction];
	}
}

- (void)updateDB:(id)threads
{
	if(!threads || [threads count] == 0) return;
	
	int numberOfAllTarget = [threads count];
	int numberOfFinishCheck = 0;
	[self setAmountString:[NSString stringWithFormat:@"%d/%d", numberOfFinishCheck, numberOfAllTarget]];
	[self setDescString:NSLocalizedStringFromTable(@"Updating database", @"ThreadsList", @"")];
	
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
- (void)dlDidFinishDownloadNotification:(id)notification
{
	id obj = [[notification userInfo] objectForKey:BSDownloadTaskServerResponseKey];
	
	if([obj isKindOfClass:[NSHTTPURLResponse class]]) {
	}
	
}
- (void)dlDidAbortDownlocadNotification:(id)notification
{
	//
}
- (void)dlCancelDownloadNotification:(id)notification
{
	//
}

@end
