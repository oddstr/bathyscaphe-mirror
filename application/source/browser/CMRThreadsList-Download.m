/**
  *
  * @see AppDefaults.h
  * @see CMRTaskManager.h
  * @see BoardManager.h
  * @see CMRDownloader.h
  * @see CMRBBSSignature.h
  * @see ThreadTextDownloader.h
  * @see ThreadsListDownloader.h
  *
  * @author Takanori Ishikawa
  * @author http:
  * @version 1.0.0d1 (02/08/14  1:46:59 PM)
  *
  */
#import "CMRThreadsList_p.h"
#import "ThreadTextDownloader.h"
#import "ThreadsListDownloader.h"
#import "CMRNetRequestQueue.h"




@implementation CMRThreadsList(Download)
- (void) downloadThreadsList
{
	CMRDownloader		*downloader_;
	
	downloader_ = [ThreadsListDownloader 
					threadsListDownloaderWithBBSSignature : [self BBSSignature]];
	if(nil == downloader_){
		NSLog(@"  Sorry, not supported...");
		return;
	}
	
	[self registerToNotificationCeterWithDownloader : downloader_];
	[[CMRTaskManager defaultManager] addTask : downloader_];
	[downloader_ startLoadInBackground];
}

- (void) postListDidUpdateNotification : (int) mask;
{
	id		obj_;
	
	obj_ = [NSNumber numberWithUnsignedInt : mask];
	UTILNotifyInfo3(
		CMRThreadsListDidUpdateNotification,
		obj_,
		ThreadsListUserInfoSelectionHoldingMaskKey);
	UTILNotifyName(CMRThreadsListDidChangeNotification);
}
@end



@implementation CMRThreadsList(DownLoadPrivate)
- (void) registerToNotificationCeterWithDownloader : (CMRDownloader *) downloader
{
	NSNotificationCenter	*nc_;
	
	if(nil == downloader) return;
	nc_ = [NSNotificationCenter defaultCenter];
	
	[nc_ addObserver : self
			selector : @selector(downloaderFinishedNotified:)
			    name : ThreadListDownloaderUpdatedNotification
			  object : downloader];
	[nc_ addObserver : self
			selector : @selector(downloaderNotFound:)
			    name : CMRDownloaderNotFoundNotification
			  object : downloader];
}
- (void) removeFromNotificationCeterWithDownloader : (CMRDownloader *) downloader
{
	NSNotificationCenter	*nc_;
	
	if(nil == downloader) return;
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ removeObserver : self
				   name : ThreadListDownloaderUpdatedNotification
				 object : downloader];
	[nc_ removeObserver : self
				   name : CMRDownloaderNotFoundNotification
				 object : downloader];
}


- (void) downloaderFinishedNotified : (NSNotification *) notification
{
	CMRDownloader		*downloader_;
	NSMutableArray		*newList_;
	
	UTILAssertNotificationName(
		notification,
		ThreadListDownloaderUpdatedNotification);
	
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, CMRDownloader);
	UTILAssertNotNil([notification userInfo]);
	
	newList_ = 
		[[notification userInfo] objectForKey : CMRDownloaderUserInfoContentsKey];
	UTILAssertKindOfClass(newList_, NSMutableArray);
	
	[self donwnloader : [downloader_ retain]
		  didFinished : [newList_ retain]];
}

- (void) donwnloader : (CMRDownloader  *) theDownloader
         didFinished : (NSMutableArray *) newList
{
	SGFileRef   *folder;
	
	folder = [[CMRDocumentFileManager defaultManager]
				ensureDirectoryExistsWithBoardName : [self boardName]];
	UTILAssertNotNil(folder);
	
	[self startUpdateThreadsList:newList update:YES usesWorker:YES];
	[self removeFromNotificationCeterWithDownloader : theDownloader];
	
	[theDownloader release];
	[newList release];
}



- (void) downloaderNotFound : (NSNotification *) notification
{
	CMRDownloader *downloader_;
	NSString      *msg_;
	
	UTILAssertNotificationName(
		notification,
		CMRDownloaderNotFoundNotification);
	
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, CMRDownloader);
	[self removeFromNotificationCeterWithDownloader : downloader_];
	
	
	msg_ = [NSString stringWithFormat : 
						[self localizedString : APP_TLIST_NOT_FOUND_MSG_FMT],
						[[downloader_ resourceURL] absoluteString]];
	
	NSBeep();
	NSRunAlertPanel(
		[self localizedString : APP_TLIST_NOT_FOUND_TITLE],
		msg_,
		nil,
		nil,
		nil);
}
@end
