/**
  * $Id: CMRThreadViewer-Download.m,v 1.7 2005/12/10 15:42:21 tsawada2 Exp $
  * 
  * CMRThreadViewer-Download.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadViewer_p.h"
#import "CMRDownloader.h"
#import "ThreadTextDownloader.h"

//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
// そんな板 or スレッドありません
#define kNotFoundTitleKey				@"Not Found Title"
#define kNotFoundMessageFormatKey		@"Not Found Message"
#define kSearchKakoLogLabelKey			@"Search Kako Log"




@implementation CMRThreadViewer(Download)
- (void) downloadThread : (CMRThreadSignature *) aSignature
				  title : (NSString           *) threadTitle
			  nextIndex : (unsigned int        ) aNextIndex
{
	CMRDownloader			*downloader;
	NSNotificationCenter	*ncenter;
	
	ncenter = [NSNotificationCenter defaultCenter];
	downloader = 
		[ThreadTextDownloader downloaderWithIdentifier : aSignature
									threadTitle : threadTitle
									nextIndex : aNextIndex];
	
	if (nil == downloader) {
		return;
	}
	
	/* NotificationCenter */
	[ncenter addObserver : self
			selector : @selector(threadTextDownloaderInvalidPerticalContents:)
			    name : ThreadTextDownloaderInvalidPerticalContentsNotification
			  object : downloader];
	[ncenter addObserver : self
			selector : @selector(threadTextDownloaderNotFound:)
			    name : CMRDownloaderNotFoundNotification
			  object : downloader];
	[ncenter addObserver : self
			selector : @selector(threadTextDownloaderDidFinishLoading:)
			    name : ThreadTextDownloaderDidFinishLoadingNotification
			  object : downloader];
	
	/* TaskManager, load */
	[[CMRTaskManager defaultManager] addTask : downloader];
	[downloader loadInBackground];
}


- (void) removeFromNotificationCeterWithDownloader : (CMRDownloader *) downloader
{
	NSNotificationCenter	*nc_;
	
	if (nil == downloader) return;
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ removeObserver : self
				   name : ThreadTextDownloaderInvalidPerticalContentsNotification
				 object : downloader];
	[nc_ removeObserver : self
				   name : CMRDownloaderNotFoundNotification
				 object : downloader];
	[nc_ removeObserver : self
				   name : ThreadTextDownloaderDidFinishLoadingNotification
				 object : downloader];
}

- (void) threadTextDownloaderDidFinishLoading : (NSNotification *) notification
{
	ThreadTextDownloader	*downloader_;
	NSDictionary			*userInfo_;
	NSString				*contents_;
	
	UTILAssertNotificationName(
		notification,
		ThreadTextDownloaderDidFinishLoadingNotification);
	
	userInfo_ = [notification userInfo];
	downloader_ = [notification object];
	contents_ = [userInfo_ objectForKey : CMRDownloaderUserInfoContentsKey];
	
	UTILAssertKindOfClass(downloader_, ThreadTextDownloader);
	UTILAssertNotNil(userInfo_);
	UTILAssertKindOfClass(contents_, NSString);
	
	[self removeFromNotificationCeterWithDownloader : downloader_];
	if (NO == [[self threadIdentifier] isEqual : [downloader_ identifier]]) {
		return;
	}
	[self composeDATContents : contents_
			 threadSignature : [downloader_ identifier]
				   nextIndex : [downloader_ nextIndex]];
}
- (void) threadTextDownloaderInvalidPerticalContents : (NSNotification *) notification
{
	ThreadTextDownloader	*downloader_;
	
	UTILAssertNotificationName(
		notification,
		ThreadTextDownloaderInvalidPerticalContentsNotification);
		
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, ThreadTextDownloader);
	[self removeFromNotificationCeterWithDownloader : downloader_];
	
	
	NSBeginAlertSheet(
		[self localizedString : APP_TVIEWER_INVALID_PERT_TITLE],
		[self localizedString : APP_TVIEWER_DEL_AND_RETRY_LABEL],
		[self localizedString : APP_TVIEWER_DELETE_LABEL],
		[self localizedString : APP_TVIEWER_NOT_DELETE_LABEL],
		[self window],
		self,
		@selector(threadInvalidPerticalContentsSheetDidEnd:returnCode:contextInfo:),
		NULL,
		[downloader_ retain],
		[self localizedString : APP_TVIEWER_INVALID_PERT_MSG_FMT],
		[downloader_ threadTitle]);//,
		//[downloader_ filePathToWrite]);
	
	
	return;
}



- (void) threadTextDownloaderNotFound : (NSNotification *) notification
{
	ThreadTextDownloader	*downloader_;
	// 過去ログ検索
	NSURL					*threadURL_;
	NSString				*alternateButton_ = nil;
	
	UTILAssertNotificationName(
		notification,
		CMRDownloaderNotFoundNotification);
	
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, ThreadTextDownloader);
	[self removeFromNotificationCeterWithDownloader : downloader_];
	
	threadURL_ = [downloader_ threadURL];
	
	// 過去ログの検索
/*
	alternateButton_ = is_2channel([[threadURL_ host] UTF8String])
							? [self localizedString : kSearchKakoLogLabelKey]
							: nil;
*/
	
	NSBeginAlertSheet(
		[self localizedString : kNotFoundTitleKey],
		nil,
		alternateButton_,	// alternateButton
		nil,
		[self window],
		self,
		@selector(threadNotFoundSheetDidEnd:returnCode:contextInfo:),
		NULL,						// didDismissSelector
		[downloader_ retain],		// contextInfo
		
		// message...
		[self localizedString : kNotFoundMessageFormatKey],
		[downloader_ threadTitle] ? [downloader_ threadTitle] : @"",
		[[downloader_ threadSignature] BBSName],
		[downloader_ filePathToWrite],
		[threadURL_ absoluteString]);
	
	return;
}

- (void) reloadAfterDeletion : (NSString *) filePath_
{
	[self loadFromContentsOfFile : filePath_];
}

- (void) threadInvalidPerticalContentsSheetDidEnd : (NSWindow *) sheet
									   returnCode : (int       ) returnCode
									  contextInfo : (void     *) contextInfo;
{
	ThreadTextDownloader	*downloader_;
	NSString				*filePathToWrite_;
	
	downloader_ = [(id)contextInfo autorelease];
	UTILAssertKindOfClass(downloader_, ThreadTextDownloader);
	
	filePathToWrite_ = [downloader_ filePathToWrite];
	
	switch(returnCode) {
	case NSAlertDefaultReturn: // Delete and try again
	{
		if ([self forceDeleteThreadAtPath : filePathToWrite_ alsoReplyFile : NO]) {
			[self reloadAfterDeletion : filePathToWrite_];
		} else {
			NSBeep();
			NSLog(@"Deletion failed : %@\n...So reloading operation has been canceled.", filePathToWrite_);
		}
		break;
	}
	case NSAlertAlternateReturn: // Delete only
		[self forceDeleteThreadAtPath : filePathToWrite_ alsoReplyFile : YES];
		break;
	case NSAlertOtherReturn:
		break;
	case NSAlertErrorReturn:
		break;
	default:
		UTILUnknownSwitchCase(returnCode);
		break;
	}
}

- (void) threadNotFoundSheetDidEnd : (NSWindow *) sheet
						returnCode : (int       ) returnCode
					   contextInfo : (void     *) contextInfo
{
	ThreadTextDownloader	*downloader_;
	NSString				*filePathToWrite_;
	
	downloader_ = [(id)contextInfo autorelease];
	UTILAssertKindOfClass(downloader_, ThreadTextDownloader);
	
	filePathToWrite_ = [downloader_ filePathToWrite];
	
	switch(returnCode) {
	case NSAlertDefaultReturn:
		break;
	case NSAlertAlternateReturn:	// 過去ログ検索
/*
		[self forceDeleteThreadAtPath : filePathToWrite_ alsoReplyFile : NO];
		[self downloadKakoThread : [downloader_ threadSignature]];
*/
		break;
	case NSAlertOtherReturn:
		break;
	case NSAlertErrorReturn:
		break;
	default:
		UTILUnknownSwitchCase(returnCode);
		break;
	}
}
@end