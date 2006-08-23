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

#import "CMRTask.h"

@class BoardListItem;

@interface BSDBThreadList : CMRThreadsList
{
	id <SQLiteMutableCursor> mCursor;
		
	BoardListItem *mBoardListItem;
	
	NSString *mSortKey;
	NSString *mSearchString;
	ThreadStatus mStatus;
	
	NSLock *mCursorLock;
	
	id<CMRTask> mTask;
	NSLock *mTaskLock;
	
	id<CMRTask> mUpdateTask;
	
	id mSortDescriptors;
}

- (id) initWithBoardListItem : (BoardListItem *)item;
+ (id) threadListWithBoardListItem : (BoardListItem *)item;

- (void)setBoardListItem:(BoardListItem *)item;
- (id) boardListItem;
- (id) searchString;
- (id) sortKey;
- (ThreadStatus) status;

- (void) updateCursor;


@end
