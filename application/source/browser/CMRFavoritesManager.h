//:CMRFavoritesManager.h
/**
  *
  *
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  *
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
- (CMRFavoritesOperation) avalableOperationWithPath : (NSString *) filepath;
- (BOOL) canCreateFavoriteLinkFromPath : (NSString *) filepath;
- (BOOL) favoriteItemExistsOfThreadPath : (NSString *) filepath;

- (BOOL) addFavoriteWithThread : (NSDictionary *) thread;
- (BOOL) addFavoriteWithFilePath : (NSString *) filepath;
- (BOOL) removeFromFavoritesWithThread : (NSDictionary *) thread;
- (BOOL) removeFromFavoritesWithFilePath : (NSString *) filepath;

- (void) removeFromFavoritesWithPathArray : (NSArray *) pathArray_;

- (int) insertFavItemsTo : (int) index withIndexArray : (NSArray *) indexArray_ isAscending : (BOOL) isAscending_;

- (void) addItemToPoolWithFilePath : (NSString *) filepath;
- (void) removeFromPoolWithFilePath : (NSString *) filepath;
@end



//////////////////////////////////////////////////////////////////////
////////////////////// [ íËêîÇ‚É}ÉNÉçíuä∑ ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * userInfo:
  * 	@"File"	-- filepath to be performed (NSString)
  *
  */
#define kAppFavoritesManagerInfoFilesKey	@"File"

extern NSString *const CMRFavoritesManagerDidLinkFavoritesNotification;
extern NSString *const CMRFavoritesManagerDidRemoveFavoritesNotification;
