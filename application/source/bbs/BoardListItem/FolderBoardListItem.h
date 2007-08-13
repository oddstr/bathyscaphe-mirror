//
//  FolderBoardListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BoardListItem.h"

@interface FolderBoardListItem : BoardListItem
{
	NSMutableArray *items;
}

- (id) initWithFolderName : (NSString *) name;

@end
