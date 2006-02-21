//
//  BSDBThreadList.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/19.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "BSDBThreadList.h"

#import "CMRThreadsList_p.h"
#import "CMRThreadsListReadFileTask.h"
#import "BSFavoritesHEADCheckTask.h"
// #import "CMRThreadSignature.h"
#import "ThreadTextDownloader.h"
#import "CMRSearchOptions.h"
#import "missing.h"

#import "BoardListItem.h"

#import "DatabaseManager.h"


@interface CMRThreadsList (PPPPP)
+ (id)statusImageWithStatus : (ThreadStatus)s;
- (void)downloaderTextUpdatedNotified:(id)notification;
@end
@interface BSDBThreadList (ToBeRefactoring)
- (void)updateDateBaseForThreads : (id) aThread;
@end

@implementation BSDBThreadList

// primitive
- (id)initWithBoardListItem : (BoardListItem *) item
{
//	CMRBBSSignature *sig = [CMRBBSSignature BBSSignatureWithName : [item name]];
	
	self = [super init];
	if (self) {
		[self setBBSName : [item name]];
		mBoardListItem = [item retain];
		mSortKey = [[[BoardManager defaultManager] sortColumnForBoard : [self boardName]] retain];
		mCursorLock = [[NSLock alloc] init];
		mCursor = [[item cursorForThreadList] retain];
		if (!mCursor) {
			[self release];
			self = nil;
		}
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
	
	[super dealloc];
}
/*
- (id) initWithBBSSignature : (CMRBBSSignature *) aSignature
{
	if([CMXFavoritesDirectoryName isSameAsString : [aSignature name]]){
		if(self = [self init]){
			[self setBBSSignature : aSignature];
		}
	} else {
		self = [super initWithBBSSignature : aSignature];
	}
	
	return self;
}
*/
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
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRFavoritesManagerDidLinkFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRFavoritesManagerDidRemoveFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	
	[super removeFromNotificationCenter];
}

- (BOOL)isFavorites
{
	return [BoardListItem isFavoriteItem : [self boardListItem]];
}

- (id) boardListItem
{
	return mBoardListItem;
}

static inline NSArray *componentsSeparatedByWhiteSpace(NSString *string)
{
	NSMutableArray *result = [NSMutableArray array];
	NSScanner *s = [NSScanner scannerWithString : string];
	NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
	NSString *str;
	
	while ([s scanUpToCharactersFromSet : cs intoString : &str]) {
		[result addObject : str];
	}
	
	if ([result count] == 0) {
		return nil;
	}
	
	return result;
}
static inline NSString *whereClauseFromSearchString(NSString *searchString)
{
	NSMutableString *clause;
	NSArray *searchs;
	NSEnumerator *searchsEnum;
	NSString *token;
	
	NSString *p = @"";
	
	searchs = componentsSeparatedByWhiteSpace(searchString);
	
	if (!searchs || [searchs count] == 0) {
		return nil;
	}
	
	clause = [NSMutableString stringWithFormat : @" WHERE "];
	
	searchsEnum = [searchs objectEnumerator];
	while (token = [searchsEnum nextObject]) {
		if ([token hasPrefix : @"!"]) {
			if ([token length] == 1) continue;
			
			[clause appendFormat : @"%@NOT %@ LIKE '%%%@%%' ",
				p, ThreadNameColumn, [token substringFromIndex : 1]];
		} else {
			[clause appendFormat : @"%@%@ LIKE '%%%@%%' ",
				p, ThreadNameColumn, token];
		}
		p = @"AND ";
	}
	
	return clause;
}

enum {
	kNewerThreadType,	// 新着検索
	kOlderThreadType,	// 非新着検索
	kAllThreadType,		// 全部！
};

// filter 処理と
// 新着のみもしくは非新着のみもしくはすべてのスレッドをDBから取得するための
// WHERE句を生成。
static inline NSString *conditionFromStatusAndType( int status, int type )
{
	NSMutableString *result = [NSMutableString string];
	NSString *brankOrAnd = @"";
	
	if(status & ThreadLogCachedStatus && 
	   (type == kOlderThreadType || !(status & ThreadNewCreatedStatus))) {
		// 新着/既得スレッドで且つ既得分表示 もしくは　既得スレッド
		[result appendFormat : @"NOT %@ IS NULL\n", NumberOfReadColumn];
		brankOrAnd = @" AND ";
	} else if(status & ThreadNoCacheStatus) {
		// 未取得スレッド
		[result appendFormat : @"%@ IS NULL\n", NumberOfReadColumn];
		brankOrAnd = @" AND ";
	} else if(status & ThreadNewCreatedStatus && type == kOlderThreadType) {
		// 新着スレッドで且つ既得分表示。あり得ない boardID を指定し、要素数を0にする
		[result appendFormat : @"%@ < 0\n",BoardIDColumn];
		brankOrAnd = @" AND ";
	}
	
	switch(type) {
		case kNewerThreadType:	
			[result appendFormat : @"%@%@ = %u\n", 
				brankOrAnd, ThreadStatusColumn, ThreadNewCreatedStatus];
			break;
		case kOlderThreadType:
			[result appendFormat : @"%@%@ != %u\n", 
				brankOrAnd, ThreadStatusColumn, ThreadNewCreatedStatus];
			break;
		case kAllThreadType:
			// Do nothing.
			break;
		default:
			UTILUnknownCSwitchCase(type);
			break;
	}
	
	return result;
}
static inline NSString *orderBy( NSString *sortKey, BOOL isAscending )
{
	NSString *result = nil;
	NSString *sortCol = nil;
	NSString *ascending = @"";
	
	if (!isAscending) ascending = @"DESC";
	
	if ([sortKey isEqualTo : CMRThreadTitleKey]) {
		sortCol = ThreadNameColumn;
	} else if ([sortKey isEqualTo : CMRThreadLastLoadedNumberKey]) {
		sortCol = NumberOfReadColumn;
	} else if ([sortKey isEqualTo : CMRThreadNumberOfMessagesKey]) {
		sortCol = NumberOfAllColumn;
	} else if ([sortKey isEqualTo : CMRThreadNumberOfUpdatedKey]) {
		sortCol = [NSString stringWithFormat : @"(%@ - %@)", NumberOfAllColumn, NumberOfReadColumn];
	} else if ([sortKey isEqualTo : CMRThreadSubjectIndexKey]) {
		sortCol = TempThreadThreadNumberColumn;
	} else if ([sortKey isEqualTo : CMRThreadStatusKey]) {
		sortCol = ThreadStatusColumn;
	} else if ([sortKey isEqualTo : CMRThreadModifiedDateKey]) {
		sortCol = ModifiedDateColumn;
	}
	
	if(sortCol) {
		result = [NSString stringWithFormat : @"ORDER BY %@ %@",sortCol, ascending];
	}
	
	return result;
}
- (NSString *) sqlForListForType : (int) type
{
	NSString *targetTable = [mBoardListItem query];
	NSMutableString *sql;
	NSString *whereOrAnd = @" WHERE ";
	NSString *searchCondition;
	NSString *filterCondition;
	NSString *order;
	
	sql = [NSMutableString stringWithFormat : @"SELECT * FROM (%@) ",targetTable];
	
	if (mSearchString && ![mSearchString isEmpty]) {
		searchCondition = whereClauseFromSearchString(mSearchString);
		if (searchCondition) {
			[sql appendString : searchCondition];
			whereOrAnd = @" AND ";
		}
	}
	
	filterCondition = conditionFromStatusAndType( mStatus, type);
	if(filterCondition) {
		[sql appendFormat : @"%@ %@\n", whereOrAnd, filterCondition];
//		whereOrAnd = @" AND ";
	}
	
	order = orderBy( mSortKey, [self isAscending]);
	if(order) {
		[sql appendString : order];
	}

	return sql;
}
- (void) updateCursor
{
	id temp;
	
#ifdef DEBUG
	clock_t time00, time01, time02, time03;
	
	time00 = clock();
#endif
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	NSString *newersSQL = nil;
	NSString *sql;
	id <SQLiteMutableCursor> newerCursor = nil;
	id <SQLiteMutableCursor> olderCursor = nil;
	
	UTILAssertNotNil(db);
	
	if( [CMRPref collectByNew] ) {
		newersSQL = [self sqlForListForType : kNewerThreadType];
		sql = [self sqlForListForType : kOlderThreadType];
	} else {
		sql = [self sqlForListForType : kAllThreadType];
	}
	
#ifdef DEBUG
	time01 = clock();
#endif
	do {
		olderCursor = [db cursorForSQL : sql];
		if ([db lastErrorID] != 0) {
			NSLog(@"sql error on %s line %d.\n\tReason   : %@", __FILE__, __LINE__, [db lastError]);
			olderCursor = nil;
			break;
		}
		if(newersSQL) {
			newerCursor = [db cursorForSQL : newersSQL];
			if([db lastErrorID] != 0) {
				NSLog(@"sql error on %s line %d.\n\tReason   : %@", __FILE__, __LINE__, [db lastError]);
				newerCursor = nil;
				break;
			}
		}
		if(newerCursor && [newerCursor rowCount]) {
			[newerCursor appendCursor : olderCursor];
			olderCursor = nil;
		}
	} while( NO );
#ifdef DEBUG
	time02 = clock();
#endif
	if(olderCursor || newerCursor) {
		temp = mCursor;
		[mCursorLock lock];
		{
			if(olderCursor) {
				mCursor = [olderCursor retain];
			} else {
				mCursor = [newerCursor retain];
			}
		}
		[mCursorLock unlock];
		[temp release];
	}
#ifdef DEBUG
	time03 = clock();
#endif
	
	
#ifdef DEBUG	
	printf("creating SQL time   : %ld\n"
		   "getting cursor time : %ld\n",
		   time01 - time00, time03 - time01 );
#endif
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

- (void) sortByKey : (NSString *) key
{
	id tmp = mSortKey;
	mSortKey = [key retain];
	[tmp release];
	
	[self updateCursor];
}

#pragma mark## Filter ##
- (BOOL) filterByFindOperation : (CMRSearchOptions *) operation
{
	id tmp = mSearchString;
	id newSearchString = [operation findObject];
	
	if (![newSearchString isKindOfClass : [NSString class]]) {
		return NO;
	}
	
	mSearchString = [newSearchString retain];
	[tmp release];
	
	[self updateCursor];
	
	return YES;
}

- (void) filterByStatus : (int) status
{
	mStatus = status;
	[self updateCursor];
}

#pragma mark## DataSource ##
- (NSDictionary *) threadAttributesAtRowIndex : (int) rowIndex useLock : (BOOL) useLock
{
	NSMutableDictionary *result;
	id<SQLiteRow> row;
	
	id temp;
	NSString *title;
	NSString *newCount;
	NSString *dat;
	NSString *boardName;
	NSString *statusStr;
	NSNumber *status;
	NSString *modDateStr;
	NSDate *modDate = nil;
	NSString *threadPath;
	
	if(useLock)
		[mCursorLock lock];
	row = [[[mCursor rowAtIndex : rowIndex] retain] autorelease];
	if(useLock)
		[mCursorLock unlock];
	
	temp = [row valueForColumn : ThreadNameColumn];
	title = temp == [NSNull null] ? nil : temp;
	temp = [row valueForColumn : NumberOfAllColumn];
	newCount = temp == [NSNull null] ? nil : temp;
	temp = [row valueForColumn : ThreadIDColumn];
	dat = temp == [NSNull null] ? nil : temp;
	temp = [row valueForColumn : BoardNameColumn];
	boardName = temp == [NSNull null] ? nil : temp;
	temp = [row valueForColumn : ThreadStatusColumn];
	statusStr = temp == [NSNull null] ? nil : temp;
	temp = [row valueForColumn : ModifiedDateColumn];
	modDateStr = temp == [NSNull null] ? nil : temp;
	
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
	
	return result;
}
- (NSArray *) allThreadAttributes
{
	NSMutableArray *result;
	unsigned i, count;
	id attr;
	
	[mCursorLock lock];
	{
		count = [mCursor rowCount];
		result = [NSMutableArray arrayWithCapacity:count];
		for( i = 0; i < count; i++ ) {
			attr = [self threadAttributesAtRowIndex:i useLock:NO];
			if(attr) {
				[result addObject:attr];
			}
		}
	}
	[mCursorLock unlock];
	
	return result;
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

enum {
	kValueTemplateDefaultType,
	kValueTemplateNewArrivalType,
	kValueTemplateNewUnknownType
};
- (int)numberOfRowsInTableView : (NSTableView *)tableView
{
	return [self numberOfFilteredThreads];
}

- (id)tableView : (NSTableView *)tableView objectValueForTableColumn : (NSTableColumn *)tableColumn row : (int)rowIndex
{
	NSString *identifier = [tableColumn identifier];
	id <SQLiteRow> row;
	id result = nil;
	ThreadStatus s;
	
	[mCursorLock lock];
	row = [[[mCursor rowAtIndex : rowIndex] retain] autorelease];
	[mCursorLock unlock];
	
	s = [[row valueForColumn : ThreadStatusColumn] intValue];
	
	if ([identifier isEqualTo : CMRThreadStatusKey]) {
		result = [[self class] statusImageWithStatus : s];
	} else if ([identifier isEqualTo : CMRThreadNumberOfUpdatedKey]) {
		id all = [row valueForColumn : NumberOfAllColumn];
		id read = [row valueForColumn : NumberOfReadColumn];
		
		if ([all respondsToSelector : @selector(intValue)] && [read respondsToSelector : @selector(intValue)]) {
			result = [NSNumber numberWithInt : [all intValue] - [read intValue]];
		}
	} else if ( [identifier isEqualTo : CMRThreadModifiedDateKey] ) {
		id mod = [row valueForColumn : ModifiedDateColumn];
		
		if (![mod isKindOfClass : [NSNull class]]) {
			result = [NSDate dateWithTimeIntervalSince1970 : [mod doubleValue]];
			
			if (dateFormatter)
				result = [dateFormatter stringForObjectValue : result];
			else
				result = [[CMXDateFormatter sharedInstance] stringForObjectValue : result];
		}
	} else if ( [identifier isEqualTo : CMRThreadTitleKey] ) {
		result = [row valueForColumn : ThreadNameColumn];
	} else if ( [identifier isEqualTo : CMRThreadNumberOfMessagesKey] ) {
		result = [row valueForColumn : NumberOfAllColumn];
	} else if ( [identifier isEqualTo : CMRThreadLastLoadedNumberKey] ) {
		result = [row valueForColumn : NumberOfReadColumn];
	} else if ( [identifier isEqualTo : CMRThreadSubjectIndexKey] ) {
		result = [row valueForColumn : TempThreadThreadNumberColumn];
	}
	
	if ([result isKindOfClass : [NSNull class]]) {
		result = nil;
	}
	
	result = [[self class] objectValueTemplate : result
									   forType : ((s == ThreadNewCreatedStatus) 
												  ? kValueTemplateNewArrivalType
												  : kValueTemplateDefaultType)];
	
	return result;
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
- (BOOL)tableView : (NSTableView *)tv writeRowsWithIndexes : (NSIndexSet *)rowIndexes toPasteboard : (NSPasteboard*)pboard
{
	return [super tableView : tv writeRowsWithIndexes : rowIndexes toPasteboard : pboard];
}

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
		
		boardName = [dfm boardNameWithLogPath : inFilePath];
		if (!boardName) return NO;
		
		boardIDs = [[DatabaseManager defaultManager] boardIDsForName : boardName];
		if (!boardIDs || [boardIDs count] == 0) return NO;
		
		*outBoardID = [[boardIDs objectAtIndex : 0] intValue];
	}
	
	return YES;
}

- (void) downloaderTextUpdatedNotified : (NSNotification *) notification
{
	CMRDownloader			*downloader_;
	NSDictionary			*userInfo_;
	NSDictionary			*newContents_;
	//	NSMutableDictionary		*thread_;
	
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
		
		int baordID;
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
		[sql appendFormat : @"WHERE %@ = %u AND %@ = '%@'",
			BoardIDColumn, baordID, ThreadIDColumn, threadID];
		
		[db cursorForSQL : sql];
		
		if ([db lastErrorID] != 0) {
			NSLog(@"Fail Insert or udate. Reson: %@", [db lastError] );
		}
		
		[self updateCursor];
		
	} while ( NO );
	
	[super downloaderTextUpdatedNotified : notification];
}
- (void)favoritesHEADCheckTaskDidFinish:(id)notification
{
	UTILAssertNotificationName(
							   notification,
							   BSFavoritesHEADCheckTaskDidFinishNotification);
	
	id					object_;
	NSDictionary		*userInfo_;
	NSMutableArray		*threadsArray_;
	NSEnumerator		*threadsEnum;
	id					thread;
	SQLiteDB *db = nil;
	NSString *query;
	
	object_ = [notification object];
	UTILAssertKindOfClass(object_, BSFavoritesHEADCheckTask);
	if(NO == [[object_ identifier] isEqual : [self boardName]])
		goto fail;
	
	userInfo_ = [notification userInfo];
	
	threadsArray_	= [userInfo_ objectForKey : kBSUserInfoThreadsArrayKey];
	UTILAssertKindOfClass(threadsArray_, NSArray);
	
	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if(!db) goto fail;
	
	if([db beginTransaction]) {
		threadsEnum = [threadsArray_ objectEnumerator];
		while(thread = [threadsEnum nextObject]) {
			NSNumber *status;
			int boardID;
			NSString *threadID;
			
			if( !(status = [thread objectForKey:CMRThreadStatusKey]) ) {
				continue;
			}
			if([status unsignedIntValue] == ThreadLogCachedStatus) {
				continue;
			}
			
			if(!searchBoardIDAndThreadIDFromFilePath( &boardID, &threadID, [thread objectForKey:CMRThreadLogFilepathKey]) ) {
				continue;
			}
			
			query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %u WHERE %@ = %u AND %@ = '%@'",
				ThreadInfoTableName,
				ThreadStatusColumn, ThreadHeadModifiedStatus,
				BoardIDColumn, boardID,
				ThreadIDColumn, threadID];
			
			[db cursorForSQL : query];
			
			if ([db lastErrorID] != 0) {
				NSLog(@"Fail Insert or udate. Reson: %@", [db lastError] );
				goto fail;
			}
		}
		[db commitTransaction];
	}
	
	[self updateCursor];
	
	[[NSNotificationCenter defaultCenter]
			removeObserver : self
					  name : [notification name]
					object : [notification object]];
	
	UTILNotifyName(CMRThreadsListDidChangeNotification);
	
	return;
	
fail:
		[db rollbackTransaction];
		[[NSNotificationCenter defaultCenter]
			removeObserver : self
					  name : [notification name]
					object : [notification object]];
}

@end

@implementation BSDBThreadList (ToBeRefactoring)


#pragma mark## Download ##
- (void) downloadThreadsList
{
	if( [self isFavorites] ) {
		BSFavoritesHEADCheckTask		*task_;
		
		task_ = [[BSFavoritesHEADCheckTask alloc]
				initWithFavItemsArray : [[[self allThreadAttributes] mutableCopy] autorelease]];
		[task_ setBoardName : [self boardName]];
		[task_ setIdentifier : [self boardName]];
		
		[[NSNotificationCenter defaultCenter]
			addObserver : self
			   selector : @selector(favoritesHEADCheckTaskDidFinish:)
				   name : BSFavoritesHEADCheckTaskDidFinishNotification
				 object : task_];
		
		[[self worker] push : task_];
		
		[task_ release];
	} else {
		[super downloadThreadsList];
	}
}

- (void) cleanUpItemsToBeRemoved : (NSArray *) files
{
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	NSString *query;
	
	NSEnumerator *filesEnum;
	NSString *path;
	
	if([db beginTransaction]) {
		filesEnum = [files objectEnumerator];
		while(path = [filesEnum nextObject]) {
			int boardID;
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
	[super cleanUpItemsToBeRemoved : files];
}

- (void) setThreads : (NSMutableArray *) aThreads
{
	[self updateDateBaseForThreads : aThreads];
	[self updateCursor];
	
	[super setThreads : aThreads];
}


//<チラシの裏>
//長いよ！このメソッド！
//でも、ここはスピード命で。あと、分けるとやってることが分かりにくくなる可能性が。
//いっぱいコメント書いたから許して。
//</チラシの裏>
- (void) updateDateBaseForThreads : (id) aThreads
{
	NSLog(@"CHECKKING ME! %s : %d", __FILE__, __LINE__);
	
#ifdef DEBUG
	NSDate *start = [NSDate dateWithTimeIntervalSinceNow : 0.0];
	unsigned sendSQLCount = 0;
#define incrementCount() sendSQLCount++
#else
#define incrementCount() 
#endif
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	if (db && [db beginTransaction]) {
		NSEnumerator *threadsEnum;
		id thread;
		
		NSString *prevBoardName = nil;
		NSURL *boardURL;
		unsigned boardID = NSNotFound;
		
		SQLiteReservedQuery *reservedInsert;
		SQLiteReservedQuery *reservedUpdate;
		SQLiteReservedQuery *reservedInsertNumber;
		SQLiteReservedQuery *reservedSelectThreadTable;
		
		id query;
		
		// データ確認用
		query = [NSString stringWithFormat : @"SELECT %@, %@ FROM %@ WHERE %@ = ? AND %@ = ?",
			ThreadStatusColumn, NumberOfAllColumn,
			ThreadInfoTableName,
			BoardIDColumn, ThreadIDColumn];
		reservedSelectThreadTable = [db reservedQuery : query];
		if (!reservedSelectThreadTable) {
			NSLog(@"Can NOT create reservedSelectThreadTable");
			goto abort;
		}
		
		// スレッド登録用
		query = [NSString stringWithFormat : @"INSERT INTO %@ ( %@, %@, %@, %@, %@ ) VALUES ( ?, ?, ?, ?, ? )",
			ThreadInfoTableName,
			BoardIDColumn, ThreadIDColumn, ThreadNameColumn, NumberOfAllColumn, ThreadStatusColumn];
		reservedInsert = [db reservedQuery : query];
		if (!reservedInsert) {
			NSLog(@"Can NOT create reservedInsert");
			goto abort;
		}
		
		// スレッドデータ更新用
		query = [NSString stringWithFormat : @"UPDATE %@ SET %@ = ?, %@ = ? WHERE %@ = ? AND %@ = ?",
			ThreadInfoTableName,
			NumberOfAllColumn, ThreadStatusColumn,
			BoardIDColumn, ThreadIDColumn];
		reservedUpdate = [db reservedQuery : query];
		if (!reservedUpdate) {
			NSLog(@"Can NOT create reservedUpdate");
			goto abort;
		}
		
		// スレッド番号登録用
		query = [NSString stringWithFormat : @"INSERT INTO %@ ( %@, %@, %@ ) VALUES ( ?, ?, ? )",
			TempThreadNumberTableName,
			BoardIDColumn, ThreadIDColumn, TempThreadThreadNumberColumn];
		reservedInsertNumber = [db reservedQuery : query];
		if (!reservedInsertNumber) {
			NSLog(@"Can NOT create reservedInsertNumber");
			goto abort;
		}
		
		// スレッド番号用テーブルをクリア
		query = [NSString stringWithFormat : @"DELETE FROM %@",
			TempThreadNumberTableName];
		[db performQuery : query];
		incrementCount();
		
		threadsEnum = [aThreads objectEnumerator];
		while( thread = [threadsEnum nextObject] ) {
			id pool = [[NSAutoreleasePool alloc] init];
			
			NSString *boardName = [thread objectForKey : ThreadPlistBoardNameKey];
			NSString *title = [thread objectForKey : CMRThreadTitleKey];
			NSString *dat = [thread objectForKey : ThreadPlistIdentifierKey];
			NSNumber *count = [thread objectForKey : CMRThreadNumberOfMessagesKey];
			NSNumber *status = [thread objectForKey : CMRThreadStatusKey];
			NSNumber *index = [thread objectForKey : CMRThreadSubjectIndexKey];
			
			if( !boardName || !title || !dat || !count || !status || !index ) {
				NSLog(@"Thread infomation is broken. (%@)", thread);
				continue;
			}
			
			if (![prevBoardName isEqualTo : boardName]) {
				// URLForBoardName: がオーバーヘッドになっているため少しでも呼び出しを減らす。
				id tmp;
				
				boardURL = [[BoardManager defaultManager] URLForBoardName : boardName];
				boardID = [[DatabaseManager defaultManager] boardIDForURLString : [boardURL absoluteString]];
				
				tmp = prevBoardName;
				prevBoardName = [boardName retain];
				[tmp release];
			}
			
			if (boardID != NSNotFound) {
				NSArray *bindValues;
				id <SQLiteCursor> cursor;
				
				// 対象スレッドを以前読み込んだか調べる
				// [cursor rowCount] が0なら初めて読み込んだ。
				bindValues = [NSArray arrayWithObjects:
					[NSNumber numberWithUnsignedInt : boardID], dat, nil];
				cursor = [reservedSelectThreadTable cursorForBindValues : bindValues];
				incrementCount();
				UTILRequireCondition(cursor, abort);
				
				if(![cursor rowCount]) {
					// 初めての読み込み。データベースに登録。
					//			title = [SQLiteDB prepareStringForQuery : title];
					
					bindValues = [NSArray arrayWithObjects:
						[NSNumber numberWithUnsignedInt : boardID], dat, title, count, status, nil];
					[reservedInsert cursorForBindValues : bindValues];
					incrementCount();
					if ([db lastErrorID] != 0) {
						NSLog(@"Fail Insert. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
					}
					
				} else {
					// ２度目以降の読み込み。レス数かステータスが変更されていれば
					// データベースを更新。
					id <SQLiteRow> row = [cursor rowAtIndex:0];
					
					if( [count intValue] != [[row valueForColumn : NumberOfAllColumn] intValue] ||
						[status intValue] != [[row valueForColumn : ThreadStatusColumn] intValue]) {
						
						bindValues = [NSArray arrayWithObjects:
							count, status,
							[NSNumber numberWithUnsignedInt : boardID], dat, nil];
						[reservedUpdate cursorForBindValues : bindValues];
						incrementCount();
						if ([db lastErrorID] != 0) {
							NSLog(@"Fail udate. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
						}
					}
				}
				
				// スレッド番号のための一時テーブルに番号を登録。
				bindValues = [NSArray arrayWithObjects:
					[NSNumber numberWithUnsignedInt : boardID], dat, index, nil];
				[reservedInsertNumber cursorForBindValues : bindValues];
				incrementCount();
				if ([db lastErrorID] != 0) {
					NSLog(@"Fail Insert. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
				}
			}
			
			[pool release];
		}
		
		[db commitTransaction];
		
		[prevBoardName release];
	}
	
#ifdef DEBUG
	{
		NSDate *end = [NSDate dateWithTimeIntervalSinceNow : 0.0];
		
		NSLog(@"Database access time -> %lfs.", [end timeIntervalSinceDate : start]);
		NSLog(@"Sending SQL Query count -> %u.", sendSQLCount);
	}
#endif
			
	return;
	
abort:
		NSLog(@"Fail Database operation. Reson: \n%@", [db lastError]);
	[db rollbackTransaction];
}

@end
