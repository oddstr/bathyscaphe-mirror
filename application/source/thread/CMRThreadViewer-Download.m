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
#import "BSLoggedInDATDownloader.h"

@implementation CMRThreadViewer(Download)
#pragma mark Start Downloading
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

#pragma mark After Download (Success)
- (void)removeFromNotificationCeterWithDownloader:(CMRDownloader *)downloader
{
	NSNotificationCenter	*nc;

	if (!downloader) return;
	nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self
				  name:ThreadTextDownloaderInvalidPerticalContentsNotification
				object:downloader];
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

#pragma mark After Download (Some Error)
- (void)threadTextDownloaderInvalidPerticalContents:(NSNotification *)notification
{
	ThreadTextDownloader	*downloader;
	NSString				*threadTitle = @"";
	
	UTILAssertNotificationName(notification, ThreadTextDownloaderInvalidPerticalContentsNotification);

	downloader = [[notification object] retain];
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
						contextInfo:[downloader retain]];
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

	const char *hs;
	hs = [[threadURL host] UTF8String];

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *title = [NSString stringWithFormat:[self localizedString:kNotFoundTitleKey], threadTitle];
	NSString *info;
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:title];
	[alert addButtonWithTitle:[self localizedString:kNotFoundCancelLabelKey]];
	if (hs != NULL && is_2channel(hs)) {
		[alert addButtonWithTitle:[self localizedString:kNotFoundMaruLabelKey]];
		info = [NSString stringWithFormat:[self localizedString:kNotFoundMessageFormatKey], [threadURL absoluteString]];
	} else {
		info = [NSString stringWithFormat:[self localizedString:kNotFoundMessageFormat2Key], [threadURL absoluteString]];
	}
	[alert setInformativeText:info];
	[alert setShowsHelp:YES];
	[alert setHelpAnchor:[self localizedString:kNotFoundHelpKeywordKey]];
	[alert setDelegate:self];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(threadNotFoundSheetDidEnd:returnCode:contextInfo:)
						contextInfo:[downloader retain]];
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

- (BOOL)alertShowHelp:(NSAlert *)alert
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:[alert helpAnchor] inBook:[NSBundle applicationHelpBookName]];
	return YES;
}

- (void)threadInvalidParticalContentsSheetDidEnd:(NSAlert *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSString				*path;
	id	downloader;
	downloader = (id)contextInfo;
	UTILAssertKindOfClass(downloader, ThreadTextDownloader);
	path = [downloader filePathToWrite];

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
	[downloader autorelease];
}

- (void) threadNotFoundSheetDidEnd:(NSAlert *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	id	downloader;
	downloader = (id)contextInfo;
	UTILAssertKindOfClass(downloader, ThreadTextDownloader);

	switch (returnCode) {
	case NSAlertFirstButtonReturn:
		break;
	case NSAlertSecondButtonReturn:
		[self downloadThreadUsingMaru:[downloader identifier] title:[downloader threadTitle]];
		break;
	default:
		UTILUnknownSwitchCase(returnCode);
		break;
	}
	[downloader autorelease];
}

#pragma mark Start Maru-Login Downloading
- (void)downloadThreadUsingMaru:(CMRThreadSignature *)aSignature title:(NSString *)threadTitle
{
	BSLoggedInDATDownloader *downloader;
	NSNotificationCenter	*nc = [NSNotificationCenter defaultCenter];

	downloader = [BSLoggedInDATDownloader downloaderWithIdentifier:aSignature threadTitle:threadTitle];
	if (!downloader) return;

	[nc addObserver:self selector:@selector(loggedInDATDownloaderDidFinishLoading:) name:ThreadTextDownloaderDidFinishLoadingNotification object:downloader];

	/* TaskManager, load */
	[[CMRTaskManager defaultManager] addTask:downloader];
	[downloader loadInBackground];
}

- (void)loggedInDATDownloaderDidFinishLoading:(NSNotification *)notification
{
	BSLoggedInDATDownloader	*downloader;
	NSDictionary			*userInfo;
	NSString				*contents;

	UTILAssertNotificationName(notification, ThreadTextDownloaderDidFinishLoadingNotification);
	
	userInfo = [notification userInfo];
	UTILAssertNotNil(userInfo);

	downloader = [notification object];
	contents = [userInfo objectForKey:CMRDownloaderUserInfoContentsKey];
	UTILAssertKindOfClass(downloader, BSLoggedInDATDownloader);
	UTILAssertKindOfClass(contents, NSString);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ThreadTextDownloaderDidFinishLoadingNotification object:downloader];

	if (![[self threadIdentifier] isEqual:[downloader identifier]]) {
		return;
	}

	[[self threadAttributes] addEntriesFromDictionary:[userInfo objectForKey:CMRDownloaderUserInfoAdditionalInfoKey]];
	[(CMRAbstructThreadDocument *)[self document] setIsDatOchiThread:YES];

	[self composeDATContents:contents threadSignature:[downloader identifier] nextIndex:[downloader nextIndex]];
}
@end
