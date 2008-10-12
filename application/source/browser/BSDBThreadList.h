//
//  BSDBThreadList.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/19.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
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
	
//	NSString *mSortKey;
	NSString *mSearchString;
//	ThreadStatus mStatus;
	BSThreadsListViewModeType mViewMode;
	
	NSLock *mCursorLock;
	
	id<CMRThreadLayoutTask> mTask;
	NSLock *mTaskLock;
	
	id<CMRThreadLayoutTask> mUpdateTask;
	
	NSArray *mSortDescriptors;
}

- (id)initWithBoardListItem:(BoardListItem *)item;
+ (id)threadListWithBoardListItem:(BoardListItem *)item;

- (void)setBoardListItem:(BoardListItem *)item;
- (id)boardListItem;
- (id)searchString;
//- (id) sortKey;
- (NSArray *)sortDescriptors;
- (void)setSortDescriptors:(NSArray *)inDescs;
//- (BOOL)isAscendingForKey:(NSString *)key;
//- (void)toggleIsAscendingForKey:(NSString *)key;
//- (ThreadStatus) status;

- (void)updateCursor;
- (void)updateFilteredThreadsIfNeeded;
- (BSThreadsListViewModeType)viewMode;
- (void)setViewMode:(BSThreadsListViewModeType)mode;
@end

extern NSString *BSDBThreadListDidFinishUpdateNotification;
