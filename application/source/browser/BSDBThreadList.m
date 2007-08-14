//
//  BSDBThreadList.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/19.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSDBThreadList.h"

#import "CMRThreadsList_p.h"
#import "missing.h"
#import "BSDateFormatter.h"

#import "BSThreadListUpdateTask.h"
#import "BSThreadsListOPTask.h"
#import "BSBoardListItemHEADCheckTask.h"
#import "BoardListItem.h"
#import "DatabaseManager.h"
#import "BSThreadListItem.h"

NSString *BSDBThreadListDidFinishUpdateNotification = @"BSDBThreadListDidFinishUpdateNotification";


@interface BSDBThreadList (Private)
- (void)setSortDescriptors:(NSArray *)inDescs;
- (void)addSortDescriptor:(NSSortDescriptor *)inDesc;
- (void) filterByStatusWithoutUpdateList: (int) status;
@end
@interface BSDBThreadList (ToBeRefactoring)
@end

@implementation BSDBThreadList

// primitive
- (id)initWithBoardListItem : (BoardListItem *) item
{
	self = [super init];
	if (self) {
		[self setBBSName : [item name]];
		[self setBoardListItem:item];
		
//		[self filterByStatusWithoutUpdateList:[CMRPref browserStatusFilteringMask]];
		[self filterByStatusWithoutUpdateList:0];
		
		mCursorLock = [[NSLock alloc] init];
		mTaskLock = [[NSLock alloc] init];
	}
	
	return self;
}
- (id) initWithBBSName : (NSString *) boardName
{
	BoardListItem *item;
	
	UTILAssertNotNilArgument(boardName, @"boardName");
	
	if ([boardName isEqualTo : CMXFavoritesDirectoryName]) {
		item = [BoardListItem favoritesItem];
	} else {
		NSArray *boardIDs;
		unsigned boardID;
		
		boardIDs = [[DatabaseManager defaultManager] boardIDsForName : boardName];
		if (!boardIDs || ![boardIDs count]) {
			NSLog(@"Not found board named %@", boardName);
			return nil;
		}
		
		/* TODO 複数あった場合の処理 */
		
		boardID = [[boardIDs objectAtIndex : 0] unsignedIntValue];
		item = [BoardListItem baordListItemWithBoradID : boardID];
	}
	
	return [self initWithBoardListItem : item];
}
+ (id)threadListWithBoardListItem : (BoardListItem *) item
{
	return [[[self alloc] initWithBoardListItem : item] autorelease];
}
- (void) dealloc
{
	[mCursor release];
	mCursor = nil;
	[mCursorLock release];
	mCursorLock = nil;
	[mBoardListItem release];
	mBoardListItem = nil;
	[mSortKey release];
	mSortKey = nil;
	[mSearchString release];
	mSearchString = nil;
	
	[mTask cancel:self];
	[mTask autorelease];
	[mUpdateTask cancel:self];
	[mUpdateTask autorelease];
	[mTaskLock release];
	
	[mSortDescriptors release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

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
	
	[super registerToNotificationCenter];
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
	[nc removeObserver : self
				  name : BSThreadListUpdateTaskDidFinishNotification
				object : nil];

	[super removeFromNotificationCenter];
}

#pragma mark## Accessor ##
- (void)setBoardListItem:(BoardListItem *)item
{
	id temp = mBoardListItem;
	mBoardListItem = [item retain];
	[temp release];
	
	temp = [[BoardManager defaultManager] sortDescriptorsForBoard : [self boardName]];
	[self setSortDescriptors:temp];	
}

- (BOOL)isFavorites
{
	return [BoardListItem isFavoriteItem : [self boardListItem]];
}
- (BOOL)isSmartItem
{
	return [BoardListItem isSmartItem : [self boardListItem]];
}
- (id) boardListItem
{
	return mBoardListItem;
}
- (id) searchString
{
	return mSearchString;
}
- (ThreadStatus) status
{
	return mStatus;
}
- (NSString *) boardName
{
	if (mBoardListItem) {
		return [mBoardListItem name];
	}
	
	return [super boardName];
}

- (unsigned) numberOfThreads
{
	unsigned count;
	
	@synchronized(mCursorLock) {
		count = [mCursor count];
	}
	
	return count;
}
- (unsigned) numberOfFilteredThreads
{
	return [self numberOfThreads];
}

- (BSThreadsListViewModeType)viewMode
{
	return mViewMode;
}

- (void)setViewMode:(BSThreadsListViewModeType)mode
{
	mViewMode = mode;
}

#pragma mark## Sorting ##
- (id) sortKey
{
	return mSortKey;
}
- (void) setSortKey : (NSString *) key
{
	id tmp = mSortKey;
	mSortKey = [key retain];
	[tmp release];
	
	{
		id sortDescriptor;
		
		sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:tableNameForKey(mSortKey)
													  ascending:[self isAscending]
													   selector:@selector(numericCompare:)] autorelease];
		
		[self addSortDescriptor:sortDescriptor];
	}
}
- (void) sortByKey : (NSString *) key
{
	// お気に入りとスマートボードではindexは飾り
	// TODO 要変更
	if([self isFavorites] || [self isSmartItem]) {
		if([key isEqualTo : CMRThreadSubjectIndexKey]) {
			return;
		}
	}
	
	[self setSortKey:key];
	[self updateCursor];
}
- (NSArray *)sortDescriptors
{
	return [NSArray arrayWithArray:mSortDescriptors];
}
- (void)setSortDescriptors:(NSArray *)inDescs
{
	UTILAssertKindOfClass(inDescs, NSArray);
	
	id temp = mSortDescriptors;
	mSortDescriptors = [[NSMutableArray arrayWithArray:inDescs] retain];
	[temp release];
}
- (void)setSortDescriptor:(NSSortDescriptor *)inDesc
{
	UTILAssertKindOfClass(inDesc, NSSortDescriptor);
	
	id temp = mSortDescriptors;
	mSortDescriptors = [[NSMutableArray arrayWithObject:inDesc] retain];
	[temp release];
}
- (void)addSortDescriptor:(NSSortDescriptor *)inDesc
{
	UTILAssertKindOfClass(inDesc, NSSortDescriptor);
	
	if(!mSortDescriptors) {
		mSortDescriptors = [[NSMutableArray array] retain];
	}
	
	// remove sortdescriptor has same key.
	id key = [inDesc key];
	int i, c; id o;
	for(i = 0,c = [mSortDescriptors count]; i < c; i++) {
		o = [mSortDescriptors objectAtIndex:i];
		
		if([key isEqual:[o key]]) {
			[mSortDescriptors removeObjectAtIndex:i];
			break;
		}
	}
	
	[mSortDescriptors insertObject:inDesc atIndex:0];
}
- (BOOL)isAscendingForKey:(NSString *)key
{
	id enume;
	NSSortDescriptor *sortDesc;
	NSString *sortKey = tableNameForKey(key);
	
	if(!sortKey) return NO;
	
	enume = [mSortDescriptors objectEnumerator];
	while(sortDesc = [enume nextObject]) {
		if([sortKey isEqualTo:[sortDesc key]]) {
			return [sortDesc ascending];
		}
	}
	
	return NO;
}
- (void)toggleIsAscendingForKey:(NSString *)key
{
	id enume;
	NSSortDescriptor *sortDesc;
	NSSortDescriptor *newDesc = nil;
	NSString *sortKey = tableNameForKey(key);
	
	if(!sortKey) return;
	
	enume = [mSortDescriptors objectEnumerator];
	while(sortDesc = [enume nextObject]) {
		if([sortKey isEqualTo:[sortDesc key]]) {
			newDesc = [sortDesc reversedSortDescriptor];
			break;
		}
	}
	
	if(newDesc) {
		[self addSortDescriptor:newDesc];
	}
	
	return;
}

#pragma mark## Thread item operations ##
- (void) updateCursor
{
	@synchronized(self) {
		if(mUpdateTask) {
			if([mUpdateTask isInProgress]) {
				[mUpdateTask cancel:self];
			}
			[[NSNotificationCenter defaultCenter]
				removeObserver:self
						  name:BSThreadListUpdateTaskDidFinishNotification
						object:mUpdateTask];
			[mUpdateTask release];
			mUpdateTask = nil;
		} 
		{
			mUpdateTask = [[BSThreadListUpdateTask taskWithBSDBThreadList:self] retain];
			
			[[NSNotificationCenter defaultCenter]
			addObserver:self
			   selector:@selector(didFinishiCreateCursor:)
				   name:BSThreadListUpdateTaskDidFinishNotification
				 object:mUpdateTask];
		}
		[[self worker] push:mUpdateTask];
	}
}

- (void)setCursorOnMainThread:(id)cursor
{
	if(cursor) {
		@synchronized(mCursorLock) {
			[mCursor autorelease];
			mCursor = [[BSThreadListItem threadItemArrayFromCursor:cursor] retain];
			UTILDebugWrite1(@"cursor count -> %ld", [mCursor count]);
		}
	}
	
	UTILNotifyName(CMRThreadsListDidChangeNotification);
	UTILNotifyName(BSDBThreadListDidFinishUpdateNotification);
}
- (void)didFinishiCreateCursor:(id)notification
{
	id obj = [notification object];
	
	if(![obj isKindOfClass:[BSThreadListUpdateTask class]]) {
		return;
	}
	
	id temp = [[[obj cursor] retain] autorelease];	
	
	[self performSelectorOnMainThread:@selector(setCursorOnMainThread:)
						   withObject:temp
						waitUntilDone:YES];
}

#pragma mark## Filter ##
- (BOOL) filterByString : (NSString *)string
{
	id tmp = mSearchString;
	mSearchString = [string retain];
	[tmp release];
	
	[self updateCursor];
	
	return YES;
}

- (void) filterByStatusWithoutUpdateList: (int) status
{
	mStatus = status;
}
- (void) filterByStatus : (int) status
{
	[self filterByStatusWithoutUpdateList:status];
	[self updateCursor];
}

#pragma mark## DataSource ##
- (NSDictionary *)paragraphStyleAttrForIdentifier : (NSString *)identifier
{
	static NSMutableParagraphStyle *style_ = nil;
	
	NSDictionary *result = nil;
	
	if(!style_) {
		// 長過ぎる内容を「...」で省略
		style_ = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[style_ setLineBreakMode : NSLineBreakByTruncatingTail];
	}
	
	if([identifier isEqualToString : ThreadPlistIdentifierKey]) {
		result = [[self class] threadCreatedDateAttrTemplate];
	} else if([identifier isEqualToString : LastWrittenDateColumn]) {
		result = [[self class] threadLastWrittenDateAttrTemplate];
	} else if([identifier isEqualToString : CMRThreadModifiedDateKey]) {
		result = [[self class] threadModifiedDateAttrTemplate];
	} else {
		result = [NSDictionary dictionaryWithObjectsAndKeys:style_, NSParagraphStyleAttributeName, nil];
	}
	
	return result;
}

- (NSDictionary *) threadAttributesAtRowIndex : (int          ) rowIndex
                                  inTableView : (NSTableView *) tableView
{
	BSThreadListItem *row;
	
	@synchronized(mCursorLock) {
		row = [[[mCursor objectAtIndex : rowIndex] retain] autorelease];
	}
	
	return [row attribute];
}
- (unsigned int) indexOfThreadWithPath : (NSString *) filepath
{
	unsigned result;
	CMRDocumentFileManager *dfm = [CMRDocumentFileManager defaultManager];
	NSString *identifier = [dfm datIdentifierWithLogPath : filepath];
	
	@synchronized(mCursorLock) {
		result = indexOfIdentifier(mCursor, identifier);
	}
	
	return result;
}

- (int)numberOfRowsInTableView : (NSTableView *)tableView
{
	UTILDebugWrite1(@"numberOfRowsInTableView -> %ld", [self numberOfFilteredThreads]);
	
	return [self numberOfFilteredThreads];
}

- (id) objectValueForIdentifier : (NSString *) identifier
					threadArray : (NSArray  *) threadArray
						atIndex : (int       ) index
{
	BSThreadListItem *row;
	id result = nil;
	ThreadStatus s;
	
	@synchronized(mCursorLock) {
		row = [[[mCursor objectAtIndex : index] retain] autorelease];
	}
	
	s = [row status];
	
	if ( [identifier isEqualTo : CMRThreadSubjectIndexKey] ) {
		result = [row threadNumber];
		if(!result || result == [NSNull null]) {
			result = [NSNumber numberWithInt:index + 1];
		}
	} else {
		result = [row valueForKey : identifier];
	}
	
	// パラグラフスタイルを設定。
	if(nil != result && ![result isKindOfClass : [NSImage class]]) {
		id attr = [self paragraphStyleAttrForIdentifier:identifier];
		if([result isKindOfClass : [NSDate class]]) {
			result = [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue: result
																	 withDefaultAttributes: attr];
		} else {
			result = [[[NSMutableAttributedString alloc] initWithString : [result stringValue]
															 attributes : attr] autorelease];
		}
	}
	
	// Font and Color を設定。
	int type = (s == ThreadNewCreatedStatus) 
		? kValueTemplateNewArrivalType
		: kValueTemplateDefaultType;
	if([row isDatOchi]) {
		type = kValueTemplateDatOchiType;
	}
	result = [[self class] objectValueTemplate : result
									   forType : type];
	
	return result;
}
- (id)            tableView : (NSTableView   *) aTableView
  objectValueForTableColumn : (NSTableColumn *) aTableColumn
                        row : (int            ) rowIndex
{
	NSString		*identifier_ = [aTableColumn identifier];
	
    if ([identifier_ isEqualToString: ThreadPlistIdentifierKey] ||
        [identifier_ isEqualToString: CMRThreadModifiedDateKey] || [identifier_ isEqualToString: LastWrittenDateColumn])
    {
        float location_ = [aTableColumn width];
        location_ -= [aTableView intercellSpacing].width * 2;
        [[self class] resetDataSourceTemplateForColumnIdentifier: identifier_ width: location_];
    }
	
	return [self objectValueForIdentifier: identifier_ threadArray: nil atIndex: rowIndex];
}

#pragma mark## Notification ##
- (void)favoritesManagerDidChange : (id) notification
{
	UTILAssertNotificationObject(
								 notification,
								 [CMRFavoritesManager defaultManager]);
	[self updateCursor];
	
	UTILNotifyName(CMRThreadsListDidChangeNotification);
}


- (void) postListDidUpdateNotification : (int) mask;
{
	id		obj_;
	
	obj_ = [NSNumber numberWithUnsignedInt : mask];
	UTILNotifyInfo3(
					CMRThreadsListDidUpdateNotification,
					obj_,
					ThreadsListUserInfoSelectionHoldingMaskKey);
	UTILNotifyName(CMRThreadsListDidChangeNotification);
}

#pragma mark## SearchThread ##
+ (NSMutableDictionary *) attributesForThreadsListWithContentsOfFile : (NSString *) filePath
{
	return [[[[BSThreadListItem threadItemWithFilePath:filePath] attribute] mutableCopy] autorelease];
}
- (NSMutableDictionary *)seachThreadByPath : (NSString *)filePath
{
	return [[self class] attributesForThreadsListWithContentsOfFile:filePath];
}

@end

@implementation BSDBThreadList (ToBeRefactoring)
/*
- (void) filterByDisplayingThreadAtPath : (NSString *) filepath
{
	// TODO
	NSLog(@"Should implement this!! (%@)", NSStringFromSelector(_cmd));
}*/
#pragma mark## Download ##
- (void) loadAndDownloadThreadsList : (CMRThreadLayout *) worker forceDownload : (BOOL) forceDL
{
	//　既に起動中の更新タスクを強制終了させる
	[mTaskLock lock];
	if(mTask) {
		if([mTask isInProgress]) {
			[mTask cancel:self];
		}
		[mTask release];
		mTask = nil;
	}
	[mTaskLock unlock];
	
	if( [self isFavorites] || [self isSmartItem] ) {
		if(forceDL) {
			[mTaskLock lock];
			mTask = [[BSBoardListItemHEADCheckTask alloc] initWithThreadList:self];
			[worker push:mTask];
			[mTaskLock unlock];
		} else {
			[self updateCursor];
		}
	} else {
		[mTaskLock lock];
		mTask = [[BSThreadsListOPTask alloc] initWithThreadList:self forceDownload:forceDL];
		[worker push : mTask];
		[mTaskLock unlock];
	}
}
- (void) doLoadThreadsList : (CMRThreadLayout *) worker
{
	[self setWorker : worker]; // ????
	[self loadAndDownloadThreadsList : worker forceDownload : NO];
}
- (void) downloadThreadsList
{
	[self loadAndDownloadThreadsList : [self worker] forceDownload : YES];
}
@end
