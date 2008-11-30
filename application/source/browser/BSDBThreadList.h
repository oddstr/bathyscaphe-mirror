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
	NSLock *mCursorLock;
		
	BoardListItem *mBoardListItem;
	NSString *mSearchString;
	
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
- (NSArray *)sortDescriptors;
- (void)setSortDescriptors:(NSArray *)inDescs;

- (void)updateCursor;
- (void)updateFilteredThreadsIfNeeded;
@end

extern NSString *BSDBThreadListDidFinishUpdateNotification;
