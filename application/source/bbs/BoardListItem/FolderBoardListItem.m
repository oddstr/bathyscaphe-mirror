//
//  FolderBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "FolderBoardListItem.h"

#import "CMRBBSListTemplateKeys.h"

static NSString *FolderBoardListItemItemsKey = @"FolderBoardListItemItemsKey";
static NSString *FolderBoardListItemNameKey = @"FolderBoardListItemNameKey";

@implementation FolderBoardListItem

-(id)initWithFolderName:(NSString *)inName
{
	if( self = [super init] ) {
		items = [[NSMutableArray array] retain];
		[self setName:inName];
	}
	
	return self;
}

-(void)dealloc
{
	[items release];
	[name release];
	
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:name forKey:FolderBoardListItemNameKey];
	[aCoder encodeObject:items forKey:FolderBoardListItemItemsKey];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if( self = [super initWithCoder:aDecoder] ) {
		[self setName:[aDecoder decodeObjectForKey:FolderBoardListItemNameKey]];
		items = [[aDecoder decodeObjectForKey:FolderBoardListItemItemsKey] mutableCopy];
	}
	return self;
}

-(NSImage *)icon
{
	return [NSImage imageAppNamed : kCategoryImageName];
}
-(NSString *)name
{
	return name;
}
-(void)setName:(id)newName
{
	id temp = name;
	
	name = [newName copy];
	[temp release];
}

-(BOOL)hasChildren
{
	return YES;
}
-(unsigned)numberOfItem
{
	return [items count];
}
-(id)itemAtIndex:(unsigned)index
{
	return [items objectAtIndex:index];
}

-(BOOL)isMutable
{
	return YES;
}
-(void)addItem:(BoardListItem *)item
{
	[items addObject:item];
	[self postUpdateChildrenNotification];
}
-(void)insertItem:(BoardListItem *)item atIndex:(unsigned)index
{
	[items insertObject:item atIndex:index];
	[self postUpdateChildrenNotification];
}
-(void)removeItem:(BoardListItem *)item
{
	[items removeObject:item];
	[self postUpdateChildrenNotification];
}
-(void)removeItemAtIndex:(unsigned)index
{
	[items removeObjectAtIndex:index];
	[self postUpdateChildrenNotification];
}

@end
