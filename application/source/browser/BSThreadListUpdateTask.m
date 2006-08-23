//
//  BSThreadListUpdateTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/29.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSThreadListUpdateTask.h"
#import "BSDBThreadList.h"
#import "BoardListItem.h"
#import "DatabaseManager.h"
#import "AppDefaults.h"

@implementation BSThreadListUpdateTask

+ (id)taskWithBSDBThreadList:(BSDBThreadList *)threadList
{
	return [[[[self class] alloc] initWithBSDBThreadList:threadList] autorelease];
}
- (id)initWithBSDBThreadList:(BSDBThreadList *)threadList
{
	if(self = [super init]) {
		target = threadList; //[threadList retain];
		progress = YES;
		userCanceled = NO;
	}
	
	return self;
}
- (void)dealloc
{
//	[target release];
	
	[super dealloc];
}

- (id) identifier
{
	return [NSValue valueWithPointer:self];
}

- (NSString *) title
{
	return [[target boardListItem] representName];
}
- (NSString *) message
{
	return [NSString stringWithFormat:@"Updating -- %@", [[target boardListItem] representName]];
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


//- (id)copyWithZone:(NSZone *)zone
//{
//	BSThreadListUpdateTask *result = [[self class] taskWithBSDBThreadList:target];
//	if(result) {
//		result->progress = progress;
//		result->userCanceled = userCanceled;
//	}
//	
//	return [result retain];
//}

#pragma mark-

static inline NSArray *componentsSeparatedByWhiteSpace(NSString *string)
{
	NSMutableArray *result = [NSMutableArray array];
	NSScanner *s = [NSScanner scannerWithString : string];
	NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
	NSString *str;
	
	while ([s scanUpToCharactersFromSet : cs intoString : &str]) {
		[result addObject : str];
	}
	
	if ([result count] == 0) {
		return nil;
	}
	
	return result;
}
static inline NSString *whereClauseFromSearchString(NSString *searchString)
{
	NSMutableString *clause;
	NSArray *searchs;
	NSEnumerator *searchsEnum;
	NSString *token;
	
	NSString *p = @"";
	
	searchs = componentsSeparatedByWhiteSpace(searchString);
	
	if (!searchs || [searchs count] == 0) {
		return nil;
	}
	
	clause = [NSMutableString stringWithFormat : @" WHERE "];
	
	searchsEnum = [searchs objectEnumerator];
	while (token = [searchsEnum nextObject]) {
		if ([token hasPrefix : @"!"]) {
			if ([token length] == 1) continue;
			
			[clause appendFormat : @"%@NOT %@ LIKE '%%%@%%' ",
				p, ThreadNameColumn, [token substringFromIndex : 1]];
		} else {
			[clause appendFormat : @"%@%@ LIKE '%%%@%%' ",
				p, ThreadNameColumn, token];
		}
		p = @"AND ";
	}
	
	return clause;
}

enum {
	kNewerThreadType,	// 新着検索
	kOlderThreadType,	// 非新着検索
	kAllThreadType,		// 全部！
};

// filter 処理と
// 新着のみもしくは非新着のみもしくはすべてのスレッドをDBから取得するための
// WHERE句を生成。
static inline NSString *conditionFromStatusAndType( int status, int type )
{
	NSMutableString *result = [NSMutableString string];
	NSString *brankOrAnd = @"";
	
	if(status & ThreadLogCachedStatus && 
	   (type == kOlderThreadType || !(status & ThreadNewCreatedStatus))) {
		// 新着/既得スレッドで且つ既得分表示 もしくは　既得スレッド
		[result appendFormat : @"NOT %@ IS NULL\n", NumberOfReadColumn];
		brankOrAnd = @" AND ";
	} else if(status & ThreadNoCacheStatus) {
		// 未取得スレッド
		[result appendFormat : @"%@ IS NULL\n", NumberOfReadColumn];
		brankOrAnd = @" AND ";
	} else if(status & ThreadNewCreatedStatus && type == kOlderThreadType) {
		// 新着スレッドで且つ既得分表示。あり得ない boardID を指定し、要素数を0にする
		[result appendFormat : @"%@ < 0\n",BoardIDColumn];
		brankOrAnd = @" AND ";
	}
	
	switch(type) {
		case kNewerThreadType:	
			[result appendFormat : @"%@%@ = %u\n", 
				brankOrAnd, ThreadStatusColumn, ThreadNewCreatedStatus];
			break;
		case kOlderThreadType:
			[result appendFormat : @"%@%@ != %u\n", 
				brankOrAnd, ThreadStatusColumn, ThreadNewCreatedStatus];
			break;
		case kAllThreadType:
			// Do nothing.
			break;
		default:
			UTILUnknownCSwitchCase(type);
			break;
	}
	
	return result;
}
static inline NSString *orderBy( NSString *sortKey, BOOL isAscending )
{
	NSString *result = nil;
	NSString *sortCol = nil;
	NSString *ascending = @"";
	
	if (!isAscending) ascending = @"DESC";
	
	if ([sortKey isEqualTo : CMRThreadTitleKey]) {
		sortCol = ThreadNameColumn;
	} else if ([sortKey isEqualTo : CMRThreadLastLoadedNumberKey]) {
		sortCol = NumberOfReadColumn;
	} else if ([sortKey isEqualTo : CMRThreadNumberOfMessagesKey]) {
		sortCol = NumberOfAllColumn;
	} else if ([sortKey isEqualTo : CMRThreadNumberOfUpdatedKey]) {
		sortCol = NumberOfDifferenceColumn;
	} else if ([sortKey isEqualTo : CMRThreadSubjectIndexKey]) {
		sortCol = TempThreadThreadNumberColumn;
	} else if ([sortKey isEqualTo : CMRThreadStatusKey]) {
		sortCol = ThreadStatusColumn;
	} else if ([sortKey isEqualTo : CMRThreadModifiedDateKey]) {
		sortCol = ModifiedDateColumn;
	} else if ([sortKey isEqualTo : ThreadPlistIdentifierKey]) {
		sortCol = ThreadIDColumn;
	} else if ([sortKey isEqualTo : ThreadPlistBoardNameKey]) {
		sortCol = BoardNameColumn;
	}
	
//	if(sortCol) {
//		result = [NSString stringWithFormat : @"ORDER BY %@ %@",sortCol, ascending];
//	}
//	
//	return result;
	return [sortCol lowercaseString];
}
- (NSString *) sqlForListForType : (int) type
{
	NSString *targetTable = [[target boardListItem] query];
	NSMutableString *sql;
	NSString *whereOrAnd = @" WHERE ";
	NSString *searchCondition;
	NSString *filterCondition;
	NSString *order;
	
	sql = [NSMutableString stringWithFormat : @"SELECT * FROM (%@) ",targetTable];
	
	if ([target searchString] && ![[target searchString] isEmpty]) {
		searchCondition = whereClauseFromSearchString([target searchString]);
		if (searchCondition) {
			[sql appendString : searchCondition];
			whereOrAnd = @" AND ";
		}
	}
	
	filterCondition = conditionFromStatusAndType( [target status], type);
	if(filterCondition && [filterCondition length] != 0) {
		[sql appendFormat : @"%@ %@\n", whereOrAnd, filterCondition];
		//		whereOrAnd = @" AND ";
	}
	
//	order = orderBy( [target sortKey], [target isAscending]);
//	if(order) {
//		[sql appendString : order];
//	}
	
	return sql;
}
- (id)cursor
{
	id result = nil;
	
	[self postTaskWillStartNotification];
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	NSString *newersSQL = nil;
	NSString *sql;
	id <SQLiteMutableCursor> newerCursor = nil;
	id <SQLiteMutableCursor> olderCursor = nil;
	
	UTILAssertNotNil(db);
	
	if( [CMRPref collectByNew] ) {
		if(userCanceled) goto final;
		newersSQL = [self sqlForListForType : kNewerThreadType];
		if(userCanceled) goto final;
		sql = [self sqlForListForType : kOlderThreadType];
	} else {
		sql = [self sqlForListForType : kAllThreadType];
	}
	
//	if(userCanceled) goto final;
//	sql = [sql stringByAppendingString:@"\nLIMIT 5000"];
//	newersSQL = [newersSQL stringByAppendingString:@"\nLIMIT 5000"];
	
	do {
		if(userCanceled) goto final;
		olderCursor = [db cursorForSQL : sql];
		if ([db lastErrorID] != 0) {
			NSLog(@"sql error on %s line %d.\n\tReason   : %@", __FILE__, __LINE__, [db lastError]);
			olderCursor = nil;
			break;
		}
		if(userCanceled) goto final;
		if(newersSQL) {
			newerCursor = [db cursorForSQL : newersSQL];
			if([db lastErrorID] != 0) {
				NSLog(@"sql error on %s line %d.\n\tReason   : %@", __FILE__, __LINE__, [db lastError]);
				newerCursor = nil;
				break;
			}
		}
		
		if(userCanceled) goto final;
		id sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:orderBy([target sortKey], 0)
														 ascending:[target isAscending]
														  selector:@selector(numericCompare:)] autorelease];
		id sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		if(newerCursor) {
			NSArray *data = [newerCursor arrayForTableView];
			NSArray *col = [newerCursor columnNames];
			NSArrayController *acon = [[[NSArrayController alloc] initWithContent:data] autorelease];
			
			[acon setSortDescriptors:sortDescriptors];
			data = [acon arrangeObjects:data];
			
			newerCursor = [NSDictionary dictionaryWithObjectsAndKeys:data, @"Values", col, @"ColumnNames", nil];
		}
		if(olderCursor) {
			NSArray *data = [olderCursor arrayForTableView];
			NSArray *col = [olderCursor columnNames];
			NSArrayController *acon = [[[NSArrayController alloc] initWithContent:data] autorelease];
			
			[acon setSortDescriptors:sortDescriptors];
			data = [acon arrangeObjects:data];
			
			olderCursor = [NSDictionary dictionaryWithObjectsAndKeys:data, @"Values", col, @"ColumnNames", nil];
		}
		
		if(userCanceled) goto final;
		if(newerCursor && [newerCursor rowCount]) {
			[newerCursor appendCursor : olderCursor];
			olderCursor = nil;
		}
	} while( NO );
	
	if(olderCursor || newerCursor) {
		if(olderCursor) {
			result = olderCursor;
		} else {
			result = newerCursor;
		}
	}
	
final:
	[self postTaskDidFinishNotification];
	
	return result;
}

@end

@implementation BSThreadListUpdateTask(TaskNotification)
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
	
	progress = NO;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : CMRTaskDidFinishNotification
					   object : self];
}
@end

@implementation NSString(BSThreadListUpdateTaskAddition)
- (NSComparisonResult)numericCompare:(NSString *)string
{
	return [self compare:string options:NSNumericSearch];
}
@end
@implementation NSNumber(BSThreadListUpdateTaskAddition)
- (NSComparisonResult)numericCompare:(id)obj
{
	return [self compare:obj];
}
@end
