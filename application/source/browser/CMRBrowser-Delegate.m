/**
  * $Id: CMRBrowser-Delegate.m,v 1.3 2005/05/15 00:12:15 tsawada2 Exp $
  * 
  * CMRBrowser-Delegate.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"
#import "CMRNoNameManager.h"
#import "missing.h"

extern NSString *const ThreadsListDownloaderShouldRetryUpdateNotification;

@implementation CMRBrowser(Delegate)
- (void) saveBoardDrawerState
{
	[CMRPref setBoardListState : [[self boardDrawer] state]];
}
- (NSSize) drawerWillResizeContents : (NSDrawer *) sender
                             toSize : (NSSize    ) contentSize
{
	if (sender != [self boardDrawer]) return contentSize;
	[CMRPref setBoardListContentSize : [[self boardDrawer] contentSize]];
	
	return contentSize;
}
- (void) drawerDidClose : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		NSDrawerDidCloseNotification);
	UTILAssertNotificationObject(
		notification,
		[self boardDrawer]);
	[self saveBoardDrawerState];
	
    // Restore window size if it was shrinked by CocoMonar
    if (_needToRestoreWindowSize) {
		/* 2005-01-25 tsawada2 <ben-sawa@td5.so-net.ne.jp>
			まずブラウザウインドウを元のサイズに戻してから、スレッド一覧のサイズを元のサイズに戻して、
			さらに再描画して反映させる。無駄なのでブラウザウインドウの setFrame:display:でNOを渡したいが、
			そうすると見苦しくなる…　もっといい方法がある気がするんだが。要研究 */
		[[[self boardDrawer] parentWindow] setFrame:_oldSize display:YES];
		/*
		if ([[self splitView] isVertical]) {
			[[[self splitView] firstSubview] setFrame:_oldTListSize];
			[[[self boardDrawer] parentWindow] displayIfNeeded];
		}
		*/
        _needToRestoreWindowSize = NO;
    }
}
- (void) drawerDidOpen : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		NSDrawerDidOpenNotification);
	UTILAssertNotificationObject(
		notification,
		[self boardDrawer]);
	
	[self saveBoardDrawerState];
}
- (void)drawerWillOpen:(NSNotification*)notification
{
    // if no space for drawer, we need to shrink parent window
	NSWindow	*parentWindow;
    NSRectEdge  edge;
    NSSize      contentSize;
    NSRect      windowFrame, withDrawerFrame, screenFrame;
	
	parentWindow = [[self boardDrawer] parentWindow];
    edge = [[self boardDrawer] edge];
    contentSize = [[self boardDrawer] contentSize];

    windowFrame = [parentWindow frame];
    withDrawerFrame = windowFrame;

    screenFrame = [[NSScreen mainScreen] visibleFrame];
	
    if (edge == NSMaxXEdge) {
		// Drawer は右側に開こうとしている
        withDrawerFrame.size.width += (contentSize.width + 10);
		
        if (withDrawerFrame.origin.x + withDrawerFrame.size.width
			> screenFrame.origin.x + screenFrame.size.width) {

            _needToRestoreWindowSize = YES;
			_oldSize = windowFrame;
			_oldTListSize = [[[self splitView] firstSubview] frame];
			
            windowFrame.size.width -= (withDrawerFrame.origin.x + withDrawerFrame.size.width) - (screenFrame.origin.x + screenFrame.size.width);
            [parentWindow setFrame:windowFrame display:YES animate:YES];
        }
    }
    if (edge == NSMinXEdge) {
		// Drawer は左側に開こうとしている
        withDrawerFrame.origin.x -= (contentSize.width + 10);
        withDrawerFrame.size.width += (contentSize.width + 10);
		
        if (withDrawerFrame.origin.x < screenFrame.origin.x) {

            _needToRestoreWindowSize = YES;
			_oldSize = windowFrame;
			_oldTListSize = [[[self splitView] firstSubview] frame];
            
            int delta;
            delta = screenFrame.origin.x - withDrawerFrame.origin.x;
            windowFrame.origin.x += delta;
            windowFrame.size.width -= delta;
            [parentWindow setFrame:windowFrame display:YES animate:YES];
        }
    }
}

#pragma mark -

- (BOOL)splitView:(id)sender canCollapseSubview:(NSView *)subview
{
    return (subview == bottomSubview);
}
- (void)splitView:(id)sender didDoubleClickInDivider:(int)index
{
    BOOL currentState = [[self splitView] isSubviewCollapsed:bottomSubview];
    [[self splitView] setSubview:bottomSubview isCollapsed:!currentState];
    [[self splitView] resizeSubviewsWithOldSize:[[self splitView] frame].size];
}
- (void)splitView:(id)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    // It's our responsibility to set the frame rectangles of
    // all uncollapsed subviews.
    int i, numSubviews, numDividers;
    float heightTotal, splitViewWidth, splitViewHeight, newSubviewHeight;
    float curYAxisPos, dividerThickness, scaleFactor, availableSpace;
    float minimumFirstSubviewHeight;
	
	float widthTotal, curXAxisPos, minimumFirstSubviewWidth, newSubviewWidth;
	
    id subview, subviews;

    // setup
    subviews = [sender subviews];
    numSubviews = [subviews count];
    numDividers = numSubviews - 1;
    splitViewWidth = [sender frame].size.width;
    splitViewHeight = [sender frame].size.height;
    dividerThickness = [sender dividerThickness];

    minimumFirstSubviewHeight = 90;
	minimumFirstSubviewWidth = 120;

	if ([sender isVertical]) {
		widthTotal = 0;
		for (i = 1; i < numSubviews; i++)
		{
			subview = [subviews objectAtIndex:i];
			if (![sender isSubviewCollapsed:subview]) {
				widthTotal += [subview frame].size.width;
			}
		}

		availableSpace = splitViewWidth - minimumFirstSubviewWidth - numDividers*dividerThickness;
		if (widthTotal > availableSpace) {
			if (availableSpace < 0) {
				scaleFactor = 0;
			} else {
				scaleFactor = availableSpace / widthTotal;
			}
		} else {
			scaleFactor = 1;
		}
		
		curXAxisPos = splitViewWidth;
		for (i = numSubviews - 1; i > 0; i--) {
			subview = [subviews objectAtIndex:i];
			if (![sender isSubviewCollapsed:subview]) {
				newSubviewWidth = floor([subview frame].size.width*scaleFactor);
				curXAxisPos -= newSubviewWidth;
				[subview setFrame:NSMakeRect(curXAxisPos, 0, newSubviewWidth, splitViewHeight)];
			}
			
			curXAxisPos -= dividerThickness;
		}
		
		subview = [subviews objectAtIndex:0];
		[subview setFrame:NSMakeRect(0, 0, curXAxisPos, splitViewHeight)];
		
	} else {
		// tabulate the total space taken up by uncollapsed subviews other than the first
		heightTotal = 0;
		for (i = 1; i < numSubviews; i++)
		{
			subview = [subviews objectAtIndex:i];
			if (![sender isSubviewCollapsed:subview]) {
				heightTotal += [subview frame].size.height;
			}
		}

		// if the uncollapsed subviews (not counting the first) take up too much space then
		// we have to scale them
		availableSpace = splitViewHeight - minimumFirstSubviewHeight - numDividers*dividerThickness;
		if (heightTotal > availableSpace) {
			if (availableSpace < 0) {
				scaleFactor = 0;
			} else {
				scaleFactor = availableSpace / heightTotal;
			}
		} else {
			scaleFactor = 1;
		}

		// we walk up the Y-axis, setting subview frames as we go
		curYAxisPos = splitViewHeight;
		for (i = numSubviews - 1; i >0; i--) {
			subview = [subviews objectAtIndex:i];
			if (![sender isSubviewCollapsed:subview]) {
				// expanded subviews need to have their origin set correctly and
				// their size scaled.

				newSubviewHeight = floor([subview frame].size.height*scaleFactor);
				curYAxisPos -= newSubviewHeight;
				[subview setFrame:NSMakeRect(0, curYAxisPos, splitViewWidth, newSubviewHeight)];
			}

			// account for the divider taking up space
			curYAxisPos -= dividerThickness;
		}

		// the first subview subview's height is whatever's left over
		subview = [subviews objectAtIndex:0];
		[subview setFrame:NSMakeRect(0, 0, splitViewWidth, curYAxisPos)];
	}

    // if we wanted error checking, we could call adjustSubviews.  It would
    // only change something if we messed up and didn't really tile the split view correctly.

    // [sender adjustSubviews];
}
@end

#pragma mark -

@implementation CMRBrowser(NotificationPrivate)
- (void) registerToNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(favoritesManagerDidLinkFavorites:)
	            name : CMRFavoritesManagerDidLinkFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(favoritesManagerDidRemoveFavorites:)
	            name : CMRFavoritesManagerDidRemoveFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(boardManagerUserListDidChange:)
	            name : CMRBBSManagerUserListDidChangeNotification
	          object : [BoardManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(threadsListDownloaderShouldRetryUpdate:)
	            name : ThreadsListDownloaderShouldRetryUpdateNotification
	          object : nil];
	
	[super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRFavoritesManagerDidLinkFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRFavoritesManagerDidRemoveFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRBBSManagerUserListDidChangeNotification
	          object : [BoardManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : ThreadsListDownloaderShouldRetryUpdateNotification
	          object : nil];

	[super removeFromNotificationCenter];
}

- (void) boardManagerUserListDidChange : (NSNotification *) notification;
{
	UTILAssertNotificationName(
		notification,
		CMRBBSManagerUserListDidChangeNotification);
	UTILAssertNotificationObject(
		notification,
		[BoardManager defaultManager]);
	
	[[self boardListTable] reloadData];
}
- (void) appDefaultsLayoutSettingsUpdated : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		AppDefaultsLayoutSettingsUpdatedNotification);
	UTILAssertNotificationObject(
		notification,
		CMRPref);
		
	if (nil == [self threadsListTable]) 
		return;
	
	[CMRThreadsList resetDataSourceTemplates];
	[self updateDefaultsWithTableView : [self threadsListTable]];
	[[self threadsListTable] setNeedsDisplay : YES];
	
	if ([[self superclass] instancesRespondToSelector : _cmd])
		[super appDefaultsLayoutSettingsUpdated : notification];
}

- (void) cleanUpItemsToBeRemoved : (NSArray *) files
{
	if ([files containsObject : [self path]]) {
		// 
		// 再選択
		// 
		[[self currentThreadsList] filterByDisplayingThreadAtPath : [self path]];
		[self synchronizeWithSearchField];
		[self selectCurrentThreadWithMask : 
			[CMRPref threadsListAutoscrollMask]];
	}
	
	if ([[self superclass] instancesRespondToSelector : _cmd])
		[super cleanUpItemsToBeRemoved : files];
}

- (void) threadsListDidChange : (NSNotification *) notification
{
	CMRThreadsList	*currentList;

	currentList = [self currentThreadsList];	

	UTILAssertNotificationName(
		notification,
		CMRThreadsListDidChangeNotification);
	UTILAssertNotificationObject(
		notification,
		currentList);
	
#if PATCH
//	NSLog(@"threadsListDidChange updateDateFormatter");
	[[[self threadsListTable] dataSource] updateDateFormatter];
#endif

	[[self threadsListTable] reloadData];
	[self updateStatusLineBoardInfo];
}

- (void) threadsListDownloaderShouldRetryUpdate : (NSNotification *) notification
{
    [self reloadThreadsList : nil];
}
- (void) threadsListDidFinishUpdate : (NSNotification *) notification
{
	NSNumber	*maskNum_;
	int			mask_;
	
	UTILAssertNotificationName(
		notification,
		CMRThreadsListDidUpdateNotification);
	UTILAssertNotificationObject(
		notification,
		[self currentThreadsList]);
	
	maskNum_ = [[notification userInfo] 
					objectForKey : ThreadsListUserInfoSelectionHoldingMaskKey];
	if (maskNum_ != nil)
		UTILAssertRespondsTo(maskNum_, @selector(unsignedIntValue));
	
	mask_ = (nil == maskNum_) 
				? CMRAutoscrollWhenTLUpdate
				: [maskNum_ unsignedIntValue];
	
	[[self currentThreadsList] filterByDisplayingThreadAtPath : [self path]];
	[self synchronizeWithSearchField];
#if PATCH
//	NSLog(@"threadsListDidFinishUpdate updateDateFormatter");
	[[[self threadsListTable] dataSource] updateDateFormatter];
#endif
	[[self threadsListTable] reloadData];
	[self selectCurrentThreadWithMask : mask_];
}
/*
- (void) favoritesManagerDidLinkFavorites : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		CMRFavoritesManagerDidLinkFavoritesNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRFavoritesManager defaultManager]);
	
	//if ([[self currentThreadsList] isFavorites]) {
	//	;
    //}
}
- (void) favoritesManagerDidRemoveFavorites : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		CMRFavoritesManagerDidRemoveFavoritesNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRFavoritesManager defaultManager]);
	
	//if ([[self currentThreadsList] isFavorites]) {
	//	;
    //}
}
*/
@end



@implementation CMRBrowser(NSOutlineViewDelegate)
- (void) outlineViewSelectionDidChange : (NSNotification *) notification
{
	int					rowIndex_;
	NSOutlineView		*brdListTable_;
	NSDictionary		*item_;
	
	brdListTable_ = [self boardListTable];

	UTILAssertNotificationName(
		notification,
		NSOutlineViewSelectionDidChangeNotification);
	UTILAssertNotificationObject(
		notification,
		[self boardListTable]);
	
	rowIndex_ = [brdListTable_ selectedRow];
	
	if ([brdListTable_ numberOfSelectedRows] > 1) return;
	if (rowIndex_ < 0) return;
	if (rowIndex_ >= [brdListTable_ numberOfRows]) return;
	
	item_ = [brdListTable_ itemAtRow : rowIndex_];

	if (nil == item_) return;
	UTILAssertKindOfClass(item_, NSDictionary);
	if ([BoardList isCategory : item_]) return;
	
	[self showThreadsListForBoard : item_];
}
@end


@implementation CMRBrowser(NSTableViewDelegate)
static BOOL isOptionKeyDown(unsigned flag_)
{
	if (flag_ & NSAlternateKeyMask) {
		return YES;
	} else {
		return NO;
	}
}

- (void)    tableView : (NSTableView   *) tableView
  didClickTableColumn : (NSTableColumn *) tableColumn
{
	NSString		*theId_;
	CMRBBSSignature	*currentBoard_;
	CMRThreadsList	*currentList_;
	
	theId_ = [tableColumn identifier];
	currentBoard_ = [[self currentThreadsList] BBSSignature];
	currentList_ = [self currentThreadsList];
	
	// Sort:
	// 既にハイライトされているヘッダをクリックした場合は
	// 昇順／降順の切り替えと見なす。
	if (tableColumn == [tableView highlightedTableColumn]) {
		[currentList_ toggleIsAscending];
		[[CMRNoNameManager defaultManager] setSortColumnIsAscending : [currentList_ isAscending]
															atBoard : currentBoard_];
	}
		
	// 実際のソート
	[currentList_ sortByKey : theId_];
	
	// カラムヘッダの描画を更新
	[self changeHighLightedTableColumnTo : theId_ isAscending : [currentList_ isAscending]];

	[[CMRNoNameManager defaultManager] setSortColumn : theId_
											forBoard : currentBoard_];

	// option キーを押しながらヘッダをクリックした場合は、変更後の設定を CMRPref に保存する（グローバルな設定の変更）。
	if (isOptionKeyDown([[NSApp currentEvent] modifierFlags])) {
		[CMRPref setBrowserSortColumnIdentifier : theId_];
		[CMRPref setBrowserSortAscending : [currentList_ isAscending]];
	}

	[self selectCurrentThreadWithMask : CMRAutoscrollWhenTLSort];
	[[self threadsListTable] reloadData];
}
@end