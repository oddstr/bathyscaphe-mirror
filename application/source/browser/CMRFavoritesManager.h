//
//  CMRFavoritesManager.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/12/09.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@class CMRThreadSignature;

enum {
	CMRFavoritesOperationNone,
	CMRFavoritesOperationLink,
	CMRFavoritesOperationRemove
};
typedef unsigned int CMRFavoritesOperation;


@interface CMRFavoritesManager : NSObject
{
	IBOutlet NSPanel	*m_progressPanel;
	IBOutlet NSProgressIndicator	*m_progressBar;
}
+ (id) defaultManager;

- (CMRFavoritesOperation)availableOperationWithPath:(NSString *)filepath;
- (CMRFavoritesOperation)availableOperationWithSignature:(CMRThreadSignature *)signature;

- (BOOL)canCreateFavoriteLinkFromPath:(NSString *)filepath;
- (BOOL)favoriteItemExistsOfThreadPath:(NSString *)filepath;
- (BOOL)favoriteItemExistsOfThreadSignature:(CMRThreadSignature *)signature;

- (BOOL)addFavoriteWithThread:(NSDictionary *)thread;
- (BOOL)addFavoriteWithSignature:(CMRThreadSignature *)signature;

- (BOOL)removeFromFavoritesWithFilePath:(NSString *)filepath;
- (BOOL)removeFromFavoritesWithSignature:(CMRThreadSignature *)signature;
@end

@interface CMRFavoritesManager(ImportAndExport)
- (BOOL)exportFavoritesToFile:(NSString *)filepath atomically:(BOOL)atomically;
- (BOOL)importFavoritesFromFile:(NSString *)filepath;
@end


/**
  * userInfo:
  * 	@"File"	-- filepath to be performed (NSString)
  *
  */
#define kAppFavoritesManagerInfoFilesKey	@"File"

extern NSString *const CMRFavoritesManagerDidLinkFavoritesNotification;
extern NSString *const CMRFavoritesManagerDidRemoveFavoritesNotification;
