//
//  AbstractDBBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "AbstractDBBoardListItem.h"

//#import "DatabaseManager.h"

@implementation AbstractDBBoardListItem

-(void)setQuery:(NSString *)query
{
	id temp = mQuery;
	
	mQuery = [query copy];
	[temp release];
}
-(NSString *)query
{
	return mQuery;
}
/*
-(id <SQLiteCursor>)cursorForThreadList
{
	SQLiteDB *db;
	id result;
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
//	[db setIsInDebugMode:YES];
	result = [db performQuery:mQuery];
//	[db setIsInDebugMode:NO];
		
	return result;
}
*/
@end
