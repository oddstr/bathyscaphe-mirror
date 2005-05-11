//:CMRFavoritesManager.m
/**
  *
  * @see CMRThreadAttributes.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.1.1d1 (05/03/07  11:43:00 AM)
  *
  */
#import "CMRFavoritesManager_p.h"
#import "CMRBBSSignature.h"
#import "CMRThreadsList_p.h"


//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
NSString *const CMRFavoritesManagerDidLinkFavoritesNotification = @"CMRFavoritesManagerDidLinkFavoritesNotification";
NSString *const CMRFavoritesManagerDidRemoveFavoritesNotification = @"CMRFavoritesManagerDidRemoveFavoritesNotification";

static NSString *const kFavItemsPoolMaxCountKey = @"Favorites - MaxCountForPool";

@implementation CMRFavoritesManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

+ (NSString *) defaultFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRFavoritesFile
						resolvingFileRef : NULL];
}

// 暫定
+ (NSString *) subFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRFavMemoFile
						resolvingFileRef : NULL];
}

- (id) init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(applicationWillTerminate:)
					    name : NSApplicationWillTerminateNotification
					  object : NSApp];
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[_favoritesItemsArray release];
	[_favoritesItemsIndex release];
	[_changedFavItemsPool release];
	[super dealloc];
}

- (void) applicationWillTerminate : (NSNotification *) notification
{	
	UTILAssertNotificationName(
		notification,
		NSApplicationWillTerminateNotification);
	UTILAssertNotificationObject(
		notification,
		NSApp);	
	
	[[self favoritesItemsArray] writeToFile : [[self class] defaultFilepath]
								 atomically : YES];
	[[self changedFavItemsPool] writeToFile : [[self class] subFilepath]
								 atomically : YES];

}

#pragma mark -

- (NSMutableArray *) favoritesItemsArray
{
	if (nil == _favoritesItemsArray) {
		_favoritesItemsArray = [[NSMutableArray alloc] initWithContentsOfFile : 
														[[self class] defaultFilepath]];
	}
	if (nil == _favoritesItemsArray) {
		_favoritesItemsArray = [[NSMutableArray empty] mutableCopy];
	}
	
	return _favoritesItemsArray;
}

- (void) setFavoritesItemsArray : (NSMutableArray *) anArray
{
	id		tmp;
	
	tmp = _favoritesItemsArray;
	_favoritesItemsArray = [anArray mutableCopyWithZone : [self zone]];
	[tmp release];
}

- (NSMutableArray *) favoritesItemsIndex
{
	if (nil == _favoritesItemsIndex) {
		if ([[self favoritesItemsArray] isEmpty]) {
			_favoritesItemsIndex = [[NSMutableArray empty] mutableCopy];
		} else {
			NSEnumerator	*iter_;
			NSDictionary	*anItem_;	// each favorite item

			_favoritesItemsIndex = [[NSMutableArray empty] mutableCopy];

			iter_ = [[self favoritesItemsArray] objectEnumerator];
	
			while ((anItem_ = [iter_ nextObject]) != nil) {
				id	itemPath_;
		
				itemPath_ = [CMRThreadAttributes pathFromDictionary : anItem_];
				if (itemPath_ == nil) itemPath_ = [NSNull null];
				
				[_favoritesItemsIndex addObject : itemPath_];
			}
		}
	}
	
	return _favoritesItemsIndex;
}		

- (void) setFavoritesItemsIndex : (NSMutableArray *) anArray
{
	id		tmp;
	
	tmp = _favoritesItemsIndex;
	_favoritesItemsIndex = [anArray mutableCopyWithZone : [self zone]];
	[tmp release];
}

// このへん、暫定的な実装
- (NSMutableArray *) changedFavItemsPool
{
	if (nil == _changedFavItemsPool) {
		_changedFavItemsPool = [[NSMutableArray alloc] initWithContentsOfFile : 
														[[self class] subFilepath]];
	}
	if (nil == _changedFavItemsPool) {
		_changedFavItemsPool = [[NSMutableArray empty] mutableCopy];
	}
	
	return _changedFavItemsPool;
}

- (void) setChangedFavItemsPool : (NSMutableArray *) anArray
{
	id		tmp;
	
	tmp = _changedFavItemsPool;
	_changedFavItemsPool = [anArray mutableCopyWithZone : [self zone]];
	[tmp release];
}

- (NSMutableArray *) itemsForRemoving
{
	NSEnumerator	*iter_;
	NSString		*anItem_;	// each pool item
	
	NSMutableArray	*array_ = [NSMutableArray array];

	iter_ = [[self changedFavItemsPool] objectEnumerator];
	
	while ((anItem_ = [iter_ nextObject]) != nil) {
		if (![[self favoritesItemsIndex] containsObject : anItem_])
			[array_ addObject : anItem_];
	}

	return array_;
}

- (NSMutableArray *) itemsForChange
{
	NSEnumerator	*iter_;
	NSString		*anItem_;	// each pool item
	
	NSMutableArray	*array_ = [NSMutableArray array];

	iter_ = [[self changedFavItemsPool] objectEnumerator];
	
	while ((anItem_ = [iter_ nextObject]) != nil) {
		if ([[self favoritesItemsIndex] containsObject : anItem_])
			[array_ addObject : anItem_];
	}

	return array_;
}
@end

#pragma mark -

@implementation CMRFavoritesManager(Management)
- (CMRFavoritesOperation) avalableOperationWithPath : (NSString *) filepath
{
	NSString				*fileType_;
	NSDocumentController	*docc_;
	
	if(nil == filepath) return NO;
	
	if(NO == [[NSFileManager defaultManager] fileExistsAtPath : filepath])
		return CMRFavoritesOperationNone;
	
	if([self favoriteItemExistsOfThreadPath : filepath])
		return CMRFavoritesOperationRemove;
	
	docc_ = [NSDocumentController sharedDocumentController];
	fileType_ = [docc_ typeFromFileExtension : [filepath pathExtension]];
	
	return [fileType_ isEqualToString : CMRThreadDocumentType]
				? CMRFavoritesOperationLink
				: CMRFavoritesOperationNone;
}

- (BOOL) canCreateFavoriteLinkFromPath : (NSString *) filepath
{
	return (CMRFavoritesOperationLink == [self avalableOperationWithPath : filepath]);
}

- (BOOL) favoriteItemExistsOfThreadPath : (NSString *) filepath
{
	NSEnumerator	*iter_;
	NSDictionary	*anItem_;	// each favorite item

	if (nil == filepath) return NO;

	iter_ = [[self favoritesItemsArray] objectEnumerator];
	
	while ((anItem_ = [iter_ nextObject]) != nil) {
		NSString	*itemPath_;
		
		itemPath_ = [CMRThreadAttributes pathFromDictionary : anItem_];
		if ([itemPath_ isEqualToString : filepath])
			return YES;
	}
	
	return NO;
}
	
- (BOOL) addFavoriteWithThread : (NSDictionary *) thread
{
	NSString	*path_;
	if(nil == thread) return NO;

	path_ = [CMRThreadAttributes pathFromDictionary : thread];
	if(NO == [self canCreateFavoriteLinkFromPath : path_]) return NO;
	
	[[self favoritesItemsArray] addObject : thread];
	[[self favoritesItemsIndex] addObject : path_];
	
	// write Now
	[[self favoritesItemsArray] writeToFile : [[self class] defaultFilepath]
								 atomically : YES];

	UTILNotifyInfo3(
		CMRFavoritesManagerDidLinkFavoritesNotification,
		path_,
		kAppFavoritesManagerInfoFilesKey);
			
	return YES;
}

- (BOOL) addFavoriteWithFilePath : (NSString *) filepath
{
	NSDictionary	*attr_;
	
	if(NO == [self canCreateFavoriteLinkFromPath : filepath]) return NO;
	
	attr_ = [CMRThreadsList attributesForThreadsListWithContentsOfFile : filepath];
	if (attr_ == nil) return NO;
	
	return [self addFavoriteWithThread : attr_];
}

- (BOOL) removeFromFavoritesWithThread : (NSDictionary *) thread
{
	NSString *path_;
	if (nil == thread) return NO;
	
	path_ = [CMRThreadAttributes pathFromDictionary : thread];
	return [self removeFromFavoritesWithFilePath : path_];
}

- (BOOL) removeFromFavoritesWithFilePath : (NSString *) filepath
{
	NSEnumerator	*iter_;
	NSDictionary	*anItem_;	// each favorite item
	id				deleteTarget_ = nil;

	if (nil == filepath) return NO;

	iter_ = [[self favoritesItemsArray] objectEnumerator];
	
	while ((anItem_ = [iter_ nextObject]) != nil) {
		NSString	*itemPath_;
		
		itemPath_ = [CMRThreadAttributes pathFromDictionary : anItem_];
		if ([itemPath_ isEqualToString : filepath]) {
			deleteTarget_ = anItem_;
			break;
		}
	}

	if (!(deleteTarget_ == nil)) {
		[[self favoritesItemsArray] removeObject : deleteTarget_];
		[[self favoritesItemsIndex] removeObject : filepath];

		UTILNotifyInfo3(
			CMRFavoritesManagerDidRemoveFavoritesNotification,
			filepath,
			kAppFavoritesManagerInfoFilesKey);

		return YES;
	}
	return NO;
}

- (void) removeFromFavoritesWithPathArray : (NSArray *) pathArray_
{
	NSEnumerator	*iter_;
	NSString		*aPath_;

	if (nil == pathArray_ || [pathArray_ count] == 0 ) return;
	iter_ = [pathArray_ objectEnumerator];
	
	while ((aPath_ = [iter_ nextObject]) != nil) {
		if ([[self favoritesItemsIndex] containsObject : aPath_])
			[self removeFromFavoritesWithFilePath : aPath_];
	}
}

#pragma mark -

- (int) insertFavItemsTo : (int) index withIndexArray : (NSArray *) indexArray_ isAscending : (BOOL) isAscending_
{
	NSEnumerator	*iter_;
	NSNumber		*num;
	int				c;
	
	NSMutableArray	*insertArray_;
	NSMutableArray	*aboveArray_;
	NSMutableArray	*belowArray_;
	
	NSMutableArray	*newFavAry_;
	
	if (indexArray_ == nil || [indexArray_ count] == 0) return index;
	c = [[self favoritesItemsArray] count];
	
	index = isAscending_ ? index : (c - index); 
	
	insertArray_ = [[NSMutableArray empty] mutableCopy];
	
	aboveArray_ = [NSMutableArray arrayWithArray : 
								[[self favoritesItemsArray] subarrayWithRange : NSMakeRange(0, index)]];
	belowArray_ = [NSMutableArray arrayWithArray :
								[[self favoritesItemsArray] subarrayWithRange : NSMakeRange(index, (c - index))]];
	
	iter_ = isAscending_ ? [indexArray_ objectEnumerator] : [indexArray_ reverseObjectEnumerator];
	
	while ((num = [iter_ nextObject]) != nil) {
		id	favItem;
		int	n = [num intValue];
		favItem = isAscending_ ? [[self favoritesItemsArray] objectAtIndex : n]
							   : [[self favoritesItemsArray] objectAtIndex : ((c - n) - 1)];

		[insertArray_ addObject : favItem];
		[aboveArray_ removeObject : favItem];
		[belowArray_ removeObject : favItem];
	}
	
	newFavAry_ = [[NSMutableArray empty] mutableCopy];
	[newFavAry_ addObjectsFromArray : aboveArray_];
	[newFavAry_ addObjectsFromArray : insertArray_];
	[newFavAry_ addObjectsFromArray : belowArray_];
	
	[self setFavoritesItemsArray : newFavAry_];
	[self setFavoritesItemsIndex : nil];	// nil にすることで、次回新しい内容で favoritesItemIndex が再生成される

	[insertArray_ release];
	[newFavAry_ release];
	
	return isAscending_ ? [aboveArray_ count] : [belowArray_ count];
}

#pragma mark -

//暫定実装
- (void) addItemToPoolWithFilePath : (NSString *) filepath
{
	id tmp;
	if (filepath == nil) return;

	// 何らかの理由で既に登録されている場合は、登録しない
	if ([[self changedFavItemsPool] containsObject : filepath]) return;
	
	// 保持数の上限を超えた場合は一番古いものを削除（パフォーマンスとの兼ね合い）
	tmp = SGTemplateResource(kFavItemsPoolMaxCountKey);
    UTILAssertRespondsTo(tmp, @selector(intValue));
    if ([[self changedFavItemsPool] count] > [tmp intValue]) {
		[[self changedFavItemsPool] removeObjectAtIndex : 0];
	}
	
	[[self changedFavItemsPool] addObject : filepath];
}

- (void) removeFromPoolWithFilePath : (NSString *) filepath
{	
	if (filepath == nil) return;
	
	[[self changedFavItemsPool] removeObject : filepath];
}
@end