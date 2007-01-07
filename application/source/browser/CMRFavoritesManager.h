/**
  * $Id: CMRFavoritesManager.h,v 1.7 2007/01/07 17:04:23 masakih Exp $
  *
  * Copyright (c) 2005 BathyScaphe Project. All rights reserved.
  */

#import <Foundation/Foundation.h>


typedef enum {
	CMRFavoritesOperationNone,
	CMRFavoritesOperationLink,
	CMRFavoritesOperationRemove
} CMRFavoritesOperation;


@interface CMRFavoritesManager : NSObject
{
	NSMutableArray	*_favoritesItemsArray;
	NSMutableArray	*_favoritesItemsIndex;
	NSMutableArray	*_changedFavItemsPool;
	NSTimer			*m_writeTimer;
}

+ (id) defaultManager;

- (NSMutableArray *) favoritesItemsArray;
- (void) setFavoritesItemsArray : (NSMutableArray *) anArray;
- (NSMutableArray *) favoritesItemsIndex;
- (void) setFavoritesItemsIndex : (NSMutableArray *) anArray;

- (NSMutableArray *) changedFavItemsPool;
- (void) setChangedFavItemsPool : (NSMutableArray *) anArray;

- (NSMutableArray *) itemsForRemoving;
- (NSMutableArray *) itemsForChange;
@end



@interface CMRFavoritesManager(Management)
- (CMRFavoritesOperation) availableOperationWithPath : (NSString *) filepath;
- (BOOL) canCreateFavoriteLinkFromPath : (NSString *) filepath;
- (BOOL) favoriteItemExistsOfThreadPath : (NSString *) filepath;

- (BOOL) addFavoriteWithThread : (NSDictionary *) thread;
- (BOOL) addFavoriteWithFilePath : (NSString *) filepath;
- (BOOL) removeFromFavoritesWithThread : (NSDictionary *) thread;
- (BOOL) removeFromFavoritesWithFilePath : (NSString *) filepath;

- (void) removeFromFavoritesWithPathArray : (NSArray *) pathArray_;
// Removed in ReinforceII and later.
//- (int) insertFavItemsTo : (int) index withIndexArray : (NSArray *) indexArray_ isAscending : (BOOL) isAscending_;
// Available in ReinforceII and later.
- (NSIndexSet *) insertFavItemsWithIndexes: (NSIndexSet *) indexSet atIndex: (unsigned int) index isAscending: (BOOL) isAscending;

- (void) addItemToPoolWithFilePath : (NSString *) filepath;
- (void) removeFromPoolWithFilePath : (NSString *) filepath;

- (unsigned int) getNumOfMsgsWithFilePath: (NSString *) filepath;
- (void) updateFavItemsArrayWithAppendingNumOfMsgs;
@end



/**
  * userInfo:
  * 	@"File"	-- filepath to be performed (NSString)
  *
  */
#define kAppFavoritesManagerInfoFilesKey	@"File"

extern NSString *const CMRFavoritesManagerDidLinkFavoritesNotification;
extern NSString *const CMRFavoritesManagerDidRemoveFavoritesNotification;
