//
//  SmartBoardList.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/18.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BoardListItem.h"

@interface SmartBoardList : NSObject
{
	id topLevelItem;
	
	BOOL isEdited;
}

- (NSString *) defaultBoardListPath;

- (BOOL) writeToFile : (NSString *) filepath atomically : (BOOL) flag;

- (BOOL) isEdited;
- (void) setIsEdited : (BOOL) flag;

- (NSArray *) boardItems;

- (id) itemForName : (id) name;

- (void) setName : (NSString *) name toItem : (id) item;
- (void) setURL : (NSString *) urlString toItem : (id) item;

- (NSURL *) URLForBoardName : (id) name;

- (BOOL) addItem : (id) item afterObject : (id) target;
- (void) removeItem : (id) item;

+ (BoardListItemType) typeForItem : (id) item;
+ (BOOL) isBoard : (id) item;
+ (BOOL) isCategory : (id) item;
+ (BOOL) isFavorites : (id) item;

@end
