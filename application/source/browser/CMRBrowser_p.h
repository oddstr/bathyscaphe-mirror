//:CMRBrowser_p.h
/**
  *
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/08  7:36:04 PM)
  *
  */
#import "CMRBrowser.h"
#import "CMRThreadViewer_p.h"

#import "AppDefaults.h"
#import "BoardManager.h"
#import "SmartBoardList.h"

#import "Browser.h"
#import "CMRThreadDocument.h"

#import "CMRBrowserTbDelegate.h"
#import "CMRThreadsList.h"
#import "CMXDateFormatter.h"

#import "BSDBThreadList.h"

#import "ThreadsListTable.h"
#import "CMRSplitView.h"
#import "CMXScrollView.h"
#import "CMRAccessorySheetController.h"

#import "CMRSearchOptions.h"

#define APP_BROWSER_WINDOW_AUTOSAVE_NAME			@"CocoMonar:Browser Window Autosave"
#define APP_BROWSER_SPVIEW_AUTOSAVE_NAME			@"CocoMonar:Browser SplitView Autosave"
#define APP_BROWSER_STATUSLINE_IDENTIFIER			@"Browser"
#define APP_BROWSER_THREADSLIST_TABLE_AUTOSAVE_NAME	@"CocoMonar:ThreadsListTable Autosave"
#define APP_BROWSER_BOARDLIST_OLVIEW_AUTOSAVE_NAME	@"BoardListTable Autosave"

#define STATUS_HEADER_IMAGE_NAME					@"Status_header"
#define STATUS_HEADER_IMAGE_WIDTH					18.0f

// 前回最後に開いていた掲示板を開くよう指示する通知
#define kSelectLastBBSNotification @"kSelectLastBBSNotification"

// 掲示板リストの編集
#define kEditDrawerTitleKey					@"Edit Title"
#define kAddCategoryTitleKey				@"Add Category Title"

#define kEditDrawerItemMsgForAdditionKey	@"Add Category Msg"

#define kEditDrawerItemMsgForBoardKey		@"Edit Board Msg"
#define kEditDrawerItemTitleForBoardKey		@"PleaseInputURL"

#define kEditDrawerItemMsgForCategoryKey	@"Edit Category Msg"
#define kEditDrawerItemTitleForCategoryKey	@"PleaseInputName"

#define kRemoveDrawerItemTitleKey			@"Browser Del Drawer Item Title"
#define kRemoveDrawerItemMsgKey				@"Browser Del Drawer Item Message"

#define kRemoveMultipleItemTitleKey			@"Browser Del Multiple Item Title"
#define kRemoveMultipleItemMsgKey			@"Browser Del Multiple Item Message"

// PropertyList
#define kThreadsListTableICSKey				@"Browser - ListViewInterCellSpacing"
#define kThreadsListTableActionKey			@"Browser - ListViewAction"
#define kThreadsListTableDoubleActionKey	@"Browser - ListViewDoubleAction"

// Localized
#define kSearchListNotFoundKey				@"Search Thread Not Found"
#define kSearchListResultKey				@"Search Thread Result"

//:CMRBrowser-ViewAccessor.m
// TableView Columns
#define kBrowserListColumnsPlist			@"browserListColumns.plist"
#define kChooseColumnAction					@selector(chooseColumn:)
#define kToolbarSearchFieldItemKey			@"Search Thread"
// menuItem tags
#define kSearchPopUpOptionItemTag			11
#define kSearchPopUpSeparatorTag			22
#define kSearchPopUpHistoryHeaderItemTag	33
#define kSearchPopUpHistoryItemTag			44

#define kBLOpenItemItemTag					1001
#define kBLEditItemViaMenubarItemTag		1002
#define kBLEditItemViaContextualMenuItemTag	1102
#define kBLAddItemItemTag					1000
#define kBLDeleteItemViaMenubarItemTag		1004
#define kBLDeleteItemViaContMenuItemTag		1104

#define kBLMenubarItemTagMaximalValue		1000
#define kBLContMenuItemTagMaximalValue		1100

//:CMRBrowser-List.m
@interface CMRBrowser(List)
- (void) changeThreadsFilteringMask : (int) aMask;

- (id) currentThreadsList;
- (void) setCurrentThreadsList : (id) newList;

- (void) showThreadsListWithBoardListItem : (id) board;
- (void) showThreadsListForBoard : (id) aSignature;
- (void) showThreadsListWithBoardName : (NSString *) boardName;
@end



@interface CMRBrowser(Table)
- (void) changeHighLightedTableColumnTo : (NSString *) columnIdentifier_ isAscending : (BOOL) isAscending;

/* 選択できなければ -1 */
- (unsigned) selectCurrentThreadWithMask : (int) mask;
- (unsigned) selectRowWithCurrentThread;
- (unsigned) selectRowWithThreadPath : (NSString *) filepath
		        byExtendingSelection : (BOOL      ) flag;

@end

//:CMRBrowser-Delegate.m
@interface CMRBrowser(NotificationPrivate)
- (void) boardManagerUserListDidChange : (NSNotification *) notification;
- (void) threadsListDidFinishUpdate : (NSNotification *) notification;
- (void) threadsListDidChange : (NSNotification *) notification;

// CMRFavoritesManagerDidLinkFavoritesNotification
- (void) favoritesManagerDidLinkFavorites : (NSNotification *) notification;
// CMRFavoritesManagerDidRemoveFavoritesNotification
- (void) favoritesManagerDidRemoveFavorites : (NSNotification *) notification;
@end


//:CMRBrowser-ViewAccessor.m
@interface CMRBrowser(ViewAccessor)
/* Accessor for m_splitView */
- (CMRSplitView *) splitView;
/* Accessor for m_threadsListTable */
- (ThreadsListTable *) threadsListTable;
/* Accessor for m_threadsListScrollView */
- (CMXScrollView *) threadsListScrollView;
/* Accessor for m_threadsFilterPopUp */
- (NSPopUpButton *) threadsFilterPopUp;
/* Accessor for m_boardListTable */
- (NSOutlineView *) boardListTable;
- (id) brdListActMenuBtn;
- (RBSplitSubview *) boardListSubView;
- (id) splitterBtn;

- (NSMenu *) listContextualMenu;
- (NSMenu *) drawerContextualMenu;

- (NSSearchField *) searchField;
- (CMRAccessorySheetController *) listSorterSheetController;
- (AddBoardSheetController *) addBoardSheetController;
@end

@interface CMRBrowser(UIComponents)
- (void) setupLoadedComponents;
@end

@interface CMRBrowser(TableColumnInitializer)
- (NSArray *) defaultColumnsArray;
- (id) defaultColumnsArrayPropertyListRep;
- (NSTableColumn *) defaultTableColumnWithIdentifier : (NSString *) anIdentifer;
- (NSTableColumn *) tableColumnWithPropertyListRep : (id) rep;

- (void) createDefaultTableColumnsWithTableView : (NSTableView *) tableView;
- (void) setupTableColumn : (NSTableColumn *) column;
@end


@interface CMRBrowser(ViewInitializer)
- (void) updateDefaultsWithTableView : (NSTableView *) tbview;
- (void) setupBoardListOutlineView : (NSOutlineView *) outlineView;

- (void) setupSplitView;
- (void) setupThreadsListTable;
- (void) setupThreadsListScrollView;
- (void) setupThreadsFilterPopUp;

- (void) setupBoardListTable;

- (void) setupFrameAutosaveName;
@end
