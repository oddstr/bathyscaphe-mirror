//
//  BSDBThreadsListDBUpdateTask2.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSDBThreadsListDBUpdateTask2.h"

#import <OgreKit/OgreKit.h>

#import "DatabaseManager.h"


NSString *BSDBThreadsListDBUpdateTask2DidFinishNotification = @"BSDBThreadsListDBUpdateTask2DidFinishNotification";


static inline id nilIfObjectIsNSNull( id obj )
{
	return obj == [NSNull null] ? nil : obj;
}

@implementation BSDBThreadsListDBUpdateTask2

+ (id)taskWithBBSName:(NSString *)name data:(NSData *)data
{
	return [[[self alloc] initWithBBSName:name data:data] autorelease];
}
- (id)initWithBBSName:(NSString *)name data:(NSData *)data
{
	if(self = [super init]) {
		[self setBBSName:name];
		subjectData = [data retain];
		
		if(!boardID) {
			[self release];
			return nil;
		}
	}
	
	return self;
}
- (void)dealloc
{
	[subjectData release];
	[boardID release];
	[bbsName release];
	
	[reservedInsert release];
	[reservedUpdate release];
	[reservedInsertNumber release];
	[reservedSelectThreadTable release];
	
	[super dealloc];
}

- (void)setBBSName:(NSString *)name
{
	NSArray *boradIDs = [[DatabaseManager defaultManager] boardIDsForName:name];
	if(!boradIDs || [boradIDs count] == 0) return;
	
	boardID = [[boradIDs objectAtIndex:0] retain];
	bbsName = [name retain];
}

- (BOOL)makeQuerysForDatabase:(SQLiteDB *)db
{
	NSString *query;
	
	// データ確認用
	query = [NSString stringWithFormat : @"SELECT %@, %@, %@ FROM %@ WHERE %@ = ? AND %@ = ?",
		ThreadStatusColumn, NumberOfAllColumn, NumberOfReadColumn,
		ThreadInfoTableName,
		BoardIDColumn, ThreadIDColumn];
	reservedSelectThreadTable = [[db reservedQuery : query] retain];
	if (!reservedSelectThreadTable) {
		NSLog(@"Can NOT create reservedSelectThreadTable");
		goto abort;
	}
	
	// スレッド登録用
	query = [NSString stringWithFormat : @"INSERT INTO %@ ( %@, %@, %@, %@, %@ ) VALUES ( ?, ?, ?, ?, %d )",
		ThreadInfoTableName,
		BoardIDColumn, ThreadIDColumn, ThreadNameColumn, NumberOfAllColumn, ThreadStatusColumn,
		ThreadNewCreatedStatus];
	reservedInsert = [[db reservedQuery : query] retain];
	if (!reservedInsert) {
		NSLog(@"Can NOT create reservedInsert");
		goto abort;
	}
	
	// スレッドデータ更新用
	query = [NSString stringWithFormat : @"UPDATE %@ SET %@ = ?, %@ = ? WHERE %@ = ? AND %@ = ?",
		ThreadInfoTableName,
		NumberOfAllColumn, ThreadStatusColumn,
		BoardIDColumn, ThreadIDColumn];
	reservedUpdate = [[db reservedQuery : query] retain];
	if (!reservedUpdate) {
		NSLog(@"Can NOT create reservedUpdate");
		goto abort;
	}
	
	// スレッド番号登録用
	query = [NSString stringWithFormat : @"INSERT INTO %@ ( %@, %@, %@ ) VALUES ( ?, ?, ? )",
		TempThreadNumberTableName,
		BoardIDColumn, ThreadIDColumn, TempThreadThreadNumberColumn];
	reservedInsertNumber = [[db reservedQuery : query] retain];
	if (!reservedInsertNumber) {
		NSLog(@"Can NOT create reservedInsertNumber");
		goto abort;
	}
	
	return YES;
	
abort:
	return NO;
}
- (BOOL)updateDB:(SQLiteDB *)db ID:(NSString *)datString title:(NSString *)title count:(NSNumber *)count index:(NSNumber *)index
{
	NSArray *bindValues;
	id <SQLiteCursor> cursor;
	
	// 対象スレッドを以前読み込んだか調べる
	// [cursor rowCount] が0なら初めて読み込んだ。
	bindValues = [NSArray arrayWithObjects:
		boardID, datString, nil];
	cursor = [reservedSelectThreadTable cursorForBindValues : bindValues];
	UTILRequireCondition(cursor, abort);
	
	if(![cursor rowCount]) {
		// 初めての読み込み。データベースに登録。
		
		bindValues = [NSArray arrayWithObjects:
			boardID, datString, title, count, nil];
		[reservedInsert cursorForBindValues : bindValues];
		if ([db lastErrorID] != 0) {
			NSLog(@"Fail Insert. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
		}
		
	} else {
		// ２度目以降の読み込み。レス数かステータスが変更されていればデータベースを更新。
		id <SQLiteRow> row = [cursor rowAtIndex:0];
		
		unsigned currentNumber, newNumber;
		unsigned currentStatus, newStatus;
		unsigned readNumber;
		
		currentNumber = [nilIfObjectIsNSNull([row valueForColumn:NumberOfAllColumn]) intValue];
		newNumber = [count intValue];
		currentStatus = [nilIfObjectIsNSNull([row valueForColumn : ThreadStatusColumn]) intValue];
		readNumber = [nilIfObjectIsNSNull([row valueForColumn : NumberOfReadColumn]) intValue];
		if(readNumber == 0) {
			newStatus = ThreadNoCacheStatus;
		} else if(newNumber <= readNumber) {
			newStatus = ThreadLogCachedStatus;
		} else {
			newStatus = ThreadUpdatedStatus;;
		}
		
		if(currentNumber != newNumber || currentStatus != newStatus) {
			
			bindValues = [NSArray arrayWithObjects:
				count, [NSNumber numberWithUnsignedInt:newStatus],
				boardID, datString, nil];
			[reservedUpdate cursorForBindValues : bindValues];
			if ([db lastErrorID] != 0) {
				NSLog(@"Fail udate. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
			}
		}
	}
	
	// スレッド番号のための一時テーブルに番号を登録。
	bindValues = [NSArray arrayWithObjects:
		boardID, datString, index, nil];
	[reservedInsertNumber cursorForBindValues : bindValues];
	if ([db lastErrorID] != 0) {
		NSLog(@"Fail Insert. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
	}
	
	return YES;
	
abort:
	return NO;
}
- (void) run
{
	NSString *str;
	NSArray *lines;
	unsigned count, i;
	NSString *line;
	NSString *datString;
	NSString *title;
	NSString *numString;
	
	UTILDebugWrite(@"Start BSDBThreadsListDBUpdateTask2.");
	
	str = [NSString stringWithDataUsingTEC:subjectData
								  encoding:NS2CFEncoding(NSShiftJISStringEncoding)];
	// 行分割
	lines = [str componentsSeparatedByNewline];	
	
	NSString *p = [NSString stringWithFormat:@"(\\d+).*(?:<>|,)(.*)\\s*(?:\\(|<>|%C)(\\d+)",0xFF08];
	OGRegularExpression *regex = [OGRegularExpression regularExpressionWithString:p];
	OGRegularExpressionMatch *match;
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if (db && [db beginTransaction]) {
		if(NO == [self makeQuerysForDatabase:db]) {
			goto abort;
		}
		
		if(isInterrupted) goto abort;
		
		// スレッド番号用テーブルをクリア
		id query = [NSString stringWithFormat : @"DELETE FROM %@ WHERE %@ = %@",
			TempThreadNumberTableName,
			BoardIDColumn, boardID];
		[db performQuery : query];
		
		for( count = [lines count], i = 0; i < count; i++ ) {
			if(isInterrupted) goto abort;
			
			line = [lines objectAtIndex:i];
			match = [regex matchInString:line];
			
			datString = [match substringAtIndex:1];
			title = [match substringAtIndex:2];
			numString = [match substringAtIndex:3];
			
			if(!numString) continue;
			
			// DB に投入
			if(NO == [self updateDB:db
								 ID:datString
							  title:title
							  count:[NSNumber numberWithUnsignedInt:[numString intValue]]
							  index:[NSNumber numberWithUnsignedInt:i+1]]) {
				goto abort;
			}
		}
		
		[db commitTransaction];
	}
	
	[self postNotificationWithName:BSDBThreadsListDBUpdateTask2DidFinishNotification];
	
	return;
	
abort:
	NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	[db rollbackTransaction];
	
	if(!isInterrupted) {
		[self postNotificationWithName:BSDBThreadsListDBUpdateTask2DidFinishNotification];
	}
}
- (void)cancel:(id)sender
{
	[self postNotificationWithName:BSDBThreadsListDBUpdateTask2DidFinishNotification];
	isInterrupted = YES;
}
@end

@implementation BSDBThreadsListDBUpdateTask2(TaskNotification)
- (void) postNotificationWithName:(NSString *)name
{
	NSNotificationCenter	*nc_;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : name
					   object : self];
	
	UTILDebugWrite(@"End BSDBThreadsListDBUpdateTask2.");
//	[self postTaskDidFinishNotification];
}

- (void) postTaskWillStartNotification
{
	NSNotificationCenter	*nc_;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : CMRTaskWillStartNotification
					   object : self];
	
	UTILDebugWrite(@"Start BSDBThreadsListDBUpdateTask2.");
}

- (void) postTaskDidFinishNotification
{
	NSNotificationCenter	*nc_;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : CMRTaskDidFinishNotification
					   object : self];
	
	UTILDebugWrite(@"End BSDBThreadsListDBUpdateTask2.");
}
@end
