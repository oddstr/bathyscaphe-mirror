//
//  FavoritesBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "FavoritesBoardListItem.h"

#import "DatabaseManager.h"
#import "CMRBBSListTemplateKeys.h"
#import "misc.h"

@implementation FavoritesBoardListItem

-(id)init
{
	if( self = [super init] ) {
		[self setQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ IN (SELECT %@ FROM %@)", ThreadInfoTableName, ThreadIDColumn, ThreadIDColumn, FavoritesTableName]];
	}
	
	return self;
}

-(NSImage *)icon
{
	return [NSImage imageAppNamed : kFavoritesImageName];
}

-(NSString *)name
{
	return CMXFavoritesDirectoryName;
}
-(void)setName:(NSString *)newName
{
	//
}

@end
