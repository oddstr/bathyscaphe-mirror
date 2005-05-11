/**
  * $Id: CMRThreadsList-Notification.m,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadsList-Notification.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
#import "CMRThreadViewer.h"
#import "CMRThreadAttributes.h"
#import "ThreadTextDownloader.h"
#import "CMRThreadsUpdateListTask.h"
#import "CMRFavoritesManager.h"
#import "missing.h"

// these functions are used in both CMRThreadsList-Notification.m and w2chFavoriteItemList.m
BOOL synchronizeThreadAttributes(NSMutableDictionary *theThread, CMRThreadAttributes *theAttributes)
{
	unsigned		nLoaded_;
	unsigned		nCorrectLoaded_;
	unsigned		nRes_;
	ThreadStatus	status_;
	
	nLoaded_ = [theThread unsignedIntForKey : CMRThreadLastLoadedNumberKey];
	nCorrectLoaded_ = [theAttributes numberOfLoadedMessages];
	if(nLoaded_ == nCorrectLoaded_ || 0 == nCorrectLoaded_)
		return NO;
	
	[theThread setUnsignedInt : nCorrectLoaded_
					   forKey : CMRThreadLastLoadedNumberKey];
	nRes_ = [theThread unsignedIntForKey : CMRThreadNumberOfMessagesKey];
	
	if(0 == nCorrectLoaded_)
		status_ = ThreadNoCacheStatus;
	else if(nRes_ == nCorrectLoaded_)
		status_ = ThreadLogCachedStatus;
	else
		status_ = ThreadUpdatedStatus;
	
	[theThread setUnsignedInt : status_
					   forKey : CMRThreadStatusKey];
	
	return YES;
}

void margeThreadAttributesWithContentDict(NSMutableDictionary *thread, NSDictionary *content)
{
	int		cnt_;
	id		o1, o2;
	NSArray		*messages_;
	NSNumber	*n;
	
	messages_ = [content objectForKey : ThreadPlistContentsKey];
	cnt_ = (messages_ != nil) ? [messages_ count] : 0;
	n = [NSNumber numberWithInt : cnt_];
	[thread setObject : n
			   forKey : CMRThreadLastLoadedNumberKey];
	[thread setObject : n
			   forKey : CMRThreadNumberOfMessagesKey];
	[thread setObject : 
			[NSNumber numberWithUnsignedInt : ThreadLogCachedStatus] 
			  forKey : CMRThreadStatusKey];
	
	o1 = [thread objectForKey : CMRThreadModifiedDateKey];
	o2 = [content objectForKey : CMRThreadModifiedDateKey];
	
	[thread setNoneNil : [content objectForKey : CMRThreadModifiedDateKey]
				forKey : CMRThreadModifiedDateKey];
}

#pragma mark -

@implementation CMRThreadsList(NotificationCenterSupport)
- (void) registerToNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(downloaderTextUpdatedNotified:)
	            name : ThreadTextDownloaderUpdatedNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(threadViewerDidChangeThread:)
	            name : CMRThreadViewerDidChangeThreadNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(trashDidPerformNotification:)
	            name : CMRTrashboxDidPerformNotification
	          object : [CMRTrashbox trash]];
	
	[super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
		removeObserver : self
		name : CMRThreadsUpdateListTaskDidFinishNotification
		object : [self worker]];
	
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : ThreadTextDownloaderUpdatedNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRThreadViewerDidChangeThreadNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRTrashboxDidPerformNotification
	          object : [CMRTrashbox trash]];
	
	[super removeFromNotificationCenter];
}
// スレッドの読み込みが完了。
- (void) threadViewerDidChangeThread : (NSNotification *) theNotification
{
	NSMutableDictionary		*thread_;
	NSString				*filepath_;
	CMRThreadAttributes		*threadAttributes_;
	
	UTILAssertNotificationName(
		theNotification,
		CMRThreadViewerDidChangeThreadNotification);
	
	
	threadAttributes_ = [[theNotification object] threadAttributes];
	filepath_ = [[theNotification object] path];
	thread_ = [self seachThreadByPath : filepath_];
	if(nil == thread_)
		return;
	
	
	// 既得数を更新
	if(synchronizeThreadAttributes(thread_, threadAttributes_)) {
		int	i;
		i = [[[CMRFavoritesManager defaultManager] favoritesItemsIndex] indexOfObject : filepath_];
		if (i != NSNotFound) {
			[[[CMRFavoritesManager defaultManager] favoritesItemsArray] replaceObjectAtIndex : i withObject : thread_];
		}
		[self postListDidUpdateNotification : CMRAutoscrollWhenThreadUpdate];
	}
}
// スレッドのダウンロードが終了した。
- (void) downloaderTextUpdatedNotified : (NSNotification *) notification
{
	CMRDownloader			*downloader_;
	NSDictionary			*userInfo_;
	NSDictionary			*newContents_;
	NSMutableDictionary		*thread_;
	
	int	i;

	UTILAssertNotificationName(
		notification,
		ThreadTextDownloaderUpdatedNotification);
		

	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, CMRDownloader);
	
	userInfo_ = [notification userInfo];
	UTILAssertNotNil(userInfo_);
	
	newContents_ = [userInfo_ objectForKey : CMRDownloaderUserInfoContentsKey];
	UTILAssertKindOfClass(
		newContents_,
		NSDictionary);

	thread_ = [self seachThreadByPath : [downloader_ filePathToWrite]];
	if(nil == thread_) return;

	margeThreadAttributesWithContentDict(thread_, newContents_);

	i = [[[CMRFavoritesManager defaultManager] favoritesItemsIndex] indexOfObject : [downloader_ filePathToWrite]];
	if (i != NSNotFound) {
		[[[CMRFavoritesManager defaultManager] favoritesItemsArray] replaceObjectAtIndex : i withObject : thread_];
	}
	
	[self postListDidUpdateNotification : CMRAutoscrollWhenThreadUpdate];
}
@end
