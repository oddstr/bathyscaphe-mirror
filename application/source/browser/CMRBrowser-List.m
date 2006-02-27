/**
  * $Id: CMRBrowser-List.m,v 1.7.2.5 2006/02/27 16:01:43 masakih Exp $
  * 
  * CMRBrowser-List.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"
#import "missing.h"
#import "CMRHistoryManager.h"
#import "CMRStatusLine.h"
#import "BoardManager.h"
#import "CMRBBSSignature.h"

@implementation CMRBrowser(List)
- (void) changeThreadsFilteringMask : (int) aMask
{
	[[self document] changeThreadsFilteringMask : aMask];
	[[self threadsListTable] reloadData];
	
	[self clearSearchFilter];
	[self synchronizeWindowTitleWithDocumentName];
}
- (id) currentThreadsList
{
	return [[self document] currentThreadsList];
}
- (void) setCurrentThreadsList : (id) newList
{
	[self exchangeNotificationObserver :
						CMRThreadsListDidUpdateNotification
			selector : @selector(threadsListDidFinishUpdate:)
		 oldDelegate : [self currentThreadsList]
		 newDelegate : newList];
	[self exchangeNotificationObserver :
						CMRThreadsListDidChangeNotification
			selector : @selector(threadsListDidChange:)
		 oldDelegate : [self currentThreadsList]
		 newDelegate : newList];
	
	[[self threadsListTable] setDataSource : newList];
	[[self document] setCurrentThreadsList : newList];

	[self clearSearchFilter];
}

- (void) boardChanged : (NSString *) boardName
{
	// 読み込みの完了、設定に保存
	// 履歴に登録してから、変更の通知
	[CMRPref setBrowserLastBoard : boardName];
	[[CMRHistoryManager defaultManager]
		addItemWithTitle : boardName
					type : CMRHistoryBoardEntryType
				  object : [CMRBBSSignature BBSSignatureWithName : boardName]];

	UTILNotifyName(CMRBrowserDidChangeBoardNotification);
}

- (void) showThreadsListWithBoardName : (NSString *) boardName
{
	id		list_;
	NSString			*sortColumnIdentifier_;
	BOOL				isAscending_;
	
	if(nil == boardName) return;
	if([[[[self currentThreadsList] boardListItem] name] isEqual : boardName]){
		return;
	}
	
	[[self threadsListTable] deselectAll : nil];
	[[self threadsListTable] setDataSource : nil];
	
	list_ = [BSDBThreadList threadsListWithBBSName : boardName];
	if(nil == list_)
		return;
	
	[self setCurrentThreadsList : list_];
	
	// sort column change
	sortColumnIdentifier_ = [[BoardManager defaultManager] sortColumnForBoard : boardName];
	isAscending_ = [[BoardManager defaultManager] sortColumnIsAscendingAtBoard : boardName];
	
	[list_ setIsAscending : isAscending_];
	[self changeHighLightedTableColumnTo : sortColumnIdentifier_ isAscending : isAscending_];
	
	[self synchronizeWindowTitleWithDocumentName];
	[[self window] makeFirstResponder : [self threadsListTable]];
	
	// リストの読み込みを開始する。
	[list_ startLoadingThreadsList : [self threadLayout]];
	[self boardChanged : boardName];
}

- (void) showThreadsListForBoard : (id) board;
{	
	id		list_;
	NSString *boardName;
	NSString			*sortColumnIdentifier_;
	BOOL				isAscending_;
	
	boardName = [board name];
	if(nil == boardName) return;
	if([[[[self currentThreadsList] boardListItem] name] isEqual : boardName]){
		return;
	}
	
	[[self threadsListTable] deselectAll : nil];
	[[self threadsListTable] setDataSource : nil];
	
	list_ = [BSDBThreadList threadListWithBoardListItem : board];
	if(nil == list_)
		return;
	
	[self setCurrentThreadsList : list_];
	
	// sort column change
	sortColumnIdentifier_ = [[BoardManager defaultManager] sortColumnForBoard : boardName];
	isAscending_ = [[BoardManager defaultManager] sortColumnIsAscendingAtBoard : boardName];
	
	[list_ setIsAscending : isAscending_];
	[self changeHighLightedTableColumnTo : sortColumnIdentifier_ isAscending : isAscending_];
	
	[self synchronizeWindowTitleWithDocumentName];
	[[self window] makeFirstResponder : [self threadsListTable]];
	
	// リストの読み込みを開始する。
	[list_ startLoadingThreadsList : [self threadLayout]];
	[self boardChanged : boardName];
}

@end



@implementation CMRBrowser(Table)
static NSImage *fnc_indicatorImageWithDirection(BOOL isAscending)
{
	return isAscending ? [NSImage imageNamed : @"NSAscendingSortIndicator"]
					   : [NSImage imageNamed : @"NSDescendingSortIndicator"]; 
}

- (void) changeHighLightedTableColumnTo : (NSString *) columnIdentifier_ isAscending : (BOOL) TorF
{
	NSTableView		*tableView_;
	NSTableColumn	*newColumn_;
	NSTableColumn	*oldColumn_;
	NSImage			*image_;
		
	tableView_ = [self threadsListTable];
	oldColumn_ = [tableView_ highlightedTableColumn];
	newColumn_ = [tableView_ tableColumnWithIdentifier : columnIdentifier_];
	image_ = fnc_indicatorImageWithDirection(TorF);

	if(oldColumn_ != nil && newColumn_ != oldColumn_ ) {
		[tableView_ setIndicatorImage : nil
						inTableColumn : oldColumn_];
	}

	[tableView_ setIndicatorImage : image_ inTableColumn : newColumn_]; 
	[tableView_ setHighlightedTableColumn : newColumn_];
}

/**
  * 現在、表示しているスレッドを再選択。
  * 引数maskに設定した値が初期設定で設定されていなければ選択しても、
  * 自動スクロールしない。
  *
  * @param    mask  そのときの状況
  */
- (unsigned) selectCurrentThreadWithMask : (int) mask
{
	int			pref_  = [CMRPref threadsListAutoscrollMask];
	unsigned	index_ = [self selectRowWithCurrentThread];
	
	if((pref_ & mask) > 0 && index_ != NSNotFound)
		[[self threadsListTable] scrollRowToVisible : index_];
	
	return index_;
}

- (unsigned) selectRowWithCurrentThread
{
	return [self selectRowWithThreadPath : [self path]
			 		byExtendingSelection : NO];
}
- (unsigned) selectRowWithThreadPath : (NSString *) filepath
                byExtendingSelection : (BOOL      ) flag
{
	CMRThreadsList	*tlist_ = [self currentThreadsList];
	NSTableView		*tview_ = [self threadsListTable];
	NSIndexSet		*indexes_;
	unsigned int	index_;
	int				selected_;
	
	if(nil == filepath || nil == tlist_) 
		return NSNotFound;
	
	selected_ = [tview_ selectedRow];
	index_ = [tlist_ indexOfThreadWithPath : filepath];
	
	// すでに選択済み
	if(NSNotFound == index_ || (selected_ != -1 && index_ == (unsigned)selected_))
		return index_;

	// Mac OS X 10.3 以降では NSIndexSet を使う
	indexes_ = [NSIndexSet indexSetWithIndex : index_];
	[tview_ selectRowIndexes:indexes_ byExtendingSelection:NO];

	return index_;
}
@end
