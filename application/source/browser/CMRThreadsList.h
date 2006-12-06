/**
  * $Id: CMRThreadsList.h,v 1.6.4.5 2006/12/06 02:33:30 tsawada2 Exp $
  * 
  * CMRThreadsList.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CocoMonar_Prefix.h"

@class CMRDownloader;
@class CMRThreadLayout;

@interface CMRThreadsList : NSObject 
{
	NSString				*_BBSName;
	CMRThreadLayout			*_worker;
	
	NSMutableArray			*_threads;
	NSMutableArray			*_filteredThreads;
	NSMutableDictionary		*_threadsInfo;
	
	NSLock		*_threadsListUpdateLock;
	NSLock		*_filteredThreadsLock;

	BOOL		_isAscending;
}

- (id) initWithBBSName : (NSString *) boardName;
+ (id) threadsListWithBBSName : (NSString *) boardName;

/**
  * 
  * 読み込みを開始。
  * 初期化したクラスは直後に呼び出すこと。
  * workerを保持する。
  * 
  */
- (void) startLoadingThreadsList : (CMRThreadLayout *) worker;
- (CMRThreadLayout *) worker;
- (void) setWorker : (CMRThreadLayout *) aWorker;

- (BOOL) isFavorites;
- (BOOL) addFavoriteAtRowIndex : (int          ) rowIndex
				   inTableView : (NSTableView *) tableView;

- (id) objectValueForBoardInfo;
- (BOOL) writeListToFileNow;
@end





@interface CMRThreadsList(AccessingList)
- (NSMutableArray *) threads;
- (void) setThreads : (NSMutableArray *) aThreads;
- (NSMutableArray *) filteredThreads;
- (void) setFilteredThreads : (NSMutableArray *) aFilteredThreads;
- (int) filteringMask;
- (void) setFilteringMask : (int) mask;
- (BOOL) isAscending;
- (void) setIsAscending : (BOOL)  flag;
- (NSMutableDictionary *) threadsInfo;
- (void) setThreadsInfo : (NSMutableDictionary *) aThreadsInfo;
- (void) toggleIsAscending;
- (void) sortByKey : (NSString *) key;
- (void) _sortArrayByKey : (NSString       *) key
                   array : (NSMutableArray *) array;
@end


 
@interface CMRThreadsList(Attributes)
- (NSString *) BBSName;
- (NSString *) boardName;
- (NSString *) threadsListPath;
- (NSURL *) boardURL;

- (unsigned) numberOfThreads;
- (unsigned) numberOfFilteredThreads;
@end



@interface CMRThreadsList(Filter)
- (void) filterByDisplayingThreadAtPath : (NSString *) filepath;
- (void) filterByStatus : (int) status;

// Available in MeteorSweeper.
- (BOOL) filterByString: (NSString *) searchString;

- (NSArray *) _arrayWithStatus : (ThreadStatus    ) status
               fromSortedArray : (NSMutableArray *) array
			     subarrayRange : (NSRangePointer  ) aRange;
- (void) _filteredThreadsLock;
- (void) _filteredThreadsUnlock;
@end



@interface CMRThreadsList(SearchThreads)
- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath;
- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath
									inArray : (NSArray  *) array;

// Added in TestaRossa and later.
- (NSArray *) _searchThreadsInArray : (NSArray *) array context : (NSString *) context;
@end



@interface CMRThreadsList(DataSource)
+ (void) resetDataSourceTemplates;
// Available in ReinforceII.
+ (void) resetDataSourceTemplateForColumnIdentifier: (NSString *) identifier width: (float) loc;
+ (void) resetDataSourceTemplateForDateColumn;

+ (id) objectValueTemplate : (id ) aValue
				   forType : (int) aType;


- (NSArray *) threadFilePathArrayWithRowIndexSet : (NSIndexSet	*) anIndexSet
									 inTableView : (NSTableView	*) tableView;
// Removed in ReinforceII and later. Use threadFilePathArrayWithRowIndexSet:inTableView: instead.
//- (NSArray *) threadFilePathArrayWithRowIndexArray : (NSArray	  *) anIndexArray
//									   inTableView : (NSTableView *)tableView;
- (ThreadStatus) threadStatusForThread : (NSDictionary *) aThread;
- (id) objectValueForIdentifier : (NSString *) identifier
					threadArray : (NSArray  *) threadArray
						atIndex : (int       ) index;
- (NSString *) threadFilePathAtRowIndex : (int          ) rowIndex
                            inTableView : (NSTableView *) tableView
							     status : (ThreadStatus *) status;
- (NSDictionary *) threadAttributesAtRowIndex : (int          ) rowIndex
                                  inTableView : (NSTableView *) tableView;

- (unsigned int) indexOfThreadWithPath : (NSString *) filepath;

// available in ReinforceII and later.
- (NSImage *) dragImageForTheRow: (unsigned int) rowIndex
					 inTableView: (NSTableView *) tableView
						  offset: (NSPointPointer) dragImageOffset;
@end



@interface CMRThreadsList(Download)
- (void) downloadThreadsList;
- (void) postListDidUpdateNotification : (int) mask;
@end




@interface CMRThreadsList(ListImport)
+ (void) clearAttributes : (NSMutableDictionary *) attributes;
+ (NSMutableDictionary *) attributesForThreadsListWithContentsOfFile : (NSString *) path;
+ (id) threadsListTemplateWithPath : (NSString *) path;
@end



@interface w2chFavoriteItemList : CMRThreadsList
@end



// Notification
extern NSString *const CMRThreadsListDidUpdateNotification;
extern NSString *const CMRThreadsListDidChangeNotification;
extern NSString *const ThreadsListUserInfoSelectionHoldingMaskKey;
