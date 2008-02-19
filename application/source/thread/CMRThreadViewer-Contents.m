//
//  CMRThreadViewer-Contents.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/19.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadViewer_p.h"
#import "CMRThreadVisibleRange.h"
#import "BSRelativeKeywordsCollector.h"

@implementation CMRThreadViewer(ThreadContents)
- (BOOL)shouldShowContents
{
	return YES;
}

- (BOOL)shouldSaveThreadDataAttributes
{
	return ([self shouldShowContents] && (![self isInvalidate]));
}

- (BOOL)shouldLoadWindowFrameUsingCache
{
	return YES;
}

- (BOOL)canGenarateContents
{
	return (![self isInvalidate]);
}

- (BOOL)checkCanGenarateContents
{
	if ([self canGenarateContents]) return YES;

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *informativeText;

	informativeText = [NSString stringWithFormat:[self localizedString:APP_TVIEWER_INVALID_THREAD_MSG_FMT],
		([self title] ? [self title] : @""), ([self path] ? [self path] : @"")];

	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:[self localizedString:APP_TVIEWER_INVALID_THREAD_TITLE]];
	[alert setInformativeText:informativeText];
	[alert addButtonWithTitle:[self localizedString:APP_TVIEWER_DO_RELOAD_LABEL]];
	[alert addButtonWithTitle:[self localizedString:APP_TVIEWER_NOT_RELOAD_LABEL]];

	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(threadStatusInvalidateAlertDidEnd:returnCode:contextInfo:)
						contextInfo:nil];	
	return NO;
}

- (void)threadStatusInvalidateAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	switch(returnCode){
	case NSAlertFirstButtonReturn:
		[self loadFromContentsOfFile:[self path]];
		break;
	default:
		break;
	}	
}

- (void)setThreadAttributes:(CMRThreadAttributes *)newAttrs
{
	id		tmp;

	tmp = [self threadAttributes];
	if (tmp == newAttrs) return;

	[self disposeThreadAttributes];//:tmp];
	[[self document] setThreadAttributes:newAttrs];
	[self registerThreadAttributes:newAttrs];
}

- (void)disposeThreadAttributes//:(CMRThreadAttributes *)oldAttrs
{
	CMRThreadAttributes *oldAttrs = [self threadAttributes];
	if (!oldAttrs) return;

	[oldAttrs removeObserver:self forKeyPath:@"visibleRange"];
//	[oldAttrs removeObserver:self forKeyPath:@"windowFrame"];
	[self threadWillClose];
}

- (void)registerThreadAttributes:(CMRThreadAttributes *)newAttrs
{
	if (!newAttrs) return;

//	[newAttrs addObserver:self forKeyPath:@"windowFrame" options:NSKeyValueObservingOptionNew context:kThreadViewerAttrContext];
	[newAttrs addObserver:self forKeyPath:@"visibleRange" options:NSKeyValueObservingOptionNew context:kThreadViewerAttrContext];
	[self synchronizeAttributes];
}

#pragma mark Keywords Support (Starlight Breaker Additions)
- (void)collector:(BSRelativeKeywordsCollector *)aCollector didCollectKeywords:(NSArray *)keywordsDict
{
	[self setCachedKeywords:keywordsDict];
	[[self indexingPopupper] updateKeywordsMenu];
}

- (void)collector:(BSRelativeKeywordsCollector *)aCollector didFailWithError:(NSError *)error
{
//	NSLog(@"BSRKC - ERROR! %i", [error code]);
	[self setCachedKeywords:[NSArray array]];
}

- (void)updateKeywordsCache
{
	if (![CMRPref isOnlineMode]) {
		[[self indexingPopupper] updateKeywordsMenuForOfflineMode];
		return;
	}

	BSRelativeKeywordsCollector *collector = [[self document] keywordsCollector];
	if ([collector isInProgress]) {
		[collector abortCollecting];
	}
	[collector setThreadURL:[self threadURL]];
	[collector setDelegate:self];
	[collector startCollecting];
}
@end


@implementation CMRThreadViewer(ThreadAttributesNotification)
- (void)synchronizeVisibleRange
{
	[[self indexingPopupper] setVisibleRange:[[self threadAttributes] visibleRange]];
}

- (void)synchronizeAttributes
{
	[self window];
	[self synchronizeVisibleRange];
	[self synchronizeWindowTitleWithDocumentName];
}

- (void)synchronizeLayoutAttributes
{
	if ([self shouldLoadWindowFrameUsingCache]) {
		[self setWindowFrameUsingCache];
	}
}
@end
