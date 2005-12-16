//
//  BSDBThreadList.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/19.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMRThreadsList.h"

#import <SQLiteDB.h>

@class BoardListItem;

@interface BSDBThreadList : CMRThreadsList
{
	id <SQLiteCursor> mCursor;
		
	BoardListItem *boardListItem;
	
	NSString *mSortKey;
	NSString *mSearchString;
	
	NSLock *cursorLock;
}

- (id) initWithBoardListItem : (BoardListItem *)item;
+ (id) threadListWithBoardListItem : (BoardListItem *)item;

- (id) boardListItem;

- (void) updateCursor;


@end
