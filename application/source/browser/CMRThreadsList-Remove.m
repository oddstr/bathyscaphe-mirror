/**
  * $Id: CMRThreadsList-Remove.m,v 1.11 2007/01/27 15:48:42 tsawada2 Exp $
  * 
  * CMRThreadsList-Remove.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
#import "CMRReplyDocumentFileManager.h"
#import "NSIndexSet+BSAddition.h"

@implementation CMRThreadsList(CleanUp)
/*- (void) trashDidPerformNotification : (NSNotification *) notification
{
	NSArray		*files_;
	NSNumber	*err_;
	
	UTILAssertNotificationName(
		notification,
		CMRTrashboxDidPerformNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRTrashbox trash]);
	
	err_ = [[notification userInfo] objectForKey : kAppTrashUserInfoStatusKey];
	if(nil == err_) return;
	UTILAssertKindOfClass(err_, NSNumber);
	if([err_ intValue] != noErr) return;
	
	files_ = [[notification userInfo] objectForKey : kAppTrashUserInfoFilesKey];
	UTILAssertKindOfClass(files_, NSArray);
	
	[self cleanUpItemsToBeRemoved : files_];
}*/
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

//	if(tmp && flag) [[CMRFavoritesManager defaultManager] removeFromFavoritesWithPathArray : files];
//	if(tmp)[self cleanUpItemsToBeRemoved : files];
	
	return tmp;
}
@end
