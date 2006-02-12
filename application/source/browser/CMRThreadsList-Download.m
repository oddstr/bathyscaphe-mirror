/**
  * $Id: CMRThreadsList-Download.m,v 1.3 2006/02/12 15:39:46 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005 BathyScaphe Project. All rights reserved.
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
	
	downloader_ = [ThreadsListDownloader threadsListDownloaderWithBBSName : [self boardName]];

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
	[self writeListToFileNow];
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
	[nc_ addObserver : self
			selector : @selector(downloaderTaskStopped:)
				name : CMRTaskDidFinishNotification
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

- (void) downloaderTaskStopped : (NSNotification *) notification
{
	//NSLog(@"TASKSTOPPED");
	/* �t�F�X�g�E�e�X�^���b�T�@�`���V�̗�
	�@�_�E�����[�h�����O�� task ���X�g�b�v�����Ƃ��̃��\�b�h���Ă΂��B*/
	[[NSNotificationCenter defaultCenter] removeObserver : self
				   name : CMRTaskDidFinishNotification
				 object : [notification object]];

	[self postListDidUpdateNotification : CMRAutoscrollWhenTLUpdate];
}

- (void) downloaderFinishedNotified : (NSNotification *) notification
{
	CMRDownloader		*downloader_;
	NSMutableArray		*newList_;
	//NSLog(@"downloaderFInidhedNotified");
	/* �t�F�C�g�E�e�X�^���b�T�@�`���V�̗�
	�@downloaderFinishedNotified ��������ꂽ���_�ł܂� task �͒�~���Ă��Ȃ��B�������_�E�����[�h������������A
	�@�������� task ��߂܂���K�v�͂Ȃ��̂ŁA���̃��\�b�h���Œʒm�ώ@����������B����Ă��̃��\�b�h�ɂ��ǂ蒅������A
	�@downloaderTaskStopped: �͌Ă΂�Ȃ��B*/
	UTILAssertNotificationName(
		notification,
		ThreadListDownloaderUpdatedNotification);
	
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, CMRDownloader);
	UTILAssertNotNil([notification userInfo]);
	
	newList_ = 
		[[notification userInfo] objectForKey : CMRDownloaderUserInfoContentsKey];
	UTILAssertKindOfClass(newList_, NSMutableArray);

	// task �̊ώ@������
	[[NSNotificationCenter defaultCenter] removeObserver : self
				   name : CMRTaskDidFinishNotification
				 object : [notification object]];
	
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
	//NSLog(@"downloaderNotFound");
	/* �t�F�C�g�E�e�X�^���b�T�@�`���V�̗�
	downloaderNotFound ��������ꂽ���_�ł͂܂� task �͏I�����Ă��Ȃ��B����Ă��̎��_�ł� taskDidFinish ��
	�ʒm�ώ@�����������A���̃��\�b�h�I����� taskDidFinish ��ʒm���Ă��炤�B
	���̎��_�� postListDidUpdateNotification �� downloaderTaskStopped: �������A�ꗗ�͕\�������B*/
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
