//
//  AbstractDBBoardListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BoardListItem.h"

#import <SQLiteDB.h>


@interface AbstractDBBoardListItem : BoardListItem
{	
	NSString *mQuery;
}

// setting up QuickLiteCursor.
- (void) setQuery: (NSString *) query;
- (NSString *) query;

@end
