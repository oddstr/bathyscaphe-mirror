/**
  * $Id: CMRThreadsList.m,v 1.10.4.1 2006/08/25 17:48:01 masakih Exp $
  * 
  * CMRThreadsList.m
  *
  * Copyright (c) 2003, Takanori Ishikawa, and 2005-2006, BathyScaphe Project.
  * See the file LICENSE for copying permission.
  */

#import "CMRThreadsList_p.h"
#import "CMRThreadLayout.h"
#import "BoardManager.h"
#import "CMRThreadsUpdateListTask.h"
#import "CMRDocumentFileManager.h"
#import "missing.h"


NSString *const CMRThreadsListDidUpdateNotification = @"ThreadsListDidUpdateNotification";
NSString *const CMRThreadsListDidChangeNotification = @"ThreadsListDidChangeNotification";
NSString *const ThreadsListUserInfoSelectionHoldingMaskKey = @"ThreadsListUserInfoSelectionHoldingMaskKey";



// ソート
static NSComparisonResult sortArrayByContextKey(id arg1, id arg2, void *aKey);
static NSComparisonResult sortArrayByStatus(id arg1, id arg2, void *alternateKey);
static NSComparisonResult sortArrayByStatusAtFav(id arg1, id arg2, void *alternateKey);
static NSComparisonResult sortArrayByFavNumKey(id arg1, id arg2, void *alternateKey);

#define SORT_KEY(context)		(context)->key
#define SORT_ASCENDING(context)	(context)->flags.isAscending
#define SORT_NEWTHREAD(context)	(context)->flags.collectsByNewArrival

struct SortContext {
	NSString	*key;
	struct {
		unsigned	isAscending:1;
		unsigned	collectsByNewArrival:1;
		unsigned	reserved:30;
	} flags;
};



@implementation CMRThreadsList
+ (id) threadsListWithBBSName : (NSString *) boardName
{
	return [[[self alloc] initWithBBSName : boardName] autorelease];
}

- (id) initConcreateWithBBSName : (NSString *) boardName
{
	NSURL		*boardURL_;
	
	boardURL_ = [[BoardManager defaultManager] URLForBoardName : boardName];
	if((NO == [CMXFavoritesDirectoryName isSameAsString : boardName]) && nil == boardURL_){
		[self autorelease];
		return nil;
	}
	
	if(self = [self init]){
		[self setBBSName : boardName];
	}
	return self;
}

- (id) initWithBBSName : (NSString *) boardName
{
	if([CMXFavoritesDirectoryName isSameAsString : boardName]){
		[self autorelease];
		return [[w2chFavoriteItemList alloc] 
					initConcreateWithBBSName : boardName];
	}
	
	return [self initConcreateWithBBSName : boardName];
}

- (id) init
{
	if(self = [super init]){
		[self registerToNotificationCenter];

		_threadsListUpdateLock = [[NSLock alloc] init];
		_filteredThreadsLock = [[NSLock alloc] init];
	}
	return self;
}

- (BOOL) writeListToFileNow
{
/*	if ([CMRPref saveThreadListAsBinaryPlist]) {
		NSData *data_;
		NSString *errStr;
		data_ = [NSPropertyListSerialization dataFromPropertyList : [self threads]
														   format : NSPropertyListBinaryFormat_v1_0
												 errorDescription : &errStr];
		
		if(!data_) {
			NSLog(errStr);
			[errStr release];
			goto standard_writing;
		} else {
			return [data_ writeToFile : [self threadsListPath] atomically : NO];
		}
	}

standard_writing:*/
	return [[self threads] writeToFile : [self threadsListPath] atomically : NO];
}

- (void) dealloc
{
	[self removeFromNotificationCenter];

	if (NO == [self isFavorites]) {
		[self writeListToFileNow];
	}
	
	[_BBSName release];

	[_worker release];
	[_threadsListUpdateLock release];
	[_filteredThreadsLock release];
	[_threads release];
	[_filteredThreads release];
	[_threadsInfo release];
	[dateFormatter release];
	[super dealloc];
}

// CMRThreadsList:
- (void) startLoadingThreadsList : (CMRThreadLayout *) worker
{
	[self doLoadThreadsList : worker];
}
- (CMRThreadLayout *) worker
{
	return _worker;
}
- (void) setWorker : (CMRThreadLayout *) aWorker
{
	id		tmp;
	
	tmp = _worker;
	_worker = [aWorker retain];
	[tmp release];
}

- (BOOL) isFavorites
{
	return NO;
}
- (BOOL) addFavoriteAtRowIndex : (int          ) rowIndex
				   inTableView : (NSTableView *) tableView
{
	NSDictionary *thread_;
	
	thread_ = [self threadAttributesAtRowIndex : rowIndex
								   inTableView : tableView];
	return [[CMRFavoritesManager defaultManager] addFavoriteWithThread : thread_];
}
+ (NSString *) objectValueForBoardInfoFormatKey
{
	return @"Board Info Format";
}

- (id) objectValueForBoardInfo
{
	NSString	*format_;
	id			tmp;
	
	tmp = SGTemporaryString();
	format_ = [self localizedString : [[self class] objectValueForBoardInfoFormatKey]];
	[tmp appendFormat : format_, [self numberOfThreads]];
	return tmp;
}
@end



@implementation CMRThreadsList(PrivateAccessor)
- (void) setBBSName : (NSString *) boardName
{
	id		tmp;
	
	tmp = _BBSName;
	_BBSName = [boardName retain];
	[tmp release];
}
@end



@implementation CMRThreadsList(AccessingList)
- (NSMutableArray *) threads
{
	return _threads;
}
- (void) setThreads : (NSMutableArray *) aThreads
{
	id tmp_;
	
	tmp_ = _threads;
	_threads = [aThreads retain];
	[tmp_ release];
}

/*
	2005-02-12 tsawada2<ben-sawa@td5.so-net.ne.jp>
	filteredThreads アクセッサ・メソッドは、 _filteredThreads が nil だった場合でも、nil を返す訳ではない。
	しかし、検索結果が見つからないときは、スレッド一覧を空にしたい。つまり、nil を返してほしい。
	そこで検索結果が見つからないときは、temporaryArrayWithFindOperation:fromArray: で
	特別な配列（ただ一つの NSString 要素 "SearchNotFound" を含む配列）を返すことにして、
	filteredThreads アクセッサ・メソッドでは、もし _filteredThreads がその「特別な配列」だったら nil を返すことにする。
*/
- (NSMutableArray *) filteredThreads
{
	if(nil == _filteredThreads) {
		[self filterByStatus : [self filteringMask]];
	} else if ([_filteredThreads containsObject : @"SearchNotFound"]) {
		//NSLog(@"Contains SearchNotFound.");
		return nil;
	}
	return _filteredThreads;
}
- (void) setFilteredThreads : (NSMutableArray *) aFilteredThreads
{
	id tmp = _filteredThreads;
	[self _filteredThreadsLock];
	_filteredThreads = [aFilteredThreads retain];
	[self _filteredThreadsUnlock];
	[tmp release];
}
- (int) filteringMask
{
	return [CMRPref browserStatusFilteringMask];
}
- (void) setFilteringMask : (int) mask
{
	[CMRPref setBrowserStatusFilteringMask : mask];
}
/* Accessor for _isAscending */
- (BOOL) isAscending
{
	return _isAscending;
}
- (void) setIsAscending : (BOOL) flag
{
	_isAscending = flag;
}
/* Accessor for _threadsInfo */
- (NSMutableDictionary *) threadsInfo
{
	if(nil == _threadsInfo){
		_threadsInfo = [[NSMutableDictionary alloc] init];
	}
	return _threadsInfo;
}
- (void) setThreadsInfo : (NSMutableDictionary *) aThreadsInfo
{
	[aThreadsInfo retain];
	[_threadsInfo release];
	_threadsInfo = aThreadsInfo;
}
- (void) toggleIsAscending
{
	[self setIsAscending : (NO == [self isAscending])];
}
- (void) sortByKey : (NSString *) key
{
	[self _filteredThreadsLock];
	[self _sortArrayByKey:key array:[self filteredThreads]];
	[self _filteredThreadsUnlock];
}
- (void) _sortArrayByKey : (NSString       *) key
                   array : (NSMutableArray *) theArray
{
	struct SortContext context;
	int(*func_)(id, id, void *);
	
	if([key isEqualToString : CMRThreadStatusKey]){
		func_ = [self isFavorites] ? sortArrayByStatusAtFav : sortArrayByStatus;
		key   = CMRThreadSubjectIndexKey;
	}else if([key isEqualToString : CMRThreadSubjectIndexKey] && [self isFavorites]){
		func_ = sortArrayByFavNumKey;
	}else{
		func_ = sortArrayByContextKey;
	}
	SORT_KEY(&context) = key;
	SORT_ASCENDING(&context) = [self isAscending];
	SORT_NEWTHREAD(&context) = [CMRPref collectByNew];
	
	[theArray sortUsingFunction : func_
						context : &context];
}
@end



@implementation CMRThreadsList(Attributes)
- (NSString *) BBSName
{
	return _BBSName;
}
- (NSString *) boardName
{
	return [self BBSName];
}
- (NSString *) threadsListPath
{
	//return [[self BBSSignature] threadsListPlistPath];
	return [[CMRDocumentFileManager defaultManager] threadsListPathWithBoardName : [self boardName]];
}
- (NSURL *) boardURL
{
	return [[BoardManager defaultManager] URLForBoardName : [self boardName]];
}

- (unsigned) numberOfThreads
{
	if(nil == [self threads]) return 0;
	return [[self threads] count];
}
- (unsigned) numberOfFilteredThreads
{
	if(nil == [self filteredThreads]) return 0;
	return [[self filteredThreads] count];
}
@end



@implementation CMRThreadsList(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
	return APP_TLIST_LOCALIZABLE_FILE;
}
@end

#pragma mark -

static NSComparisonResult sortArrayByContextKey(id arg1, id arg2, void *context)
{
	struct SortContext	*context_ = (struct SortContext*)context;
	NSString			*key_;
	NSComparisonResult	result;
	
	key_ = context_ ? SORT_KEY(context_) : CMRThreadModifiedDateKey;
	
	// 新着スレッドは常に大きい位置に持っていくか？
	if(SORT_NEWTHREAD(context_)){
		BOOL	new1, new2;
		NSNumber	*s1, *s2;
		s1 = [arg1 objectForKey : CMRThreadStatusKey];
		s2 = [arg2 objectForKey : CMRThreadStatusKey];
		if (s1 == nil) {
			new1 = NO;
		} else {
			new1 = (ThreadNewCreatedStatus == [s1 unsignedIntValue]);
		}
		if (s2 == nil) {
			new2 = NO;
		} else {
			new2 = (ThreadNewCreatedStatus == [s2 unsignedIntValue]);
		}
		
		if(new1 != new2)
			return new1 ? NSOrderedAscending : NSOrderedDescending;
	}
	
	// 差分
	if([CMRThreadNumberOfUpdatedKey isEqualToString : key_]){
		int		d1, d2;
		
		d1 = [CMRThreadAttributes numberOfUpdatedFromDictionary : arg1];
		d2 = [CMRThreadAttributes numberOfUpdatedFromDictionary : arg2];
		result = UTILComparisionResultPrimitives(d1, d2);
		
	}else{
		id<SGComparable, NSObject>	o1, o2;

		o1 = [arg1 objectForKey : key_];
		o2 = [arg2 objectForKey : key_];
		
		if (nil == o1 && nil == o2)
			result = NSOrderedSame;
		else if (nil == o1)
			result = NSOrderedAscending;
		else if (nil == o2)
			result = NSOrderedDescending;
		else
			result = [o1 compareTo : o2];
		
	}
	
	if(NSOrderedSame == result &&
	   NO == [key_ isEqualToString : CMRThreadSubjectIndexKey]){
		// 結果が同値の場合はインデックスで比較
		// また、結果は反転させる
		SORT_KEY(context_) = CMRThreadSubjectIndexKey;
		result =  sortArrayByContextKey(arg1, arg2, context_);
		SORT_KEY(context_) = key_;
	}

	return (SORT_ASCENDING(context_)) 
				? result
				: UTILComparisionResultReversed(result);
}

static NSComparisonResult sortArrayByStatus(id arg1, id arg2, void *context)
{
	struct SortContext	*context_ = (struct SortContext*)context;
	NSNumber			*s1, *s2;
	NSComparisonResult	result;
	
	s1 = [arg1 objectForKey : CMRThreadStatusKey];
	s2 = [arg2 objectForKey : CMRThreadStatusKey];
	
	result = UTILComparisionResultObjects(s1, s2);
	if(NSOrderedSame == result){
		// sortArrayByContextKey() ですでに SORT_ASCENDING
		// はチェックされている。
		result = sortArrayByContextKey(arg1, arg2, context_);
		return result;
		// return (UTILComparisionResultReversed(result));
	}
	
	return (!SORT_ASCENDING(context_)) 
				? result
				: UTILComparisionResultReversed(result);
}

static NSComparisonResult sortArrayByStatusAtFav(id arg1, id arg2, void *context)
{
	struct SortContext	*context_ = (struct SortContext*)context;
	NSNumber			*s1, *s2;
	NSComparisonResult	result;
	
	s1 = [arg1 objectForKey : CMRThreadStatusKey];
	s2 = [arg2 objectForKey : CMRThreadStatusKey];
	
	result = UTILComparisionResultObjects(s1, s2);
	if(NSOrderedSame == result){
		// お気に入りのときは専用のソート関数でやる必要があるので
		result = sortArrayByFavNumKey(arg1, arg2, context_);
		return result;
	}
	
	return (!SORT_ASCENDING(context_)) 
				? result
				: UTILComparisionResultReversed(result);
}

static NSComparisonResult sortArrayByFavNumKey(id arg1, id arg2, void *context)
{
	struct SortContext	*context_ = (struct SortContext*)context;
	NSNumber			*s1, *s2;
	NSComparisonResult	result;
	NSArray				*favItemsIdx_ = [[CMRFavoritesManager defaultManager] favoritesItemsIndex];
		
	s1 = [NSNumber numberWithInt :
					[favItemsIdx_ indexOfObject : [CMRThreadAttributes pathFromDictionary : arg1]]];
	s2 = [NSNumber numberWithInt :
					[favItemsIdx_ indexOfObject : [CMRThreadAttributes pathFromDictionary : arg2]]];
	
	result = UTILComparisionResultObjects(s1, s2);
	if(NSOrderedSame == result){
		result = sortArrayByContextKey(arg1, arg2, context_);
		return result;
	}
	
	return (!SORT_ASCENDING(context_)) 
				? UTILComparisionResultReversed(result)
				: result;
}
