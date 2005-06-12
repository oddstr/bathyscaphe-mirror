/**
  * $Id: CMRBrowser-Action.m,v 1.5 2005/06/12 01:36:14 tsawada2 Exp $
  * 
  * CMRBrowser-Action.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"
#import "CMRMainMenuManager.h"
#import "CMRHistoryManager.h"
#import "CMRThreadsList_p.h"

enum {
	kShowsBoardListInSheet,
	kShowsSearchFieldInSheet
};

@implementation CMRBrowser(Action)
- (IBAction) focus : (id) sender
{
    [[self window] makeFirstResponder : [[self threadsListTable] enclosingScrollView]];
}
// History Menu
- (IBAction) showBoardWithMenuItem : (id) sender
{
    NSString        *boardName;

    id historyItem = nil;
    
    if ([sender respondsToSelector : @selector(representedObject)]) {
        id o = [sender representedObject];
        
        if (nil == o || NO == [o isKindOfClass : [CMRHistoryItem class]]) {
            UTILDebugWrite1(
              @"[WARN] [sender representedObject] must be an instance"
              @" of CMRHistoryItem."
              @" at %@", UTIL_HANDLE_FAILURE_IN_METHOD);
            return;
        }
        historyItem = o;
    }
	[self showThreadsListWithBBSSignature : [historyItem representedObject]];
    // 掲示板リストでも同じ板を選択させる
    boardName = [historyItem title];
	[self selectRowWhoseNameIs : boardName];
	[self focus : sender];
}

- (IBAction) showThreadWithMenuItem : (id) sender
{
	// 他の板のスレッドに移動することを考え、スレ一覧での選択状態を解除しておく
	[[self threadsListTable] deselectAll: nil];
	[super showThreadWithMenuItem : sender];
}

- (void) selectRowWhoseNameIs : (NSString *) brdname_
{
    BoardList       *source;
    NSDictionary	*selected;
    int				index;

    source = (BoardList *)[[self boardListTable] dataSource];
    
    selected = [source itemForName : brdname_];
    if (nil == selected)
        return;
    
    index = [[self boardListTable] rowForItem : selected];
    if (-1 == index) {
        return;
    }
    
    [[self boardListTable] selectRow : index 
                byExtendingSelection : NO];
    [[self boardListTable] scrollRowToVisible : index];
}

- (IBAction) clear : (id) sender
{
	[self deleteThread : nil];
}

- (void) openThreadsInThreadWidnow : (NSArray *) threads
{
	NSEnumerator		*Iter_;
	NSDictionary		*thread_;
	
	Iter_ = [threads objectEnumerator];
	while ((thread_ = [Iter_ nextObject])) {
		NSString				*path_;
		
		path_ = [CMRThreadAttributes pathFromDictionary : thread_];
		[CMRThreadDocument showDocumentWithContentOfFile : path_
											 contentInfo : thread_];
	}
}
- (NSArray *) targetThreadsForAction : (SEL) action
{
	// currentlly no use action.
	NSEvent *event = [NSApp currentEvent];
	NSPoint mouse = [event locationInWindow];
	NSView *targetView = [[[self window] contentView] hitTest : mouse];
	NSArray *result = nil;
	
	if ([targetView isKindOfClass : [m_threadsListTable class]] || nil == targetView) {	// スレッドリストから
		result = [self selectedThreadsReallySelected];
		if (0 == [result count]) {
			if (nil == [self threadURL]) {
				result = [NSArray empty];
			}
			result = [self selectedThreads];
		}
//	} else if (nil == targetView) {
		// メニューバーもしくはキーイベントから 今はスレッドリストの場合と同じ
	} else { //　スレッドリストから。
		id selected = [self selectedThread];
		if (nil == selected) {
			result = [NSArray empty];
		} else {
			result = [NSArray arrayWithObject : selected];
		}
	}
		return result;
}
- (IBAction) openLogfile : (id) sender
{
	[self openThreadsLogFiles :  [self targetThreadsForAction : _cmd]];
}
- (IBAction) openInBrowser : (id) sender
{
	[self openThreadsInBrowser : [self targetThreadsForAction : _cmd]];
}

- (IBAction) openSelectedThreads : (id) sender
{
	[self openThreadsInThreadWidnow : [self targetThreadsForAction : _cmd]];
}
- (IBAction) selectThread : (id) sender
{
	// 特定のモディファイア・キーが押されているときは
	// クリックで項目を選択してもスレッドを読み込まない
	if (NSAlternateKeyMask & [[NSApp currentEvent] modifierFlags])
		return;
	
	if (NO == [self shouldShowContents])
		return;
	
	[self showSelectedThread : self];
}
- (BOOL) shouldLoadThreadAtPath : (NSString *) filepath
{
	if (NO == [self shouldShowContents]) return NO;
	
	return (NO == [filepath isSameAsString : [self path]] || NO == [[NSFileManager defaultManager] fileExistsAtPath : filepath]);
}
- (void) showThreadAtRow : (int) rowIndex
{
	NSTableView				*tbView_ = [self threadsListTable];
	NSDictionary			*thread_;
	NSString				*path_;
	
	NSAssert2(
		(rowIndex >= 0 && rowIndex < [tbView_ numberOfRows]),
		@"  rowIndex was over. size = %d but was %d",
		[tbView_ numberOfRows],
		rowIndex);
	
	thread_ = [[self currentThreadsList] 
				threadAttributesAtRowIndex:rowIndex inTableView:tbView_];
	path_ = [CMRThreadAttributes  pathFromDictionary : thread_];
	
	if ([self shouldLoadThreadAtPath : path_]) {
		[self setThreadContentWithFilePath : path_
								 boardInfo : thread_];
		// フォーカス
		[[self window] makeFirstResponder : [self textView]];
		[self updateStatusLineBoardInfo];
	}
}

- (IBAction) showSelectedThread : (id) sender
{
	if (-1 == [[self threadsListTable] selectedRow]) return;
	if ([[self threadsListTable] numberOfSelectedRows] != 1) return;
	
	[self showThreadAtRow : [[self threadsListTable] selectedRow]];
}


/*
	2005-06-06 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	Key Binding の便宜を図るためだけのメソッド。
	return キーに対応するアクションにこれを指定しておくと、2ペインのとき、3ペインのとき
	それぞれに応じて自動的に適切な動作（別窓で開く、下部に表示する）を呼び出せるという仕掛け。
*/
- (IBAction) showOrOpenSelectedThread : (id) sender
{
	if ([self shouldShowContents]) {
		[self showSelectedThread : sender];
	} else {
		[self openSelectedThreads : sender];
	}
}

- (IBAction) selectFilteringMask : (id) sender
{
	NSPopUpButton	*popUpButton_;
	NSNumber		*representedObject_;
	unsigned int	mask_;
	
	if (nil == [self currentThreadsList]) return;
	if (nil == sender) return;
	
	UTILAssertKindOfClass(sender, NSPopUpButton);
	
	popUpButton_ = (NSPopUpButton*) sender;
	representedObject_ = [[popUpButton_ selectedItem] representedObject];
	UTILAssertKindOfClass(representedObject_, NSNumber);

	mask_ = [representedObject_ unsignedIntValue];
	[self changeThreadsFilteringMask : mask_];
}

- (IBAction) searchToolbarPopupChanged : (id) sender
{
	CMRSearchMask		prefOption_;		// 設定済みのオプション
	CMRSearchMask		settingOpt_;		// 設定または解除されたオプション
	BOOL				isOnState_;			// 設定か
	
	if (NO == [sender respondsToSelector:@selector(representedObject)]) return;
	if (NO == [sender respondsToSelector:@selector(state)]) return;
	
	prefOption_ = [CMRPref threadSearchOption];
	settingOpt_ = [[sender representedObject] unsignedIntValue];
	isOnState_  = NSOffState == [(NSMenuItem*)sender state];
	
	[sender setState : isOnState_ ? NSOnState : NSOffState];
	if (CMRSearchOptionCaseInsensitive == settingOpt_ || 
	   CMRSearchOptionZenHankakuInsensitive == settingOpt_) {
		// 意味が逆になっている。
		isOnState_ = (NO == isOnState_);
	}
	if (isOnState_) {
		[CMRPref setThreadSearchOption : 
			prefOption_ | settingOpt_];
	} else {
		[CMRPref setThreadSearchOption : 
			(prefOption_ & (~settingOpt_))];
	}
	
}

- (IBAction) forceDeleteThread : (id) sender
{
	NSString *thePath_ = [self path];

	[self forceDeleteThreadAtPath : thePath_];
}

- (IBAction) deleteThread : (id) sender
{
    CMRThreadsList *threadsList = [self currentThreadsList];
    NSTableView    *tableView   = [self threadsListTable];
    
    if (nil == threadsList || 0 == [tableView numberOfSelectedRows]) {
		/* スレ一覧で何も選択されていないとき */
		if ([self shouldShowContents]) {
			/* 3ペイン表示なら、ログ表示領域で表示中のスレを削除する */
			if ([CMRPref quietDeletion]) {
				[self forceDeleteThread : sender];
			} else {
				NSBeep();
				NSBeginAlertSheet(
				[self localizedString : kDeleteThreadTitleKey],
				[self localizedString : kDeleteOKBtnKey],
				nil,
				[self localizedString : kDeleteCancelBtnKey],
				[self window],
				self,
				@selector(_threadDeletionSheetDidEnd:returnCode:contextInfo:),
				NULL,
				sender,
				[self localizedString : kDeleteThreadMessageKey]);
			}
			return;
		} else {
			/* 2ペイン表示なら、削除するものは何も無い */
			return;
		}
    }
    if (NO == [CMRPref quietDeletion]) {
		NSBeep();
		if(NO == [threadsList isFavorites]){
			NSBeginAlertSheet(
			[self localizedString : kBrowserDelThTitleKey],
			[self localizedString : kDeleteOKBtnKey],
			nil,
			[self localizedString : kDeleteCancelBtnKey],
			[self window],
			self,
			@selector(_threadDeletionSheetDidEnd:returnCode:contextInfo:),
			NULL,
			nil,
			[self localizedString : kBrowserDelThMsgKey]);

		}else{
			NSBeginAlertSheet(
			[self localizedString : kDeleteFavTitleKey],
			[self localizedString : kDeleteOnlyFavBtnKey],
			[self localizedString : kDeleteFavAlsoFileBtnKey],
			[self localizedString : kDeleteCancelBtnKey],
			[self window],
			self,
			@selector(_threadDeletionSheetDidEnd:returnCode:contextInfo:),
			NULL,
			nil,
			[self localizedString : kDeleteFavMsgKey]);
		}
    } else {

		[threadsList tableView : tableView
			removeItems : [[tableView selectedRowEnumerator] allObjects]
			deleteFile : YES];
		[tableView reloadData];
	}
}

- (void) _threadDeletionSheetDidEnd : (NSWindow *) sheet
						 returnCode : (int       ) returnCode
						contextInfo : (void     *) contextInfo
{
    CMRThreadsList *threadsList = [self currentThreadsList];
    NSTableView    *tableView   = [self threadsListTable];

	switch(returnCode){
	case NSAlertDefaultReturn:
		if (contextInfo == nil) {
			[threadsList tableView : tableView
					   removeItems : [[tableView selectedRowEnumerator] allObjects]
						deleteFile : (NO == [threadsList isFavorites])];
			[tableView reloadData];
		} else {
			[self forceDeleteThread : contextInfo];
		}
		break;
	case NSAlertAlternateReturn:
		[threadsList tableView : tableView
			removeItems : [[tableView selectedRowEnumerator] allObjects]
			deleteFile : YES];
		[tableView reloadData];
		break;
	case NSAlertOtherReturn:
		break;
	case NSAlertErrorReturn:
		break;
	default:
		break;
	}
	
}

#pragma mark -

- (void) showSearchResultAppInfoWithFound : (BOOL) aResult
{
	NSString	*string_;
	
	if (NO == aResult) {
		string_ = [self localizedString : kSearchListNotFoundKey];
	} else {
		string_ = [NSString stringWithFormat : 
					[self localizedString : kSearchListResultKey],
					[[self currentThreadsList] numberOfFilteredThreads]];
	}
	[[self statusLine] setInfoText : string_];
}
- (BOOL) showsSearchResult
{
	return (_filterString != nil);
}
- (void) clearSearchFilter
{
	[_filterString release];
	_filterString = nil;
}
- (void) synchronizeWithSearchField
{
	[self searchThreadWithString : _filterString];
}
- (void) searchThreadWithString : (NSString *) aString
{
	BOOL		result = NO;
	
	if (nil == aString || [aString isEmpty]) {
		int		mask_;
		
		mask_ = [[self currentThreadsList] filteringMask];
		[self changeThreadsFilteringMask : mask_];
	} else {
		result = [[self document] searchThreadsInListWithString : aString];
		[self showSearchResultAppInfoWithFound : result];
	}
	
	if (result && _filterString != aString) {
		[_filterString autorelease]; 
		_filterString = [aString copy];
	}

	[[self threadsListTable] reloadData];
}
- (IBAction) searchThread : (id) sender
{
	if (NO == [sender respondsToSelector : @selector(stringValue)])
		return;

	[self searchThreadWithString : [sender stringValue]];
}

// リスト検索：シート表示
- (IBAction) showSearchThreadPanel : (id) sender
{
	if ([self ifSearchFieldIsInToolbar]) {
		// ツールバーに検索フィールドが見えているときは、単にそこにフォーカスを移動するだけ（シートは表示しない）
		[[self searchTextField] selectText : sender];
	} else {
		id		contentView_;
		id		info_;

		contentView_ = [[self searchTextField] retain];
		info_ = [NSNumber numberWithInt : kShowsSearchFieldInSheet];

		[[self listSorterSheetController] beginSheetModalForWindow : [self window]
													 modalDelegate : self
													   contentView : contentView_
													   contextInfo : info_];
		[contentView_ release];
	}
}

- (void) controller : (CMRAccessorySheetController *) aController
		sheetDidEnd : (NSWindow					 *) sheet
		contentView : (NSView					 *) contentView
		contextInfo : (id						  ) info;
{
	int		status_;
	
	UTILAssertKindOfClass(info, NSNumber);
	
	status_ = [info intValue];
	switch(status_) {
	case kShowsBoardListInSheet :
		[[self boardDrawer] setContentView : contentView];
		[self setupBoardDrawer];
		break;
	case kShowsSearchFieldInSheet :{
		break;
	}
	default :
		break;
	}
}

#pragma mark -

- (BOOL) shouldOpenBoardListInSheet
{
	int			mask_;
	
	mask_ = [CMXTemplateResource(kOpenBoardListInSheetMaskKey, nil) intValue];
	return ((mask_ & [[NSApp currentEvent] modifierFlags]) || 0 == mask_);
}
- (IBAction) beginBoardListSheet : (id) sender
{
	int				status_;
	NSView			*contentView_;
	id				info_;
	
	status_ = [[self boardDrawer] state];
	if (NSDrawerOpenState == status_ || NSDrawerOpeningState == status_) {
		[[self boardDrawer] setDelegate : nil];
		[[self boardDrawer] close];
		[CMRPref setIsBoardListOpen : YES];
	}
	contentView_ = [[[self boardDrawer] contentView] retain];
	info_ = [NSNumber numberWithInt : kShowsBoardListInSheet];
	
	[[self boardListSheetController] 
				beginSheetModalForWindow : [self window]
						   modalDelegate : self
							 contentView : contentView_
							 contextInfo : info_];
	[contentView_ release];
}
- (IBAction) toggleBoardDrawer : (id) sender
{
	if ([self shouldOpenBoardListInSheet]) {
		[self beginBoardListSheet : sender];
		return;
	}
	
	NSRectEdge	defaultEdge_;
	defaultEdge_ = [CMRPref boardListDrawerEdge];

	if (defaultEdge_ == NSMinXEdge || defaultEdge_ == NSMaxXEdge) {
		if ([[self boardDrawer] state] == NSDrawerClosedState) {
			[[self boardDrawer] openOnEdge : defaultEdge_];
		} else {
			[[self boardDrawer] close];
		}
	} else {
		[[self boardDrawer] toggle : sender];
	}
}

- (IBAction) changeBrowserArrangement : (id) sender
{
	NSNumber	*represent_;
	
	if (NO == [sender respondsToSelector : @selector(representedObject)]) {
		UTILDebugWrite(@"Sender must respondsToSelector : -representedObject");
		return;
	}
	
	represent_ = [sender representedObject];
	UTILAssertKindOfClass(represent_, NSNumber);
	[CMRPref setIsSplitViewVertical : [represent_ boolValue]];
	[[CMRMainMenuManager defaultManager] synchronizeBrowserArrangementMenuItemState];
	
	[self setupSplitView];
	[[self splitView] resizeSubviewsWithOldSize : [[self splitView] frame].size];
}

#pragma mark -

- (IBAction) addDrawerItem : (id) sender
{
	[[self dItemAddSheetNameField] setStringValue : @""];
	[[self dItemAddSheetURLField]  setStringValue : @""];

	[NSApp beginSheet : [self drawerItemAddSheet]
	   modalForWindow : [self window]
	    modalDelegate : self
	   didEndSelector : @selector(_drawerAddItemSheetDidEnd:returnCode:contextInfo:)
	      contextInfo : nil];
}

- (IBAction) addCategoryItem : (id) sender
{
	[[self dItemEditSheetTitleField] setStringValue : [self localizedString : kAddCategoryTitleKey]];
	[[self dItemEditSheetMsgField]   setStringValue : [self localizedString : kEditDrawerItemMsgForAdditionKey]];
	[[self dItemEditSheetLabelField] setStringValue : [self localizedString : kEditDrawerItemTitleForCategoryKey]];
	[[self dItemEditSheetInputField] setStringValue : @""];
	
	[NSApp beginSheet : [self drawerItemEditSheet]
	   modalForWindow : [self window]
		modalDelegate : self
	   didEndSelector : @selector(_drawerAddCategorySheetDidEnd:returnCode:contextInfo:)
		  contextInfo : nil];
}

- (IBAction) editDrawerItem : (id) sender
{
	int	rowIndex_ = [[self boardListTable] selectedRow];

	NSDictionary	*item_;
	NSString	*name_;

	item_ = [[self boardListTable] itemAtRow : rowIndex_];
	name_ = [item_ objectForKey : BoardPlistNameKey];
	
	[[self dItemEditSheetTitleField] setStringValue : [self localizedString : kEditDrawerTitleKey]];
	if ([BoardList isBoard : item_]) {
		[[self dItemEditSheetMsgField]   setStringValue :
					 [NSString localizedStringWithFormat: [self localizedString : kEditDrawerItemMsgForBoardKey],name_]];
		[[self dItemEditSheetLabelField] setStringValue : [self localizedString : kEditDrawerItemTitleForBoardKey]];
		[[self dItemEditSheetInputField] setStringValue : [item_ objectForKey : BoardPlistURLKey]];

	} else if ([BoardList isCategory : item_]) {
		[[self dItemEditSheetMsgField]   setStringValue :
					 [NSString localizedStringWithFormat: [self localizedString : kEditDrawerItemMsgForCategoryKey],name_]];
		[[self dItemEditSheetLabelField] setStringValue : [self localizedString : kEditDrawerItemTitleForCategoryKey]];
		[[self dItemEditSheetInputField] setStringValue : name_];
	}
	
	[NSApp beginSheet : [self drawerItemEditSheet]
	   modalForWindow : [self window]
		modalDelegate : self
	   didEndSelector : @selector(_drawerItemEditSheetDidEnd:returnCode:contextInfo:)
		  contextInfo : item_];
}

- (IBAction) removeDrawerItem : (id) sender
{
	int	rowIndex_ = [[self boardListTable] selectedRow];
	NSDictionary	*item_;
	item_ = [[self boardListTable] itemAtRow : rowIndex_];
		
	NSBeep();
	NSBeginAlertSheet(
		[self localizedString : kRemoveDrawerItemTitleKey],
		[self localizedString : kDeleteOKBtnKey],
		nil,
		[self localizedString : kDeleteCancelBtnKey],
		[self window],
		self,
		@selector(_drawerItemDeletionSheetDidEnd:returnCode:contextInfo:),
		NULL,
		item_,
		[self localizedString : kRemoveDrawerItemMsgKey],[item_ objectForKey : BoardPlistNameKey]
	);
}

- (IBAction) endEditSheet : (id) sender
{	
	[NSApp endSheet : [sender window]
		 returnCode : ([sender tag] == 1) ? NSOKButton : NSCancelButton];
}

- (void) _drawerAddItemSheetDidEnd : (NSWindow *) sheet
						returnCode : (int       ) returnCode
					   contextInfo : (id) contextInfo
{
	if (NSOKButton == returnCode) {
		NSMutableDictionary *newItem_;
		NSString *name_;
		NSString *url_;

		name_ = [[self dItemAddSheetNameField] stringValue];
		url_  = [[self dItemAddSheetURLField] stringValue];
		
		if ([name_ isEqualToString : @""]|[url_ isEqualToString : @""]) {
			// 名前またはURLが入力されていない場合は中止
			NSBeep();
			[sheet close];
			return;
		} else {
			id userList = [[BoardManager defaultManager] userList];

			if ([userList containsItemWithName : name_]) {
				[sheet close];	
				NSBeep();
				NSBeginInformationalAlertSheet(
					[self localizedString : @"Same Name Exists"],
					[self localizedString : @"OK"],
					nil, nil,
					[self window],
					self, NULL, NULL, nil,
					[self localizedString : @"So cannot add board."]
				);
				return;
			}

			int rowIndex;
			id selectedItem;
		
			newItem_ = [NSMutableDictionary dictionaryWithObjectsAndKeys :
							name_, BoardPlistNameKey, url_, BoardPlistURLKey, nil];

			rowIndex = [[self boardListTable] selectedRow];

			selectedItem = (rowIndex >= 0) 
						? [[self boardListTable] itemAtRow : rowIndex]
						: nil;
	
			if (nil == selectedItem || [BoardList isFavorites : selectedItem]) {
				[[userList boardItems] addObject : newItem_];
				[userList postBoardListDidChangeNotification];
			} else {
				[userList addItem:newItem_ afterObject:selectedItem];
			}
			[[self boardListTable] reloadData];
		}
	}
	[sheet close];
}

- (void) _drawerAddCategorySheetDidEnd : (NSWindow *) sheet
							returnCode : (int       ) returnCode
						   contextInfo : (id) contextInfo
{
	if (NSOKButton == returnCode) {

		NSMutableDictionary *newItem_;
		NSString *name_;
		id userList = [[BoardManager defaultManager] userList];
	
		name_ = [[self dItemEditSheetInputField] stringValue];

		if ([name_ isEqualToString : @""]) {
			NSBeep();
			[sheet close];
			return;
		}

		if ([userList containsItemWithName : name_]) {
			[sheet close];	
			NSBeep();
			NSBeginInformationalAlertSheet(
				[self localizedString : @"Same Name Exists"],
				[self localizedString : @"OK"], nil, nil, [self window], self, NULL, NULL, nil,
				[self localizedString : @"So cannot add category."]
			);
			return;
		}

		int rowIndex;
		id selectedItem;
	
		newItem_ = [NSMutableDictionary dictionaryWithObjectsAndKeys :
					name_, BoardPlistNameKey, [NSMutableArray array], BoardPlistContentsKey, nil];
	
		rowIndex = [[self boardListTable] selectedRow];
		selectedItem = (rowIndex >= 0) ? [[self boardListTable] itemAtRow : rowIndex]: nil;
	
		if (nil == selectedItem || [BoardList isFavorites : selectedItem]) {
			[[userList boardItems] addObject : newItem_];
			[userList postBoardListDidChangeNotification];
		} else {
			[userList addItem:newItem_ afterObject:selectedItem];
		}
		[[self boardListTable] reloadData];
	}
	[sheet close];
}

- (void) _drawerItemEditSheetDidEnd : (NSWindow *) sheet
						 returnCode : (int       ) returnCode
						contextInfo : (NSDictionary *) contextInfo
{
	if (NSOKButton == returnCode) {

		NSString *value_;
		value_ = [[self dItemEditSheetInputField] stringValue];

		id userList = [[BoardManager defaultManager] userList];

		NSMutableDictionary *newItem_;
		NSString *oldname_;

		if ([value_ isEqualToString : @""]) {
			NSBeep();
			[sheet close];
			return;
		}
		
		if ([BoardList isBoard : contextInfo]) {

			newItem_ = (NSMutableDictionary *)contextInfo;
			oldname_ = [newItem_ objectForKey : BoardPlistNameKey];
		
			[userList item : newItem_
				   setName : oldname_
					setURL : value_];
						   
		} else if ([BoardList isCategory : contextInfo]) {

			newItem_ = (NSMutableDictionary *)contextInfo;
			oldname_ = [newItem_ objectForKey : BoardPlistNameKey];
		
			if ([userList containsItemWithName : value_] && (NO == [oldname_ isEqualToString : value_])) {
				[sheet close];
				NSBeep();
				NSBeginInformationalAlertSheet(
					[self localizedString : @"Same Name Exists"],
					[self localizedString : @"OK"], nil, nil, [self window], self, NULL, NULL, nil,
					[self localizedString : @"So cannot change name."]
				);
				return;
			}
			[userList item : newItem_
				   setName : value_
					setURL : nil];
		}
		[[self boardListTable] reloadData];
	}
	[sheet close];
}

- (void) _drawerItemDeletionSheetDidEnd : (NSWindow *) sheet
							 returnCode : (int       ) returnCode
							contextInfo : (NSDictionary *) contextInfo
{
	switch (returnCode) {
	case NSAlertDefaultReturn:
		[[[BoardManager defaultManager] userList] removeItemWithName : [contextInfo objectForKey : BoardPlistNameKey]];
		[[self boardListTable] reloadData];
		[[self boardListTable] deselectAll : nil];
		break;
	default:
		break;
	}
}

#pragma mark -

- (IBAction) reloadThreadsList : (id) sender
{
	[[self document] reloadThreadsList];
	
	int row_ = [[self threadsListTable] selectedRow];
	int mask_ = [CMRPref threadsListAutoscrollMask];
	
	if ((mask_ & CMRAutoscrollWhenTLUpdate) > 0 && row_ != -1){
		// リストで選択されている項目までスクロール
		[[self threadsListTable] scrollRowToVisible : row_];
	}else{
		// リストの先頭までスクロール
		[[self threadsListTable] scrollRowToVisible : 0];
	}
}
- (IBAction) openBBSInBrowser : (id) sender
{
	NSURL		*url_;
	
	url_ = [[self document] boardURL];
	if (url_ != nil) {
		[[NSWorkspace sharedWorkspace] openURL : url_ inBackGround : [CMRPref openInBg]];
	} else {
		[super openBBSInBrowser : sender];
	}
}

/*
NSTableView action, doubleAction はカラムのクリックでも
発生するので、以下のメソッドでフックする。
*/
- (IBAction) tableViewActionDispatch : (id        ) sender
						   actionKey : (NSString *) aKey
					   defaultAction : (SEL       ) defaultAction
{
	SEL				action_;
	
	// カラムのクリック
	if (-1 == [[self threadsListTable] clickedRow])
		return;

	// 設定されたアクションにディスパッチ
	action_ = SGTemplateSelector(aKey);
	if (NULL == action_ || _cmd == action_)
		action_ = defaultAction;
	
	[NSApp sendAction:action_ to:self from:sender];
}
- (IBAction) listViewAction : (id) sender
{
	[self tableViewActionDispatch : sender
						actionKey : kThreadsListTableActionKey
					defaultAction : @selector(selectThread:)];
}
- (IBAction) listViewDoubleAction : (id) sender
{
	[self tableViewActionDispatch : sender
						actionKey : kThreadsListTableDoubleActionKey
					defaultAction : @selector(openSelectedThreads:)];
}
@end
