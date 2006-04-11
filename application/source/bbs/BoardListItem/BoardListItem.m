//
//  BoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/16.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "BoardListItem.h"
#import "ConcreteBoardListItem.h"

#import "DatabaseManager.h"

NSString *BoardListItemUpdateChildrenNotification = @"BoardListItemUpdateChildrenNotification";
NSString *BoardListItemUpdateThreadsNotification = @"BoardListItemUpdateThreadsNotification";

@implementation BoardListItem

+ (id) allocWithZone : (NSZone *) zone
{
	if ([self class] == [BoardListItem class]) {
		return [ConcreteBoardListItem sharedInstance];
	}
	
	return [super allocWithZone : zone];
}

- (NSImage *) icon
{	
	return _icon;
}
- (void) setIcon : (NSImage *) icon
{
	id temp = _icon;
	_icon = [icon retain];
	[temp release];
}
- (NSString *) name
{
	return _name;
}
- (void) setName : (NSString *) newName
{
	id temp = _name;
	_name = [newName retain];
	[temp release];
}

- (BOOL) hasURL
{
	return NO;
}
- (NSURL *) url
{
	[self doesNotRecognizeSelector : _cmd];
	
	return nil;
}
- (void) setURLString : (NSString *) urlString
{
	[self doesNotRecognizeSelector : _cmd];
}

- (BOOL) hasChildren
{
	return NO;
}
- (BoardListItem *) parentForItem : (BoardListItem *) item
{
	return nil;
}
- (unsigned) numberOfItem
{	
	return 0;
}
- (unsigned) indexOfItem : (id) item
{
	return NSNotFound;
}
- (id) itemAtIndex : (unsigned) index
{	
	return nil;
}
- (NSArray *) items
{
	return [NSArray array];
}
- (id) itemForName : (NSString *) name
{
	return [self itemForName : name deepSearch : NO];
}
- (id) itemForName : (NSString *) name deepSearch : (BOOL) isDeep
{
	return [self itemForName : name ofType : BoardListAnyTypeItem deepSearch : isDeep];
}
- (id) itemForRepresentName : (NSString *) name
{
	return [self itemForRepresentName : name deepSearch : NO];
}
- (id) itemForRepresentName : (NSString *) name deepSearch : (BOOL) isDeep
{
	return [self itemForName : name deepSearch : isDeep];
}
- (id) itemForName : (NSString *)name ofType: (BoardListItemType)type
{
	return [self itemForName : name ofType : type deepSearch : NO];
}

// primitive
- (id) itemForName : (NSString *)name ofType: (BoardListItemType)type deepSearch : (BOOL) isDeep
{
	return nil;
}
- (id) itemForRepresentName : (NSString *)name ofType: (BoardListItemType)type
{
	return [self itemForRepresentName : name ofType : type deepSearch : NO];
}
- (id) itemForRepresentName : (NSString *)name ofType: (BoardListItemType)type deepSearch : (BOOL) isDeep
{
	return [self itemForName : name ofType : type deepSearch : isDeep];
}

- (NSString *) representName
{
	return [self name];
}
- (void) setRepresentName : (NSString *) newRepresentName
{
	[self setName : newRepresentName];
}

- (id) description
{
	return [super description];
}
- (id)plist
{
	return [NSString stringWithFormat : @"%@ (%p)", NSStringFromClass([self class]), self];
}

#pragma mark## NSCoding protocol ##
- (void) encodeWithCoder : (NSCoder *) aCoder
{
	//
}
- (id) initWithCoder : (NSCoder *) aDecoder
{
	return [self init];
}

#pragma mark## CMRPropertyListCoding protocol ##
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	return [[[self alloc] initWithPropertyListRepresentation : rep] autorelease];
}
- (id) propertyListRepresentation
{
	NSLog(@"Enter <%@ : %p> <%@>", NSStringFromClass ([self class]) , self, NSStringFromSelector (_cmd) );
	[self doesNotRecognizeSelector : _cmd];
	return nil;
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	[self doesNotRecognizeSelector : _cmd];
	
	return nil;
}
- (BOOL) isHistoryEqual : (id) anObject
{
	if ([anObject isEqual : self]) return YES;
	
	if ([anObject isKindOfClass : [self class]]) return YES;
	
	return NO;
}

#ifdef DEBUG
- (id) objectForKey : (id) key
{
	NSLog(@"Enter <%@ : %p> <%@>", NSStringFromClass ([self class]) , self, NSStringFromSelector (_cmd) );
	return nil;
}
#endif
@end


@implementation BoardListItem (ThreadsList)

- (id <SQLiteCursor>) cursorForThreadList
{
	return nil;
}
- (NSString *) query
{
	return nil;
}

- (void) postUpdateThreadsNotification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center postNotificationName : BoardListItemUpdateThreadsNotification
						  object : self];
}
	
@end


@implementation BoardListItem (Creation)
+ (id) favoritesItem
{
	return [ConcreteBoardListItem favoritesItem];
}
+ (id) boardListItemWithFolderName : (NSString *) name
{
	return [ConcreteBoardListItem boardListItemWithFolderName : name];
}
+ (id) baordListItemWithBoradID : (unsigned) boardID
{
	return [ConcreteBoardListItem baordListItemWithBoradID : boardID];
}
+ (id) boardListItemWithURLString : (NSString *) urlString
{
	return [ConcreteBoardListItem boardListItemWithURLString : urlString];
}
+ (id) baordListItemWithName : (NSString *) name condition : (id) condition
{
	return [ConcreteBoardListItem baordListItemWithName : name condition : condition];
}
+ (id) baordListItemFromPlist : (id) plist
{
	return [ConcreteBoardListItem baordListItemFromPlist : plist];
}
- (id) initForFavorites
{
	NSLog(@"Oh! what do you do?") ;
	
	return nil;
}
- (id) initWithFolderName : (NSString *) name
{
	NSLog(@"Oh! what do you do?") ;
	
	return nil;
}
- (id) initWithBoardID : (unsigned) boardID
{
	NSLog(@"Oh! what do you do?") ;
	
	return nil;
}
- (id) initWithURLString : (NSString *) urlString
{
	NSLog(@"Oh! what do you do?") ;
	
	return nil;
}
- (id) initWithName : (NSString *) name condition : (id) condition;
{
	NSLog(@"Oh! what do you do?") ;
	
	return nil;
}
- (id) initWithContentsOfFile : (NSString *) path;
{
	NSLog(@"Oh! what do you do?") ;
	
	return nil;
}

@end

@implementation BoardListItem (TypeCheck)

+ (BOOL) isBoardItem : (BoardListItem *) item
{
	return [ConcreteBoardListItem isBoardItem : item];
}
+ (BOOL) isFavoriteItem : (BoardListItem *) item
{
	return [ConcreteBoardListItem isFavoriteItem : item];
}
+ (BOOL) isFolderItem : (BoardListItem *) item
{
	return [ConcreteBoardListItem isFolderItem : item];
}
+ (BOOL) isSmartItem : (BoardListItem *) item
{
	return [ConcreteBoardListItem isSmartItem : item];
}
+ (BOOL) isCategory : (BoardListItem *) item
{
	return [ConcreteBoardListItem isFolderItem : item];
}

+ (BoardListItemType) typeForItem : (BoardListItem *) item
{
	return [ConcreteBoardListItem typeForItem : item];
}
- (BoardListItemType) type
{
	return [BoardListItem typeForItem : self];
}
@end

@implementation BoardListItem (Mutable)

- (BOOL) isMutable
{
	return NO;
}
- (void) addItem : (BoardListItem *) item
{
	[self doesNotRecognizeSelector : _cmd];
}
- (void) insertItem : (BoardListItem *) item atIndex : (unsigned) index
{
	[self doesNotRecognizeSelector : _cmd];
}
- (void) insertItem : (BoardListItem *) item afterItem : (BoardListItem *) object
{
	[self insertItem : item afterItem : object deepSearch : NO];
}
- (void) insertItem : (BoardListItem *) item afterItem : (BoardListItem *) object deepSearch : (BOOL) isDeep
{
	[self doesNotRecognizeSelector : _cmd];
}
- (void) removeItem : (BoardListItem *) item
{
	[self removeItem : item deepSearch : NO];
}
- (void) removeItem : (BoardListItem *) item deepSearch : (BOOL) isDeep
{
	[self doesNotRecognizeSelector : _cmd];
}
- (void) removeItemAtIndex : (unsigned) index
{
	[self doesNotRecognizeSelector : _cmd];
}

- (void) postUpdateChildrenNotification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center postNotificationName : BoardListItemUpdateChildrenNotification
						  object : self];
}

@end
