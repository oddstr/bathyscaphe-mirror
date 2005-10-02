/**
  * $Id: CMRBrowser-List.m,v 1.6 2005/10/02 12:24:49 tsawada2 Exp $
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
- (void) updateStatusLineBoardInfo
{
	NSLog(@"Method updateStatusLineBoardInfo is deprecated in SledgeHammer. you should not use this method.");
}
- (void) changeThreadsFilteringMask : (int) aMask
{
	[[self document] changeThreadsFilteringMask : aMask];
	[[self threadsListTable] reloadData];
	
	[self clearSearchFilter];
	[self synchronizeWindowTitleWithDocumentName];
}
- (CMRThreadsList *) currentThreadsList
{
	return [[self document] currentThreadsList];
}
- (void) setCurrentThreadsList : (CMRThreadsList *) newList
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

- (void) boardChanged : (id) aBoardIdentifier
{
	// �ǂݍ��݂̊����A�ݒ�ɕۑ�
	// �����ɓo�^���Ă���A�ύX�̒ʒm
	[CMRPref setBrowserLastBoard : aBoardIdentifier];
	[[CMRHistoryManager defaultManager]
		addItemWithTitle : [aBoardIdentifier name]
					type : CMRHistoryBoardEntryType
				  object : aBoardIdentifier];
	UTILNotifyName(CMRBrowserDidChangeBoardNotification);
}
- (void) showThreadsListWithBoardName : (NSString *) boardName
{
	CMRBBSSignature		*signature_;
	CMRThreadsList		*list_;
	NSString			*sortColumnIdentifier_;
	BOOL				isAscending_;
	
	if(nil == boardName) return;
	signature_ = [CMRBBSSignature BBSSignatureWithName : boardName];
	if([[[self currentThreadsList] BBSSignature] isEqual : signature_]){
		return;
	}
	
	[[self threadsListTable] deselectAll : nil];
	[[self threadsListTable] setDataSource : nil];
	
	list_ = [CMRThreadsList threadsListWithBBSSignature : signature_];
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
	
	// ���X�g�̓ǂݍ��݂��J�n����B
	[list_ startLoadingThreadsList : [self threadLayout]];
	[self boardChanged : signature_];
}

- (void) showThreadsListForBoard : (NSDictionary *) board;
{
	NSString			*bname_;
	
	bname_ = [board objectForKey : BoardPlistNameKey];
	if(nil == bname_) return;
	
	[self showThreadsListWithBoardName : bname_];
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
	CMRThreadsList	*tlist_ = [self currentThreadsList];
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
