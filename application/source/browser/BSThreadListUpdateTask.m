//
//  BSThreadListUpdateTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/29.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSThreadListUpdateTask.h"
#import "BSDBThreadList.h"
#import "BoardListItem.h"
#import "DatabaseManager.h"
#import "AppDefaults.h"

NSString *BSThreadListUpdateTaskDidFinishNotification = @"BSThreadListUpdateTaskDidFinishNotification";

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
		
		bbsName = [[[target boardListItem] representName] copy];
	}
	
	return self;
}
- (void)dealloc
{
	[cursor release];
	
	[super dealloc];
}

- (id) identifier
{
	return [NSValue valueWithPointer:self];
}

- (NSString *) title
{
	return bbsName;
}
- (NSString *) messageInProgress
{
	return [NSString stringWithFormat:
		NSLocalizedStringFromTable(@"Updating Thread(%@)", @"ThreadsList", @""),
		bbsName];
}

- (IBAction) cancel : (id) sender
{
	userCanceled = YES;
	target = nil;
}

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
	} else if ((status == ~ThreadNoCacheStatus) && type == kAllThreadType) {
		// 新着スレッドを常に最上位にソート「しない」かつ「新着／既得スレッド」
		[result appendFormat:@"%@ > %u\n", ThreadStatusColumn, ThreadNoCacheStatus];
	} else if ((status == (ThreadNewCreatedStatus ^ ThreadNoCacheStatus)) && type == kAllThreadType) {
		// 新着スレッドを常に最上位にソート「しない」かつ「新着スレッド」
		[result appendFormat:@"%@ = %u\n", ThreadStatusColumn, ThreadNewCreatedStatus];
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
- (NSString *) sqlForListForType : (int) type
{
	NSString *targetTable = [[target boardListItem] query];
	NSMutableString *sql;
	NSString *whereOrAnd = @" WHERE ";
	NSString *searchCondition;
	NSString *filterCondition;
	
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
	}
	
	return sql;
}
- (id)cursor
{
	return cursor;
}
- (void) setCursor:(id)new
{
	id temp = cursor;
	cursor = [new retain];
	[temp release];
}
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	id <SQLiteMutableCursor> result = nil;
		
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	NSString *sql;
	
	UTILAssertNotNil(db);
	
	sql = [self sqlForListForType : kAllThreadType];
	if(userCanceled) goto final;
	result = [db cursorForSQL : sql];
	if ([db lastErrorID] != 0) {
		NSLog(@"sql error on %s line %d.\n\tReason   : %@", __FILE__, __LINE__, [db lastError]);
		result = nil;
	}	
	
final:
	[self setCursor:result];
	[self postTaskDidFinishNotification];
}

@end

@implementation BSThreadListUpdateTask(Notification)

- (void) postTaskDidFinishNotification
{
	NSNotificationCenter	*nc_;
		
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : BSThreadListUpdateTaskDidFinishNotification
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
@implementation NSDate(BSThreadListUpdateTaskAddition)
- (NSComparisonResult)numericCompare:(id)obj
{
	return [self compare:obj];
}
@end
