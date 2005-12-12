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
#import "CMRThreadSignature.h"
#import "ThreadTextDownloader.h"
#import "CMRSearchOptions.h"

#import "BoardListItem.h"

#import "DatabaseManager.h"


@interface BSDBThreadList (PPPPP)
+ (id)statusImageWithStatus : (ThreadStatus)s;
@end

@implementation BSDBThreadList

- (id)initWithBoardListItem : (BoardListItem *) item
{
	CMRBBSSignature *sig = [CMRBBSSignature BBSSignatureWithName : [item name]];
	
	self = [self initWithBBSSignature : sig];
	if (self) {
		boardListItem = item;
		mCursor = [[item cursorForThreadList] retain];
		if (!mCursor) {
			[self release];
			self = nil;
		} else {
			cursorLock = [[NSLock alloc] init];
		}
	}
	
	return self;
}
+ (id)threadListWithBoardListItem : (BoardListItem *) item
{
	return [[[self alloc] initWithBoardListItem : item] autorelease];
}
- (void) dealloc
{
	[mCursor release];
	[cursorLock release];
	
	[super dealloc];
}

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

- (id) boardListItem
{
	return boardListItem;
}

NSArray *componentsSeparatedByWhiteSpace(NSString *string)
{
	//
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
NSString *wherePhraseFromSearchString(NSString *searchString)
{
	NSMutableString *phrase;
	NSArray *searchs;
	NSEnumerator *searchsEnum;
	NSString *token;
	
	NSString *p = @"";
	
	searchs = componentsSeparatedByWhiteSpace(searchString);
	
	if (!searchs || [searchs count] == 0) {
		return nil;
	}
	
	phrase = [NSMutableString stringWithFormat : @" WHERE "];
	
	searchsEnum = [searchs objectEnumerator];
	while (token = [searchsEnum nextObject]) {
		if ([token hasPrefix : @"!"]) {
			if ([token length] == 1) continue;
			
			[phrase appendFormat : @"%@NOT %@ LIKE '%%%@%%' ",
				p, ThreadNameColumn, [token substringFromIndex : 1]];
		} else {
			[phrase appendFormat : @"%@%@ LIKE '%%%@%%' ",
				p, ThreadNameColumn, token];
		}
		p = @"AND ";
	}
	
	return phrase;
}
- (void) updateCursor
{
	id temp;
	
#ifdef DEBUG
	clock_t time00, time01, time02, time03;
#endif
	
	SQLiteDB *db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	
	NSString *sortCol = nil;
	NSString *ascending = @"";
	NSString *targetTable = [boardListItem query];
	NSMutableString *sql;
	
	sql = [NSMutableString stringWithFormat : @"SELECT * FROM (%@) ",targetTable];
	
	if (mSearchString) {
		id phrase = wherePhraseFromSearchString( mSearchString );
		if (phrase) {
			[sql appendString : phrase];
		}
	}
	
	if (![self isAscending]) ascending = @"DESC";
	
	if ([mSortKey isEqualTo : CMRThreadTitleKey]) {
		sortCol = ThreadNameColumn;
	} else if ([mSortKey isEqualTo : CMRThreadLastLoadedNumberKey]) {
		sortCol = NumberOfReadColumn;
	} else if ([mSortKey isEqualTo : CMRThreadNumberOfMessagesKey]) {
		sortCol = NumberOfAllColumn;
	} else if ([mSortKey isEqualTo : CMRThreadNumberOfUpdatedKey]) {
		sortCol = [NSString stringWithFormat : @"(%@ - %@)", NumberOfAllColumn, NumberOfReadColumn];
	} else if ([mSortKey isEqualTo : CMRThreadSubjectIndexKey]) {
		sortCol = TempThreadThreadNumberColumn;
	} else if ([mSortKey isEqualTo : CMRThreadStatusKey]) {
		sortCol = ThreadStatusColumn;
	} else if ([mSortKey isEqualTo : CMRThreadModifiedDateKey]) {
		sortCol = ModifiedDateColumn;
	}
	
	if (sortCol) {
		[sql appendFormat : @"ORDER BY %@ %@;",sortCol, ascending];
	}
	
#ifdef DEBUG
	time00 = clock();
#endif
	
	[cursorLock lock];
#ifdef DEBUG
	time01 = clock();
#endif
	temp = mCursor;
	mCursor = [[db cursorForSQL : sql] retain];
	if ([db lastErrorID] != 0) {
		[mCursor release];
		mCursor = [temp retain];
	}
	[temp release];
#ifdef DEBUG
	time02 = clock();
#endif
	[cursorLock unlock];
	
#ifdef DEBUG
	time03 = clock();
	
	printf("\ntotal time: %ld\ncursor lock time: %ld\ngetting cursor time: %ld\ncursor unlock time %ld\n",
		   time03 - time00, time01 - time00, time02 - time01, time03 - time02 );
#endif
	
	temp = data;
	data = [[mCursor arrayForTableView] retain];
	[temp release];
}
- (NSString *) boardName
{
	//	NSLog(@"CHECKKING ME! %s : %d", __FILE__, __LINE__);
	if (boardListItem) {
		return [boardListItem name];
	}
	
	return [super boardName];
}

- (unsigned) numberOfThreads
{
	return [mCursor rowCount];
}
- (unsigned) numberOfFilteredThreads
{
	return [mCursor rowCount];
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

// - (void) filterByStatus : (int) status

BOOL searchBoardIDAndThreadIDFromFilePath( int *outBoardID, NSString **outThreadID, NSString *inFilePath )
{
	CMRThreadSignature *threadSig = [CMRThreadSignature threadSignatureFromFilepath : inFilePath];
	
	if (outThreadID) {
		*outThreadID = [threadSig identifier];
	}
	
	if (outBoardID) {
		NSString *boardName;
		NSArray *boardIDs;
		
		boardName = [threadSig BBSName];
		if (!boardName) return NO;
		
		boardIDs = [[DatabaseManager defaultManager] boardIDsForName : boardName];
		if (!boardIDs || [boardIDs count] == 0) return NO;
		
		*outBoardID = [[boardIDs objectAtIndex : 0] intValue];
	}
	
	return YES;
}

- (void) setThreads : (NSMutableArray *) aThreads
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
		NSEnumerator *threadsEnum = [aThreads objectEnumerator];
		id thread;
		
		NSString *prevBoardName = nil;
		NSURL *boardURL;
		
		SQLiteReservedQuery *reservedInsert;
		SQLiteReservedQuery *reservedUpdate;
		SQLiteReservedQuery *reservedInsertNumber;
		
		id query;
		
		query = [NSString stringWithFormat : @"INSERT INTO %@ ( %@, %@, %@, %@, %@ ) VALUES ( ?, ?, ?, ?, ? );",
			ThreadInfoTableName,
			BoardIDColumn, ThreadIDColumn, ThreadNameColumn, NumberOfAllColumn, ThreadStatusColumn];
		reservedInsert = [db reservedQuery : query];
		if (!reservedInsert) {
			NSLog(@"Can NOT create reservedInsert");
			return;
		}
		
		query = [NSString stringWithFormat : @"UPDATE %@ SET %@ = ?, %@ = ? WHERE %@ = ? AND %@ = ?;",
			ThreadInfoTableName,
			NumberOfAllColumn, ThreadStatusColumn,
			BoardIDColumn, ThreadIDColumn];
		reservedUpdate = [db reservedQuery : query];
		if (!reservedUpdate) {
			NSLog(@"Can NOT create reservedUpdate");
			return;
		}
		
		query = [NSString stringWithFormat : @"INSERT INTO %@ ( %@, %@, %@ ) VALUES ( ?, ?, ? );",
			TempThreadNumberTableName,
			BoardIDColumn, ThreadIDColumn, TempThreadThreadNumberColumn];
		reservedInsertNumber = [db reservedQuery : query];
		if (!reservedInsertNumber) {
			NSLog(@"Can NOT create reservedInsertNumber");
			return;
		}
		
		query = [NSString stringWithFormat : @"DELETE FROM %@;",
			TempThreadNumberTableName];
		[db performQuery : query];
		incrementCount();
		
		while( thread = [threadsEnum nextObject] ) {
			id pool = [[NSAutoreleasePool alloc] init];
			
			NSString *boardName = [thread objectForKey : ThreadPlistBoardNameKey];
			
			NSString *title = [thread objectForKey : CMRThreadTitleKey];
			NSString *dat = [thread objectForKey : ThreadPlistIdentifierKey];
			NSNumber *count = [thread objectForKey : CMRThreadNumberOfMessagesKey];
			NSNumber *status = [thread objectForKey : CMRThreadStatusKey];
			NSNumber *index = [thread objectForKey : CMRThreadSubjectIndexKey];
			unsigned boardID;
			
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
				
				title = [SQLiteDB prepareStringForQuery : title];
				
				bindValues = [NSArray arrayWithObjects:
					[NSNumber numberWithUnsignedInt : boardID], dat, title, count, status, nil];
				[reservedInsert cursorForBindValues : bindValues];
				incrementCount();
				
				// 制約違反(複合主キーのユニーク制約)なら既に存在しているデータをアップデート
				if (SQLITE_CONSTRAINT == [db lastErrorID]) {
					bindValues = [NSArray arrayWithObjects:
						count, status,
						[NSNumber numberWithUnsignedInt : boardID], dat, nil];
					[reservedUpdate cursorForBindValues : bindValues];
					incrementCount();
					
					if ([db lastErrorID] != 0) {
						NSLog(@"Fail Insert or udate. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
					}
				}
				
				bindValues = [NSArray arrayWithObjects:
					[NSNumber numberWithUnsignedInt : boardID], dat, index, nil];
				[reservedInsertNumber cursorForBindValues : bindValues];
				incrementCount();
				
				if ([db lastErrorID] != 0) {
					NSLog(@"Fail Insert or udate. ErrorID -> %d. Reson: %@", [db lastErrorID], [db lastError] );
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
	
	[self updateCursor];
	
	[super setThreads : aThreads];
}

#pragma mark## DataSource ##
- (NSDictionary *) threadAttributesAtRowIndex : (int          ) rowIndex
                                  inTableView : (NSTableView *) tableView
{
	NSDictionary *result;
	id<SQLiteRow> row = [mCursor rowAtIndex : rowIndex];
	
	NSString *title = [row valueForColumn : ThreadNameColumn];
	NSNumber *newCount = [row valueForColumn : NumberOfAllColumn];
	NSString *dat = [row valueForColumn : ThreadIDColumn];
	NSString *boardName = [row valueForColumn : BoardNameColumn];
	NSNumber *status = [row valueForColumn : ThreadStatusColumn];
	
	result = [NSDictionary dictionaryWithObjectsAndKeys:
		title, CMRThreadTitleKey,
		newCount, CMRThreadNumberOfMessagesKey,
		dat, ThreadPlistIdentifierKey,
		boardName, ThreadPlistBoardNameKey,
		status, CMRThreadUserStatusKey,
		nil];
	
	return result;
}
- (unsigned int) indexOfThreadWithPath : (NSString *) filepath
{
	unsigned result;
	CMRThreadSignature *threadSig = [CMRThreadSignature threadSignatureFromFilepath : filepath];
	NSString *identifier = [threadSig identifier];
	
	NSArray *threadIDs = [mCursor valuesForColumn : ThreadIDColumn];
	
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
	return [mCursor rowCount];
}

- (id)tableView : (NSTableView *)tableView objectValueForTableColumn : (NSTableColumn *)tableColumn row : (int)rowIndex
{
	NSString *identifier = [tableColumn identifier];
	id <SQLiteRow> row = [data objectAtIndex : rowIndex];
	id result = nil;
	
	ThreadStatus s = [[row valueForColumn : ThreadStatusColumn] intValue];
	
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
		[sql appendFormat : @"WHERE %@ = %u AND %@ = '%@';",
			BoardIDColumn, baordID, ThreadIDColumn, threadID];
		
		db = [[DatabaseManager defaultManager] databaseForCurrentThread];
		[db cursorForSQL : sql];
		
		if ([db lastErrorID] != 0) {
			NSLog(@"Fail Insert or udate. Reson: %@", [db lastError] );
		}
		
		[self updateCursor];
		
	} while ( NO );
	
	[self postListDidUpdateNotification : CMRAutoscrollWhenThreadUpdate];
}

@end

@implementation NSObject(Compare)
- (NSComparisonResult)compareForBS : (id)obj
{
	int c = (int)self - (int)obj;
	
	if (c > 0) {
		return NSOrderedDescending;
	} else if ( c < 0 ) {
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}
@end

@implementation NSString (Compare)
- (NSComparisonResult)compareForBS : (id)obj
{
	if (![obj isKindOfClass : [NSString class]]) {
		return NSOrderedAscending;
	}
	
	return [self compare : obj];
}
@end

@implementation NSNumber (Compare)
- (NSComparisonResult)compareForBS : (id)obj
{
	if (![obj isKindOfClass : [NSNumber class]]) {
		return NSOrderedAscending;
	}
	
	return [self compare : obj];
}
@end

@implementation NSDate (Compare)
- (NSComparisonResult)compareForBS : (id)obj
{
	if (![obj isKindOfClass : [NSDate class]]) {
		return NSOrderedAscending;
	}
	
	return [self compare : obj];
}
@end

@implementation NSNull (Compare)
- (NSComparisonResult)compareForBS : (id)obj
{
	if ([obj isKindOfClass : [NSNull class]]) return NSOrderedSame;
	
	return NSOrderedDescending;
}
@end
