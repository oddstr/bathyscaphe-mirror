//
//  BSThreadListSmartItemDBUpdateTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/31.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSThreadListSmartItemDBUpdateTask.h"

#import "DatabaseManager.h"
#import "CMRDocumentFileManager.h"


@implementation BSThreadListSmartItemDBUpdateTask

+ (id)taskWithUpdateThreads:(NSArray *)inThreads
{
	return [[[[self class] alloc] initWithUpdateThreads:inThreads] autorelease];
}
- (id)initWithUpdateThreads:(NSArray *)inThreads
{
	if(self = [super init]) {
		threads = [inThreads retain];
		
		[self setProgress:0];
		[self setAmountString:@"0"];
		[self setIdentifier:[NSValue valueWithPointer:self]];
	}
	
	return self;
}
- (void)dealloc
{
	[threads release];
	[target release];
	
	[super dealloc];
}

- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[self update];
	[target updateCursor];
}

- (id) identifier
{
	return [NSString stringWithFormat:@"%@-%@",
		NSStringFromClass([self class]),
		[NSValue valueWithPointer:self]];
}

- (NSString *) title
{
	return @"Update ThreadInfo Table.";
}
- (NSString *) messageInProgress
{
    NSString        *format_;
    NSString        *title_;
    
    title_ = [self title];
    format_ = nil; //[self localizedString : @"Checking Favorites Message"];
    
    return [NSString stringWithFormat : 
					format_ ? format_ : @"%@ (%@)",
					  title_ ? title_ : @"",
		[self amountString]];
}
- (unsigned)progress
{
	return mProgress;
}
- (void)setProgress:(unsigned) new
{
	mProgress = new;
}
- (double)amount
{
	return ([self progress] <= 0) ? -1 : [self progress];
}
- (NSString *)amountString
{
	id res;
	
	[mAmountStringLock lock];
	res = [mAmountString retain];
	[mAmountStringLock unlock];
	
	return [res autorelease];;
}
- (void)setAmountString:(NSString *)new
{
	id temp;
	
	[mAmountStringLock lock];
	temp = mAmountString;
	mAmountString = [new retain];
	[temp release];
	[mAmountStringLock unlock];
}

#pragma mark-

- (void)setTarget:(id)inTarget
{
	target = [inTarget retain];
}

static inline BOOL searchBoardIDAndThreadIDFromFilePath( int *outBoardID, NSString **outThreadID, NSString *inFilePath )
{
	CMRDocumentFileManager *dfm = [CMRDocumentFileManager defaultManager];
	
	if (outThreadID) {
		*outThreadID = [dfm datIdentifierWithLogPath : inFilePath];
	}
	
	if (outBoardID) {
		NSString *boardName;
		NSArray *boardIDs;
		id boardID;
		
		boardName = [dfm boardNameWithLogPath : inFilePath];
		if (!boardName) return NO;
		
		boardIDs = [[DatabaseManager defaultManager] boardIDsForName : boardName];
		if (!boardIDs || [boardIDs count] == 0) return NO;
		
		boardID = [boardIDs objectAtIndex : 0];
		
		*outBoardID = [boardID intValue];
	}
	
	return YES;
}

- (void) update
{
	unsigned i, count;
	id					thread;
	SQLiteDB *db = nil;
	NSString *query;
	
	[self postTaskWillStartNotification];
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if(!db) goto fail;
	
	if([db beginTransaction]) {
		SQLiteReservedQuery *reservedUpdate;
		
		query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE %@ = ? AND %@ = ? AND %@ != ?",
			ThreadInfoTableName,
			ThreadStatusColumn,
			BoardIDColumn, ThreadIDColumn, ThreadStatusColumn];
		reservedUpdate = [db reservedQuery:query];
		if(!reservedUpdate) {
			NSLog(@"Can NOT create reservedUpdate on update");
			goto fail;
		}
		
		count = [threads count];
		[self setProgress:0];
		[self setAmountString:[NSString stringWithFormat:@"%d/%d",0, count]];
		
		for(i = 0; i < count; i++ ) {
			id pool = [[NSAutoreleasePool alloc] init];
			NSNumber *status;
			int boardID;
			NSString *threadID;
			NSArray *bindValues;
			
			thread = [threads objectAtIndex:i];
			
			if( !(status = [thread objectForKey:CMRThreadStatusKey]) ) {
				[pool release];
				continue;
			}
			if([status unsignedIntValue] == ThreadLogCachedStatus) {
				[pool release];
				continue;
			}
			
			if(!searchBoardIDAndThreadIDFromFilePath( &boardID, &threadID, [thread objectForKey:CMRThreadLogFilepathKey]) ) {
				[pool release];
				continue;
			}
			
			bindValues = [NSArray arrayWithObjects:
				status, [NSNumber numberWithInt:boardID], threadID, status, nil];
			[reservedUpdate cursorForBindValues:bindValues];
			
			if ([db lastErrorID] != 0) {
				NSLog(@"Fail Insert or udate. Reson: %@", [db lastError] );
				[pool release];
				goto fail;
			}
			
			[self setProgress:(double)i / count * 100];
			[self setAmountString:[NSString stringWithFormat:@"%d/%d", i + 1, count]];
			
			[pool release];
		}
		[db commitTransaction];
	}
	
	[self postTaskDidFinishNotification];
	return;
	
fail:
	[db rollbackTransaction];
	NSLog(@"Abort in %@ - %@",NSStringFromSelector(_cmd), NSStringFromClass([self class]));
	[self postTaskDidFinishNotification];
}

@end

@implementation BSThreadListSmartItemDBUpdateTask(TaskNotification)
- (void) postTaskWillStartNotification
{
	NSNotificationCenter	*nc_;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : CMRTaskWillStartNotification
					   object : self];
}

- (void) postTaskDidFinishNotification
{
	NSNotificationCenter	*nc_;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : CMRTaskDidFinishNotification
					   object : self];
}
@end