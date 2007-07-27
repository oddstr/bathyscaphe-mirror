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

#import "CMRThreadLayoutTask.h"

@class BoardListItem;

@interface BSDBThreadList : CMRThreadsList
{
	id mCursor;
		
	BoardListItem *mBoardListItem;
	
	NSString *mSortKey;
	NSString *mSearchString;
	ThreadStatus mStatus;
	BSThreadsListViewModeType mViewMode;
	
	NSLock *mCursorLock;
	
	id<CMRThreadLayoutTask> mTask;
	NSLock *mTaskLock;
	
	id<CMRThreadLayoutTask> mUpdateTask;
	
	id mSortDescriptors;
}

- (id) initWithBoardListItem : (BoardListItem *)item;
+ (id) threadListWithBoardListItem : (BoardListItem *)item;

- (void)setBoardListItem:(BoardListItem *)item;
- (id) boardListItem;
- (id) searchString;
- (id) sortKey;
- (NSArray *)sortDescriptors;
- (BOOL)isAscendingForKey:(NSString *)key;
- (void)toggleIsAscendingForKey:(NSString *)key;
- (ThreadStatus) status;

- (void) updateCursor;

- (BSThreadsListViewModeType)viewMode;
- (void)setViewMode:(BSThreadsListViewModeType)mode;
@end

extern NSString *BSDBThreadListDidFinishUpdateNotification;
