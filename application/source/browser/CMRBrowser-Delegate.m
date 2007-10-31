//
//  CMRBrowser-Delegate.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/09/18.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRBrowser_p.h"
#import "BoardManager.h"
#import "missing.h"
#import "BSNobiNobiToolbarItem.h"

extern NSString *const ThreadsListDownloaderShouldRetryUpdateNotification;

@implementation CMRBrowser(Delegate)
BOOL isOptionKeyDown(void)
{
	unsigned flag_ = [[NSApp currentEvent] modifierFlags];
	if (flag_ & NSAlternateKeyMask) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark NSControl Delegate (SearchField)
// Available in RainbowJerk and later.
// 検索フィールドで return などを押したとき、フォーカスをスレッド一覧に移動させる
- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	if ([aNotification object] == [self searchField]) {
		[[self window] makeFirstResponder:[self threadsListTable]];
	}
}

- (void)windowDidResignMain:(NSNotification *)notification
{
	[[self boardListTable] setBackgroundColor:[CMRPref boardListNonActiveBgColor]];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[[self boardListTable] setBackgroundColor:[CMRPref boardListBackgroundColor]];
}

#pragma mark KFSplitView Delegate
- (BOOL)splitView:(id)sender canCollapseSubview:(NSView *)subview
{
	return (subview == bottomSubview);
}

- (void)splitView:(id)sender didDoubleClickInDivider:(int)index
{
	BOOL currentState = [sender isSubviewCollapsed:bottomSubview];
	[sender setSubview:bottomSubview isCollapsed:!currentState];
	[sender resizeSubviewsWithOldSize:[sender frame].size];
}

- (void)splitViewDidCollapseSubview:(NSNotification *)notification
{
	[[self threadsListTable] setNextKeyView:[self searchField]];

	[[[self indexingStepper] contentView] setHidden:YES];
	[[[self indexingPopupper] contentView] setHidden:YES];
}

- (void)splitViewDidExpandSubview:(NSNotification *)notification
{
	[[self threadsListTable] setNextKeyView:[self textView]];
	[[self textView] setNextKeyView:[[self indexingStepper] textField]];
	[[[self indexingStepper] textField] setNextKeyView:[self searchField]];

	[[[self indexingStepper] contentView] setHidden:NO];
	[[[self indexingPopupper] contentView] setHidden:NO];
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

    //[sender adjustSubviews];
}

#pragma mark NSOutlineView Delegate
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	int					rowIndex_;
	NSOutlineView		*brdListTable_;
	NSDictionary		*item_;
	
	brdListTable_ = [notification object];

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

	item_ = [brdListTable_ itemAtRow:rowIndex_];

	if (!item_) return;
	if (![item_ hasURL] && ![BoardListItem isFavoriteItem:item_] && ![BoardListItem isSmartItem:item_]) return;

	[self showThreadsListForBoard:item_];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	// 自身のデータソースにデリゲートメソッドを処理させる（ようにしていたが、もうその必要はなさそうだ）。
//	[[olv dataSource] outlineView : olv willDisplayCell : cell forTableColumn : tableColumn item : item];
	if ([[tableColumn identifier] isEqualToString:BoardPlistNameKey]) {
		[cell setImage:[item icon]];
	}
}

#pragma mark Type-To-Select Support
- (NSIndexSet *)outlineView:(BSBoardListView *)boardListView findForString:(NSString *)aString
{
    SmartBoardList       *source;
	BoardListItem	*matchedItem;
    int				index;

    source = (SmartBoardList *)[boardListView dataSource];
    
    matchedItem = [source itemWithNameHavingPrefix:aString];

    if (!matchedItem) {
		return nil;
	}
		
    index = [self searchRowForItemInDeep:matchedItem fromSource:[source boardItems] forView:boardListView];
	if (-1 == index) return nil;
	return [NSIndexSet indexSetWithIndex:index];
}

#pragma mark NSTableView Delegate
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	NSString		*theId_;
	NSString		*currentBoard_;
	BSDBThreadList	*currentList_;

	BoardManager	*bm_ = [BoardManager defaultManager];
	
	theId_ = [tableColumn identifier];
	currentList_ = [self currentThreadsList];
	currentBoard_ = [currentList_ boardName];
	
	// Sort:
	// Mac OS標準的ソート変更 (Finderのリスト表示参照)
	// ソートの向きは各カラムごとに保存されており、
	// ハイライトされているカラムヘッダがクリックされた時以外は、
	// 保存されている向きでソートされる。
	// 既にハイライトされているヘッダをクリックした場合は
	// 昇順／降順の切り替えと見なす。
	if (tableColumn == [tableView highlightedTableColumn]) {
		[currentList_ toggleIsAscendingForKey:theId_];
		[bm_ setSortColumnIsAscending:[currentList_ isAscending] atBoard:currentBoard_];
	}
		
	// 実際のソート
	// 保存されている向きに戻す。
	[currentList_ setIsAscending:[currentList_ isAscendingForKey:theId_]];
	[currentList_ sortByKey:theId_];
	
	// カラムヘッダの描画を更新
	[self changeHighLightedTableColumnTo:theId_ isAscending:[currentList_ isAscending]];

	[bm_ setSortColumn:theId_ forBoard:currentBoard_];
	[bm_ setSortDescriptors:[currentList_ sortDescriptors] forBoard:currentBoard_];

	// option キーを押しながらヘッダをクリックした場合は、変更後の設定を CMRPref に保存する（グローバルな設定の変更）。
	if (isOptionKeyDown()) {
		[CMRPref setBrowserSortColumnIdentifier:theId_];
		[CMRPref setBrowserSortAscending:[currentList_ isAscending]];
	}

	[self selectCurrentThreadWithMask:CMRAutoscrollWhenTLSort];
	[tableView reloadData];
}

- (void)saveBrowserListColumnState:(NSTableView *)targetTableView
{
//	NSString *boardName = [[self currentThreadsList] boardName];
//	if (!boardName) return;

//	if (isOptionKeyDown()) {
		[CMRPref setThreadsListTableColumnState:[targetTableView columnState]];
//		[[BoardManager defaultManager] setBrowserListColumns:nil forBoard:boardName]; // Remove Custom Settings.
//	} else {
//		[[BoardManager defaultManager] setBrowserListColumns:[targetTableView columnState] forBoard:boardName];
//	}
}

- (void)tableViewColumnDidMove:(NSNotification *)aNotification
{
//	NSLog(@"Received %@", [aNotification name]);
	[self saveBrowserListColumnState:[aNotification object]];
}

- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
//	NSLog(@"Received %@", [aNotification name]);
	[self saveBrowserListColumnState:[aNotification object]];
}

// そのセルの内容が「...」で省略表示されているのかどうか判別するよい方法が無いなぁ
- (NSString *)tableView:(NSTableView *)aTableView
		 toolTipForCell:(NSCell *)aCell
				   rect:(NSRectPointer)rect
			tableColumn:(NSTableColumn *)aTableColumn
					row:(int)row
		  mouseLocation:(NSPoint)mouseLocation
{
	static float dX = -1.0;
	// Leopard 対策：Leopard の NSTableView は何もしなくても省略表示されたセルの内容をポップアップ表示する。
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_4) return nil;
	if (dX == -1.0) {
		dX = ([aTableView intercellSpacing].width)*2;
	}

	if ([[aTableColumn identifier] isEqualToString:CMRThreadTitleKey]) {
		NSAttributedString *attrStr_ = [aCell objectValue];
		float cellWidth = [aTableColumn width] - dX;
		if ([attrStr_ size].width > cellWidth) {
			return [attrStr_ string];
		}
	}

	return nil;
}


#pragma mark RBSplitView Delegate
- (void)splitView:(RBSplitView *)sender wasResizedFrom:(float)oldDimension to:(float)newDimension
{
	[sender adjustSubviewsExcepting:[self boardListSubView]];
}

- (void)splitView:(RBSplitView*)sender changedFrameOfSubview:(RBSplitSubview*)subview from:(NSRect)fromRect to:(NSRect)toRect
{
	if (subview == [self boardListSubView]) {
		NSToolbar *toolbar = [[self window] toolbar];
		if (!toolbar) return;
		NSArray *items = [toolbar visibleItems];
		NSEnumerator *iter = [items objectEnumerator];
		NSToolbarItem *eachItem;
		while (eachItem = [iter nextObject]) {
			if ([[eachItem itemIdentifier] isEqualToString: @"Boards List Space"]) {
				[NSObject cancelPreviousPerformRequestsWithTarget:eachItem selector:@selector(adjustTo:) object:nil];
				[eachItem performSelector:@selector(adjustTo:) withObject:[NSNumber numberWithFloat:toRect.size.width] afterDelay:0.2];
				return;
			}
		}
	}
}

// This makes it possible to drag the first divider around by the dragView.
- (unsigned int)splitView:(RBSplitView *)sender dividerForPoint:(NSPoint)point inSubview:(RBSplitSubview *)subview
{
	if (subview == [self boardListSubView]) {
		id draggingSplitter_ = [self splitterBtn];
		if ([draggingSplitter_ mouse:[draggingSplitter_ convertPoint:point fromView:sender] inRect:[draggingSplitter_ bounds]]) {
			return 0;	// [firstSplit position], which we assume to be zero
		}
	}
	return NSNotFound;
}

// This changes the cursor when it's over the dragView.
- (NSRect)splitView:(RBSplitView *)sender cursorRect:(NSRect)rect forDivider:(unsigned int)divider
{
	if (divider == 0) {
		id draggingSplitter_ = [self splitterBtn];
		[sender addCursorRect:[draggingSplitter_ convertRect:[draggingSplitter_ bounds] toView:sender]
					   cursor:[RBSplitView cursor:RBSVVerticalCursor]];
	}
	return rect;
}
@end


@implementation CMRBrowser(NotificationPrivate)
- (void)registerToNotificationCenter
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(boardManagerUserListDidChange:)
			   name:CMRBBSManagerUserListDidChangeNotification
			 object:[BoardManager defaultManager]];
	[nc addObserver:self
		   selector:@selector(threadsListDownloaderShouldRetryUpdate:)
			   name:ThreadsListDownloaderShouldRetryUpdateNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(threadDocumentDidToggleDatOchiStatus:)
			   name:CMRAbstractThreadDocumentDidToggleDatOchiNotification
			 object:nil];

	[[[NSWorkspace sharedWorkspace] notificationCenter]
	     addObserver:self
	        selector:@selector(sleepDidEnd:)
	            name:NSWorkspaceDidWakeNotification
	          object:nil];

	[super registerToNotificationCenter];
}

- (void)removeFromNotificationCenter
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:CMRAbstractThreadDocumentDidToggleDatOchiNotification object:nil];
	[nc removeObserver:self name:ThreadsListDownloaderShouldRetryUpdateNotification object:nil];
	[nc removeObserver:self name:CMRBBSManagerUserListDidChangeNotification object:[BoardManager defaultManager]];

	[[[NSWorkspace sharedWorkspace] notificationCenter]
	  removeObserver:self
	            name:NSWorkspaceDidWakeNotification
	          object:nil];

	[super removeFromNotificationCenter];
}

- (void)boardManagerUserListDidChange:(NSNotification *)notification;
{
	UTILAssertNotificationName(
		notification,
		CMRBBSManagerUserListDidChangeNotification);
	UTILAssertNotificationObject(
		notification,
		[BoardManager defaultManager]);
	
	[[self boardListTable] reloadData];
}

- (void)appDefaultsLayoutSettingsUpdated:(NSNotification *)notification
{
	UTILAssertNotificationName(notification, AppDefaultsLayoutSettingsUpdatedNotification);
	UTILAssertNotificationObject(notification, CMRPref);
	
	[BSDBThreadList resetDataSourceTemplates];
	[BSDBThreadList resetDataSourceTemplateForDateColumn];

	[self updateThreadsListTableWithNeedingDisplay:YES];
	[self updateBoardListViewWithNeedingDisplay:YES];
	
	if ([[self superclass] instancesRespondToSelector:_cmd]) {
		[super appDefaultsLayoutSettingsUpdated:notification];
	}
}

- (void)cleanUpItemsToBeRemoved:(NSArray *)files
{
//	if ([files containsObject:[self path]]) {
		[self synchronizeWithSearchField];
		[self selectCurrentThreadWithMask:[CMRPref threadsListAutoscrollMask]];
//	}

	if ([[self superclass] instancesRespondToSelector:_cmd]) {
		[super cleanUpItemsToBeRemoved:files];
	}
}

- (void)threadsListDidChange:(NSNotification *)notification
{
	UTILAssertNotificationName(notification, CMRThreadsListDidChangeNotification);

	[[self threadsListTable] reloadData];
	[self synchronizeWindowTitleWithDocumentName];
	UTILNotifyName(CMRBrowserThListUpdateDelegateTaskDidFinishNotification);
}

- (void)threadsListDownloaderShouldRetryUpdate:(NSNotification *)notification
{
	[self reloadThreadsList:nil];
}

- (void)threadDocumentDidToggleDatOchiStatus:(NSNotification *)aNotification
{
	NSString *path = [aNotification userInfo];
	unsigned int index = [[self currentThreadsList] indexOfThreadWithPath:path];
	if (index != NSNotFound) [self synchronizeWithSearchField];
}

// Added in InnocentStarter.
- (void)sleepDidEnd:(NSNotification *)aNotification
{
	if ([CMRPref isOnlineMode] && [CMRPref autoReloadListWhenWake] && ![[self currentThreadsList] isFavorites]) {
		id value = SGTemplateResource(kThreadsListReloadDelayKey);
		UTILAssertKindOfClass(value, NSNumber);
		NSTimeInterval delay = [value doubleValue];
		[self performSelector:@selector(reloadThreadsList:) withObject:nil afterDelay:delay];
	}
}

- (void)reselectThreadIfNeeded:(NSNotification *)aNotification
{
	if([self shouldShowContents]) {
		[self selectCurrentThreadWithMask:CMRAutoscrollWhenTLUpdate];
	}
}
@end
