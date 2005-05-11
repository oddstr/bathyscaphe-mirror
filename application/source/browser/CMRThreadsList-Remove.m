/**
  * $Id: CMRThreadsList-Remove.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadsList-Remove.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
#import "CMRReplyDocumentFileManager.h"

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
- (void) cleanUpItemsToBeRemoved : (NSArray *) files
{
	NSEnumerator		*iter_;
	NSString			*path_;
	
	iter_ = [files objectEnumerator];
	[_threadsListUpdateLock lock];
	while(path_ = [iter_ nextObject]){
		NSMutableDictionary		*thread_;
		
		thread_ = [self seachThreadByPath : path_];
		[[self class] clearAttributes : thread_];
	}
	[_threadsListUpdateLock unlock];
	
	UTILNotifyName(CMRThreadsListDidChangeNotification);
}
- (BOOL) tableView : (NSTableView *) tableView
	   removeItems : (NSArray	  *) rows
		deleteFile : (BOOL         ) flag
{
	
	NSArray				*pathArray_;
	
	pathArray_ = [self threadFilePathArrayWithRowIndexArray : rows 
												inTableView : tableView];
	return [self tableView:tableView removeFiles:pathArray_ deleteFile:flag];
}

- (BOOL) tableView : (NSTableView	*) tableView
	   removeFiles : (NSArray		*) files
		deleteFile : (BOOL			 ) flag
{
	if(flag) {
		NSArray	*alsoReplyFiles_;
		
		alsoReplyFiles_ = [[CMRReplyDocumentFileManager defaultManager]
								replyDocumentFilesArrayWithLogsArray : files];
		return [[CMRTrashbox trash] performWithFiles : alsoReplyFiles_];
	}
	[self cleanUpItemsToBeRemoved : files];
	
	return YES;
}
@end