//
//  SmartBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "SmartBoardListItem.h"

#import "DatabaseManager.h"

#import <SGAppKit/NSImage-SGExtensions.h>

@interface SmartBoardListItem(Private)
- (void)updateQuery;
@end

@implementation SmartBoardListItem
- (id) initWithName : (NSString *) inName condition : (id) condition
{
	if (self = [super init]) {
		if(!inName || !condition) {
			[self release];
			return nil;
		}
		[self setName : inName];
		mConditions = [condition retain];
		[self updateQuery];
	}
	
	return self;
}

- (BOOL)isEqual:(id) other
{
	if(self == other) return YES;
	
	if([self class] != [other class]) return NO;
	if(![[self name] isEqualTo:[other name]]) return NO;
	if(![[self query] isEqualTo:[other query]]) return NO;
	
	return YES;
}
- (NSImage *) icon
{
	return [NSImage imageAppNamed : @"SmartBoard"];
}

- (id)query
{
	return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",
		BoardThreadInfoViewName, mConditions];
}
- (void)updateQuery
{
	NSString *query;
	
	query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",
		BoardThreadInfoViewName, mConditions];
	
	[self setQuery:query];
}

- (id) condition
{
	return mConditions;
}
- (void) setCondition:(id)condition
{
	id tmp = mConditions;
	mConditions = [condition retain];
	[tmp release];
	
	[self updateQuery];
	
	[self postUpdateThreadsNotification];
}

#pragma mark## CMRPropertyListCoding protocol ##
static NSString *SmartConditionNameKey = @"Name";
static NSString *SmartConditionConditionKey = @"SmartConditionConditionKey";

- (id) propertyListRepresentation
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[self name], SmartConditionNameKey,
//		[NSArchiver archivedDataWithRootObject:mConditions], SmartConditionConditionKey,
		[NSKeyedArchiver archivedDataWithRootObject:mConditions], SmartConditionConditionKey,
		nil];
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	id v;
	id name, cond = nil;
	
	name = [rep objectForKey:SmartConditionNameKey];
	
	v = [rep objectForKey:SmartConditionConditionKey];
	if(v) {
//		cond = [[NSUnarchiver unarchiveObjectWithData:v] retain];
		cond = [[NSKeyedUnarchiver unarchiveObjectWithData:v] retain];
	}
	
	return [self initWithName:name condition:cond];
}

- (id)plist
{
	return [self propertyListRepresentation];
}
- (id) description
{
	return [[self plist] description];
}

- (BOOL) isHistoryEqual : (id) anObject
{
	if (![super isHistoryEqual : anObject]) return NO;

	if ([[anObject query] isEqualToString: [self query]]) return YES;
	
	return NO;
}
@end

