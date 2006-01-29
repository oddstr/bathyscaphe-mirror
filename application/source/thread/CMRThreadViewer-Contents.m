/**
  * $Id: CMRThreadViewer-Contents.m,v 1.2.2.1 2006/01/29 12:58:10 masakih Exp $
  * 
  * CMRThreadViewer-Contents.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadViewer_p.h"
#import "CMRThreadLayout.h"
#import "CMRThreadVisibleRange.h"
//#import "NSLayoutManager+CMXAdditions.h"



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
@end



@implementation CMRThreadViewer(ThreadAttributesNotification)
- (void) synchronizeVisibleLength : (BOOL					) isFirst
					 visibleRange : (CMRThreadVisibleRange *) visibleRange
{
    NSPopUpButton *popUp;
    unsigned       length;
    id             num;
    int            idx = -1;
    
    if (nil == visibleRange) {
        return;
    }
    
    popUp = isFirst ? [self firstVisibleRangePopUpButton]
                    : [self lastVisibleRangePopUpButton];
    
    length = isFirst ? [visibleRange firstVisibleLength]
                     : [visibleRange lastVisibleLength];
    
    num = [NSNumber numberWithUnsignedInt : length];
    idx = [popUp indexOfItemWithRepresentedObject : num];
    if (-1 == idx) {
        NSMenuItem *item;
        
        item = [self addItemWithVisibleRangePopUpButton : popUp
            isFirstVisibles : isFirst
            representedIndex : num];
        idx = [popUp indexOfItem : item];
    }
    [popUp selectItemAtIndex : idx];
}
- (void) synchronizeVisibleRange
{
	CMRThreadVisibleRange	*visibleRange_;
	
	visibleRange_ = [[self threadAttributes] visibleRange];
	[self synchronizeVisibleLength:YES visibleRange:visibleRange_];
	[self synchronizeVisibleLength:NO visibleRange:visibleRange_];
}
- (void) synchronizeAttributes
{
	[self window];
	[self synchronizeVisibleRange];
	[self synchronizeWindowTitleWithDocumentName];
}
- (void) synchronizeLayoutAttributes
{
	if([self shouldLoadWindowFrameUsingCache]){
		[self setWindowFrameUsingCache];
	}
}
@end
