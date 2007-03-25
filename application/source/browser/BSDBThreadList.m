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

NSString *BSDBThreadListDidFinishUpdateNotification = @"BSDBThreadListDidFinishUpdateNotification";


@interface BSDBThreadList (Private)
- (void)setSortDescriptors:(NSArray *)inDescs;
- (void) sortByKeyWithoutUpdateList : (NSString *) key;
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

- (void)setBoardListItem:(BoardListItem *)item
{
	id temp = mBoardListItem;
	mBoardListItem = [item retain];
	[temp release];
	
//	BOOL isAsc = [[BoardManager defaultManager] sortColumnIsAscendingAtBoard : [self boardName]];
//	[self setIsAscending:isAsc];
//	temp = [[BoardManager defaultManager] sortColumnForBoard : [self boardName]];
//	[self sortByKeyWithoutUpdateList:temp];
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
- (id) sortKey
{
	return mSortKey;
}
- (NSArray *)sortDescriptors
{
	return [NSArray arrayWithArray:mSortDescriptors];
}
- (void)setSortDescriptors:(NSArray *)inDescs
{
	UTILAssertKindOfClass(inDescs, NSArray);
	
	id temp = mSortDescriptors;
	mSortDescriptors = [[NSMutableArray arrayWithArray:inDescs] retain];;
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
	
	// 同じキーのNSSortDescriptorを取り除く
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
- (ThreadStatus) status
{
	return mStatus;
}
	
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
		[mCursorLock lock];
		{
			mCursor = [cursor retain];
		}
		[mCursorLock unlock];
	}
	
	UTILDebugWrite1(@"cursor count -> %ld", [mCursor rowCount]);
	
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
	
	[mCursorLock lock];
	count = [mCursor rowCount];
	[mCursorLock unlock];
	
	return count;
}
- (unsigned) numberOfFilteredThreads
{
	return [self numberOfThreads];
}

- (void) sortByKeyWithoutUpdateList : (NSString *) key
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
	
	[self sortByKeyWithoutUpdateList:key];

	[self updateCursor];
	
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
// Status image
#define kStatusUpdatedImageName		@"Status_updated"
#define kStatusCachedImageName		@"Status_logcached"
#define kStatusNewImageName			@"Status_newThread"
#define kStatusHEADModImageName		@"Status_HeadModified"
static NSImage *_statusImageWithStatusBSDB(ThreadStatus s)
{
	switch (s){
		case ThreadLogCachedStatus :
			return [NSImage imageAppNamed : kStatusCachedImageName];
		case ThreadUpdatedStatus :
			return [NSImage imageAppNamed : kStatusUpdatedImageName];
		case ThreadNewCreatedStatus :
			return [NSImage imageAppNamed : kStatusNewImageName];
		case ThreadHeadModifiedStatus :
			return [NSImage imageAppNamed : kStatusHEADModImageName];
		case ThreadNoCacheStatus :
			return nil;
		default :
			return nil;
	}
	return nil;
}
static inline id nilIfObjectIsNSNull( id obj )
{
	return obj == [NSNull null] ? nil : obj;
}
static inline NSMutableDictionary *threadAttributesForBoardIDAndThreadID(
																		 int boardID,
																		 NSString *threadID )
{
	NSMutableDictionary *result = nil;
	
	SQLiteDB *db;
	id<SQLiteCursor> cursor;
	id<SQLiteRow> row;
	NSMutableString *query;
	
	if(boardID == 0) return nil;
	if(!threadID || ![threadID isKindOfClass:[NSString class]]) return nil;
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if(!db) return nil;
	
	query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", BoardThreadInfoViewName];
	[query appendFormat:@"WHERE %@ = %u AND %@ = %@",
		BoardIDColumn, boardID, ThreadIDColumn, threadID];
	
	{
		NSString *title;
		NSString *newCount;
		NSString *dat;
		NSString *boardName;
		NSString *statusStr;
		NSNumber *status;
		NSString *modDateStr;
		NSDate *modDate = nil;
		NSString *threadPath;
		
		cursor = [db cursorForSQL:query];
		if(!cursor || [cursor rowCount] == 0) {
			goto abort;
		}
		
		row = [cursor rowAtIndex:0];
		
		title = nilIfObjectIsNSNull([row valueForColumn:ThreadNameColumn]);
		newCount = nilIfObjectIsNSNull([row valueForColumn:NumberOfAllColumn]);
		dat = nilIfObjectIsNSNull([row valueForColumn:ThreadIDColumn]);
		boardName = nilIfObjectIsNSNull([row valueForColumn:BoardNameColumn]);
		statusStr = nilIfObjectIsNSNull([row valueForColumn:ThreadStatusColumn]);
		modDateStr = nilIfObjectIsNSNull([row valueForColumn:ModifiedDateColumn]);
		
		threadPath = [[CMRDocumentFileManager defaultManager] threadPathWithBoardName : boardName
																		datIdentifier : dat];
		status = [NSNumber numberWithInt : [statusStr intValue]];
		if(modDateStr) {
			modDate = [NSDate dateWithTimeIntervalSince1970 : [modDateStr doubleValue]];
		}
		
		result = [NSMutableDictionary dictionaryWithCapacity:7];
		[result setNoneNil:title forKey:CMRThreadTitleKey];
		[result setNoneNil:newCount forKey:CMRThreadNumberOfMessagesKey];
		[result setNoneNil:dat forKey:ThreadPlistIdentifierKey];
		[result setNoneNil:boardName forKey:ThreadPlistBoardNameKey];
		[result setNoneNil:status forKey:CMRThreadUserStatusKey];
		[result setNoneNil:modDate forKey:CMRThreadModifiedDateKey];
		[result setNoneNil:threadPath forKey:CMRThreadLogFilepathKey];
	}
	
	return result;
	
abort:{
	return nil;
}

}
- (NSDictionary *) threadAttributesAtRowIndex : (int) rowIndex useLock : (BOOL) useLock
{
	id<SQLiteRow> row;
	
	NSString *dat;
	NSString *boardID;

	
	if(useLock)
		[mCursorLock lock];
	row = [[[mCursor rowAtIndex : rowIndex] retain] autorelease];
	if(useLock)
		[mCursorLock unlock];
	
	dat = nilIfObjectIsNSNull([row valueForColumn:ThreadIDColumn]);
	boardID = nilIfObjectIsNSNull([row valueForColumn:BoardIDColumn]);
	
	return threadAttributesForBoardIDAndThreadID([boardID intValue], dat);
}

- (NSDictionary *) threadAttributesAtRowIndex : (int          ) rowIndex
                                  inTableView : (NSTableView *) tableView
{
	return [self threadAttributesAtRowIndex : rowIndex useLock : YES];
}
- (unsigned int) indexOfThreadWithPath : (NSString *) filepath
{
	unsigned result;
	CMRDocumentFileManager *dfm = [CMRDocumentFileManager defaultManager];
	NSString *identifier = [dfm datIdentifierWithLogPath : filepath];
	
	NSArray *threadIDs;
	
	[mCursorLock lock];
	threadIDs	= [[[mCursor valuesForColumn : ThreadIDColumn] retain] autorelease];
	[mCursorLock unlock];
	
	result = [threadIDs indexOfObject : identifier];
	
	return result;
}
// Described in CMRThreadsList.h (2007-01-28)
/*enum {
	kValueTemplateDefaultType,
	kValueTemplateNewArrivalType,
	kValueTemplateNewUnknownType
};*/

- (int)numberOfRowsInTableView : (NSTableView *)tableView
{
	UTILDebugWrite1(@"numberOfRowsInTableView -> %ld", [self numberOfFilteredThreads]);
	
	return [self numberOfFilteredThreads];
}

- (id) objectValueForIdentifier : (NSString *) identifier
					threadArray : (NSArray  *) threadArray
						atIndex : (int       ) index
{
	id <SQLiteRow> row;
	id result = nil;
	ThreadStatus s;
	
	[mCursorLock lock];
	row = [[[mCursor rowAtIndex : index] retain] autorelease];
	[mCursorLock unlock];
	
	s = [[row valueForColumn : ThreadStatusColumn] intValue];
	
	if ([identifier isEqualTo : CMRThreadStatusKey]) {
		result = _statusImageWithStatusBSDB(s);
	} else if ([identifier isEqualTo : CMRThreadNumberOfUpdatedKey]) {
		id read = [row valueForColumn : NumberOfReadColumn];
		// NumberOfReadColumn カラムが NULL なら NULL
		if(!UTILObjectIsNull(read)) {
			result = [row valueForColumn : NumberOfDifferenceColumn];
		}
	} else if ( [identifier isEqualTo : CMRThreadModifiedDateKey] ) {
		id mod = [row valueForColumn : ModifiedDateColumn];
		
		if (mod != [NSNull null]) {
			result = [NSDate dateWithTimeIntervalSince1970 : [mod doubleValue]];
		}
	} else if ( [identifier isEqualTo : CMRThreadTitleKey] ) {
		result = [row valueForColumn : ThreadNameColumn];
	} else if ( [identifier isEqualTo : CMRThreadNumberOfMessagesKey] ) {
		result = [row valueForColumn : NumberOfAllColumn];
	} else if ( [identifier isEqualTo : CMRThreadLastLoadedNumberKey] ) {
		result = [row valueForColumn : NumberOfReadColumn];
	} else if ( [identifier isEqualTo : CMRThreadSubjectIndexKey] ) {
		result = [row valueForColumn : TempThreadThreadNumberColumn];
		if(!result || result == [NSNull null]) {
			result = [NSNumber numberWithInt:index + 1];
		}
	} else if([identifier isEqualToString : ThreadPlistIdentifierKey]) {
		// スレッドの立った日付（dat 番号を変換）available in RainbowJerk and later.
		result = [NSDate dateWithTimeIntervalSince1970 : (NSTimeInterval)[[row valueForColumn : ThreadIDColumn] doubleValue]];
		return [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue: result
															   withDefaultAttributes: ((s == ThreadNewCreatedStatus) ? [[self class] newThreadCreatedDateAttrTemplate]
																													 : [[self class] threadCreatedDateAttrTemplate])];
	} else if([identifier isEqualToString : LastWrittenDateColumn]) {
		// 最終書き込み日時
		result = [row valueForColumn : LastWrittenDateColumn];
		if(result && result != [NSNull null]) {
			
			result = [NSDate dateWithTimeIntervalSince1970 : (NSTimeInterval)[result doubleValue]];
			return [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue: result
																   withDefaultAttributes: ((s == ThreadNewCreatedStatus) ? [[self class] newThreadCreatedDateAttrTemplate]
																														 : [[self class] threadCreatedDateAttrTemplate])];
		}
	} else {
		result = [row valueForColumn : identifier];
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

static inline BOOL searchBoardIDAndThreadIDFromFilePath( int *outBoardID, NSString **outThreadID, NSString *inFilePath )
{
	CMRDocumentFileManager *dfm = [CMRDocumentFileManager defaultManager];
	
	if (outThreadID) {
		*outThreadID = [dfm datIdentifierWithLogPath : inFilePath];
	}
	
	if (outBoardID) {
		NSString *boardName;
		NSArray *boardIDs;
		id boardID;
		
		boardName = [dfm boardNameWithLogPath : inFilePath];
		if (!boardName) return NO;
		
		boardIDs = [[DatabaseManager defaultManager] boardIDsForName : boardName];
		if (!boardIDs || [boardIDs count] == 0) return NO;
		
		boardID = [boardIDs objectAtIndex : 0];
		
		*outBoardID = [boardID intValue];
	}
	
	return YES;
}
/*
// スレッドのダウンロードが終了した。
- (void) downloaderTextUpdatedNotified : (NSNotification *) notification
{
	CMRDownloader			*downloader_;
	NSDictionary			*userInfo_;
	NSDictionary			*newContents_;
	
	UTILAssertNotificationName(
							   notification,
							   ThreadTextDownloaderUpdatedNotification);
	
	
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, CMRDownloader);
	
	userInfo_ = [notification userInfo];
	UTILAssertNotNil(userInfo_);
	
	newContents_ = [userInfo_ objectForKey : CMRDownloaderUserInfoContentsKey];
	UTILAssertKindOfClass(
						  newContents_,
						  NSDictionary);
	
	do {
		SQLiteDB *db;
		NSMutableString *sql;
		
		int		cnt_;
		NSArray		*messages_;
		NSDate *modDate = [newContents_ objectForKey : CMRThreadModifiedDateKey];
		
		int baordID = 0;
		NSString *threadID;
		
		db = [[DatabaseManager defaultManager] databaseForCurrentThread];
		if(!db) break;
		
		messages_ = [newContents_ objectForKey : ThreadPlistContentsKey];
		cnt_ = (messages_ != nil) ? [messages_ count] : 0;
		
		if (! searchBoardIDAndThreadIDFromFilePath( &baordID, &threadID, [downloader_ filePathToWrite] )) {
			break;
		}
		
		sql = [NSMutableString stringWithFormat : @"UPDATE %@ ", ThreadInfoTableName];
		[sql appendFormat : @"SET %@ = %u, %@ = %u, %@ = %u, %@ = %.0lf ",
			NumberOfAllColumn, cnt_,
			NumberOfReadColumn, cnt_,
			ThreadStatusColumn, ThreadLogCachedStatus,
			ModifiedDateColumn, [modDate timeIntervalSince1970]];
		[sql appendFormat : @"WHERE %@ = %u AND %@ = %@",
			BoardIDColumn, baordID, ThreadIDColumn, threadID];
		
		[db cursorForSQL : sql];
		
		if ([db lastErrorID] != 0) {
			NSLog(@"Fail Insert or udate. Reson: %@", [db lastError] );
		}
		
		[self updateCursor];
		
	} while ( NO );
	
}
*/
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
	int boardID = 0;
	id threadID;
	
	if( searchBoardIDAndThreadIDFromFilePath(&boardID,&threadID,filePath) ) {
		return threadAttributesForBoardIDAndThreadID( boardID, threadID );
	}
	
	return nil;
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
/*
- (void) cleanUpItemsToBeRemoved : (NSArray *) files
{
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	NSString *query;
	
	NSEnumerator *filesEnum;
	NSString *path;
	
	if([db beginTransaction]) {
		filesEnum = [files objectEnumerator];
		while(path = [filesEnum nextObject]) {
			int boardID = 0;
			NSString *threadID;
			
			if(searchBoardIDAndThreadIDFromFilePath(&boardID, &threadID, path)) {
				
				query = [NSString stringWithFormat:
					@"UPDATE %@\n"
					@"SET %@ = NULL,\n"
					@"%@ = NULL,\n"
					@"%@ = %d,\n"
					@"%@ = NULL,\n"
					@"%@ = NULL\n"
					@"WHERE %@ = %d\n"
					@"AND %@ = %@",
					ThreadInfoTableName,
					NumberOfReadColumn,
					ModifiedDateColumn,
					ThreadStatusColumn, ThreadNoCacheStatus,
					ThreadAboneTypeColumn,
					ThreadLabelColumn,
					BoardIDColumn, boardID,
					ThreadIDColumn, threadID];
				
				[db performQuery:query];
			}
			
		}
		[db commitTransaction];
	}
	
	[self updateCursor];
}*/
@end
