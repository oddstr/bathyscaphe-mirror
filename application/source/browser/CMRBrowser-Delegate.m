/**
  * $Id: CMRBrowser-Delegate.m,v 1.20.2.8 2006/12/04 21:54:46 tsawada2 Exp $
  * 
  * CMRBrowser-Delegate.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"
#import "BoardManager.h"
#import "missing.h"

extern NSString *const ThreadsListDownloaderShouldRetryUpdateNotification;

@implementation CMRBrowser(Delegate)
BOOL isCommandKeyDown(unsigned flag_)
{
	if (flag_ & NSCommandKeyMask) {
		return YES;
	} else {
		return NO;
	}
}

BOOL isOptionKeyDown(unsigned flag_)
{
	if (flag_ & NSAlternateKeyMask) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark NSControl Delegate (SearchField)
// added in RainbowJerk
// 検索フィールドで return などを押したとき、フォーカスをスレッド一覧に移動させる
- (void) controlTextDidEndEditing : (NSNotification *) aNotification
{
	if ([aNotification object] == [self searchField]) {
		[[self window] makeFirstResponder : [self threadsListTable]];
	}
}

#pragma mark KFSplitView Delegate

- (BOOL) splitView : (id) sender canCollapseSubview : (NSView *) subview
{
	return (subview == bottomSubview);
}

- (void) splitView : (id) sender didDoubleClickInDivider : (int) index
{
	BOOL currentState = [sender isSubviewCollapsed : bottomSubview];
	[sender setSubview : bottomSubview isCollapsed : !currentState];
	[sender resizeSubviewsWithOldSize : [sender frame].size];
}

- (void) splitViewDidCollapseSubview: (NSNotification *) notification
{
	[[self threadsListTable] setNextKeyView : [self searchField]];

	[[[self indexingStepper] contentView] setHidden: YES];
	[[[self indexingPopupper] contentView] setHidden: YES];
}

- (void) splitViewDidExpandSubview: (NSNotification *) notification
{
	[[self threadsListTable] setNextKeyView : [self textView]];
	[[self textView] setNextKeyView : [[self indexingStepper] textField]];
	[[[self indexingStepper] textField] setNextKeyView : [self searchField]];

	[[[self indexingStepper] contentView] setHidden: NO];
	[[[self indexingPopupper] contentView] setHidden: NO];
}

- (void) splitView: (id) sender resizeSubviewsWithOldSize: (NSSize) oldSize
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

    //[sender adjustSubviews];
}

#pragma mark NSOutlineView Delegate

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
	//if (isCommandKeyDown([[NSApp currentEvent] modifierFlags])) return;

	item_ = [brdListTable_ itemAtRow : rowIndex_];

	if (nil == item_) return;
	UTILAssertKindOfClass(item_, NSDictionary);
	if ([BoardList isCategory : item_]) return;

	[self showThreadsListForBoard : item_];
}

- (void)outlineView : (NSOutlineView *) olv
	willDisplayCell : (NSCell *) cell
	 forTableColumn : (NSTableColumn *) tableColumn
			   item : (id) item
{
	// 自身のデータソースにデリゲートメソッドを処理させる。
	[[olv dataSource] outlineView : olv willDisplayCell : cell forTableColumn : tableColumn item : item];
}

#pragma mark NSTableView Delegate

- (void)    tableView : (NSTableView   *) tableView
  didClickTableColumn : (NSTableColumn *) tableColumn
{
	NSString		*theId_;
	NSString		*currentBoard_;
	CMRThreadsList	*currentList_;
	
	theId_ = [tableColumn identifier];
	currentBoard_ = [[self currentThreadsList] boardName];
	currentList_ = [self currentThreadsList];
	
	// Sort:
	// 既にハイライトされているヘッダをクリックした場合は
	// 昇順／降順の切り替えと見なす。
	if (tableColumn == [tableView highlightedTableColumn]) {
		[currentList_ toggleIsAscending];
		[[BoardManager defaultManager] setSortColumnIsAscending : [currentList_ isAscending]
														atBoard : currentBoard_];
	}
		
	// 実際のソート
	[currentList_ sortByKey : theId_];
	
	// カラムヘッダの描画を更新
	[self changeHighLightedTableColumnTo : theId_ isAscending : [currentList_ isAscending]];

	[[BoardManager defaultManager] setSortColumn : theId_
										forBoard : currentBoard_];

	// option キーを押しながらヘッダをクリックした場合は、変更後の設定を CMRPref に保存する（グローバルな設定の変更）。
	if (isOptionKeyDown([[NSApp currentEvent] modifierFlags])) {
		[CMRPref setBrowserSortColumnIdentifier : theId_];
		[CMRPref setBrowserSortAscending : [currentList_ isAscending]];
	}

	[self selectCurrentThreadWithMask : CMRAutoscrollWhenTLSort];
	[[self threadsListTable] reloadData];
}

- (void) tableViewColumnDidMove : (NSNotification *) aNotification
{
	[CMRPref setThreadsListTableColumnState : [[self threadsListTable] columnState]];
}

- (void) tableViewColumnDidResize : (NSNotification *) aNotification
{
    NSTableColumn   *whichColumn = [[aNotification userInfo] objectForKey: @"NSTableColumn"];
    NSString        *identifier_ = [whichColumn identifier];
	[CMRPref setThreadsListTableColumnState : [[self threadsListTable] columnState]];

    if ([identifier_ isEqualToString: CMRThreadModifiedDateKey] ||
        [identifier_ isEqualToString: ThreadPlistIdentifierKey])
    {
		NSTableView	*tv = [self threadsListTable];
        NSSize  inter = [tv intercellSpacing];
        float   hoge_ = [whichColumn width];
        hoge_ -= inter.width*2;
        [CMRThreadsList resetDataSourceTemplateForColumnIdentifier: identifier_ width: hoge_];
		[tv reloadData]; 
    }
}


// そのセルの内容が「...」で省略表示されているのかどうか判別するよい方法が無いなぁ
- (NSString *) tableView : (NSTableView *) aTableView
		  toolTipForCell : (NSCell *) aCell
					rect : (NSRectPointer) rect
			 tableColumn : (NSTableColumn *) aTableColumn
					 row : (int) row
		   mouseLocation : (NSPoint) mouseLocation
{
	if ([[aTableColumn identifier] isEqualToString : CMRThreadTitleKey]) {
		NSAttributedString *attrStr_ = [aCell objectValue];
		if ([attrStr_ size].width > [aTableColumn width]) { // この判定ではちょっと不正確
			return [attrStr_ string];
		}
	}

	return nil;
}


#pragma mark RBSplitView Delegate

- (void) splitView : (RBSplitView *) sender
	wasResizedFrom : (float) oldDimension
				to : (float) newDimension
{
	[sender adjustSubviewsExcepting : [self boardListSubView]];
}
// This makes it possible to drag the first divider around by the dragView.
- (unsigned int) splitView : (RBSplitView *) sender
		   dividerForPoint : (NSPoint) point
				 inSubview : (RBSplitSubview *) subview
{
	if (subview == [self boardListSubView]) {
		id draggingSplitter_ = [self splitterBtn];
		if ([draggingSplitter_ mouse : [draggingSplitter_ convertPoint : point fromView : sender]
							  inRect : [draggingSplitter_ bounds]])
		{
			return 0;	// [firstSplit position], which we assume to be zero
		}
	}
	return NSNotFound;
}
// This changes the cursor when it's over the dragView.
- (NSRect) splitView : (RBSplitView *) sender
		  cursorRect : (NSRect) rect
		  forDivider : (unsigned int) divider
{
	if (divider == 0) {
		id draggingSplitter_ = [self splitterBtn];
		[sender addCursorRect : [draggingSplitter_ convertRect : [draggingSplitter_ bounds] toView : sender]
					   cursor : [RBSplitView cursor : RBSVVerticalCursor]];
	}
	return rect;
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

	[[[NSWorkspace sharedWorkspace] notificationCenter]
	     addObserver : self
	        selector : @selector(sleepDidEnd:)
	            name : NSWorkspaceDidWakeNotification
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


	[[[NSWorkspace sharedWorkspace] notificationCenter]
	  removeObserver : self
	            name : NSWorkspaceDidWakeNotification
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
		[self selectCurrentThreadWithMask : [CMRPref threadsListAutoscrollMask]];
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
	
//	NSLog(@"threadsListDidChange updateDateFormatter");
//	[[[self threadsListTable] dataSource] updateDateFormatter];

	[[self threadsListTable] reloadData];

	[self synchronizeWindowTitleWithDocumentName];
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

//	NSLog(@"threadsListDidFinishUpdate updateDateFormatter");
//	[[[self threadsListTable] dataSource] updateDateFormatter];

	[[self threadsListTable] reloadData];
	[self selectCurrentThreadWithMask : mask_];
	
	UTILNotifyName(CMRBrowserThListUpdateDelegateTaskDidFinishNotification);
}

- (void) favoritesManagerDidLinkFavorites : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		CMRFavoritesManagerDidLinkFavoritesNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRFavoritesManager defaultManager]);
	
	/*if ([[self currentThreadsList] isFavorites]) {
		;
    }*/
}
- (void) favoritesManagerDidRemoveFavorites : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		CMRFavoritesManagerDidRemoveFavoritesNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRFavoritesManager defaultManager]);
//	NSLog(@"CMRBrowser received CMRFavoritesManagerDidRemoveFavoritesNotification");
	/*if ([[self currentThreadsList] isFavorites]) {
		;
    }*/
}

// Added in InnocentStarter.
- (void) sleepDidEnd : (NSNotification *) aNotification
{
	if ([CMRPref isOnlineMode] && [CMRPref autoReloadListWhenWake] && ![[self currentThreadsList] isFavorites]) {
		[self reloadThreadsList : nil];
	}
}
@end