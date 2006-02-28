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
//	@synchronized(self) {
	if (!_sharedInstance) {
		_sharedInstance = [[self alloc] init];
	}
//	}
	
	return _sharedInstance;
}

- (id) retain { return self; }
- (oneway void) release {}
- (unsigned) retainCount { return UINT_MAX; }

+ (id) favoritesItem
{
	return [FavoritesBoardListItem sharedInstance];
}
+ (id) boardListItemWithFolderName : (NSString *) name
{
	return [[[FolderBoardListItem alloc] initWithFolderName : name] autorelease];
}
+ (id) baordListItemWithBoradID : (unsigned) boardID
{
	return [[[BoardBoardListItem alloc] initWithBoardID : boardID] autorelease];
}
+ (id) boardListItemWithURLString : (NSString *) urlString
{
	return [[[BoardBoardListItem alloc] initWithURLString : urlString] autorelease];
}
+ (id) baordListItemWithName : (NSString *) name condition : (id) condition
{
	return [[[SmartBoardListItem alloc] initWithName : name condition : condition] autorelease];
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

+ (BoardListItem *) boardBoardListItemFromPlist : (id) plist
{
	NSString *url;
	NSString *boardName;
	unsigned boardID;
	DatabaseManager *dbm = [DatabaseManager defaultManager];
	
	UTILCAssertKindOfClass(plist, [NSDictionary class]);
	
	boardName = [plist objectForKey : @"Name"];
	if (!boardName) goto failCreation;
			
	url = [plist objectForKey : @"URL"];
	if (!url) goto failCreation;
	
	boardID = [dbm boardIDForURLString : url];
	if (NSNotFound == boardID) {
		BOOL isOK = [dbm registerBoardName : boardName URLString : url];
		boardID = [dbm boardIDForURLString : url];
		if (!isOK || NSNotFound == boardID) {
			goto failCreation;
		}
	}
	
	return [BoardListItem baordListItemWithBoradID : boardID];
		
failCreation:
	NSLog(@"Fail Import Board. %@", plist ) ;
	return nil;
}

+ (BoardListItem *) folderBaordListItemFromPlist : (id) plist
{
	BoardListItem *result;
	NSString *name;
	NSArray *contents;
	int i, count;
	
	UTILCAssertKindOfClass(plist, [NSDictionary class]);
	
	name = [plist objectForKey : @"Name"];
	if (!name) return nil;
	contents = [plist objectForKey : @"Contents"];
	if (!contents) return nil;
	
	result = [[[BoardListItem alloc] initWithFolderName : name] autorelease];
	if(!result) goto failCreation;
	
	count = [contents count];
	for ( i = 0; i < count; i++ ) {
		id item = [contents objectAtIndex : i];
		BoardListItem *boardItem;
		
		if (!item) continue;

//		boardItem = [self boardBoardListItemFromPlist : item];
		boardItem = [self baordListItemFromPlist : item];
		if(boardItem) {
			[result addItem : boardItem];
			continue;
		}
	}
	
	return result;
	
failCreation:
	NSLog(@"Fail Import Folder. %@", plist ) ;
	return nil;
}

+ (BoardListItem *) baordListItemFromPlist : (id) plist
{
	BoardListItem *result = nil;
	NSString *name;
	id contents;
	id url;
	id cond;
	
	UTILCAssertKindOfClass(plist, [NSDictionary class]);
	
	name = [plist objectForKey : @"Name"];
	if (!name) return nil;
	
	contents = [plist objectForKey : @"Contents"];
	if (contents) {
		result = [self folderBaordListItemFromPlist : plist];
	}
	
	url = [plist objectForKey : @"URL"];
	if (url) {
		result = [self boardBoardListItemFromPlist : plist];
	}
	
	cond = [plist objectForKey:@"SmartConditionConditionKey"];
	if(cond) {
		result = [SmartBoardListItem objectWithPropertyListRepresentation:plist];
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
			
			item = [[self class] baordListItemFromPlist : object];
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

+ (BoardListItemType) typeForItem : (BoardListItem *) item
{
	if ([self isBoardItem : item]) {
		return BoardListBoardItem;
	} else if ([self isFolderItem : item]) {
		return BoardListCategoryItem;
	} else if ([self isFavoriteItem : item]) {
		return BoardListFavoritesItem;
	} else if ([self isSmartItem : item]) {
		return BoardListSmartBoardItem;
	}
	
	return BoardListUnknownItem;
}

@end

