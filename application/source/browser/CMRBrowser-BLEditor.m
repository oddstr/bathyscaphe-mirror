/*
 * $Id: CMRBrowser-BLEditor.m,v 1.21 2007/10/29 05:54:46 tsawada2 Exp $
 * BathyScaphe
 * CMRBrowser-Action.m, CMRBrowser-ViewAccessor.m から分割
 *
 * First created on 05/10/11.
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 *
 */

#import "CMRBrowser_p.h"
#import "AddBoardSheetController.h"
#import "EditBoardSheetController.h"

#import "SmartBoardList.h"
#import "BoardListItem.h"
#import "SmartBoardListItemEditor.h"

static NSString *const kRemoveDrawerItemTitleKey	= @"Browser Del Drawer Item Title";
static NSString *const kRemoveDrawerItemMsgKey		= @"Browser Del Board Items Message";

@implementation CMRBrowser(BoardListEditor)
- (void)setItem : (id) item : (int *) userInfo
{
	//
	if(item) {
		int rowIndex;
//		id selectedItem;
		id userList = [[BoardManager defaultManager] userList];
		
		rowIndex = [[self boardListTable] selectedRow];
//		selectedItem = (rowIndex >= 0) ? [[self boardListTable] itemAtRow : rowIndex]: nil;
		
		[userList addItem:item afterObject:nil];//selectedItem];
		[[self boardListTable] reloadData];
	}
}

- (IBAction)addSmartItem:(id)sender
{
	[[SmartBoardListItemEditor editor] cretateFromUIWindow:[self window]
												  delegate:self
										   settingSelector:@selector(setItem::)
												  userInfo:NULL];
}

- (IBAction)addBoardListItem:(id)sender
{
	[[self addBoardSheetController] beginSheetModalForWindow:[self window] modalDelegate:self contextInfo:nil];
}

- (IBAction)addCategoryItem:(id)sender
{
	[[self editBoardSheetController] beginAddCategorySheetForWindow:[self window] modalDelegate:self contextInfo:nil];
}

- (IBAction)editBoardListItem:(id)sender
{
	int tag_ = [sender tag];
	int	targetRow;

	NSOutlineView *boardListTable_ = [self boardListTable];
	if (tag_ == kBLEditItemViaContMenuItemTag) {
		targetRow = [(BSBoardListView *)boardListTable_ semiSelectedRow];
	} else {
		targetRow = [boardListTable_ selectedRow];
	}

	if (targetRow == -1) return;

	id	item_ = [boardListTable_ itemAtRow:targetRow];

	if ([BoardListItem isBoardItem:item_]) {
		[[self editBoardSheetController] beginEditBoardSheetForWindow:[self window] modalDelegate:self contextInfo:item_];
	} else if ([BoardListItem isFolderItem:item_]) {
		[[self editBoardSheetController] beginEditCategorySheetForWindow:[self window] modalDelegate:self contextInfo:item_];
	} else if ([BoardListItem isSmartItem:item_]) {
		SmartBoardListItemEditor *editor = [SmartBoardListItemEditor editor];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(smartBoardDidEdit:)
													 name:SBLIEditorDidEditSmartBoardListItemNotification
												   object:editor];
		[editor editWithUIWindow:[self window] smartBoardItem:item_];
	}
}

- (void) smartBoardDidEdit: (NSNotification *) aNotification
{
	id curThreadsListItem = [[self currentThreadsList] boardListItem];
	id anotherItem = [aNotification userInfo];

	if (curThreadsListItem == anotherItem) { // 編集したスマート掲示板を現在表示中である
		[self showThreadsListForBoard: curThreadsListItem forceReload: YES]; // 編集後の条件で再読み込み
	}
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: SBLIEditorDidEditSmartBoardListItemNotification
												  object: nil];
}

- (IBAction)removeBoardListItem:(id)sender
{
	int tag_ = [sender tag];
	int targetRow;

	BSBoardListView *boardListTable_ = (BSBoardListView *)[self boardListTable];	
	NSIndexSet	*indexSet_;

	if (tag_ == kBLDeleteItemViaContMenuItemTag) {
		targetRow = [(BSBoardListView *)boardListTable_ semiSelectedRow];
	} else {
		targetRow = [boardListTable_ selectedRow];
	}

	if (targetRow == -1) return;

	if ([boardListTable_ numberOfSelectedRows] == 1) {
		indexSet_ = [[NSIndexSet alloc] initWithIndex:targetRow];
	} else {
		NSIndexSet *selectedRows = [boardListTable_ selectedRowIndexes];
		if (tag_ == kBLDeleteItemViaMenubarItemTag) {
			indexSet_ = [[NSIndexSet alloc] initWithIndexSet:selectedRows];
		} else {
			if ([selectedRows containsIndex:targetRow]) {
				indexSet_ = [[NSIndexSet alloc] initWithIndexSet:selectedRows];
			} else { // 複数選択項目とは別の項目を semiSelect した
				indexSet_ = [[NSIndexSet alloc] initWithIndex:targetRow];
			}
		}
	}

	NSAlert *alert_ = [[[NSAlert alloc] init] autorelease];
	[alert_ setAlertStyle:NSWarningAlertStyle];
	[alert_ setMessageText:[self localizedString:kRemoveDrawerItemTitleKey]];
	[alert_ setInformativeText:[self localizedString:kRemoveDrawerItemMsgKey]];
	[alert_ addButtonWithTitle:[self localizedString:kDeleteOKBtnKey]];
	[alert_ addButtonWithTitle:[self localizedString:kDeleteCancelBtnKey]];

	NSBeep();
	[alert_ beginSheetModalForWindow:[self window]
					   modalDelegate:self
					  didEndSelector:@selector(boardItemsDeletionSheetDidEnd:returnCode:contextInfo:)
						 contextInfo:indexSet_];
}

- (void)boardItemsDeletionSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(id)contextInfo
{
	UTILAssertKindOfClass(contextInfo, NSIndexSet);

	if (returnCode == NSAlertFirstButtonReturn) {
		// 参考：<http://www.cocoadev.com/index.pl?NSIndexSet>
		unsigned int	arrayElement;
		NSDictionary	*item_;
		int				size = [contextInfo lastIndex]+1;
		NSRange			e = NSMakeRange(0, size);

		NSMutableArray	*boardItemsForRemoving = [NSMutableArray array];

		[[self boardListTable] deselectAll:nil]; // 先に選択を解除しておく

		while ([contextInfo getIndexes:&arrayElement maxCount:1 inIndexRange:&e] > 0) {
			item_ = [[self boardListTable] itemAtRow:arrayElement];

			if (item_) [boardItemsForRemoving addObject:item_];
		}

		[[BoardManager defaultManager] removeBoardItems:boardItemsForRemoving];
	}
	[contextInfo release];
}
@end
