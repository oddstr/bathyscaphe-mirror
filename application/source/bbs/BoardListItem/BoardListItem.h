//
//  BoardListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/16.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// SledgeHammer ではまだ使用しない
//#import "SQLiteDB.h"

@interface BoardListItem : NSObject <NSCoding>

// subclass MUST override.
-(NSImage *)icon;
-(NSString *)name;
-(void)setName:(NSString *)newName;

// default return NO.
-(BOOL)hasURL;
-(NSString *)url;
-(void)setURLString:(NSString *)urlString;

// default return NO;
-(BOOL)hasChildren;

// default retrun 0.
-(unsigned)numberOfItem;
-(id)itemAtIndex:(unsigned)index;

@end

@interface BoardListItem (Creation)

-(id)initForFavorites;
-(id)initWithFolderName:(NSString *)name;
-(id)initWithBoardID:(unsigned)boardID;
-(id)initWithName:(NSString *)name condition:(id)condition;

-(id)initWithContentsOfFile:(NSString *)path;

@end

/* SledgeHammer ではまだ使用しない
@interface BoardListItem (ThreadsList)

// this cursor ONLY used by thread list.
// default return nil.
-(id <SQLiteCursor>)cursorForThreadList;
-(NSString *)query;

-(void)postUpdateThreadsNotification;

@end
*/

@interface BoardListItem (Mutable)

// default return NO.
-(BOOL)isMutable;

-(void)addItem:(BoardListItem *)item;
-(void)insertItem:(BoardListItem *)item atIndex:(unsigned)index;
-(void)removeItem:(BoardListItem *)item;
-(void)removeItemAtIndex:(unsigned)index;

-(void)postUpdateChildrenNotification;

@end

extern NSString *BoardListItemUpdateChildrenNotification;
extern NSString *BoardListItemUpdateThreadsNotification;



