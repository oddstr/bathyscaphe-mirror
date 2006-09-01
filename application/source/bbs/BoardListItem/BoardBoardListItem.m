//
//  BoardBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "BoardBoardListItem.h"

#import "DatabaseManager.h"
#import "CMRBBSListTemplateKeys.h"

#import <SGAppKit/NSImage-SGExtensions.h>

static NSMutableDictionary *_commonInstances = nil;
static NSLock *_commonInstancesLock = nil;

@interface BoardBoardListItem(Private)
- (id) _privateInitWithBoardID : (unsigned) boardID;
@end

@implementation BoardBoardListItem

+ (void)initialize
{
	static BOOL isFirst = YES;
	
	if (isFirst) {
		isFirst = NO;
		
		_commonInstances = [[NSMutableDictionary dictionary] retain];
		_commonInstancesLock = [[NSLock alloc] init];
	}
}

+ (id) boardBoardListWithBoardID : (unsigned) inBoardID
{
	return [[[self alloc] _privateInitWithBoardID : inBoardID] autorelease];
}

- (id)_privateInitWithBoardID : (unsigned) inBoardID
{
	id result = nil;
	id key = [NSNumber numberWithUnsignedInt : inBoardID];
	
	[_commonInstancesLock lock];
	result = [[_commonInstances objectForKey : key] retain];
	if (!result) {
		result = [super init];
		if (result) {
			[result setBoardID : inBoardID];
			[_commonInstances setObject : result forKey : key];
		}
	} else {
		[self release];
	}
	[_commonInstancesLock unlock];
	
	return result;
}

- (id) initWithBoardID : (unsigned) inBoardID
{	
	return [self _privateInitWithBoardID : inBoardID];
}
- (id) initWithURLString : (NSString *) urlString
{
	unsigned inBoardID;
	
	inBoardID = [[DatabaseManager defaultManager] boardIDForURLString : urlString];
	if (inBoardID == NSNotFound) {
		[self release];
		return nil;
	}
	
	return [self _privateInitWithBoardID : inBoardID];
}

- (void) dealloc
{
	[representName release];
	
	[super dealloc];
}

- (id) description
{
	return [[self plist] description];
}
- (id) plist
{
	id dict;
	id url;
	id repName;
	
	dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys : [self name], BoardPlistNameKey, nil];
	
	url = [[DatabaseManager defaultManager] urlStringForBoardID : [self boardID]];
	UTILAssertNotNil(url);
	[dict setObject : url forKey : BoardPlistURLKey];
	
	if((repName = [self representName])) {
		[dict setObject : repName forKey : @"RepresentName"];
	}
	
	return [dict autorelease];
}

#pragma mark## CMRPropertyListCoding protocol ##
- (id) propertyListRepresentation
{
	id result;
	
	result = [NSMutableDictionary dictionaryWithObject : [NSNumber numberWithUnsignedInt : [self boardID]]
												forKey : @"BoardID"];
	if (representName) {
		[result setObject : representName
				   forKey : @"RepresentName"];
	}
	
	return result;
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	id result;
	id repname;
	
	if ([rep isKindOfClass : [NSNumber class]]) {
		return [self initWithBoardID : [rep unsignedIntValue]];
	}
	
	result = [self initWithBoardID : [[rep objectForKey : @"BoardID"] unsignedIntValue]];
	
	repname = [rep objectForKey : @"RepresentName"];
	if (repname) {
		[result setRepresentName : repname];
	}
	
	return result;
}
- (BOOL) isHistoryEqual : (id) anObject
{
	if (![super isHistoryEqual : anObject]) return NO;

	if ([anObject boardID] == [self boardID]) return YES;
	
	return NO;
}

- (NSImage *) icon
{
	return [NSImage imageAppNamed : kDefaultBBSImageName];
}

- (NSString *) name
{
	return [[DatabaseManager defaultManager] nameForBoardID : [self boardID]];
}
- (void) setName : (NSString *) name
{
	NSString *currentName;
	DatabaseManager *dbm = [DatabaseManager defaultManager];
	
	currentName = [dbm nameForBoardID : [self boardID]];
	if ([currentName isEqualTo : name]) return;
	
	[dbm renameBoardID : [self boardID] toName : name];
}

- (NSString *) representName
{
	if (representName) {
		return representName;
	}
	
	return [self name];
}
- (void) setRepresentName : (NSString *) name
{
	id temp = representName;
	
	representName = [name copy];
	[temp release];
}

- (BOOL) hasURL
{
	return YES;
}
- (NSURL *) url
{
	id urlString = [[DatabaseManager defaultManager] urlStringForBoardID : [self boardID]];
	
	return [NSURL URLWithString : urlString];
}
- (void) setURLString : (NSString *) urlString
{
	[[DatabaseManager defaultManager] moveBoardID : boardID toURLString : urlString];
}

- (unsigned) boardID
{
	return boardID;
}
- (void) setBoardID : (unsigned) newBoardID
{
	NSMutableString *query;
	
	boardID = newBoardID;
/*	
	query = [NSMutableString stringWithFormat : @"SELECT * FROM %@ INNER JOIN \n",
		TempThreadNumberTableName];
	[query appendFormat : @" (SELECT * FROM %@ INNER JOIN %@\n",
		ThreadInfoTableName, BoardInfoTableName];
	[query appendFormat : @"\t\tUSING (%@) )", BoardIDColumn];
	[query appendFormat : @"\t\tUSING (%@, %@) ", BoardIDColumn, ThreadIDColumn];
	[query appendFormat : @"WHERE %@ = %d", BoardIDColumn, boardID];
	
*/
	query = [NSMutableString stringWithFormat : @"SELECT * FROM %@ INNER JOIN %@ \n",
		TempThreadNumberTableName, BoardThreadInfoViewName];
	[query appendFormat : @"\t\tUSING (%@, %@) ", BoardIDColumn, ThreadIDColumn];
	[query appendFormat : @"WHERE %@ = %d", BoardIDColumn, boardID];
	
	[self setQuery : query];
}
@end
