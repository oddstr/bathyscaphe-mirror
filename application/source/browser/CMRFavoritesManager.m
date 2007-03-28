/**
  * $Id: CMRFavoritesManager.m,v 1.21 2007/03/28 13:03:42 tsawada2 Exp $
  *
  * Copyright (c) 2005 BathyScaphe Project. All rights reserved.
  */

#import "CMRFavoritesManager.h"
#import "CocoMonar_Prefix.h"

#import "CMRThreadAttributes.h"
#import "CMRThreadsList_p.h"
#import <AppKit/NSDocumentController.h>
#import "CMRThreadSignature.h"
#import "CMRTrashbox.h"

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

- (void) trashDidPerform : (NSNotification *) notification
{	
	UTILAssertNotificationName(
		notification,
		CMRTrashboxDidPerformNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRTrashbox trash]);
	
//	NSLog(@"FavoriteManager received CMRTrashboxDidPerformNotification");
	
	NSDictionary *userInfo_ = [notification userInfo];
	if ([userInfo_ integerForKey: kAppTrashUserInfoStatusKey] != noErr) return;
	
	BOOL	doNotDelFav_ = [userInfo_ boolForKey: kAppTrashUserInfoAfterFetchKey];
	if (doNotDelFav_) return;

	NSArray			*pathArray_ = [userInfo_ objectForKey: kAppTrashUserInfoFilesKey];
	NSEnumerator	*iter_;
	NSString		*aPath_;

	iter_ = [pathArray_ objectEnumerator];

	while ((aPath_ = [iter_ nextObject]) != nil) {
//		if (doNotDelFav_) continue;

		if ([self availableOperationWithPath: aPath_] == CMRFavoritesOperationRemove) {
			[self removeFromFavoritesWithFilePath: aPath_];
		}
	}

}
@end

#pragma mark -

@implementation CMRFavoritesManager(Management)
- (CMRFavoritesOperation)availableOperationWithThread:(id)thread
{
	id identifier;
	id boardName = [thread valueForKey:ThreadPlistBoardNameKey];
	id boardIDs;
	
	identifier = [CMRThreadAttributes identifierFromDictionary:thread];
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];
	
	if( !identifier || !boardIDs ) return CMRFavoritesOperationNone;
	
	/* TODO 
		ï°êîë∂ç›Ç∑ÇÈèÍçáÇÃèàóù
*/
	unsigned boardID;
	boardID = [[boardIDs objectAtIndex:0] unsignedIntValue];
	
	BOOL isFavorite;
	isFavorite = [[DatabaseManager defaultManager] isFavoriteThreadIdentifier:identifier
																	onBoardID:boardID];
	
	return isFavorite ? CMRFavoritesOperationRemove : CMRFavoritesOperationLink;
}
- (CMRFavoritesOperation) availableOperationWithPath : (NSString *) filepath
{
//	NSDictionary	*attr_;
	
	if(filepath == nil)
		return CMRFavoritesOperationNone;
/*	
	attr_ = [BSDBThreadList attributesForThreadsListWithContentsOfFile : filepath];
	// [Bug 10077] âÒîÇÃÇΩÇﬂÇÃã≠à¯Ç»èàóù
	if (attr_ == nil) {
		BOOL result_;
		result_ = [[DatabaseManager defaultManager] registerThreadFromFilePath:filepath];
		if (NO == result_) {
			return CMRFavoritesOperationNone;
		} else {
			return CMRFavoritesOperationLink;
		}
	}
	return [self availableOperationWithThread : attr_];*/
	CMRThreadSignature *signature_ = [CMRThreadSignature threadSignatureFromFilepath: filepath];
	return [self availableOperationWithSignature: signature_];
}

- (CMRFavoritesOperation)availableOperationWithSignature:(CMRThreadSignature *)signature
{
	id identifier = [signature identifier];
	id boardName = [signature BBSName];
	id boardIDs;

	boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];
	
	if( !identifier || !boardIDs ) return CMRFavoritesOperationNone;
	
	/* TODO 
		ï°êîë∂ç›Ç∑ÇÈèÍçáÇÃèàóù
*/
	unsigned boardID;
	boardID = [[boardIDs objectAtIndex:0] unsignedIntValue];
	
	BOOL isFavorite;
	isFavorite = [[DatabaseManager defaultManager] isFavoriteThreadIdentifier:identifier
																	onBoardID:boardID];
	
	return isFavorite ? CMRFavoritesOperationRemove : CMRFavoritesOperationLink;
}

- (BOOL) canCreateFavoriteLinkFromPath : (NSString *) filepath
{
	return (CMRFavoritesOperationLink == [self availableOperationWithPath : filepath]);
}

- (BOOL) favoriteItemExistsOfThreadPath : (NSString *) filepath
{
	UTILAssertNotNil(filepath);
	return (CMRFavoritesOperationRemove == [self availableOperationWithPath : filepath]);
}

- (BOOL) favoriteItemExistsOfThreadSignature: (CMRThreadSignature *) signature
{
	UTILAssertNotNil(signature);
	return (CMRFavoritesOperationRemove == [self availableOperationWithSignature: signature]);
}

- (BOOL) addFavoriteWithThread: (id) threadIdentifier ofBoard: (NSString *) boardName
{
	id			boardIDs; /* TODO ï°êîë∂ç›Ç∑ÇÈèÍçáÇÃèàóù */
	BOOL		isSuccess = NO;
	
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName: boardName];
	if (!boardIDs) return NO;
	
	isSuccess = [[DatabaseManager defaultManager] appendFavoriteThreadIdentifier: threadIdentifier
																	   onBoardID: [[boardIDs objectAtIndex:0] unsignedIntValue]];
	
	if (isSuccess)
		UTILNotifyName(CMRFavoritesManagerDidLinkFavoritesNotification);
	
	return isSuccess;
}
- (BOOL) addFavoriteWithThread : (NSDictionary *) thread
{
	id identifier;
	id boardName = [thread valueForKey:ThreadPlistBoardNameKey];
	
	identifier = [CMRThreadAttributes identifierFromDictionary:thread];
	if(!identifier) return NO;
	return [self addFavoriteWithThread: identifier ofBoard: boardName];
}
- (BOOL) addFavoriteWithFilePath : (NSString *) filepath
{
	NSDictionary	*attr_;
	
	if(filepath == nil || NO == [self canCreateFavoriteLinkFromPath : filepath]) return NO;
	
	attr_ = [BSDBThreadList attributesForThreadsListWithContentsOfFile : filepath];
	if (attr_ == nil) return NO;
	
	return [self addFavoriteWithThread : attr_];
}
- (BOOL) addFavoriteWithSignature : (CMRThreadSignature *) signature
{	
	if(signature == nil) return NO;

	return [self addFavoriteWithThread : [signature identifier] ofBoard: [signature BBSName]];
}

- (BOOL) removeFavoriteWithThread: (id) threadIdentifier ofBoard: (NSString *) boardName
{
	id			boardIDs; /* TODO ï°êîë∂ç›Ç∑ÇÈèÍçáÇÃèàóù */
	BOOL		isSuccess = NO;
	
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName: boardName];
	if (!boardIDs) return NO;
	
	isSuccess = [[DatabaseManager defaultManager] removeFavoriteThreadIdentifier: threadIdentifier
																	   onBoardID: [[boardIDs objectAtIndex:0] unsignedIntValue]];
	
	if (isSuccess)
		UTILNotifyName(CMRFavoritesManagerDidRemoveFavoritesNotification);
	
	return isSuccess;
}
- (BOOL) removeFromFavoritesWithThread : (NSDictionary *) thread
{
	id identifier;
	id boardName = [thread valueForKey:ThreadPlistBoardNameKey];
	
	identifier = [CMRThreadAttributes identifierFromDictionary:thread];
	
	if (!identifier|!boardName) return NO;
	return [self removeFavoriteWithThread: identifier ofBoard: boardName];
}

- (BOOL) removeFromFavoritesWithFilePath : (NSString *) filepath
{
	if (!filepath) return NO;
	CMRThreadSignature *signature_ = [CMRThreadSignature threadSignatureFromFilepath: filepath];
	return [self removeFromFavoritesWithSignature: signature_];
}

- (void) removeFromFavoritesWithPathArray : (NSArray *) pathArray_
{
}

- (BOOL) removeFromFavoritesWithSignature : (CMRThreadSignature *) signature
{	
	if(signature == nil) return NO;

	return [self removeFavoriteWithThread : [signature identifier] ofBoard: [signature BBSName]];
}
@end
