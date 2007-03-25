//
//  BSDBThreadList.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/19.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "BSDBThreadList.h"

#import "CMRThreadsList_p.h"
#import "CMRThreadViewer.h"
#import "ThreadTextDownloader.h"
#import "missing.h"
#import "BSDateFormatter.h"

#import "BSThreadListUpdateTask.h"
#import "BSThreadsListOPTask.h"
#import "BSBoardListItemHEADCheckTask.h"
#import "BoardListItem.h"
#import "DatabaseManager.h"
#import "BSThreadListItem.h"

#import <sys/time.h>

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
		
		[self filterByStatusWithoutUpdateList:[CMRPref browserStatusFilteringMask]];
		
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
		
		sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:sortKeyForKey(mSortKey)
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
	NSString *sortKey = sortKeyForKey(key);
	
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
	NSString *sortKey = sortKeyForKey(key);
	
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
static double t1, t2;
double debug_clock2()
{
	double t;
	struct timeval tv;
	gettimeofday(&tv, NULL);
	t = tv.tv_sec + (double)tv.tv_usec*1e-6;
	return t;
}
void debug_log2(const char *p,...)
{
//	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	
//	if([d boolForKey:@"SQLITE_DEBUG_LOG"]) {
		va_list args;
		va_start(args, p);
		vfprintf(stderr, p, args);
//	}
}
void debug_log_time2(double t1, double t2)
{
	debug_log2( "total time : \t%02.4lf\n",(t2) - (t1));
}
- (void) updateCursor
{
	@synchronized(self) {
		NSLog(@"Update!");t1 = debug_clock2();
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
//			mCursor = [cursor retain];
			UTILDebugWrite1(@"cursor count -> %ld", [mCursor count]);
		}
		NSLog(@"Finish!");t2 = debug_clock2();debug_log_time2(t1, t2);
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
	NSString *key = tableNameForKey(identifier);
	
	BSThreadListItem *row;
	id result = nil;
	ThreadStatus s;
	
	@synchronized(mCursorLock) {
		row = [[[mCursor objectAtIndex : index] retain] autorelease];
	}
	
	s = [row status];
	
	if ( [key isEqualTo : TempThreadThreadNumberColumn] ) {
		result = [row threadNumber];
		if(!result || result == [NSNull null]) {
			result = [NSNumber numberWithInt:index + 1];
		}
	} else if([key isEqualToString : ThreadIDColumn]) {
		// スレッドの立った日付（dat 番号を変換）available in RainbowJerk and later.
		result = [row creationDate];
		return [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue: result
															   withDefaultAttributes: ((s == ThreadNewCreatedStatus) ? [[self class] newThreadCreatedDateAttrTemplate]
																													 : [[self class] threadCreatedDateAttrTemplate])];
	} else if([key isEqualToString : LastWrittenDateColumn]) {
		// 最終書き込み日
		result = [row lastWrittenDate];
		return [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue: result
															   withDefaultAttributes: [[self class] threadLastWrittenDateAttrTemplate]];
	} else if([key isEqualTo:ThreadStatusColumn]) {
		result = [row statusImage];
	} else {
		result = [row valueForKey : key];
	}
	
	if (result == [NSNull null]) {
		result = nil;
	}
	
	// 日付
	if([result isKindOfClass : [NSDate class]]) {
		return [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue: result
															   withDefaultAttributes: [[self class] threadModifiedDateAttrTemplate]];
	}
	
	result = [[self class] objectValueTemplate : result
									   forType : ((s == ThreadNewCreatedStatus) 
												  ? kValueTemplateNewArrivalType
												  : kValueTemplateDefaultType)];
	
	return result;
}
- (id)            tableView : (NSTableView   *) aTableView
  objectValueForTableColumn : (NSTableColumn *) aTableColumn
                        row : (int            ) rowIndex
{
//	NSArray			*threads_ = [self filteredThreads];
	NSString		*identifier_ = [aTableColumn identifier];
//	NSAssert2((rowIndex >= 0 && rowIndex <= [threads_ count]),
//			  @"Threads Count(%u) but Accessed Index = %d.", [threads_ count], rowIndex);
	
    if ([identifier_ isEqualToString: ThreadPlistIdentifierKey] ||
        [identifier_ isEqualToString: CMRThreadModifiedDateKey])
    {
        float location_ = [aTableColumn width];
        location_ -= [aTableView intercellSpacing].width * 2;
        [[self class] resetDataSourceTemplateForColumnIdentifier: identifier_ width: location_];
    }
	
	return [self objectValueForIdentifier: identifier_ threadArray: nil atIndex: rowIndex];
}
/* optional - editing support
*/
//- (void)tableView : (NSTableView *)tableView setObjectValue : (id)object forTableColumn : (NSTableColumn *)tableColumn row : (int)row;


/* optional - sorting support
This is the indication that sorting needs to be done.  Typically the data source will sort its data, reload, and adjust selections.
*/
/*
 - (void)tableView : (NSTableView *)tableView sortDescriptorsDidChange : (NSArray *)oldDescriptors
 {
	 id temp = data;
	 
	 data = [[data sortedArrayUsingDescriptors : [tableView sortDescriptors]] retain];
	 [temp release];
	 
	 [tableView reloadData];
 }
 */

/* optional - drag and drop support
This method is called after it has been determined that a drag should begin, but before the drag has been started.  To refuse the drag, return NO.  To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).  The drag image and other drag related information will be set up and provided by the table view once this call returns with YES.  'rowIndexes' contains the row indexes that will be participating in the drag.

Compatability Note: This method replaces tableView : writeRows : toPasteboard : .  If present, this is used instead of the deprecated method.
*/
/*
- (BOOL)tableView : (NSTableView *)tv writeRowsWithIndexes : (NSIndexSet *)rowIndexes toPasteboard : (NSPasteboard*)pboard
{
	return [super tableView : tv writeRowsWithIndexes : rowIndexes toPasteboard : pboard];
}
*/
/* This method is used by NSTableView to determine a valid drop target.  Based on the mouse position, the table view will suggest a proposed drop location.  This method must return a value that indicates which dragging operation the data source will perform.  The data source may "re-target" a drop if desired by calling setDropRow : dropOperation: and returning something other than NSDragOperationNone.  One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position).
*/
//- (NSDragOperation)tableView : (NSTableView*)tv validateDrop : (id <NSDraggingInfo>)info proposedRow : (int)row proposedDropOperation : (NSTableViewDropOperation)op;

/* This method is called when the mouse is released over an outline view that previously decided to allow a drop via the validateDrop method.  The data source should incorporate the data from the dragging pasteboard at this time.
*/
//- (BOOL)tableView : (NSTableView*)tv acceptDrop : (id <NSDraggingInfo>)info row : (int)row dropOperation : (NSTableViewDropOperation)op;

/* NSTableView data source objects can support file promised drags via by adding  NSFilesPromisePboardType to the pasteboard in tableView : writeRowsWithIndexes : toPasteboard : .  NSTableView implements -namesOfPromisedFilesDroppedAtDestination: to return the results of this data source method.  This method should returns an array of filenames for the created files (filenames only, not full paths).  The URL represents the drop location.  For more information on file promise dragging, see documentation on the NSDraggingSource protocol and -namesOfPromisedFilesDroppedAtDestination : .
*/
//- (NSArray *)tableView : (NSTableView *)tv namesOfPromisedFilesDroppedAtDestination : (NSURL *)dropDestination forDraggedRowsWithIndexes : (NSIndexSet *)indexSet;

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
