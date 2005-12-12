//
//  ConcreteBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/06.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ConcreteBoardListItem.h"

#import "DatabaseManager.h"


@class FavoritesBoardListItem, SmartBoardListItem, FolderBoardListItem, BoardBoardListItem;

static ConcreteBoardListItem *_sharedInstance;

@implementation ConcreteBoardListItem

+ (id) sharedInstance
{
	if (!_sharedInstance) {
		_sharedInstance = [[self alloc] init];
	}
	
	return _sharedInstance;
}

- (id) retain { return self; }
- (oneway void) release {}
- (unsigned) retainCount { return UINT_MAX; }

+ (id) favoritesItem
{
	return [FavoritesBoardListItem sharedInstance];
}
- (id) initForFavorites
{
	return [FavoritesBoardListItem sharedInstance];
}
- (id) initWithFolderName : (NSString *) name
{
	return [[FolderBoardListItem alloc] initWithFolderName : name];
}
- (id) initWithBoardID : (unsigned) boardID
{
	return [[BoardBoardListItem alloc] initWithBoardID : boardID];
}
- (id) initWithURLString : (NSString *) urlString
{
	return [[BoardBoardListItem alloc] initWithURLString : urlString];
}
- (id) initWithName : (NSString *) name condition : (id) condition
{
	return [[SmartBoardListItem alloc] initWithName : name condition : condition];
}


- (BoardListItem *) folderItemFromPlist : (NSDictionary *) plist
{
	BoardListItem *result;
	NSString *name;
	NSArray *contents;
	int i, count;
	DatabaseManager *dbm = [DatabaseManager defaultManager];
	
	name = [plist objectForKey : @"Name"];
	if (!name) return nil;
	contents = [plist objectForKey : @"Contents"];
	if (!contents) return nil;
	
	result = [[[BoardListItem alloc] initWithFolderName : name] autorelease];
	
	count = [contents count];
	for ( i = 0; i < count; i++ ) {
		id item = [contents objectAtIndex : i];
		NSString *boardName;
		NSString *url;
		unsigned boardID;
		BoardListItem *boardItem;
		
		if (!item) continue;
		
		boardName = [item objectForKey : @"Name"];
		url = [item objectForKey : @"URL"];
		
		boardID = [dbm boardIDForURLString : url];
		if (NSNotFound == boardID) {
			BOOL isOK = [dbm registerBoardName : boardName URLString : url];
			boardID = [dbm boardIDForURLString : url];
			if (!isOK || NSNotFound == boardID) {
				NSLog(@"Fail Import Board. %@", item ) ;
				continue;
			}
		}
		
		boardItem = [[[BoardListItem alloc] initWithBoardID : boardID] autorelease];
//		[boardItem setName : boardName];
		[result addItem : boardItem];
	}
	
	return result;
}


- (id) initWithContentsOfFile : (NSString *) path;
{
	id result = nil;
	NSArray *array;
	NSEnumerator *elemsEnum;
	id object;
	
	SQLiteDB *db;
	
	result = [[BoardListItem alloc] initWithFolderName : @"Top"];
	
	array = [NSArray arrayWithContentsOfFile : path];
	if (!array) {
		NSLog(@"File Import BoardListFile. %@", path) ;
		goto final;
	}
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if (!db) {
		goto final;
	}
	
	if ([db beginTransaction]) {
		elemsEnum = [array objectEnumerator];
		while ( object = [elemsEnum nextObject] ) {
			id item;
			
			item = [self folderItemFromPlist : object];
			if (item) {
				[result addItem : item];
			}
		}
		[db commitTransaction];
	}
	
final :
		
		return result;
}
@end

@implementation ConcreteBoardListItem (TypeCheck)

+ (BOOL) isBoardItem : (BoardListItem *) item
{
	return [item isKindOfClass : [BoardBoardListItem class]];
}
+ (BOOL) isFavoriteItem : (BoardListItem *) item
{
	return [item isKindOfClass : [FavoritesBoardListItem class]];
}
+ (BOOL) isFolderItem : (BoardListItem *) item
{
	return [item isKindOfClass : [FolderBoardListItem class]];
}
+ (BOOL) isSmartItem : (BoardListItem *) item
{
	return [item isKindOfClass : [SmartBoardListItem class]];
}
+ (BOOL) isCategory : (BoardListItem *) item
{
	return [self isFolderItem : item];
}

+ (/*BoardListItemType*/ int) typeForItem : (BoardListItem *) item
{
	if ([self isBoardItem : item]) {
		return 1; //BoardListBoardItem;
	} else if ([self isFolderItem : item]) {
		return 1 << 1; //BoardListCategoryItem;
	} else if ([self isFavoriteItem : item]) {
		return 1 << 2; //BoardListFavoritesItem;
	} else if ([self isSmartItem : item]) {
		return 1 << 5;
	}
	
	return 0; //BoardListUnknownItem;
}

@end

