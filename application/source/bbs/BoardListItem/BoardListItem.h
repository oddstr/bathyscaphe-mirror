//
//  BoardListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/16.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CMRHistoryObject.h"

#import "SQLiteDB.h"

typedef enum _BoardListItemType {
	BoardListUnknownItem    = 0,
	BoardListBoardItem      = 1,
	BoardListCategoryItem   = 1 << 1,
	BoardListFavoritesItem  = 1 << 2,
	BoardListEmptyBoardItem = ((1 << 3) | BoardListBoardItem),
	BoardListEmptyCategoryItem = ((1 << 4) | BoardListCategoryItem),
	BoardListSmartBoardItem = 1 << 5,
	
	BoardListAnyTypeItem    = UINT_MAX,  /* 0xFFFFFFFF */
	
} BoardListItemType;

@interface BoardListItem : NSObject <CMRHistoryObject, NSCoding>
{
	@private
	NSImage *_icon;
	NSString *_name;
}

// + (id) itemForName : (NSString *) name;

- (NSImage *) icon;
- (void) setIcon : (NSImage *) icon;

- (NSString *) name;
- (void) setName : (NSString *) newName;
- (NSString *) representName; // name shown in BoardList. default call name method.
- (void) setRepresentName : (NSString *) newRepresentName; // defualt call setName method.

// default return NO.
- (BOOL) hasURL;
- (NSURL *) url;
- (void) setURLString : (NSString *) urlString;

// default return NO;
- (BOOL) hasChildren;
- (BoardListItem *) parentForItem : (BoardListItem *) item;

// default retrun 0.
- (unsigned) numberOfItem;
- (id) itemAtIndex : (unsigned) index;
- (unsigned) indexOfItem : (id) item;
- (NSArray *) items;
- (id) itemForName : (NSString *) name;
- (id) itemForName : (NSString *) name deepSearch : (BOOL) isDeep;
- (id) itemForRepresentName : (NSString *) name;
- (id) itemForRepresentName : (NSString *) name deepSearch : (BOOL) isDeep;
- (id) itemForName : (NSString *)name ofType: (BoardListItemType)type;
// primitive
- (id) itemForName : (NSString *)name ofType: (BoardListItemType)type deepSearch : (BOOL) isDeep;
- (id) itemForRepresentName : (NSString *)name ofType: (BoardListItemType)type;
- (id) itemForRepresentName : (NSString *)name ofType: (BoardListItemType)type deepSearch : (BOOL) isDeep;

- (id) description;
- (id) plist;

@end

@interface BoardListItem (Creation)

+ (id) favoritesItem;
+ (id) boardListItemWithFolderName : (NSString *) name;
+ (id) baordListItemWithBoradID : (unsigned) boardID;
+ (id) boardListItemWithURLString : (NSString *) urlString;
+ (id) baordListItemWithName : (NSString *) name condition : (id) condition;

+ (id) baordListItemFromPlist : (id) plist;

- (id) initForFavorites;
- (id) initWithFolderName : (NSString *) name;
- (id) initWithBoardID : (unsigned) boardID;
- (id) initWithURLString : (NSString *) urlString;
- (id) initWithName : (NSString *) name condition : (id) condition;

- (id) initWithContentsOfFile : (NSString *) path;

@end

@interface BoardListItem (TypeCheck)

+ (BOOL) isBoardItem : (BoardListItem *) item;
+ (BOOL) isFavoriteItem : (BoardListItem *) item;
+ (BOOL) isFolderItem : (BoardListItem *) item;
+ (BOOL) isSmartItem : (BoardListItem *) item;

+ (BOOL) isCategory : (BoardListItem *) item; // alias of +isFolderItem:

+ (BoardListItemType) typeForItem : (BoardListItem *) item;

- (BoardListItemType) type;

@end

@interface BoardListItem (ThreadsList)

// this cursor ONLY used by thread list.
// default return nil.
- (id <SQLiteCursor>) cursorForThreadList;
- (NSString *) query;

- (void) postUpdateThreadsNotification;

@end


@interface BoardListItem (Mutable)

// default return NO.
- (BOOL) isMutable;

- (void) addItem : (BoardListItem *) item;
// Raise NSRangeException, if index larger.
- (void) insertItem : (BoardListItem *) item atIndex : (unsigned) index;
// Raise NSRangeException, if not found object.
- (void) insertItem : (BoardListItem *) item afterItem : (BoardListItem *) object; // default call -insertItem:afterItem:deepSearch: isDeep argument set NO.
- (void) insertItem : (BoardListItem *) item afterItem : (BoardListItem *) object deepSearch : (BOOL) isDeep;

- (void) removeItem : (BoardListItem *) item; // default call -removeItem:deepSearch: isDeep argument set NO.
- (void) removeItem : (BoardListItem *) item deepSearch : (BOOL) isDeep;
- (void) removeItemAtIndex : (unsigned) index;

- (void) postUpdateChildrenNotification;

@end

extern NSString *BoardListItemUpdateChildrenNotification;
extern NSString *BoardListItemUpdateThreadsNotification;



