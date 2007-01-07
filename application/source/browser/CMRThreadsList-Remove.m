/**
  * $Id: CMRThreadsList-Remove.m,v 1.9 2007/01/07 17:04:23 masakih Exp $
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
- (void) trashDidPerformNotification : (NSNotification *) notification
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
}
//- (void) cleanUpItemsToBeRemoved : (NSArray *) files
//{
//	NSEnumerator		*iter_;
//	NSString			*path_;
//	
//	iter_ = [files objectEnumerator];
//	[_threadsListUpdateLock lock];
//	while(path_ = [iter_ nextObject]){
//		NSMutableDictionary		*thread_;
//		
//		thread_ = [self seachThreadByPath : path_];
//		if (thread_ != nil) {
//			[[self class] clearAttributes : thread_];
//		} else {
//			//NSLog(@"CMRThreadsList: cleanUpItemsToBeRemoved: - seachThreadByPath: returns nil, so add this item to pool");
//			[[CMRFavoritesManager defaultManager] addItemToPoolWithFilePath: path_];
//		}
//	}
//	[_threadsListUpdateLock unlock];
//	
//	UTILNotifyName(CMRThreadsListDidChangeNotification);
//}
- (BOOL) tableView : (NSTableView *) tableView
	   removeItems : (NSArray	  *) rows
 delFavIfNecessary : (BOOL         ) flag
{
/*	
	NSArray				*pathArray_;
	
	pathArray_ = [self threadFilePathArrayWithRowIndexArray : rows 
												inTableView : tableView];
	return [self tableView : tableView removeFiles : pathArray_ delFavIfNecessary : flag];*/
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

	if(tmp && flag) [[CMRFavoritesManager defaultManager] removeFromFavoritesWithPathArray : files];
	if(tmp)[self cleanUpItemsToBeRemoved : files];
	
	return tmp;
}
@end
