//
//  BoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/16.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "BoardListItem.h"

// SledgeHammer ‚Å‚Í‚Ü‚¾Žg—p‚µ‚È‚¢
//#import "DatabaseManager.h"

@interface ConcreteBoardListItem : BoardListItem
+(id)sharedInstance;
@end


NSString *BoardListItemUpdateChildrenNotification = @"BoardListItemUpdateChildrenNotification";
NSString *BoardListItemUpdateThreadsNotification = @"BoardListItemUpdateThreadsNotification";

@implementation BoardListItem

+(id)allocWithZone:(NSZone *)zone
{
	if( [self class] == [BoardListItem class] ) {
		return [ConcreteBoardListItem sharedInstance];
	}
	
	return [super allocWithZone:zone];
}

-(NSImage *)icon
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
}
-(NSString *)name
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
}
-(void)setName:(NSString *)newName
{
	[self doesNotRecognizeSelector:_cmd];
}

-(BOOL)hasURL
{
	return NO;
}
-(NSString *)url
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
}
-(void)setURLString:(NSString *)urlString
{
	[self doesNotRecognizeSelector:_cmd];
}

-(BOOL)hasChildren
{
	return NO;
}
-(unsigned)numberOfItem
{	
	return 0;
}
-(id)itemAtIndex:(unsigned)index
{	
	return nil;
}

-(id)propertyListRepresentation
{
	NSLog(@"Enter <%@:%p> <%@>", NSStringFromClass([self class]), self,NSStringFromSelector(_cmd));
	return self;
}

#pragma mark## NSCoding protocol ##
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	//
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	return [self init];
}
@end

/*
@implementation BoardListItem (ThreadsList)

-(id <SQLiteCursor>)cursorForThreadList
{
	return nil;
}
-(NSString *)query
{
	return nil;
}

-(void)postUpdateThreadsNotification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center postNotificationName:BoardListItemUpdateThreadsNotification
						  object:self];
}
	
@end
*/

@implementation BoardListItem (Creation)
-(id)initForFavorites
{
	NSLog(@"Oh! what do you do?");
	
	return nil;
}
-(id)initWithFolderName:(NSString *)name
{
	NSLog(@"Oh! what do you do?");
	
	return nil;
}
-(id)initWithBoardID:(unsigned)boardID
{
	NSLog(@"Oh! what do you do?");
	
	return nil;
}
-(id)initWithName:(NSString *)name condition:(id)condition;
{
	NSLog(@"Oh! what do you do?");
	
	return nil;
}
-(id)initWithContentsOfFile:(NSString *)path;
{
	NSLog(@"Oh! what do you do?");
	
	return nil;
}

@end

@implementation BoardListItem (Mutable)

-(BOOL)isMutable
{
	return NO;
}
-(void)addItem:(BoardListItem *)item
{
	[self doesNotRecognizeSelector:_cmd];
}
-(void)insertItem:(BoardListItem *)item atIndex:(unsigned)index
{
	[self doesNotRecognizeSelector:_cmd];
}
-(void)removeItem:(BoardListItem *)item
{
	[self doesNotRecognizeSelector:_cmd];
}
-(void)removeItemAtIndex:(unsigned)index
{
	[self doesNotRecognizeSelector:_cmd];
}

-(void)postUpdateChildrenNotification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center postNotificationName:BoardListItemUpdateChildrenNotification
						  object:self];
}

@end

@class FavoritesBoardListItem, SmartBoardListItem, FolderBoardListItem, BoardBoardListItem;

static ConcreteBoardListItem *_sharedInstance;

@implementation ConcreteBoardListItem

+(id)sharedInstance
{
	if( !_sharedInstance ) {
		_sharedInstance = [[self alloc] init];
	}
	
	return _sharedInstance;
}

-(id)retain { return self; }
-(oneway void)release {}
-(unsigned)retainCount { return UINT_MAX; }

-(id)initForFavorites
{
	return [[FavoritesBoardListItem alloc] init];
}
-(id)initWithFolderName:(NSString *)name
{
	return [[FolderBoardListItem alloc] initWithFolderName:name];
}
-(id)initWithBoardID:(unsigned)boardID
{
	return [[BoardBoardListItem alloc] initWithBoardID:boardID];
}
-(id)initWithName:(NSString *)name condition:(id)condition
{
	return [[SmartBoardListItem alloc] initWithName:name condition:condition];
}


-(BoardListItem *)folderItemFromPlist:(NSDictionary *)plist
{
	BoardListItem *result;
	NSString *name;
	NSArray *contents;
	int i, count;
	DatabaseManager *dbm = [DatabaseManager defaultManager];
	
	name = [plist objectForKey:@"Name"];
	if( !name ) return nil;
	contents = [plist objectForKey:@"Contents"];
	if( !contents ) return nil;
	
	result = [[[BoardListItem alloc] initWithFolderName:name] autorelease];
	
	count = [contents count];
	for( i = 0; i < count; i++ ) {
		id item = [contents objectAtIndex:i];
		NSString *boardName;
		NSString *url;
		unsigned boardID;
		BoardListItem *boardItem;
		
		if( !item ) continue;
		
		boardName = [item objectForKey:@"Name"];
		url = [item objectForKey:@"URL"];
		
		boardID = [dbm boardIDForURLString:url];
		if( NSNotFound == boardID ) {
			BOOL isOK = [dbm registerBoardName:boardName URLString:url];
			boardID = [dbm boardIDForURLString:url];
			if( !isOK || NSNotFound == boardID ) {
				NSLog(@"Fail Import Board. %@", item );
				continue;
			}
		}
		
		boardItem = [[[BoardListItem alloc] initWithBoardID:boardID] autorelease];
		[boardItem setName:boardName];
		[result addItem:boardItem];
	}
	
	return result;
}
		

-(id)initWithContentsOfFile:(NSString *)path;
{
	id result = nil;
	NSArray *array;
	NSEnumerator *elemsEnum;
	id object;
	
	SQLiteDB *db;
	
	result = [[BoardListItem alloc] initWithFolderName:@"Top"];
	
	array = [NSArray arrayWithContentsOfFile:path];
	if( !array ) {
		NSLog(@"File Import BoardListFile. %@", path);
		goto final;
	}
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if( !db ) {
		return nil;
	}
	
	if( [db beginTransaction] ) {
		elemsEnum = [array objectEnumerator];
		while( object = [elemsEnum nextObject] ) {
			id item;
			
			item = [self folderItemFromPlist:object];
			if( item ) {
				[result addItem:item];
			}
		}
		[db commitTransaction];
	}
	
final:
	
	return result;
}
@end

