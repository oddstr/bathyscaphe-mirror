/**
  * $Id: CMRThreadViewer-Download.m,v 1.15 2006/11/05 12:53:48 tsawada2 Exp $
  * BathyScaphe
  * 
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
  */
#import "CMRThreadViewer_p.h"
#import "CMRDownloader.h"
#import "ThreadTextDownloader.h"
#import "CMRDATDownloader.h"
#import "BoardManager.h"

// そんな板 or スレッドありません
#define kNotFoundTitleKey				@"Not Found Title"
#define kNotFoundMessageFormatKey		@"Not Found Message"
#define kNotFoundMessage2FormatKey		@"Not Found Msg 2"
#define kMakeDatOchiLabelKey			@"Make DatOchi"
#define kSearchKakoLogLabelKey			@"Search Kako Log" // reserved
#define kNotFoundHelpKeywordKey			@"NotFoundSheet Help Anchor"
#define kInvalidPerticalContentsHelpKeywordKey	@"InvalidPerticalSheet Help Anchor"
#define kNotFoundCancelLabelKey			@"Do Not Reload Button Label"


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
			selector : @selector(threadTextDownloaderDidDetectDatOchi:)
			    name : CMRDATDownloaderDidDetectDatOchiNotification
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
				   name : CMRDATDownloaderDidDetectDatOchiNotification
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
	
	
	NSAlert *alert_ = [NSAlert alertWithMessageText : [self localizedString : APP_TVIEWER_INVALID_PERT_TITLE]
									  defaultButton : [self localizedString : APP_TVIEWER_DEL_AND_RETRY_LABEL]
									alternateButton : [self localizedString : APP_TVIEWER_DELETE_LABEL]
										otherButton : [self localizedString : APP_TVIEWER_NOT_DELETE_LABEL]
						  informativeTextWithFormat : [self localizedString : APP_TVIEWER_INVALID_PERT_MSG_FMT],
													  [downloader_ threadTitle]];
	[alert_ setShowsHelp : YES];
	[alert_ setHelpAnchor : [self localizedString : kInvalidPerticalContentsHelpKeywordKey]];
	[alert_ setDelegate : self];
	[alert_ beginSheetModalForWindow : [self window]
					   modalDelegate : self
					  didEndSelector : @selector(threadInvalidPerticalContentsSheetDidEnd:returnCode:contextInfo:)
						 contextInfo : [downloader_ retain]];

	return;
}

- (void) beginNotFoundAlertSheetWithDownloader: (ThreadTextDownloader *) downloader_
{
	NSURL					*threadURL_;
	//NSString				*alternateButton_ = nil;
	NSString				*filePath_;
	BOOL					fileExists_;
	threadURL_ = [downloader_ threadURL];
	filePath_ = [downloader_ filePathToWrite];
	
	// 過去ログの検索
/*
	alternateButton_ = is_2channel([[threadURL_ host] UTF8String])
							? [self localizedString : kSearchKakoLogLabelKey]
							: nil;
*/
	fileExists_ = [[NSFileManager defaultManager] fileExistsAtPath : filePath_];

	NSAlert *alert_ = [NSAlert alertWithMessageText : [self localizedString : kNotFoundTitleKey]
									  defaultButton : [self localizedString : kNotFoundCancelLabelKey]
									alternateButton : nil
										otherButton : (fileExists_ ? [self localizedString : kMakeDatOchiLabelKey] : nil)
						  informativeTextWithFormat : (fileExists_ ? [self localizedString : kNotFoundMessage2FormatKey] :
																	 [self localizedString : kNotFoundMessageFormatKey]),
													  [downloader_ threadTitle] ? [downloader_ threadTitle] : @"",
													  [threadURL_ absoluteString]];
	[alert_ setShowsHelp : YES];
	[alert_ setHelpAnchor : [self localizedString : kNotFoundHelpKeywordKey]];
	[alert_ setDelegate : self];
	[alert_ beginSheetModalForWindow : [self window]
					   modalDelegate : self
					  didEndSelector : @selector(threadNotFoundSheetDidEnd:returnCode:contextInfo:)
						 contextInfo : [downloader_ retain]];
}

- (void) validateWhetherDatOchiWithDownloader: (ThreadTextDownloader *) downloader_
{
	unsigned	resCount;
	resCount = [downloader_ nextIndex];

	if(resCount < 1001) {
		[self beginNotFoundAlertSheetWithDownloader: downloader_];
	} else {
		[self setDatOchiThread: YES];

		if ([CMRPref informWhenDetectDatOchi]) {
			BSTitleRulerView *view_ = (BSTitleRulerView *)[[self scrollView] horizontalRulerView];

			[view_ setCurrentMode: [[self class] rulerModeForInformDatOchi]];
			[view_ setInfoStr: [self localizedString: @"titleRuler info auto-detected title"]];
			[[self scrollView] setRulersVisible: YES];
			
			[NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector: @selector(cleanUpTitleRuler:) userInfo: nil repeats: NO];
		}
	}
}

- (void) threadTextDownloaderDidDetectDatOchi : (NSNotification *) notification
{
	CMRDATDownloader	*downloader_;
	
	UTILAssertNotificationName(
		notification,
		CMRDATDownloaderDidDetectDatOchiNotification);
		
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, CMRDATDownloader);
	[self removeFromNotificationCeterWithDownloader : downloader_];
	
	[self validateWhetherDatOchiWithDownloader: downloader_];
}

- (void) threadTextDownloaderNotFound : (NSNotification *) notification
{
	ThreadTextDownloader	*downloader_;
	
	UTILAssertNotificationName(
		notification,
		CMRDownloaderNotFoundNotification);
	
	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, ThreadTextDownloader);
	[self removeFromNotificationCeterWithDownloader : downloader_];

	[self beginNotFoundAlertSheetWithDownloader: downloader_];
}

- (BOOL) alertShowHelp : (NSAlert *) alert
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : [alert helpAnchor]
											   inBook : [NSBundle applicationHelpBookName]];
	return YES;
}

- (void) reloadAfterDeletion : (NSString *) filePath_
{
	[self loadFromContentsOfFile : filePath_];
}

- (void) threadInvalidPerticalContentsSheetDidEnd : (NSAlert *) sheet
									   returnCode : (int      ) returnCode
									  contextInfo : (void    *) contextInfo;
{
	ThreadTextDownloader	*downloader_;
	NSString				*filePathToWrite_;
	
	downloader_ = [(id)contextInfo autorelease];
	UTILAssertKindOfClass(downloader_, ThreadTextDownloader);
	
	filePathToWrite_ = [downloader_ filePathToWrite];
	
	switch(returnCode) {
	case NSAlertDefaultReturn: // Delete and try again
	{
		if (![self forceDeleteThreadAtPath : filePathToWrite_ alsoReplyFile : NO]) {
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

- (void) threadNotFoundSheetDidEnd : (NSAlert *) sheet
						returnCode : (int      ) returnCode
					   contextInfo : (void    *) contextInfo
{
	ThreadTextDownloader	*downloader_;
	NSString				*filePathToWrite_;
	
	downloader_ = [(id)contextInfo autorelease];
	UTILAssertKindOfClass(downloader_, ThreadTextDownloader);
	
	filePathToWrite_ = [downloader_ filePathToWrite];
	
	switch(returnCode) {
	case NSAlertDefaultReturn:
		break;
/*
	case NSAlertAlternateReturn:	// 過去ログ検索
		break;
*/
	case NSAlertOtherReturn:
		[self setDatOchiThread : YES];
		break;
	case NSAlertErrorReturn:
		break;
	default:
		UTILUnknownSwitchCase(returnCode);
		break;
	}
}
@end
