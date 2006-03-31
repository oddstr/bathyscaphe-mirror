//
//  BSThreadListDBUpdateTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/30.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSThreadListDBUpdateTask.h"

#import "DatabaseManager.h"
#import "BoardManager.h"

@implementation BSThreadListDBUpdateTask

+ (id)taskWithUpdateThreads:(NSArray *)inThreads
{
	return [[[[self class] alloc] initWithUpdateThreads:inThreads] autorelease];
}
- (id)initWithUpdateThreads:(NSArray *)inThreads
{
	if(self = [super init]) {
		threads = [inThreads retain];
		progress = YES;
		userCanceled = NO;
	}
	
	return self;
}
- (void)dealloc
{
	[threads release];
	
	[super dealloc];
}


- (id) identifier
{
	return [NSValue valueWithPointer:self];
}

- (NSString *) title
{
	return @"Update ThreadInfo Table.";
}
- (NSString *) message
{
	return @"Update ThreadInfo Table.";
}
- (BOOL) isInProgress
{
	return progress;
}

// from 0.0 to 100.0 (or -1: Indeterminate)
- (double) amount
{
	return ([self isInProgress]) ? 0 : -1;
}

- (IBAction) cancel : (id) sender
{
	userCanceled = YES;
}

#pragma mark-

static inline id nilIfObjectIsNSNull( id obj )
{
	return obj == [NSNull null] ? nil : obj;
}

//<チラシの裏>
//長いよ！このメソッド！
//でも、ここはスピード命で。あと、分けるとやってることが分かりにくくなる可能性が。
//いっぱいコメント書いたから許して。
//</チラシの裏>
- (void) update
{
	NSLog(@"CHECKKING ME! %s : %d", __FILE__, __LINE__);
	[self postTaskWillStartNotification];
	
#ifdef DEBUG
	NSDate *start = [NSDate dateWithTimeIntervalSinceNow : 0.0];
	unsigned sendSQLCount = 0;
#define incrementCount() sendSQLCount++
#else
#define incrementCount() 
#endif
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if (db && [db beginTransaction]) {
		NSEnumerator *threadsEnum;
		id thread;
		
		NSString *prevBoardName = nil;
		NSURL *boardURL;
		unsigned boardID = NSNotFound;
		
		SQLiteReservedQuery *reservedInsert;
		SQLiteReservedQuery *reservedUpdate;
		SQLiteReservedQuery *reservedInsertNumber;
		SQLiteReservedQuery *reservedSelectThreadTable;
		
		id query;
		
		if(userCanceled) goto final;
		// データ確認用
		query = [NSString stringWithFormat : @"SELECT %@, %@, %@ FROM %@ WHERE %@ = ? AND %@ = ?",
			ThreadStatusColumn, NumberOfAllColumn, NumberOfReadColumn,
			ThreadInfoTableName,
			BoardIDColumn, ThreadIDColumn];
		reservedSelectThreadTable = [db reservedQuery : query];
		if (!reservedSelectThreadTable) {
			NSLog(@"Can NOT create reservedSelectThreadTable");
			goto abort;
		}
		
		if(userCanceled) goto final;
		// スレッド登録用
		query = [NSString stringWithFormat : @"INSERT INTO %@ ( %@, %@, %@, %@, %@ ) VALUES ( ?, ?, ?, ?, ? )",
			ThreadInfoTableName,
			BoardIDColumn, ThreadIDColumn, ThreadNameColumn, NumberOfAllColumn, ThreadStatusColumn];
		reservedInsert = [db reservedQuery : query];
		if (!reservedInsert) {
			NSLog(@"Can NOT create reservedInsert");
			goto abort;
		}
		
		if(userCanceled) goto final;
		// スレッドデータ更新用
		query = [NSString stringWithFormat : @"UPDATE %@ SET %@ = ?, %@ = ? WHERE %@ = ? AND %@ = ?",
			ThreadInfoTableName,
			NumberOfAllColumn, ThreadStatusColumn,
			BoardIDColumn, ThreadIDColumn];
		reservedUpdate = [db reservedQuery : query];
		if (!reservedUpdate) {
			NSLog(@"Can NOT create reservedUpdate");
			goto abort;
		}
		
		if(userCanceled) goto final;
		// スレッド番号登録用
		query = [NSString stringWithFormat : @"INSERT INTO %@ ( %@, %@, %@ ) VALUES ( ?, ?, ? )",
			TempThreadNumberTableName,
			BoardIDColumn, ThreadIDColumn, TempThreadThreadNumberColumn];
		reservedInsertNumber = [db reservedQuery : query];
		if (!reservedInsertNumber) {
			NSLog(@"Can NOT create reservedInsertNumber");
			goto abort;
		}
		
		if(userCanceled) goto final;
		// スレッド番号用テーブルをクリア
		query = [NSString stringWithFormat : @"DELETE FROM %@",
			TempThreadNumberTableName];
		[db performQuery : query];
		incrementCount();
		
		if(userCanceled) goto final;
		threadsEnum = [threads objectEnumerator];
		while( thread = [threadsEnum nextObject] ) {
			if(userCanceled) {
				[db commitTransaction];
				[prevBoardName release];
				goto final;
			}
			id pool = [[NSAutoreleasePool alloc] init];
			
			NSString *boardName = [thread objectForKey : ThreadPlistBoardNameKey];
			NSString *title = [thread objectForKey : CMRThreadTitleKey];
			NSString *dat = [thread objectForKey : ThreadPlistIdentifierKey];
			NSNumber *count = [thread objectForKey : CMRThreadNumberOfMessagesKey];
			NSNumber *status = [thread objectForKey : CMRThreadStatusKey];
			NSNumber *index = [thread objectForKey : CMRThreadSubjectIndexKey];
			
			if( !boardName || !title || !dat || !count || !status || !index ) {
				NSLog(@"Thread infomation is broken. (%@)", thread);
				continue;
			}
			
			if (![prevBoardName isEqualTo : boardName]) {
				// URLForBoardName: がオーバーヘッドになっているため少しでも呼び出しを減らす。
				id tmp;
				
				boardURL = [[BoardManager defaultManager] URLForBoardName : boardName];
				boardID = [[DatabaseManager defaultManager] boardIDForURLString : [boardURL absoluteString]];
				
				tmp = prevBoardName;
				prevBoardName = [boardName retain];
				[tmp release];
			}
			
			if (boardID != NSNotFound) {
				NSArray *bindValues;
				id <SQLiteCursor> cursor;
				
				// 対象スレッドを以前読み込んだか調べる
				// [cursor rowCount] が0なら初めて読み込んだ。
				bindValues = [NSArray arrayWithObjects:
					[NSNumber numberWithUnsignedInt : boardID], dat, nil];
				cursor = [reservedSelectThreadTable cursorForBindValues : bindValues];
				incrementCount();
				UTILRequireCondition(cursor, abort);
				
				if(![cursor rowCount]) {
					// 初めての読み込み。データベースに登録。
					//			title = [SQLiteDB prepareStringForQuery : title];
					
					bindValues = [NSArray arrayWithObjects:
						[NSNumber numberWithUnsignedInt : boardID], dat, title, count, status, nil];
					[reservedInsert cursorForBindValues : bindValues];
					incrementCount();
					if ([db lastErrorID] != 0) {
						NSLog(@"Fail Insert. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
					}
					
				} else {
					// ２度目以降の読み込み。レス数かステータスが変更されていれば
					// データベースを更新。
					id <SQLiteRow> row = [cursor rowAtIndex:0];
					
					if( [count intValue] != [nilIfObjectIsNSNull([row valueForColumn:NumberOfAllColumn]) intValue] ||
						[status intValue] != [nilIfObjectIsNSNull([row valueForColumn : ThreadStatusColumn]) intValue]) {
						
						bindValues = [NSArray arrayWithObjects:
							count, status,
							[NSNumber numberWithUnsignedInt : boardID], dat, nil];
						[reservedUpdate cursorForBindValues : bindValues];
						incrementCount();
						if ([db lastErrorID] != 0) {
							NSLog(@"Fail udate. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
						}
					}
				}
				
				// スレッド番号のための一時テーブルに番号を登録。
				bindValues = [NSArray arrayWithObjects:
					[NSNumber numberWithUnsignedInt : boardID], dat, index, nil];
				[reservedInsertNumber cursorForBindValues : bindValues];
				incrementCount();
				if ([db lastErrorID] != 0) {
					NSLog(@"Fail Insert. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
				}
			}
			
			[pool release];
		}
		
		[db commitTransaction];
		
		[prevBoardName release];
	}
	
#ifdef DEBUG
	{
		NSDate *end = [NSDate dateWithTimeIntervalSinceNow : 0.0];
		
		NSLog(@"Database access time -> %lfs.", [end timeIntervalSinceDate : start]);
		NSLog(@"Sending SQL Query count -> %u.", sendSQLCount);
	}
#endif
	
final:
	
	[self postTaskDidFinishNotification];
	return;
	
abort:
		NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	[db rollbackTransaction];
	[self postTaskDidFinishNotification];
}

@end

@implementation BSThreadListDBUpdateTask(TaskNotification)
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
