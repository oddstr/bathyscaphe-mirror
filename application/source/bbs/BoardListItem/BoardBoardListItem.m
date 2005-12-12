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

@implementation BoardBoardListItem

+ (NSString *) untitledItemName
{
	return NSLocalizedString(@"Untitled Board", @"Untitled Board");
}

- (id) initWithBoardID : (unsigned) inBoardID
{
	if (self = [super init]) {
		[self setBoardID : inBoardID];
//		[self setName : [[self class] untitledItemName]];
	}

	return self;
}
- (id) initWithURLString : (NSString *) urlString
{
	unsigned inBoardID;
	
	inBoardID = [[DatabaseManager defaultManager] boardIDForURLString : urlString];
	if (inBoardID == NSNotFound) {
		[self release];
		return nil;
	}
	
	return [self initWithBoardID : inBoardID];
}
- (void) dealloc
{
	[representName release];
	
	[super dealloc];
}

- (id) description
{
	id dict;
	id url;
	
	url = [[DatabaseManager defaultManager] urlStringForBoardID : [self boardID]];
	if ( url ) {
		dict = [[NSDictionary alloc] initWithObjectsAndKeys : [self name], BoardPlistNameKey,
			url, BoardPlistURLKey, nil];
	} else {
		NSLog(@"I'm broken.") ;
		dict = [[NSDictionary alloc] initWithObjectsAndKeys : [self name], BoardPlistNameKey, nil];
	}
	
	return [[dict autorelease] description];
}
- (id) plist
{
	id dict;
	id url;
	
	url = [[DatabaseManager defaultManager] urlStringForBoardID : [self boardID]];
	if (url) {
		dict = [[NSDictionary alloc] initWithObjectsAndKeys : [self name], BoardPlistNameKey,
			url, BoardPlistURLKey, nil];
	} else {
		NSLog(@"I'm broken.") ;
		dict = [[NSDictionary alloc] initWithObjectsAndKeys : [self name], BoardPlistNameKey, nil];
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
	[query appendFormat : @"\t\tUSING (%@) ", BoardIDColumn];
	[query appendFormat : @"WHERE %@ = %d ) ", BoardIDColumn, boardID];
	[query appendFormat : @"\t\tUSING (%@, %@) ", BoardIDColumn, ThreadIDColumn];
*/	
	query = [NSMutableString stringWithFormat : @"SELECT * FROM %@ INNER JOIN \n",
		TempThreadNumberTableName];
	[query appendFormat : @" (SELECT * FROM %@ INNER JOIN %@\n",
		ThreadInfoTableName, BoardInfoTableName];
	[query appendFormat : @"\t\tUSING (%@) )", BoardIDColumn];
	[query appendFormat : @"\t\tUSING (%@, %@) ", BoardIDColumn, ThreadIDColumn];
	[query appendFormat : @"WHERE %@ = %d", BoardIDColumn, boardID];
	
	[self setQuery : query];
}
@end
