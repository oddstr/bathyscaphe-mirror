//
//  CMRThreadViewer-Download.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/23.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadViewer_p.h"
#import "CMRAbstructThreadDocument.h"
#import "CMRDATDownloader.h"


@implementation CMRThreadViewer(Download)
- (void)downloadThread:(CMRThreadSignature *)aSignature title:(NSString *)threadTitle nextIndex:(unsigned int)aNextIndex
{
	CMRDownloader			*downloader;
	NSNotificationCenter	*nc;
	
	nc = [NSNotificationCenter defaultCenter];
	downloader = [ThreadTextDownloader downloaderWithIdentifier:aSignature threadTitle:threadTitle nextIndex:aNextIndex];

	if (!downloader) return;
	
	/* NotificationCenter */
	[nc addObserver:self
		   selector:@selector(threadTextDownloaderInvalidPerticalContents:)
			   name:ThreadTextDownloaderInvalidPerticalContentsNotification
			 object:downloader];
/*	[nc addObserver:self
		   selector:@selector(threadTextDownloaderNotFound:)
			   name:CMRDownloaderNotFoundNotification
			 object:downloader];*/
	[nc addObserver:self
		   selector:@selector(threadTextDownloaderDidDetectDatOchi:)
			   name:CMRDATDownloaderDidDetectDatOchiNotification
			 object:downloader];
	[nc addObserver:self
		   selector:@selector(threadTextDownloaderDidFinishLoading:)
			   name:ThreadTextDownloaderDidFinishLoadingNotification
			 object:downloader];

	/* TaskManager, load */
	[[CMRTaskManager defaultManager] addTask:downloader];
	[downloader loadInBackground];
}

- (void)removeFromNotificationCeterWithDownloader:(CMRDownloader *)downloader
{
	NSNotificationCenter	*nc;

	if (!downloader) return;
	nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self
				  name:ThreadTextDownloaderInvalidPerticalContentsNotification
				object:downloader];
/*	[nc removeObserver:self
				  name:CMRDownloaderNotFoundNotification
				object:downloader];*/
	[nc removeObserver:self
				  name:CMRDATDownloaderDidDetectDatOchiNotification
				object:downloader];
	[nc removeObserver:self
				  name:ThreadTextDownloaderDidFinishLoadingNotification
				object:downloader];
}

- (void)threadTextDownloaderDidFinishLoading:(NSNotification *)notification
{
	ThreadTextDownloader	*downloader;
	NSDictionary			*userInfo;
	NSString				*contents;

	UTILAssertNotificationName(notification, ThreadTextDownloaderDidFinishLoadingNotification);
	
	userInfo = [notification userInfo];
	UTILAssertNotNil(userInfo);

	downloader = [notification object];
	contents = [userInfo objectForKey:CMRDownloaderUserInfoContentsKey];
	UTILAssertKindOfClass(downloader, ThreadTextDownloader);
	UTILAssertKindOfClass(contents, NSString);
	
	[self removeFromNotificationCeterWithDownloader:downloader];

	if (![[self threadIdentifier] isEqual:[downloader identifier]]) {
		return;
	}

	[[self threadAttributes] addEntriesFromDictionary:[userInfo objectForKey:CMRDownloaderUserInfoAdditionalInfoKey]];
	[self composeDATContents:contents threadSignature:[downloader identifier] nextIndex:[downloader nextIndex]];
}

- (void)threadTextDownloaderInvalidPerticalContents:(NSNotification *)notification
{
	ThreadTextDownloader	*downloader;
	NSString				*threadTitle = @"";
	
	UTILAssertNotificationName(notification, ThreadTextDownloaderInvalidPerticalContentsNotification);

	downloader = [notification object];
	UTILAssertKindOfClass(downloader, ThreadTextDownloader);

	threadTitle = [downloader threadTitle];

	[self removeFromNotificationCeterWithDownloader:downloader];

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:[self localizedString:APP_TVIEWER_INVALID_PERT_TITLE]];
	[alert setInformativeText:[NSString stringWithFormat:[self localizedString:APP_TVIEWER_INVALID_PERT_MSG_FMT], threadTitle]];
	[alert addButtonWithTitle:[self localizedString:APP_TVIEWER_DEL_AND_RETRY_LABEL]];
	[alert addButtonWithTitle:[self localizedString:APP_TVIEWER_NOT_DELETE_LABEL]];
	[alert addButtonWithTitle:[self localizedString:APP_TVIEWER_DELETE_LABEL]];
	[alert setShowsHelp:YES];
	[alert setHelpAnchor:[self localizedString:kInvalidPerticalContentsHelpKeywordKey]];
	[alert setDelegate:self];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(threadInvalidParticalContentsSheetDidEnd:returnCode:contextInfo:)
						contextInfo:[[downloader filePathToWrite] retain]];
}

- (void)informDatOchiWithTitleRulerIfNeeded
{
	if ([CMRPref informWhenDetectDatOchi]) {
		BSTitleRulerView *ruler = (BSTitleRulerView *)[[self scrollView] horizontalRulerView];

		[ruler setCurrentMode:[[self class] rulerModeForInformDatOchi]];
		[ruler setInfoStr:[self localizedString:@"titleRuler info auto-detected title"]];
		[[self scrollView] setRulersVisible:YES];

		[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(cleanUpTitleRuler:) userInfo:nil repeats:NO];
	}
}

- (void)beginNotFoundAlertSheetWithDownloader:(ThreadTextDownloader *)downloader
{
	NSURL		*threadURL;
	NSString	*filePath;
	NSString	*threadTitle;

	threadURL = [downloader threadURL];
	filePath = [downloader filePathToWrite];
	threadTitle = [downloader threadTitle];
	if (!threadTitle) threadTitle = @"";

	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		[(CMRAbstructThreadDocument *)[self document] setIsDatOchiThread:YES];
		[self informDatOchiWithTitleRulerIfNeeded];
		return;
	}

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *info = [NSString stringWithFormat:[self localizedString:kNotFoundMessageFormatKey], threadTitle, [threadURL absoluteString]];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:[self localizedString:kNotFoundTitleKey]];
	[alert setInformativeText:info];
	[alert addButtonWithTitle:[self localizedString:kNotFoundCancelLabelKey]];
	[alert setShowsHelp:YES];
	[alert setHelpAnchor:[self localizedString:kNotFoundHelpKeywordKey]];
	[alert setDelegate:self];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(threadNotFoundSheetDidEnd:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)validateWhetherDatOchiWithDownloader:(ThreadTextDownloader *)downloader
{
	unsigned	resCount;
	resCount = [downloader nextIndex];

	if (resCount < 1001) {
		[self beginNotFoundAlertSheetWithDownloader:downloader];
	} else {
		[(CMRAbstructThreadDocument *)[self document] setIsDatOchiThread:YES];
		[self informDatOchiWithTitleRulerIfNeeded];
	}
}

- (void)threadTextDownloaderDidDetectDatOchi:(NSNotification *)notification
{
	CMRDATDownloader	*downloader;
	
	UTILAssertNotificationName(notification, CMRDATDownloaderDidDetectDatOchiNotification);
		
	downloader = [notification object];
	UTILAssertKindOfClass(downloader, CMRDATDownloader);

	[self removeFromNotificationCeterWithDownloader:downloader];

	[self validateWhetherDatOchiWithDownloader:downloader];
}

- (void)threadTextDownloaderNotFound:(NSNotification *)notification
{
	ThreadTextDownloader	*downloader;
	
	UTILAssertNotificationName(notification, CMRDownloaderNotFoundNotification);

	downloader = [notification object];
	UTILAssertKindOfClass(downloader, ThreadTextDownloader);

	[self removeFromNotificationCeterWithDownloader:downloader];

	[self beginNotFoundAlertSheetWithDownloader:downloader];
}

- (BOOL)alertShowHelp:(NSAlert *)alert
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:[alert helpAnchor] inBook:[NSBundle applicationHelpBookName]];
	return YES;
}

- (void)reloadAfterDeletion:(NSString *)filePath
{
	[self loadFromContentsOfFile:filePath];
}

- (void)threadInvalidParticalContentsSheetDidEnd:(NSAlert *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSString				*path;
	
	path = [(id)contextInfo autorelease];
	UTILAssertKindOfClass(path, NSString);

	switch (returnCode) {
	case NSAlertFirstButtonReturn: // Delete and try again
	{
		if (![self forceDeleteThreadAtPath:path alsoReplyFile:NO]) {
			NSBeep();
			NSLog(@"Deletion failed : %@\n...So reloading operation has been canceled.", path);
		}
		break;
	}
	case NSAlertSecondButtonReturn: // Cancel
		break;
	case NSAlertThirdButtonReturn: // Delete only
		[self forceDeleteThreadAtPath:path alsoReplyFile:YES];
		break;
	default:
		UTILUnknownSwitchCase(returnCode);
		break;
	}
}

- (void) threadNotFoundSheetDidEnd:(NSAlert *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	switch (returnCode) {
	case NSAlertFirstButtonReturn:
		break;
	case NSAlertSecondButtonReturn:
		[(CMRAbstructThreadDocument *)[self document] setIsDatOchiThread:YES];
		break;
	default:
		UTILUnknownSwitchCase(returnCode);
		break;
	}
}
@end
