/**
  * $Id: CMRThreadViewer-Contents.m,v 1.7 2007/02/12 18:22:24 tsawada2 Exp $
  * 
  * CMRThreadViewer-Contents.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRThreadViewer_p.h"
#import "CMRThreadLayout.h"
#import "CMRThreadVisibleRange.h"
#import "BSRelativeKeywordsCollector.h"

@implementation CMRThreadViewer(ThreadContents)
- (BOOL) shouldShowContents
{
	return YES;
}
- (BOOL) shouldSaveThreadDataAttributes
{
	return ([self shouldShowContents] && (NO == [self isInvalidate]));
}
- (BOOL) shouldLoadWindowFrameUsingCache
{
	return YES;
}
- (BOOL) canGenarateContents
{
	return (NO == [self isInvalidate]);
}
- (BOOL) checkCanGenarateContents
{
	if([self canGenarateContents])
		return YES;
	
	NSBeginAlertSheet(
		[self localizedString : APP_TVIEWER_INVALID_THREAD_TITLE],
		[self localizedString : APP_TVIEWER_DO_RELOAD_LABEL],
		[self localizedString : APP_TVIEWER_NOT_RELOAD_LABEL],
		nil,
		[self window],
		self,
		@selector(threadStatusInvalidateSheetDidEnd:returnCode:contextInfo:),
		NULL,
		nil,
		[self localizedString : APP_TVIEWER_INVALID_THREAD_MSG_FMT],
		[self title] ? [self title] : @"",
		[self path] ? [self path] : @"");
	
	return NO;
}
- (void) threadStatusInvalidateSheetDidEnd : (NSWindow *) sheet
								returnCode : (int       ) returnCode
							   contextInfo : (void     *) contextInfo
{
	switch(returnCode){
	case NSAlertDefaultReturn:
		[self loadFromContentsOfFile : [self path]];
		break;
	case NSAlertAlternateReturn:
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

- (NSTextStorage *) threadContent
{
	return [(CMRThreadDocument*)[self document] textStorage];
}
- (void) setThreadAttributes : (CMRThreadAttributes *) newAttrs
{
	id		tmp;
	
	tmp = [self threadAttributes];
	if(tmp == newAttrs) return;

	[self disposeThreadAttributes : tmp];
	[[self document] setThreadAttributes : newAttrs];
	[self registerThreadAttributes : newAttrs];
}

- (void) disposeThreadAttributes : (CMRThreadAttributes *) oldAttrs
{
	if(nil == oldAttrs) return;
	
	[[NSNotificationCenter defaultCenter]
			 removeObserver : self
					   name : CMRThreadAttributesDidChangeNotification
					 object : oldAttrs];
	
	[self threadWillClose];
}

- (void) registerThreadAttributes : (CMRThreadAttributes *) newAttrs
{
	NSNotificationCenter		*center_;
	
	if(nil == newAttrs) return;


	center_ = [NSNotificationCenter defaultCenter];
	[center_ addObserver : self
		        selector : @selector(threadAttributesDidChangeAttributes:)
		            name : CMRThreadAttributesDidChangeNotification
	              object : newAttrs];
	[self synchronizeAttributes];
}

#pragma mark Keywords Support (Starlight Breaker Additions)
- (void) collector: (BSRelativeKeywordsCollector *) aCollector didCollectKeywords: (NSArray *) keywordsDict
{
	[self setCachedKeywords: keywordsDict];
	[[self indexingPopupper] updateKeywordsMenu];
	[aCollector release];
}
- (void) collector: (BSRelativeKeywordsCollector *) aCollector didFailWithError: (NSError *) error
{
	NSLog(@"BSRKC - ERROR! %i", [error code]);
	[self setCachedKeywords: [NSArray array]];
	[aCollector release];
}

- (void) updateKeywordsCache
{
	if (NO == [CMRPref isOnlineMode]) {
		[[self indexingPopupper] updateKeywordsMenuForOfflineMode];
		return;
	}
	BSRelativeKeywordsCollector *collector = [[BSRelativeKeywordsCollector alloc] initWithThreadURL: [self threadURL] delegate: self];
	[collector startCollecting];
}
@end



@implementation CMRThreadViewer(ThreadAttributesNotification)
- (void) synchronizeVisibleRange
{
	[[self indexingPopupper] setVisibleRange: [[self threadAttributes] visibleRange]];
}
- (void) synchronizeAttributes
{
	[self willChangeValueForKey: @"threadAttributes"];
	[self window];
	[self synchronizeVisibleRange];
	[self synchronizeWindowTitleWithDocumentName];
	[self didChangeValueForKey: @"threadAttributes"];
}
- (void) synchronizeLayoutAttributes
{
	if([self shouldLoadWindowFrameUsingCache]){
		[self setWindowFrameUsingCache];
	}
}
@end
