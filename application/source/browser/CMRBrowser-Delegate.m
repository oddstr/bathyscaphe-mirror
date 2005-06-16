/**
  * $Id: CMRBrowser-Delegate.m,v 1.5 2005/06/16 15:19:58 tsawada2 Exp $
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
- (BOOL)splitView:(id)sender canCollapseSubview:(NSView *)subview
{
    if (sender == [self splitView]) {
		return (subview == bottomSubview);
	} else {
		return (subview == boardListSubView);
	}
}
- (void)splitView:(id)sender didDoubleClickInDivider:(int)index
{
	if (sender == [self splitView]) {
		BOOL currentState = [sender isSubviewCollapsed:bottomSubview];
		[sender setSubview:bottomSubview isCollapsed:!currentState];
		[sender resizeSubviewsWithOldSize:[sender frame].size];
	} else {
		/*
			2005-06-16 tsawada2 <ben-sawa@td5.so-net.ne.jp>
			NSSplitView のバグか、KFSplitView のバグか、BathyScaphe のバグか
			判然としないが、とにかく掲示板リストとスレッド一覧を仕切るスプリット・ビューを
			ダブルクリックで畳もうとしてもうまく畳めない。このため、今のところダブルクリック無効。
		*/
		NSLog(@"Sorry. currently not supported.");
	}	
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

    [sender adjustSubviews];
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
	[self setupBoardListOutlineView : [self boardListTable]];
	[[self threadsListTable] setNeedsDisplay : YES];
	[[self boardListTable] setNeedsDisplay : YES];
	
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