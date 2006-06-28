/**
  * $Id: CMRFavoritesManager.m,v 1.12 2006/06/28 18:37:32 tsawada2 Exp $
  *
  * Copyright (c) 2005 BathyScaphe Project. All rights reserved.
  */

#import "CMRFavoritesManager.h"
#import "CocoMonar_Prefix.h"

#import "CMRThreadAttributes.h"

#import "BSDBThreadList.h"
#import "DatabaseManager.h"

#import "CMRTrashbox.h"
#import "CMRDocumentFileManager.h"

NSString *const CMRFavoritesManagerDidLinkFavoritesNotification = @"CMRFavoritesManagerDidLinkFavoritesNotification";
NSString *const CMRFavoritesManagerDidRemoveFavoritesNotification = @"CMRFavoritesManagerDidRemoveFavoritesNotification";

@implementation CMRFavoritesManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (id) init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(trashDidPerform:)
					    name : CMRTrashboxDidPerformNotification
					  object : [CMRTrashbox trash]];
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[super dealloc];
}

- (CMRFavoritesOperation) availableOperationWithThread: (id) threadIdentifier ofBoard: (NSString *) boardName
{
	id boardIDs;
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];
	
	if (!boardIDs) return CMRFavoritesOperationNone;

	/* TODO •¡”‘¶Ý‚·‚éê‡‚Ìˆ— */
	unsigned boardID;
	boardID = [[boardIDs objectAtIndex:0] unsignedIntValue];
	
	BOOL isFavorite;
	isFavorite = [[DatabaseManager defaultManager] isFavoriteThreadIdentifier: threadIdentifier onBoardID: boardID];
	
	return isFavorite ? CMRFavoritesOperationRemove : CMRFavoritesOperationLink;
}

- (BOOL) addFavoriteWithThread: (id) threadIdentifier ofBoard: (NSString *) boardName
{
	id			boardIDs; /* TODO •¡”‘¶Ý‚·‚éê‡‚Ìˆ— */
	BOOL		isSuccess = NO;
	
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName: boardName];
	if (!boardIDs) return NO;
	
	isSuccess = [[DatabaseManager defaultManager] appendFavoriteThreadIdentifier: threadIdentifier
																	   onBoardID: [[boardIDs objectAtIndex:0] unsignedIntValue]];

	if (isSuccess)
		UTILNotifyName(CMRFavoritesManagerDidLinkFavoritesNotification);

	return isSuccess;
}

- (BOOL) removeFavoriteWithThread: (id) threadIdentifier ofBoard: (NSString *) boardName
{
	id			boardIDs; /* TODO •¡”‘¶Ý‚·‚éê‡‚Ìˆ— */
	BOOL		isSuccess = NO;
	
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName: boardName];
	if (!boardIDs) return NO;
	
	isSuccess = [[DatabaseManager defaultManager] removeFavoriteThreadIdentifier: threadIdentifier
																	   onBoardID: [[boardIDs objectAtIndex:0] unsignedIntValue]];

	if (isSuccess)
		UTILNotifyName(CMRFavoritesManagerDidRemoveFavoritesNotification);

	return isSuccess;
}

- (void) trashDidPerform : (NSNotification *) notification
{	
	UTILAssertNotificationName(
		notification,
		CMRTrashboxDidPerformNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRTrashbox trash]);	
	
	NSDictionary *userInfo_ = [notification userInfo];
	if ([userInfo_ integerForKey: kAppTrashUserInfoStatusKey] != noErr) return;
	
	NSArray			*pathArray_ = [userInfo_ objectForKey: kAppTrashUserInfoFilesKey];
	CMRDocumentFileManager	*dFM_ = [CMRDocumentFileManager defaultManager];
	NSEnumerator	*iter_;
	NSString		*aPath_;

	iter_ = [pathArray_ objectEnumerator];

	while ((aPath_ = [iter_ nextObject]) != nil) {
		id identifier_;
		NSString *bName_;
		
		identifier_ = [dFM_ datIdentifierWithLogPath: aPath_];
		bName_ = [dFM_ boardNameWithLogPath: aPath_];

		UTILAssertNotNil(identifier_);
		UTILAssertNotNil(bName_);

		if ([self availableOperationWithThread: identifier_ ofBoard: bName_] == CMRFavoritesOperationRemove) {
			[self removeFavoriteWithThread: identifier_ ofBoard: bName_];
		}
	}

}


#pragma mark WILL BE REMOVED (Deprecated Methods)
+ (NSString *) defaultFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRFavoritesFile
						resolvingFileRef : NULL];
}

// Žb’è
+ (NSString *) subFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRFavMemoFile
						resolvingFileRef : NULL];
}
/*
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
*/

- (NSMutableArray *) favoritesItemsArray
{
	if (nil == _favoritesItemsArray) {
		_favoritesItemsArray = [[NSMutableArray alloc] initWithContentsOfFile : 
														[[self class] defaultFilepath]];
	}
	if (nil == _favoritesItemsArray) {
		_favoritesItemsArray = [[NSMutableArray alloc] init];
	}
	
	return _favoritesItemsArray;
}

- (void) setFavoritesItemsArray : (NSMutableArray *) anArray
{
	id		tmp;
	
	tmp = _favoritesItemsArray;
	_favoritesItemsArray = [anArray retain];
	[tmp release];
}

- (NSMutableArray *) favoritesItemsIndex
{
	if (nil == _favoritesItemsIndex) {
		NSMutableArray	*favItems_ = [self favoritesItemsArray];

		if ([favItems_ count] == 0) {
			_favoritesItemsIndex = [[NSMutableArray alloc] init];
		} else {
			NSEnumerator	*iter_;
			NSDictionary	*anItem_;	// each favorite item
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // 2005-12-04 ‚Ç‚¤‚¾‚ë‚¤H

			_favoritesItemsIndex = [[NSMutableArray alloc] initWithCapacity : [favItems_ count]];

			iter_ = [favItems_ objectEnumerator];

			while ((anItem_ = [iter_ nextObject]) != nil) {
				id	itemPath_;
				itemPath_ = [CMRThreadAttributes pathFromDictionary : anItem_];
				UTILAssertNotNil(itemPath_);

				[_favoritesItemsIndex addObject : itemPath_];
			}
			
			[pool release];
		}
	}
	
	return _favoritesItemsIndex;
}

- (void) setFavoritesItemsIndex : (NSMutableArray *) anArray
{
	id		tmp;
	
	tmp = _favoritesItemsIndex;
	_favoritesItemsIndex = [anArray retain];
	[tmp release];
}

// ‚±‚Ì‚Ö‚ñAŽb’è“I‚ÈŽÀ‘•
- (NSMutableArray *) changedFavItemsPool
{
	if (nil == _changedFavItemsPool) {
		_changedFavItemsPool = [[NSMutableArray alloc] initWithContentsOfFile : 
														[[self class] subFilepath]];
	}
	if (nil == _changedFavItemsPool) {
		_changedFavItemsPool = [[NSMutableArray alloc] initWithCapacity : 50];
	}
	
	return _changedFavItemsPool;
}

- (void) setChangedFavItemsPool : (NSMutableArray *) anArray
{
	id		tmp;
	
	tmp = _changedFavItemsPool;
	_changedFavItemsPool = [anArray retain];
	[tmp release];
}

- (NSMutableArray *) itemsForRemoving
{
	NSEnumerator	*iter_;
	NSString		*anItem_;	// each pool item
	
	NSArray			*tmp_ = [self favoritesItemsIndex];
	NSFileManager	*dFM_ = [NSFileManager defaultManager];
	
	NSMutableArray	*array_ = [NSMutableArray array];

	iter_ = [[self changedFavItemsPool] objectEnumerator];
	
	while ((anItem_ = [iter_ nextObject]) != nil) {
		if ((![tmp_ containsObject : anItem_]) || (![dFM_ fileExistsAtPath : anItem_]))
			[array_ addObject : anItem_];
	}

	return array_;
}

- (NSMutableArray *) itemsForChange
{
	NSEnumerator	*iter_;
	NSString		*anItem_;	// each pool item
	
	NSArray			*tmp_ = [self favoritesItemsIndex];
	
	NSMutableArray	*array_ = [NSMutableArray array];

	iter_ = [[self changedFavItemsPool] objectEnumerator];
	
	while ((anItem_ = [iter_ nextObject]) != nil) {
		if ([tmp_ containsObject : anItem_])
			[array_ addObject : anItem_];
	}

	return array_;
}

- (BOOL) addFavoriteWithThread : (NSDictionary *) thread
{
	id identifier;
	id boardName = [thread valueForKey:ThreadPlistBoardNameKey];

	NSLog(@"WARNING: method addFavoriteWithThread: has been deprecated. Try to use addFavoriteWithThread:ofBoard: instead.");
	identifier = [CMRThreadAttributes identifierFromDictionary:thread];

	if(!identifier) return NO;
	return [self addFavoriteWithThread: identifier ofBoard: boardName];
}
- (BOOL) addFavoriteWithFilePath : (NSString *) filepath
{
	NSDictionary	*attr_;
	NSLog(@"WARNING: method addFavoriteWithFilePath: has been deprecated. Try to use addFavoriteWithThread:ofBoard: instead.");	
	//if(filepath == nil || NO == [self canCreateFavoriteLinkFromPath : filepath]) return NO;
	
	attr_ = [BSDBThreadList attributesForThreadsListWithContentsOfFile : filepath];
	if (attr_ == nil) return NO;
	
	return [self addFavoriteWithThread : attr_];
}

- (BOOL) removeFromFavoritesWithThread : (NSDictionary *) thread
{
	id identifier;
	id boardName = [thread valueForKey:ThreadPlistBoardNameKey];

	NSLog(@"WARNING: method removeFromFavoritesWithThread: has been deprecated. Try to use removeFavoriteWithThread:ofBoard: instead.");		
	identifier = [CMRThreadAttributes identifierFromDictionary:thread];

	if (!identifier) return NO;
	return [self removeFavoriteWithThread: identifier ofBoard: boardName];
}

- (BOOL) removeFromFavoritesWithFilePath : (NSString *) filepath
{
	NSDictionary	*attr_;
	NSLog(@"WARNING: method removeFromFavoritesWithFilePath: has been deprecated. Try to use removeFavoriteWithThread:ofBoard: instead.");		
	
	attr_ = [BSDBThreadList attributesForThreadsListWithContentsOfFile : filepath];
	if (attr_ == nil) return NO;
	
	return [self removeFromFavoritesWithThread : attr_];
}

- (void) removeFromFavoritesWithPathArray : (NSArray *) pathArray_
{
	NSEnumerator	*iter_;
	NSString		*aPath_;

	if (nil == pathArray_ || [pathArray_ count] == 0 ) return;
	iter_ = [pathArray_ objectEnumerator];

	while ((aPath_ = [iter_ nextObject]) != nil) {
		//if ([[self favoritesItemsIndex] containsObject : aPath_]) {
			[self removeFromFavoritesWithFilePath : aPath_];
		//}
	}
}

- (int) insertFavItemsTo : (int) index withIndexArray : (NSArray *) indexArray_ isAscending : (BOOL) isAscending_
{
	NSEnumerator	*iter_;
	NSNumber		*num;
	int				c;
	
	NSMutableArray	*insertArray_;
	NSMutableArray	*aboveArray_;
	NSMutableArray	*belowArray_;

	NSArray			*originalArray_ = [self favoritesItemsArray];

	NSMutableArray	*newFavAry_;
	
	if (indexArray_ == nil || [indexArray_ count] == 0) return index;
	c = [[self favoritesItemsArray] count];
	
	index = isAscending_ ? index : (c - index); 
	
	insertArray_ = [NSMutableArray arrayWithCapacity : c];
	
	aboveArray_ = [NSMutableArray arrayWithArray : 
								[originalArray_ subarrayWithRange : NSMakeRange(0, index)]];
	belowArray_ = [NSMutableArray arrayWithArray :
								[originalArray_ subarrayWithRange : NSMakeRange(index, (c - index))]];
	
	iter_ = isAscending_ ? [indexArray_ objectEnumerator] : [indexArray_ reverseObjectEnumerator];
	
	while ((num = [iter_ nextObject]) != nil) {
		id	favItem;
		int	n = [num intValue];
		favItem = isAscending_ ? [originalArray_ objectAtIndex : n]
							   : [originalArray_ objectAtIndex : ((c - n) - 1)];

		[insertArray_ addObject : favItem];
		[aboveArray_ removeObject : favItem];
		[belowArray_ removeObject : favItem];
	}
	
	newFavAry_ = [[NSMutableArray alloc] initWithCapacity : c];
	[newFavAry_ addObjectsFromArray : aboveArray_];
	[newFavAry_ addObjectsFromArray : insertArray_];
	[newFavAry_ addObjectsFromArray : belowArray_];
	
	[self setFavoritesItemsArray : newFavAry_];
	[newFavAry_ release];

	// Žè”²‚«
	[self setFavoritesItemsIndex : nil];
	[self favoritesItemsIndex];
	
	return isAscending_ ? [aboveArray_ count] : [belowArray_ count];
}


//Žb’èŽÀ‘•
- (void) addItemToPoolWithFilePath : (NSString *) filepath
{
	if (filepath == nil) return;

	// ‰½‚ç‚©‚Ì——R‚ÅŠù‚É“o˜^‚³‚ê‚Ä‚¢‚éê‡‚ÍA“o˜^‚µ‚È‚¢
	if ([[self changedFavItemsPool] containsObject : filepath]) return;
	
	// •ÛŽ”‚ÌãŒÀ‚ð’´‚¦‚½ê‡‚Íˆê”ÔŒÃ‚¢‚à‚Ì‚ðíœiƒpƒtƒH[ƒ}ƒ“ƒX‚Æ‚ÌŒ“‚Ë‡‚¢j
	// SledgeHammer : ãŒÀ 50 ‚ÉŒÅ’è
    if ([[self changedFavItemsPool] count] > 50) {
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
