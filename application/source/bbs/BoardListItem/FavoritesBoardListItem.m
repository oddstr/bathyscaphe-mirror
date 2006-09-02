//
//  FavoritesBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "FavoritesBoardListItem.h"

#import "BoardBoardListItem.h"

#import "DatabaseManager.h"
#import "CMRBBSListTemplateKeys.h"
#import <SGAppKit/NSImage-SGExtensions.h>

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
		NSMutableString *query = [NSMutableString string];
		[query appendFormat : @"SELECT * FROM %@\n", BoardThreadInfoViewName];
		[query appendFormat : @"WHERE %@ IN (SELECT %@ FROM %@) ",
			ThreadIDColumn, ThreadIDColumn, FavoritesTableName];
		[self setQuery : query];
	}
	
	return self;
}

- (id) retain { return self; }
- (oneway void) release {}
- (unsigned) retainCount { return UINT_MAX; }

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
