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
/*
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
*/
- (NSString *) sqlForList
{
	NSString *targetTable = [[target boardListItem] query];
	NSMutableString *sql;
//	NSString *searchCondition;
	
	sql = [NSMutableString stringWithFormat : @"SELECT * FROM (%@) ",targetTable];
/*	
	if ([target searchString] && ![[target searchString] isEmpty]) {
		searchCondition = whereClauseFromSearchString([target searchString]);
		if (searchCondition) {
			[sql appendString : searchCondition];
		}
	}
*/	
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
	
	sql = [self sqlForList];
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
