/**
  * $Id: CMRBrowser-List.m,v 1.20 2007/01/07 17:04:23 masakih Exp $
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
- (BSDBThreadList *) currentThreadsList
{
	return [[self document] currentThreadsList];
}
- (void) setCurrentThreadsList : (BSDBThreadList *) newList
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
	[self exchangeNotificationObserver : BSDBThreadListDidFinishUpdateNotification
							  selector : @selector(reselectThreadIfNeeded:)
						   oldDelegate : [self currentThreadsList]
						   newDelegate : newList];
	
	[[self threadsListTable] setDataSource : newList];
	[[self document] setCurrentThreadsList : newList];

	[self clearSearchFilter];
}

- (void) boardChanged : (NSString *) boardName
{
	// �ǂݍ��݂̊����A�ݒ�ɕۑ�
	// �����ɓo�^���Ă���A�ύX�̒ʒm
	[CMRPref setBrowserLastBoard : boardName];
	[[CMRHistoryManager defaultManager]
		addItemWithTitle : boardName
					type : CMRHistoryBoardEntryType
				  object : [CMRBBSSignature BBSSignatureWithName : boardName]];

	UTILNotifyName(CMRBrowserDidChangeBoardNotification);
}
- (void) showThreadList:(id)threadList
{
	NSString *boardName;
	NSString			*sortColumnIdentifier_;
	BOOL				isAscending_;
	
	boardName = [threadList boardName];
	if(nil == boardName) return;
	if([[[self currentThreadsList] boardName] isEqualToString : boardName]){
		// 2006-08-19 �u�f����\���v�����̊֌W�ケ�̒ʒm�������Ŕ��s���Ă���
		UTILNotifyName(CMRBrowserThListUpdateDelegateTaskDidFinishNotification);
		return;
	}
	
	[[self threadsListTable] deselectAll : nil];
	[[self threadsListTable] setDataSource : nil];
	
	if(nil == threadList)
		return;
	
	[self setCurrentThreadsList : threadList];
	
	// sort column change
	BoardManager	*bm_ = [BoardManager defaultManager];
	sortColumnIdentifier_ = [bm_ sortColumnForBoard : boardName];
	isAscending_ = [bm_ sortColumnIsAscendingAtBoard : boardName];
	
	[threadList setIsAscending : isAscending_];
	[self changeHighLightedTableColumnTo : sortColumnIdentifier_ isAscending : isAscending_];
	
	[self synchronizeWindowTitleWithDocumentName];
	[[self window] makeFirstResponder : [self threadsListTable]];
	
	// ���X�g�̓ǂݍ��݂��J�n����B
	[threadList startLoadingThreadsList : [self threadLayout]];
	[self boardChanged : boardName];
}
- (void) showThreadsListWithBoardName : (NSString *) boardName
{
	[self showThreadList:[BSDBThreadList threadsListWithBBSName : boardName]];
}

- (void) showThreadsListForBoard : (id) board;
{
	[self showThreadList:[BSDBThreadList threadListWithBoardListItem : board]];
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
