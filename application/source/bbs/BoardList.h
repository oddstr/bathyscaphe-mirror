/**
 * $Id: BoardList.h,v 1.2.4.1 2005/12/14 16:05:06 masakih Exp $
 * 
 * BoardList.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import <Foundation/Foundation.h>



@class NSImage;
@class NSOutlineView;

typedef enum _BoardListItemType {
	BoardListUnknownItem    = 0,
	BoardListBoardItem      = 1,
	BoardListCategoryItem   = 1 << 1,
	BoardListFavoritesItem  = 1 << 2,
	BoardListEmptyBoardItem = ((1 << 3) | BoardListBoardItem),
	BoardListEmptyCategoryItem = ((1 << 4) | BoardListCategoryItem)
	
} BoardListItemType;



@interface BoardList : NSObject
{
    @private
    NSString       *_fileName;
    NSMutableArray *_boardItems;
    BOOL           _isEdited;
}

- (id) initWithContentsOfFile : (NSString *) filepath;
+ (NSString *) defaultBoardListPath;

- (BOOL) isEdited;
- (void) setIsEdited : (BOOL) flag;

- (NSMutableArray *) boardItems;
- (void) setBoardItems : (NSMutableArray *) list;

+ (BoardListItemType) typeForItem : (NSDictionary *) item;

+ (BOOL) isBoard : (NSDictionary *) item;
+ (BOOL) isCategory : (NSDictionary *) item;
+ (BOOL) isFavorites : (NSDictionary *) item;

- (void) postBoardListDidChangeNotification;


- (BOOL) addItem : (NSDictionary   *) item
     afterObject : (NSDictionary   *) target;

- (void) item : (NSMutableDictionary *) item
      setName : (NSString     *) name
       setURL : (NSString     *) url;


- (BOOL) containsItemWithName : (NSString *) name
					   ofType : (BoardListItemType) aType;
- (BOOL) containsItemWithName : (NSString *) name;
- (void) removeItemWithName : (NSString *) name
					 ofType : (BoardListItemType) aType;
- (void) removeItemWithName : (NSString *) name;

- (NSURL *) URLForBoardName : (NSString *) boardName;
- (NSString *) boardNameForURL : (NSURL *) theURL;
- (void) updateURL : (NSURL    *) anURL
      forBoardName : (NSString *) aName;

- (void) moveItem:(NSDictionary *)item direction:(int)direction;

- (NSDictionary *) itemForName : (NSString *) name;


- (NSDictionary *) itemForURL : (NSURL *) url;

- (NSDictionary *) itemForAttribute : (id               ) attribute
					   attributeKey : (NSString        *) key
                          seachMask : (BoardListItemType) mask
					  containsArray : (NSMutableArray **) container
					        atIndex : (unsigned int    *) index;

- (BOOL) writeToFile : (NSString *) filepath
          atomically : (BOOL      ) flag;
- (BOOL) synchronizeWithFile : (NSString *) filepath;
@end



@interface BoardList(OutlineViewDataSource)
- (BOOL) outlineView : (NSOutlineView *) outlineView
             addItem : (id             ) item
           afterItem : (id             ) pointingItem;
@end



@interface FavoritesList : BoardList
+ (NSMutableDictionary *) favoritesItem;
@end

extern NSString *const CMRBBSListItemsPboardType;
extern NSString *const CMRBBSListDidChangeNotification;

