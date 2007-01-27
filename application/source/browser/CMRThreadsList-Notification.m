/**
  * $Id: CMRThreadsList-Notification.m,v 1.9 2007/01/27 15:48:42 tsawada2 Exp $
  * 
  * CMRThreadsList-Notification.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
//#import "CMRThreadViewer.h"
//#import "CMRThreadAttributes.h"
//#import "ThreadTextDownloader.h"
//#import "CMRThreadsUpdateListTask.h"
//#import "CMRFavoritesManager.h"
#import "missing.h"

@implementation CMRThreadsList(NotificationCenterSupport)
- (void) registerToNotificationCenter
{
//	[[NSNotificationCenter defaultCenter]
//	     addObserver : self
//	        selector : @selector(downloaderTextUpdatedNotified:)
//	            name : ThreadTextDownloaderUpdatedNotification
//	          object : nil];
//	[[NSNotificationCenter defaultCenter]
//	     addObserver : self
//	        selector : @selector(threadViewerDidChangeThread:)
//	            name : CMRThreadViewerDidChangeThreadNotification
//	          object : nil];
//	[[NSNotificationCenter defaultCenter]
//	     addObserver : self
//	        selector : @selector(trashDidPerformNotification:)
//	            name : CMRTrashboxDidPerformNotification
//	          object : [CMRTrashbox trash]];
	
	[super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
//	[[NSNotificationCenter defaultCenter]
//		removeObserver : self
//		name : CMRThreadsUpdateListTaskDidFinishNotification
//		object : [self worker]];
	
//	[[NSNotificationCenter defaultCenter]
//	  removeObserver : self
//	            name : ThreadTextDownloaderUpdatedNotification
//	          object : nil];
//	[[NSNotificationCenter defaultCenter]
//	  removeObserver : self
//	            name : CMRThreadViewerDidChangeThreadNotification
//	          object : nil];
//	[[NSNotificationCenter defaultCenter]
//	  removeObserver : self
//	            name : CMRTrashboxDidPerformNotification
//	          object : [CMRTrashbox trash]];
	
	[super removeFromNotificationCenter];
}

//- (void) syncFavIfNeededWithAttr : (NSMutableDictionary *) thread forPath : (NSString *) filePath
//{
//}
@end
