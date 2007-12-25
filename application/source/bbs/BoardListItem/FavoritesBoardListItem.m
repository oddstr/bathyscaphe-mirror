//
//  FavoritesBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "FavoritesBoardListItem.h"

#import "BoardBoardListItem.h"

#import "DatabaseManager.h"
#import "CMRBBSListTemplateKeys.h"
#import "CMRFavoritesManager.h"
#import <SGAppKit/NSImage-SGExtensions.h>

@interface FavoritesBoardListItem (BSPrivate)
- (void) favoritesManagerDidChange : (id) notification;
- (void) setDirty : (BOOL) inDirty;
- (BOOL) dirty;
- (void) registerToNotificationCenter;
@end

@implementation FavoritesBoardListItem
//APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance) ;
+ (id) sharedInstance
{
	static id _sharedInstance = nil;
	
	if (!_sharedInstance) {
		_sharedInstance = [[self alloc] init];
	}
	
	return _sharedInstance;
}

- (id) init
{
	if (self = [super init]) {
		[self registerToNotificationCenter];
		NSMutableString *query = [NSMutableString string];
		[query appendFormat : @"SELECT * FROM %@ WHERE %@ = 1",
			BoardThreadInfoViewName, IsFavoriteColumn];
		[self setQuery : query];
	}

	return self;
}

- (id) retain { return self; }
- (oneway void) release {}
- (unsigned) retainCount { return UINT_MAX; }

- (BOOL)isEqual:(id)other
{
	return (self == other);
}

- (NSImage *) icon
{
	return [NSImage imageAppNamed : kFavoritesImageName];
}

- (NSString *) name
{
	return CMXFavoritesDirectoryName;
}
- (void) setName : (NSString *) newName
{
	//
}

- (id <SQLiteCursor>) cursorForThreadList
{
	if(!items || [self dirty]) {
		items = [super cursorForThreadList];
	}
	
	return items;
}

- (void) favoritesManagerDidChange : (id) notification
{
	UTILAssertNotificationObject(
								 notification,
								 [CMRFavoritesManager defaultManager]);
	[self setDirty : YES];
}
- (void) setDirty : (BOOL) inDirty
{
	if((dirty && inDirty) || (!dirty && !inDirty)) return;
	
	dirty = inDirty;
}
- (BOOL) dirty
{
	return dirty;
}

#pragma mark## Notifications ##
- (void) registerToNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(favoritesManagerDidChange:)
	            name : CMRFavoritesManagerDidLinkFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(favoritesManagerDidChange:)
	            name : CMRFavoritesManagerDidRemoveFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
}
- (void) removeFromNotificationCenter
{
	id nc = [NSNotificationCenter defaultCenter];
	
	[nc removeObserver : self
				  name : CMRFavoritesManagerDidLinkFavoritesNotification
				object : [CMRFavoritesManager defaultManager]];
	[nc removeObserver : self
				  name : CMRFavoritesManagerDidRemoveFavoritesNotification
				object : [CMRFavoritesManager defaultManager]];
}

#pragma mark## CMRPropertyListCoding protocol ##
//+ (id) objectWithPropertyListRepresentation : (id) rep
//{
//	return [[[self alloc] initWithPropertyListRepresentation : rep] autorelease];
//}
- (id) propertyListRepresentation
{
	return [self name];
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	[self release];
	
	return [[self class] sharedInstance];
}
@end
