//
//  CMRBrowser-Action.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/10.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRBrowser_p.h"
#import "CMRMainMenuManager.h"
#import "CMRHistoryManager.h"
#import "CMRThreadsList_p.h"
#import "FolderBoardListItem.h"
#import "CMRReplyDocumentFileManager.h"
extern BOOL isOptionKeyDown(void); // described in CMRBrowser-Delegate.m

@class IndexField;

@implementation CMRBrowser(Action)
static int expandAndSelectItem(BoardListItem *selected, NSArray *anArray, NSOutlineView *bLT)
{
	NSEnumerator *iter_ = [anArray objectEnumerator];
	id	eachItem;
	int index = -1;
	while (eachItem = [iter_ nextObject]) {
		// 「閉じているカテゴリ」だけに興味がある
		if (NO == [SmartBoardList isCategory: eachItem] || NO == [(FolderBoardListItem *)eachItem hasChildren]) continue;

		if (NO == [bLT isItemExpanded: eachItem]) [bLT expandItem: eachItem];

		index = [bLT rowForItem: selected];
		if (-1 != index) { // 当たり！
			return index;
		} else { // カテゴリ内のサブカテゴリを開いて検査する
			index = expandAndSelectItem(selected, [(FolderBoardListItem *)eachItem items], bLT);
			if (-1 == index) // このカテゴリのどのサブカテゴリにも見つからなかった
				[bLT collapseItem: eachItem]; // このカテゴリは閉じる
		}
	}
	return index;
}

- (int)searchRowForItemInDeep:(BoardListItem *)boardItem inView:(NSOutlineView *)olView
{
	int	index = [olView rowForItem:boardItem];
	
	if (index == -1) {
		index = expandAndSelectItem(boardItem, [(SmartBoardList *)[olView dataSource] boardItems], olView);
	}
	
	return index;
}

#pragma mark -
- (IBAction)focus:(id)sender
{
    [[self window] makeFirstResponder:[[self threadsListTable] enclosingScrollView]];
}

- (void)selectRowWhoseNameIs:(NSString *)brdname_
{
	[self selectRowOfName:brdname_ forceReload:NO];
}

- (void)selectRowOfName:(NSString *)boardName forceReload:(BOOL)flag
{
	NSOutlineView	*outlineView = [self boardListTable];
    SmartBoardList  *dataSource = [outlineView dataSource];
	BoardListItem	*selectedItem;
    int				index;

	UTILAssertNotNil(dataSource);

    selectedItem = [dataSource itemForName:boardName];

    if (!selectedItem) { // 必要なら掲示板を自動的に追加
		SmartBoardList	*defaultList = [[BoardManager defaultManager] defaultList];
		BoardListItem	*newItem = [defaultList itemForName:boardName];
		if (!newItem) {
			NSBeep();
			NSLog(@"No BoardListItem for board %@ found.", boardName);
			return;
		} else {
			[dataSource addItem:newItem afterObject:nil];
			selectedItem = [dataSource itemForName:boardName];
		}
	}

	index = [self searchRowForItemInDeep:selectedItem inView:outlineView];	
	if (index == -1) return;
	if ([outlineView isRowSelected:index]) { // すでに選択したい行が選択されている
		if (flag) {
			[self reloadThreadsList:self];
		} else {
			UTILNotifyName(CMRBrowserThListUpdateDelegateTaskDidFinishNotification);
		}
	} else {
		[outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	}

	[outlineView scrollRowToVisible:index];
}

- (IBAction)reloadThreadsList:(id)sender
{
	[[self document] reloadThreadsList];

	int row_ = [[self threadsListTable] selectedRow];
	int mask_ = [CMRPref threadsListAutoscrollMask];
	
	if ((mask_ & CMRAutoscrollWhenTLUpdate) > 0 && row_ != -1){
		// リストで選択されている項目までスクロール
		[[self threadsListTable] scrollRowToVisible:row_];
	} else {
		// リストの先頭までスクロール
		[[self threadsListTable] scrollRowToVisible:0];
	}
}

- (void)openThreadsInThreadWindow:(NSArray *)threads
{
	NSEnumerator	*iter_;
	NSDictionary	*thread_;
	NSString		*path_;
	
	iter_ = [threads objectEnumerator];
	while (thread_ = [iter_ nextObject]) {
		
		path_ = [CMRThreadAttributes pathFromDictionary:thread_];
		if ([self shouldShowContents] && [path_ isEqualToString:[self path]]) {
			continue;
		}
		[CMRThreadDocument showDocumentWithContentOfFile:path_ contentInfo:thread_];
	}
}

- (NSArray *)targetThreadsForAction:(SEL)action
{
	// currentlly no use action.
	NSEvent *event = [NSApp currentEvent];
	NSPoint mouse = [event locationInWindow];
	NSView *targetView = [[[self window] contentView] hitTest:mouse];
	NSArray *result = nil;
	//NSLog(@"%@", NSStringFromClass([targetView class]));
	if ([targetView isKindOfClass:[m_threadsListTable class]] /*|| nil == targetView*/) {	// スレッドリストから
		result = [self selectedThreadsReallySelected];
		if (0 == [result count]) {
			if (![self threadURL]) {
				result = [NSArray empty];
			}
			result = [self selectedThreads];
		}
	} else if (!targetView) {
		// メニューバーもしくはキーイベントから
		// あるいはツールバーボタンから
		// スレッドリストにフォーカスが当たっているかどうかで対象をスイッチする。
		NSView *focusedView_ = (NSView *)[[self window] firstResponder];
		if (focusedView_ == [self textView] || [self isIndexFieldFirstResponder]) {
			// フォーカスがスレッド本文領域にある
			id selected = [self selectedThread];
			if (nil == selected) {
				result = [NSArray empty];
			} else {
				result = [NSArray arrayWithObject:selected];
			}
		} else { // フォーカスがそれ以外の領域にある：スレッドリストの選択項目を優先
			result = [self selectedThreadsReallySelected];
			if (0 == [result count]) {
				if (![self threadURL]) {
					result = [NSArray empty];
				}
				result = [self selectedThreads];
			}
		}	
	} else { //　スレッド本文領域から。
		id selected = [self selectedThread];
		if (!selected) {
			result = [NSArray empty];
		} else {
			result = [NSArray arrayWithObject:selected];
		}
	}
	return result;
}

- (IBAction)openBBSInBrowser:(id)sender
{
	NSURL		*url_;
	
	url_ = [[self document] boardURL];
	if (url_) {
		[[NSWorkspace sharedWorkspace] openURL:url_ inBackGround:[CMRPref openInBg]];
	} else {
		[super openBBSInBrowser:sender];
	}
}

- (IBAction)openSelectedThreads:(id)sender
{
	[self openThreadsInThreadWindow:[self targetThreadsForAction:_cmd]];
}

- (IBAction)selectThread:(id)sender
{
	// 特定のモディファイア・キーが押されているときは
	// クリックで項目を選択してもスレッドを読み込まない
	if (![self shouldShowContents] || isOptionKeyDown()) return;
	
	[self showSelectedThread:self];
}

- (BOOL)shouldLoadThreadAtPath:(NSString *)filepath
{
	if (![self shouldShowContents]) return NO;
	
	return (![filepath isSameAsString:[self path]] || ![[NSFileManager defaultManager] fileExistsAtPath:filepath]);
}

- (void)showThreadAtRow:(int)rowIndex
{
	NSTableView				*tbView_ = [self threadsListTable];
	NSDictionary			*thread_;
	NSString				*path_;
	
	NSAssert2(
		(rowIndex >= 0 && rowIndex < [tbView_ numberOfRows]),
		@"  rowIndex was over. size = %d but was %d",
		[tbView_ numberOfRows],
		rowIndex);
	
	thread_ = [[self currentThreadsList] threadAttributesAtRowIndex:rowIndex inTableView:tbView_];
	path_ = [CMRThreadAttributes  pathFromDictionary:thread_];
	
	if ([self shouldLoadThreadAtPath:path_]) {
		[self setThreadContentWithFilePath:path_ boardInfo:thread_];
		// フォーカス
		//if ([CMRPref moveFocusToViewerWhenShowThreadAtRow]) {
			[[self window] makeFirstResponder:[self textView]];
		//}
		[self synchronizeWindowTitleWithDocumentName];
	}
}

- (IBAction)showSelectedThread:(id)sender
{
	if (-1 == [[self threadsListTable] selectedRow]) return;
	if ([[self threadsListTable] numberOfSelectedRows] != 1) return;
	
	[self showThreadAtRow:[[self threadsListTable] selectedRow]];
}

/*
	2005-06-06 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	Key Binding の便宜を図るためだけのメソッド。
	return キーに対応するアクションにこれを指定しておくと、2ペインのとき、3ペインのとき
	それぞれに応じて自動的に適切な動作（別窓で開く、下部に表示する）を呼び出せるという仕掛け。
*/
- (IBAction)showOrOpenSelectedThread:(id)sender
{
	if ([self shouldShowContents]) {
		[self showSelectedThread:sender];
	} else {
		[self openSelectedThreads:sender];
	}
}

- (IBAction)selectThreadOnly:(id)sender
{
	// do nothing.
}
/*
#pragma mark MeteorSweeper Key Binding Action Additions
- (IBAction) scrollPageDownThViewOrThListProperly: (id) sender
{
	if ([CMRPref moveFocusToViewerWhenShowThreadAtRow] || ![self shouldShowContents]) {
		[[[self threadsListTable] enclosingScrollView] pageDown: sender];
	} else {
		[[self textView] scrollPageDown: sender];
	}
}

- (IBAction) scrollPageUpThViewOrThListProperly: (id) sender
{
	if ([CMRPref moveFocusToViewerWhenShowThreadAtRow] || ![self shouldShowContents]) {
		[[[self threadsListTable] enclosingScrollView] pageUp: sender];
	} else {
		[[self textView] scrollPageUp: sender];
	}
}

- (IBAction) scrollPageDownThreadViewWithoutFocus: (id) sender
{
	if(![self shouldShowContents]) {
		NSBeep();
		return;
	}
	
	[[self textView] scrollPageDown: sender];
}

- (IBAction) scrollPageUpThreadViewWithoutFocus: (id) sender
{
	if(![self shouldShowContents]) {
		NSBeep();
		return;
	}
	
	[[self textView] scrollPageUp: sender];
}
*/
- (IBAction)showThreadFromHistoryMenu:(id)sender
{
	// 他の板のスレッドに移動することを考え、スレ一覧での選択状態を解除しておく
	if ([self shouldShowContents]) {
		[[self threadsListTable] deselectAll:nil];
	}
	[super showThreadFromHistoryMenu:sender];
}

#pragma mark Deletion
- (BOOL)forceDeleteThreads:(NSArray *)threads
{
	NSMutableArray	*array_ = [NSMutableArray arrayWithCapacity:[threads count]];
	NSArray			*arrayWithReplyFiles_;
	NSEnumerator	*iter_ = [threads objectEnumerator];
	NSFileManager	*fm = [NSFileManager defaultManager];
	id				eachItem_;
	NSString		*path_;

	while (eachItem_ = [iter_ nextObject]) {
		path_ = [CMRThreadAttributes pathFromDictionary:eachItem_];
		if ([fm fileExistsAtPath:path_]) {
			[array_ addObject:path_];
		} else {
			NSLog(@"File does not exist (although we're going to remove it!)\n%@", path_);
		}
	}

	arrayWithReplyFiles_ = [[CMRReplyDocumentFileManager defaultManager] replyDocumentFilesArrayWithLogsArray:array_];
	return [[CMRTrashbox trash] performWithFiles:arrayWithReplyFiles_ fetchAfterDeletion:NO];
}

- (void)doShowDeletionAlertSheet:(id)sender
						  ofType:(BSThreadDeletionType)aType
					  allowRetry:(BOOL)allowRetry
				   targetThreads:(NSArray *)threadsArray
{
	NSAlert		*alert_;
	NSString	*title_;
	NSString	*message_;

	alert_ = [[[NSAlert alloc] init] autorelease];

	switch(aType) {
	case BSThreadAtViewerDeletionType:
	{
		NSString *tmp_ = [self localizedString:kDeleteThreadTitleKey];
		NSString *threadTitle_ = [CMRThreadAttributes threadTitleFromDictionary:[threadsArray lastObject]];
		title_ = [NSString stringWithFormat:tmp_, threadTitle_];
		message_ = [self localizedString:kDeleteThreadMessageKey];
	}
		break;
	case BSThreadAtBrowserDeletionType:
		title_ = [self localizedString:kBrowserDelThTitleKey];
		message_ = [self localizedString:kBrowserDelThMsgKey];
		break;
	case BSThreadAtFavoritesDeletionType:
		title_ = [self localizedString:kDeleteFavTitleKey];
		message_ = [self localizedString:kDeleteFavMsgKey];
		break;
	default : 
		title_ = @"Implementaion Error";
		message_ = @"Please report that You see this message. Oh, you should press Cancel button. Sorry.";
		break;
	}
	
	[alert_ setMessageText:title_];
	[alert_ setInformativeText:message_];
	[alert_ addButtonWithTitle:[self localizedString:kDeleteOKBtnKey]];
	[alert_ addButtonWithTitle:[self localizedString:kDeleteCancelBtnKey]];
	if (allowRetry) {
		NSButton	*deleteAndReloadBtn_;
		deleteAndReloadBtn_ = [alert_ addButtonWithTitle:[self localizedString:kDeleteAndReloadBtnKey]];
		[deleteAndReloadBtn_ setKeyEquivalent:@"r"];
	}

	[alert_ beginSheetModalForWindow:[self window]
					   modalDelegate:self
					  didEndSelector:@selector(_threadDeletionSheetDidEnd:returnCode:contextInfo:)
					     contextInfo:[threadsArray retain]];
}

- (IBAction)deleteThread:(id)sender
{
	NSArray			*targets_ = [self targetThreadsForAction:_cmd];
	int				numOfSelected_ = [targets_ count];

	if (numOfSelected_ == 0) return;
	
	if (numOfSelected_ == 1) {
		NSString *path_ = [CMRThreadAttributes pathFromDictionary:[targets_ lastObject]];
		if ([CMRPref quietDeletion]) {
			if (![self forceDeleteThreadAtPath:path_ alsoReplyFile:YES]) {
				NSBeep();
				NSLog(@"Deletion failed : %@", path_);
			}
		} else {
			[self doShowDeletionAlertSheet:sender
									ofType:BSThreadAtViewerDeletionType
								allowRetry:([CMRPref isOnlineMode] && [self shouldShowContents] && [[self path] isEqualToString:path_])
							 targetThreads:targets_];
		}
	} else {
		if ([CMRPref quietDeletion]) {
			if (![self forceDeleteThreads:targets_]) {
				NSBeep();
				NSLog(@"CMRTrashbox returns some error.");
			}			
		} else {
			[self doShowDeletionAlertSheet:sender
									ofType:([[self currentThreadsList] isFavorites] ? BSThreadAtFavoritesDeletionType
																					: BSThreadAtBrowserDeletionType)
								allowRetry:NO
							 targetThreads:targets_];
		}
	}
}

- (void)_threadDeletionSheetDidEnd:(NSAlert *)alert
						returnCode:(int)returnCode
					   contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn) {
		if (![self forceDeleteThreads:(NSArray *)contextInfo]) {
			NSBeep();
			NSLog(@"CMRTrashbox returns some error.");
		}
	} else if (returnCode == NSAlertThirdButtonReturn) {
		id item_ = [(NSArray *)contextInfo lastObject];
		NSString *path_ = [CMRThreadAttributes pathFromDictionary:item_];
		if (![self forceDeleteThreadAtPath:path_ alsoReplyFile:NO]) {
			NSBeep();
			NSLog(@"Deletion failed : %@, so reloading opreation has been canceled.", path_);
		}
	}
}

#pragma mark Filter, Search
- (IBAction)selectFilteringMask:(id)sender
{
	NSNumber	*represent_;
	int			mask_;
	
	UTILAssertRespondsTo(sender,@selector(representedObject));	

	represent_ = [sender representedObject];
	UTILAssertKindOfClass(represent_, NSNumber);

	mask_ = [represent_ unsignedIntValue];
	[self changeThreadsFilteringMask:mask_];

//	[[CMRMainMenuManager defaultManager] synchronizeStatusFilteringMenuItemState];
}

- (void)synchronizeWithSearchField
{
	[[self document] searchThreadsInListWithCurrentSearchString];
	[self synchronizeWindowTitleWithDocumentName];

	[[self threadsListTable] reloadData];
}

- (IBAction)searchThread:(id)sender
{
	[self synchronizeWithSearchField];
}

- (IBAction)collapseOrExpandThreadViewer:(id)sender
{
	[self splitView:[self splitView] didDoubleClickInDivider:0];
}

- (unsigned int)isToolbarContainsSearchField
{
	NSToolbar	*toolbar = [[self window] toolbar];
	UTILAssertNotNil(toolbar);

	if (![toolbar isVisible]) {
		[toolbar setVisible:YES];
	}

	NSEnumerator *iter = [[toolbar visibleItems] objectEnumerator];
	id	item;
	while (item = [iter nextObject]) {
		if ([[item itemIdentifier] isEqualToString:kToolbarSearchFieldItemKey]) {
			return [toolbar displayMode] == NSToolbarDisplayModeLabelOnly ? 1 : 0;
		}
	}

	return 2;
}

- (IBAction)showSearchThreadPanel:(id)sender
{
	unsigned int toolbarState = [self isToolbarContainsSearchField];

	switch (toolbarState) {
	case 0:
		[[self searchField] selectText:sender];
		break;
	case 1:
		[[[self window] toolbar] setDisplayMode:NSToolbarDisplayModeIconAndLabel];
		[[self searchField] selectText:sender];
		break;
	default:
		NSBeep();
		break;
	}
}

#pragma mark View Menu
- (IBAction)collapseOrExpandBoardList:(id)sender
{
	RBSplitSubview	*tmp_;
	
	tmp_ = [self boardListSubView];
	if ([tmp_ isCollapsed]) {
		[tmp_ expand];
	} else {
		[tmp_ collapse];
	}
	// Leopard 暫定対策
	[[tmp_ splitView] adjustSubviews];
}

#pragma mark -

/*
NSTableView action, doubleAction はカラムのクリックでも
発生するので、以下のメソッドでフックする。
*/
- (IBAction)tableViewActionDispatch:(id)sender actionKey:(NSString *)aKey defaultAction:(SEL)defaultAction
{
	SEL action_;

	// カラムのクリック
	if (-1 == [[self threadsListTable] clickedRow]) return;

	// 設定されたアクションにディスパッチ
	action_ = SGTemplateSelector(aKey);
	if (NULL == action_ || _cmd == action_) {
		action_ = defaultAction;
	}
	[NSApp sendAction:action_ to:self from:sender];
}

- (IBAction)listViewAction:(id)sender
{
	[self tableViewActionDispatch:sender
						actionKey:kThreadsListTableActionKey
					defaultAction:@selector(selectThread:)];
}

- (IBAction)listViewDoubleAction:(id)sender
{
	[self tableViewActionDispatch:sender
						actionKey:kThreadsListTableDoubleActionKey
					defaultAction:@selector(openSelectedThreads:)];
}

- (IBAction)boardListViewDoubleAction:(id)sender
{
	UTILAssertKindOfClass(sender, NSOutlineView);

	int	rowNum = [sender clickedRow];
	if (-1 == rowNum) return;
	
	id item_ = [sender itemAtRow:rowNum];

	if ([sender isExpandable:item_]) {
		if ([sender isItemExpanded:item_]) {
			[sender collapseItem:item_];
		} else {
			[sender expandItem:item_];
		}
	}
}	
@end
