/**
  * $Id: CMRBrowser-Delegate.m,v 1.1 2005/05/11 17:51:03 tsawada2 Exp $
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
		if ([[self splitView] isVertical]) {
			[[[self splitView] firstSubview] setFrame:_oldTListSize];
			[[[self boardDrawer] parentWindow] displayIfNeeded];
		}
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
/*- (void)splitViewDidResizeSubviews:(id)sender
{
    [[self splitView] resizeSubviewsWithOldSize:[[self splitView] frame].size];
}*/
@end


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