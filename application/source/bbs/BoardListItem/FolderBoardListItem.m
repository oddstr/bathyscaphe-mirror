//
//  FolderBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "FolderBoardListItem.h"

#import "CMRBBSListTemplateKeys.h"

#import <SGAppKit/NSImage-SGExtensions.h>

static NSString *FolderBoardListItemItemsKey = @"FolderBoardListItemItemsKey";

@implementation FolderBoardListItem

- (id) initWithFolderName : (NSString *) inName
{
	if (self = [super init]) {
		[self setName : inName];
		items = [[NSMutableArray array] retain];
	}
	
	return self;
}
- (void) dealloc
{
	[items release];
	
	[super dealloc];
}

- (BOOL)isEqual:(id)other
{
	if(self == other) return YES;
	
	if([self class] != [other class]) return NO;
	if(![[self name] isEqualTo:[other name]]) return NO;
	if([self numberOfItem] != [other numberOfItem]) return NO;
	
	unsigned i, count;
	for(i = 0, count = [self numberOfItem]; i < count; i++) {
		if(![[self itemAtIndex:i] isEqual:[other itemAtIndex:i]]) return NO;
	}
	
	return YES;
}	

- (id) itemForName : (NSString *) name deepSearch : (BOOL) isDeep
{
	id result = nil;
	NSEnumerator *objEnum;
	id obj;
	
	// NON Thread safe.
	objEnum = [items objectEnumerator];
	while ((obj = [objEnum nextObject])) {
		if ([name isEqualTo : [obj name]]) {
			result = obj;
			break;
		}
		if (isDeep && [obj hasChildren]) {
			result = [obj itemForName : name deepSearch : YES];
		}
		if (result) break;
	}
	
	return result;
}
- (id) itemForRepresentName : (NSString *) name deepSearch : (BOOL) isDeep
{
	id result = nil;
	NSEnumerator *objEnum;
	id obj;
	
	// NON Thread safe.
	objEnum = [items objectEnumerator];
	while ((obj = [objEnum nextObject])) {
		if ([name isEqualTo : [obj representName]]) {
			result = obj;
			break;
		}
		if (isDeep && [obj hasChildren]) {
			result = [obj itemForRepresentName : name deepSearch : YES];
		}
		if (result) break;
	}
	
	return result;
}
// tsawada2 added 2007-02-10
- (id) itemWithRepresentNameHavingPrefix: (NSString *) prefix deepSearch: (BOOL) isDeep // For Type-To-Select search.
{
	id result = nil;
	NSEnumerator *objEnum;
	id obj;
	
	// NON Thread safe.
	objEnum = [items objectEnumerator];
	while ((obj = [objEnum nextObject])) {
		if ([[obj representName] hasPrefix : prefix]) {
			result = obj;
			break;
		}
		if (isDeep && [obj hasChildren]) {
			result = [obj itemWithRepresentNameHavingPrefix : prefix deepSearch : YES];
		}
		if (result) break;
	}
	
	return result;
}

- (id) itemForName : (NSString *) name ofType : (int) type deepSearch : (BOOL) isDeep
{
	id result = nil;
	NSEnumerator *objEnum;
	BoardListItem *obj;
	
	// NON Thread safe.
	objEnum = [items objectEnumerator];
	while ((obj = [objEnum nextObject])) {
		if ([name isEqualTo : [obj name]] && (type & [obj type])) {
			result = obj;
			break;
		}
		if (isDeep && [obj hasChildren]) {
			result = [obj itemForName : name ofType : type deepSearch : YES];
		}
		if (result) break;
	}
	
	return result;
}
- (id) itemForRepresentName : (NSString *) name ofType : (int) type deepSearch : (BOOL) isDeep
{
	id result = nil;
	NSEnumerator *objEnum;
	BoardListItem *obj;
	
	// NON Thread safe.
	objEnum = [items objectEnumerator];
	while ((obj = [objEnum nextObject])) {
		if ([name isEqualTo : [obj representName]] && (type & [obj type])) {
			result = obj;
			break;
		}
		if (isDeep && [obj hasChildren]) {
			result = [obj itemForRepresentName : name ofType : type deepSearch : YES];
		}
		if (result) break;
	}
	
	return result;
}

- (NSArray *) itemsWithoutFavoriteItem
{
	NSMutableArray *result = [NSMutableArray array];
	id obj;
	NSEnumerator *itesEnum = [items objectEnumerator];
	
	while ((obj = [itesEnum nextObject])) {
		if (![BoardListItem isFavoriteItem : obj]) {
			[result addObject : [obj plist]];
		}
	}
	
	return result;
}
	
- (id) description
{
	id result = nil;
	
	UTILDebugWrite(@"MUST change!!!") ;
	
	if ([[self name] isEqualTo : @"Top"]) {
		result = [self itemsWithoutFavoriteItem];
	} else {
		result = [[[NSDictionary alloc] initWithObjectsAndKeys : [self itemsWithoutFavoriteItem], BoardPlistContentsKey,
			[self name], BoardPlistNameKey, nil] autorelease];
	}
	
	return [result description];
}
- (id) plist
{
	id result = nil;
	
	UTILDebugWrite(@"MUST change!!!") ;
	
	if ([[self name] isEqualTo : @"Top"]) {
		result = [self itemsWithoutFavoriteItem];
	} else {
		result = [[[NSDictionary alloc] initWithObjectsAndKeys :
			[self itemsWithoutFavoriteItem], BoardPlistContentsKey,
			[self name], BoardPlistNameKey, nil] autorelease];
	}
	
	return result;
}
- (void) encodeWithCoder : (NSCoder *) aCoder
{
	[super encodeWithCoder : aCoder];
	[aCoder encodeObject : items forKey : FolderBoardListItemItemsKey];
}
- (id) initWithCoder : (NSCoder *) aDecoder
{
	if (self = [super initWithCoder : aDecoder]) {
		items = [[aDecoder decodeObjectForKey : FolderBoardListItemItemsKey] mutableCopy];
	}
	return self;
}

- (NSImage *) icon
{
	return [NSImage imageAppNamed : kCategoryImageName];
}

- (BOOL) hasChildren
{
	return ([self numberOfItem] == 0) ? NO : YES;
}
- (unsigned) numberOfItem
{
	return [items count];
}
- (id) itemAtIndex : (unsigned) index
{
	return [items objectAtIndex : index];
}
- (unsigned) indexOfItem : (id) item
{
	return [items indexOfObject : item];
}
- (NSArray *) items
{
	return [NSArray arrayWithArray : items];
}

- (BOOL) isMutable
{
	return YES;
}
- (void) addItem : (BoardListItem *) item
{
	[items addObject : item];
	[self postUpdateChildrenNotification];
}
- (void) insertItem : (BoardListItem *) item atIndex : (unsigned) index
{
	[items insertObject : item atIndex : index];
	[self postUpdateChildrenNotification];
}
- (BoardListItem *) parentForItem : (BoardListItem *) item
{
	if ([items containsObject : item]) {
		return self;
	}
	
	id result = nil;
	NSEnumerator *objEnum;
	id obj;
	
	// NON Thread safe.
	objEnum = [items objectEnumerator];
	while ((obj = [objEnum nextObject])) {
		if ([obj hasChildren]) {
			result = [obj parentForItem : item];
			if (result) break;
		}
	}
	
	return result;
}
//ツリー内に２つ以上のobjectがあった場合、早く見つかったものが対象となる。
// TODO 要変更
- (void) insertItem : (BoardListItem *) item afterItem : (BoardListItem *) object deepSearch : (BOOL) isDeep
{
	id obj;
	unsigned i, count;
	BOOL isInserted = NO;
	
	// NON Thread safe.
	count = [items count];
	for ( i = 0; i < count; i++ ) {
		obj = [items objectAtIndex : i];
		if ([object isEqual : obj]) {
			[items insertObject : item atIndex : i + i];
			isInserted = YES;
			break;
		}
		if (isDeep && [obj hasChildren]) {
			@try {
				[obj insertItem : item afterItem : object deepSearch : YES];
			}
			@catch(NSException *exception) {
				if (![NSRangeException isEqualTo : [exception name]]) {
					@throw;
				}
			}
			@catch(id exp) {
				@throw;
			}
		}
	}
	
	if (!isInserted) {
		[NSException raise : NSRangeException format : @"Not fount target (%@) .", object];
	}
	[self postUpdateChildrenNotification];
}
- (void) removeItem : (BoardListItem *) item deepSearch : (BOOL) isDeep
{
	BoardListItem *parent;
	
	if ([items containsObject : item]) {
		[items removeObject : item];
		[self postUpdateChildrenNotification];
		return;
	}
	
	if (!isDeep) return;
	
	parent = [self parentForItem : item];
	if (!parent) return;
	
	[parent removeItem : item];
	[self postUpdateChildrenNotification];
}
- (void) removeItemAtIndex : (unsigned) index
{	
	[items removeObjectAtIndex : index];
	[self postUpdateChildrenNotification];
}

@end
