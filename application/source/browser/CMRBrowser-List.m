/**
  * $Id: CMRBrowser-List.m,v 1.26 2007/09/04 07:45:43 tsawada2 Exp $
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

@implementation CMRBrowser(List)
- (void) changeThreadsFilteringMask : (int) aMask
{
	[[self document] changeThreadsFilteringMask : aMask];
	[[self threadsListTable] reloadData];
	[self synchronizeWindowTitleWithDocumentName];
}

- (BSDBThreadList *) currentThreadsList
{
	return [[self document] currentThreadsList];
}
- (void) setCurrentThreadsList : (BSDBThreadList *) newList
{
	BSDBThreadList *oldList = [self currentThreadsList];
	[self exchangeNotificationObserver : CMRThreadsListDidChangeNotification
			selector : @selector(threadsListDidChange:)
		 oldDelegate : oldList
		 newDelegate : newList];
	[self exchangeNotificationObserver : BSDBThreadListDidFinishUpdateNotification
							  selector : @selector(reselectThreadIfNeeded:)
						   oldDelegate : oldList
						   newDelegate : newList];
	
	[[self threadsListTable] setDataSource : newList];
	[[self document] setCurrentThreadsList : newList];

//	[self clearSearchFilter];
	[[self document] setSearchString: nil];
}

- (void) boardChanged : (id) boardListItem
{
	NSString *name = [boardListItem representName];
	// �ǂݍ��݂̊����A�ݒ�ɕۑ�
	// �����ɓo�^���Ă���A�ύX�̒ʒm
	[CMRPref setBrowserLastBoard : name];
	[[CMRHistoryManager defaultManager]
		addItemWithTitle : name
					type : CMRHistoryBoardEntryType
				  object : boardListItem];

	UTILNotifyName(CMRBrowserDidChangeBoardNotification);
}
- (void) showThreadList:(id)threadList forceReload: (BOOL) force
{
	NSString	*boardName;
	NSString	*sortColumnIdentifier_;
	BOOL		isAscending_;
	
	if (!threadList) return;
	if (!force && [[[self currentThreadsList] boardListItem] isEqual: [threadList boardListItem]]) {
		// 2006-08-19 �u�f����\���v�����̊֌W�ケ�̒ʒm�������Ŕ��s���Ă���
		UTILNotifyName(CMRBrowserThListUpdateDelegateTaskDidFinishNotification);
		return;
	}

	NSTableView *table = [self threadsListTable];
	[table deselectAll : nil];
	[table setDataSource : nil];
	
	[[self threadsListTable] restoreColumnState:[[BoardManager defaultManager] browserListColumnsForBoard:[threadList boardName]]];
	[self updateTableColumnsMenu];

	[self setCurrentThreadsList : threadList];

	// sort column change
	boardName = [threadList boardName];
	sortColumnIdentifier_ = [[BoardManager defaultManager] sortColumnForBoard: boardName];
	isAscending_ = [threadList isAscendingForKey: sortColumnIdentifier_];
	[self changeHighLightedTableColumnTo : sortColumnIdentifier_ isAscending : isAscending_];
	
	[self synchronizeWindowTitleWithDocumentName];
	[[self window] makeFirstResponder: table];
	
	// ���X�g�̓ǂݍ��݂��J�n����B
	[threadList startLoadingThreadsList : [self threadLayout]];
	[self boardChanged : [threadList boardListItem]];
}
- (void) showThreadsListWithBoardName : (NSString *) boardName
{
	[self showThreadList:[BSDBThreadList threadsListWithBBSName : boardName] forceReload: NO];
}

- (void) showThreadsListForBoard : (id) board;
{
	[self showThreadList:[BSDBThreadList threadListWithBoardListItem : board] forceReload: NO];
}
- (void) showThreadsListForBoard : (id) board forceReload: (BOOL) force;
{
	[self showThreadList:[BSDBThreadList threadListWithBoardListItem : board] forceReload: force];
}

- (unsigned) selectRowWithThreadPath : (NSString *) filepath
                byExtendingSelection : (BOOL ) flag
					 scrollToVisible : (BOOL ) scroll
{
	unsigned index_ = [self selectRowWithThreadPath : filepath byExtendingSelection : flag];
	if (scroll && (index_ != NSNotFound))
		[[self threadsListTable] scrollRowToVisible : index_];
	
	return index_;
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

	if(newColumn_ != nil) {
		[tableView_ setIndicatorImage : image_ inTableColumn : newColumn_]; 
		[tableView_ setHighlightedTableColumn : newColumn_];
	}
}

/**
  * ���݁A�\�����Ă���X���b�h���đI���B
  * ����mask�ɐݒ肵���l�������ݒ�Őݒ肳��Ă��Ȃ���ΑI�����Ă��A
  * �����X�N���[�����Ȃ��B
  *
  * @param    mask  ���̂Ƃ��̏�
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
	BSDBThreadList	*tlist_ = [self currentThreadsList];
	NSTableView		*tview_ = [self threadsListTable];
	NSIndexSet		*indexes_;
	unsigned int	index_;
	int				selected_;
	
	if(nil == filepath || nil == tlist_) 
		return NSNotFound;
	
	selected_ = [tview_ selectedRow];
	index_ = [tlist_ indexOfThreadWithPath : filepath];
	
	// ���łɑI���ς�
	if(NSNotFound == index_ || (selected_ != -1 && index_ == (unsigned)selected_))
		return index_;

	// Mac OS X 10.3 �ȍ~�ł� NSIndexSet ���g��
	indexes_ = [NSIndexSet indexSetWithIndex : index_];
	[tview_ selectRowIndexes:indexes_ byExtendingSelection:NO];

	return index_;
}
@end
