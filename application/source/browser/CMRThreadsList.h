/**
  * $Id: CMRThreadsList.h,v 1.12 2007/03/25 13:27:55 masakih Exp $
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

enum {
	kValueTemplateDefaultType,
	kValueTemplateNewArrivalType,
	kValueTemplateNewUnknownType,
	kValueTemplateDatOchiType // Available in Starlight Breaker.
};

@interface CMRThreadsList : NSObject 
{
	NSString				*_BBSName;
	CMRThreadLayout			*_worker;
	
	NSMutableArray			*_threads;
	NSMutableArray			*_filteredThreads;
//	NSMutableDictionary		*_threadsInfo;

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
- (void) doLoadThreadsList : (CMRThreadLayout *) worker;
- (CMRThreadLayout *) worker;
- (void) setWorker : (CMRThreadLayout *) aWorker;

- (BOOL) isFavorites;
- (BOOL)isSmartItem;
- (BOOL) addFavoriteAtRowIndex : (int          ) rowIndex
				   inTableView : (NSTableView *) tableView;

- (id) objectValueForBoardInfo;
@end


@interface CMRThreadsList(PrivateAccessor)
- (void) setBBSName : (NSString *) boardName;
@end


@interface CMRThreadsList(CleanUp)
- (void) cleanUpItemsToBeRemoved : (NSArray *) files;

- (BOOL) tableView : (NSTableView	*) tableView
	removeIndexSet : (NSIndexSet	*) indexSet
 delFavIfNecessary : (BOOL			 ) flag;
- (BOOL) tableView : (NSTableView	*) tableView
	   removeFiles : (NSArray		*) files
 delFavIfNecessary : (BOOL			 ) flag;
@end


@interface CMRThreadsList(AccessingList)
- (NSMutableArray *) threads;
- (void) setThreads : (NSMutableArray *) aThreads;
- (NSMutableArray *) filteredThreads;
//- (void) setFilteredThreads : (NSMutableArray *) aFilteredThreads;
- (int) filteringMask;
- (void) setFilteringMask : (int) mask;
- (BOOL) isAscending;
- (void) setIsAscending : (BOOL)  flag;
//- (NSMutableDictionary *) threadsInfo;
//- (void) setThreadsInfo : (NSMutableDictionary *) aThreadsInfo;
- (void) toggleIsAscending;
- (void) sortByKey : (NSString *) key;
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

+ (NSDictionary *)newThreadCreatedDateAttrTemplate;
+ (NSDictionary *)threadCreatedDateAttrTemplate;
+ (NSDictionary *)threadModifiedDateAttrTemplate;
+ (NSDictionary *)threadLastWrittenDateAttrTemplate;

+ (id) objectValueTemplate : (id ) aValue
				   forType : (int) aType;


- (NSArray *) threadFilePathArrayWithRowIndexSet : (NSIndexSet	*) anIndexSet
									 inTableView : (NSTableView	*) tableView;

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
@end

@interface CMRThreadsList(DraggingImage)
- (NSImage *) dragImageForRowIndexes: (NSIndexSet *) rowIndexes
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

// Notification
extern NSString *const CMRThreadsListDidUpdateNotification;
extern NSString *const CMRThreadsListDidChangeNotification;
extern NSString *const ThreadsListUserInfoSelectionHoldingMaskKey;
