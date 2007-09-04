/**
  * $Id: CMRThreadsList.m,v 1.20 2007/09/04 07:45:43 tsawada2 Exp $
  * 
  * CMRThreadsList.m
  *
  * Copyright (c) 2003, Takanori Ishikawa, and 2005-2006, BathyScaphe Project.
  * See the file LICENSE for copying permission.
  */

#import "CMRThreadsList_p.h"
#import "CMRThreadLayout.h"
#import "BoardManager.h"
#import "CMRDocumentFileManager.h"
#import "CMRReplyDocumentFileManager.h"
#import "NSIndexSet+BSAddition.h"
#import "missing.h"


NSString *const CMRThreadsListDidUpdateNotification = @"ThreadsListDidUpdateNotification";
NSString *const CMRThreadsListDidChangeNotification = @"ThreadsListDidChangeNotification";
NSString *const ThreadsListUserInfoSelectionHoldingMaskKey = @"ThreadsListUserInfoSelectionHoldingMaskKey";


@implementation CMRThreadsList
+ (id) threadsListWithBBSName : (NSString *) boardName
{
	return [[[self alloc] initWithBBSName : boardName] autorelease];
}

- (id) initConcreateWithBBSName : (NSString *) boardName
{
	NSURL		*boardURL_;
	
	boardURL_ = [[BoardManager defaultManager] URLForBoardName : boardName];
	if(nil == boardURL_){
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
	return [self initConcreateWithBBSName : boardName];
}

- (id) init
{
	if(self = [super init]){
		[self registerToNotificationCenter];
	}
	return self;
}

- (void) dealloc
{
	[self removeFromNotificationCenter];
	
	[_BBSName release];
	[_worker release];
	[_threads release];
	[_filteredThreads release];
//	[_threadsInfo release];
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
	UTILAbstractMethodInvoked;
	return NO;
}
/*- (BOOL) addFavoriteAtRowIndex : (int          ) rowIndex
				   inTableView : (NSTableView *) tableView
{
	NSDictionary *thread_;
	
	thread_ = [self threadAttributesAtRowIndex : rowIndex
								   inTableView : tableView];
	return [[CMRFavoritesManager defaultManager] addFavoriteWithThread : thread_];
}*/
+ (NSString *) objectValueForBoardInfoFormatKey
{
//	return @"Board Info Format";
	static NSString *base_ = nil;
	if (base_ == nil) {
		base_ = [NSLocalizedStringFromTable(@"Board Info Format", @"ThreadsList", @"") retain];
	}
	return base_;
}

- (id) objectValueForBoardInfo
{
	NSString	*format_;
	id			tmp;
	
	tmp = SGTemporaryString();
//	format_ = [self localizedString : [[self class] objectValueForBoardInfoFormatKey]];
	format_ = [[self class] objectValueForBoardInfoFormatKey];
	[tmp appendFormat : format_, [self numberOfThreads]];
	return tmp;
}
- (void) doLoadThreadsList : (CMRThreadLayout *) worker
{
	UTILAbstractMethodInvoked;
}
- (BOOL)isSmartItem
{
	UTILAbstractMethodInvoked;
	return NO;
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

- (NSMutableArray *) filteredThreads
{
	if(nil == _filteredThreads) {
		[self filterByStatus : [self filteringMask]];
	} else if ([_filteredThreads count] == 0) {
		return nil;
	}
	return _filteredThreads;
}
/*- (void) setFilteredThreads : (NSMutableArray *) aFilteredThreads
{
	id tmp = _filteredThreads;
	[self _filteredThreadsLock];
	_filteredThreads = [aFilteredThreads retain];
	[self _filteredThreadsUnlock];
	[tmp release];
}*/
- (int) filteringMask
{
//	return [CMRPref browserStatusFilteringMask];
	return 0;
}
- (void) setFilteringMask : (int) mask
{
//	[CMRPref setBrowserStatusFilteringMask : mask];
	NSLog(@"WARNING: CMRThreadsList's -setFilteringMask: is Deprecated.");
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
/*- (NSMutableDictionary *) threadsInfo
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
}*/
- (void) toggleIsAscending
{
	[self setIsAscending : (NO == [self isAscending])];
}
- (void) sortByKey : (NSString *) key
{
	UTILAbstractMethodInvoked;
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

@implementation CMRThreadsList(CleanUp)
- (void) cleanUpItemsToBeRemoved : (NSArray *) files
{
	UTILAbstractMethodInvoked;
}

- (BOOL) tableView : (NSTableView *) tableView
	   removeItems : (NSArray	  *) rows
 delFavIfNecessary : (BOOL         ) flag
{
	NSIndexSet	*indexSet = [NSIndexSet rowIndexesWithRows: rows];
	return [self tableView: tableView removeIndexSet: indexSet delFavIfNecessary: flag];
}

- (BOOL) tableView : (NSTableView	*) tableView
	removeIndexSet : (NSIndexSet	*) indexSet
 delFavIfNecessary : (BOOL			 ) flag
{
	NSArray	*pathArray_;
	pathArray_ = [self threadFilePathArrayWithRowIndexSet : indexSet inTableView : tableView];

	return [self tableView : tableView removeFiles : pathArray_ delFavIfNecessary : flag];
}

- (BOOL) tableView : (NSTableView	*) tableView
	   removeFiles : (NSArray		*) files
 delFavIfNecessary : (BOOL			 ) flag
{
	BOOL tmp;

	if(flag) {
		NSArray	*alsoReplyFiles_;

		alsoReplyFiles_ = [[CMRReplyDocumentFileManager defaultManager] replyDocumentFilesArrayWithLogsArray : files];
		tmp = [[CMRTrashbox trash] performWithFiles : alsoReplyFiles_ fetchAfterDeletion: NO];
	} else {
		tmp = [[CMRTrashbox trash] performWithFiles : files fetchAfterDeletion: YES];
	}
	
	return tmp;
}
@end

@implementation CMRThreadsList(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
	return APP_TLIST_LOCALIZABLE_FILE;
}
@end
