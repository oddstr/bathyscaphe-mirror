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

+(NSString *)untitledItemName
{
	return NSLocalizedString(@"Untitled Board", @"Untitled Board");
}

-(id)initWithBoardID:(unsigned)inBoardID
{
	if( self = [super init] ) {
		[self setName:[[self class] untitledItemName]];
		[self setBoardID:inBoardID];
	}

	return self;
}

-(NSImage *)icon
{
	return [NSImage imageAppNamed : kDefaultBBSImageName];
}

-(NSString *)name
{
	return name;
}
-(void)setName:(NSString *)newName
{
	id temp = name;
	name = [newName copy];
	[temp release];
}

-(unsigned)boardID
{
	return boardID;
}
-(void)setBoardID:(unsigned)newBoardID
{
	NSMutableString *query;
	
	boardID = newBoardID;
	
	/*
	query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ INNER JOIN %@\n",
		ThreadInfoTableName, BoardInfoTableName];
	[query appendFormat:@"\t\tUSING(%@) ", BoardIDColumn];
	[query appendFormat:@"WHERE %@ = %d", BoardIDColumn, boardID];
	 */
	
	query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ INNER JOIN \n",
		TempThreadNumberTableName];
	[query appendFormat:@"(SELECT * FROM %@ INNER JOIN %@\n",
		ThreadInfoTableName, BoardInfoTableName];
	[query appendFormat:@"\t\tUSING(%@) ", BoardIDColumn];
	[query appendFormat:@"WHERE %@ = %d )", BoardIDColumn, boardID];
	[query appendFormat:@"\t\tUSING(%@, %@) ", BoardIDColumn, ThreadIDColumn];
	
	
	[self setQuery:query];
}
@end
