/**
  * $Id: CMRFavoritesManager.h,v 1.11 2007/03/29 13:31:49 tsawada2 Exp $
  *
  * Copyright (c) 2005 BathyScaphe Project. All rights reserved.
  */

#import <Foundation/Foundation.h>
@class CMRThreadSignature;

typedef enum {
	CMRFavoritesOperationNone,
	CMRFavoritesOperationLink,
	CMRFavoritesOperationRemove
} CMRFavoritesOperation;


@interface CMRFavoritesManager : NSObject
{
}
+ (id) defaultManager;
@end


@interface CMRFavoritesManager(Management)
- (CMRFavoritesOperation) availableOperationWithPath : (NSString *) filepath;
// Available in Starlight Breaker.
- (CMRFavoritesOperation) availableOperationWithSignature: (CMRThreadSignature *) signature;

- (BOOL) canCreateFavoriteLinkFromPath : (NSString *) filepath;
- (BOOL) favoriteItemExistsOfThreadPath : (NSString *) filepath;

// Available in Starlight Breaker.
- (BOOL) favoriteItemExistsOfThreadSignature: (CMRThreadSignature *) signature;

- (BOOL) addFavoriteWithThread : (NSDictionary *) thread;
//- (BOOL) addFavoriteWithFilePath : (NSString *) filepath; // Deprecated.
// Available in Starlight Breaker.
- (BOOL) addFavoriteWithSignature: (CMRThreadSignature *) signature;

//- (BOOL) removeFromFavoritesWithThread : (NSDictionary *) thread; // Deprecated.
- (BOOL) removeFromFavoritesWithFilePath : (NSString *) filepath;
// Available in Starlight Breaker.
- (BOOL) removeFromFavoritesWithSignature : (CMRThreadSignature *) signature;

// Deprecated in Starlight Breaker.
//- (void) removeFromFavoritesWithPathArray : (NSArray *) pathArray_;
@end



/**
  * userInfo:
  * 	@"File"	-- filepath to be performed (NSString)
  *
  */
#define kAppFavoritesManagerInfoFilesKey	@"File"

extern NSString *const CMRFavoritesManagerDidLinkFavoritesNotification;
extern NSString *const CMRFavoritesManagerDidRemoveFavoritesNotification;
