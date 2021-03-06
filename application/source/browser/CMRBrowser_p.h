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

#import "CMRThreadsList.h"

#import "BSDBThreadList.h"

#import "ThreadsListTable.h"

#import <SGAppKit/BSBoardListView.h>

#define APP_BROWSER_WINDOW_AUTOSAVE_NAME			@"CocoMonar:Browser Window Autosave"
#define APP_BROWSER_SPVIEW_AUTOSAVE_NAME			@"CocoMonar:Browser SplitView Autosave"
#define APP_BROWSER_STATUSLINE_IDENTIFIER			@"Browser"
#define APP_BROWSER_THREADSLIST_TABLE_AUTOSAVE_NAME	@"CocoMonar:ThreadsListTable Autosave"
#define APP_BROWSER_BOARDLIST_OLVIEW_AUTOSAVE_NAME	@"BoardListTable Autosave"
#define APP_BROWSER_BL_SPLITVUEW_AUTOSAVE_NAME		@"boardsList"

#define STATUS_HEADER_IMAGE_NAME					@"Status_header"
#define STATUS_HEADER_IMAGE_WIDTH					18.0f

// 前回最後に開いていた掲示板を開くよう指示する通知
#define kSelectLastBBSNotification @"kSelectLastBBSNotification"

// PropertyList
#define kThreadsListReloadDelayKey			@"Browser - DelayForAutoReloadAtWaking"
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
#define kBrowserMenuItemAlwaysEnabledTag	777

#define kBLEditItemViaMenubarItemTag		751
#define kBLEditItemViaContMenuItemTag		701
#define kBLDeleteItemViaMenubarItemTag		752
#define kBLDeleteItemViaContMenuItemTag		702
// Reserved value -- currently unused.
//#define kBLOpenBoardItemViaContMenuItemTag	703
//#define kBLShowInspectorViaContMenuItemTag	704

#define kBLContMenuItemTagMin		700
#define kBLContMenuItemTagMax		705


@interface CMRBrowser(Table)
/* 選択できなければ -1 */
- (unsigned)selectCurrentThreadWithMask:(int)mask;
- (unsigned)selectRowWithCurrentThread;
- (unsigned)selectRowWithThreadPath:(NSString *)filepath byExtendingSelection:(BOOL)flag;
@end

//:CMRBrowser-Delegate.m
@interface CMRBrowser(NotificationPrivate)
- (void)boardManagerUserListDidChange:(NSNotification *)notification;
- (void)threadsListDidChange:(NSNotification *)notification;
@end


@interface CMRBrowser(ViewAccessor)
- (BSKFSplitView *)splitView;

- (ThreadsListTable *)threadsListTable;

- (NSOutlineView *)boardListTable;
- (id)brdListActMenuBtn;
- (RBSplitSubview *)boardListSubView;
- (id)splitterBtn;

- (NSMenu *)listContextualMenu;
- (NSMenu *)drawerContextualMenu;

- (NSSearchField *)searchField;
- (AddBoardSheetController *)addBoardSheetController;
- (EditBoardSheetController *)editBoardSheetController;

- (NSSegmentedControl *)viewModeSwitcher;
@end


@interface CMRBrowser(UIComponents)
- (void)setupLoadedComponents;
@end

@interface CMRBrowser(Validation)
- (BOOL)isIndexFieldFirstResponder;
@end

@interface CMRBrowser(TableColumnInitializer)
- (NSTableColumn *)tableColumnWithPropertyListRep:(id)rep;

- (void)createDefaultTableColumnsWithTableView:(NSTableView *)tableView;
- (void)setupTableColumn:(NSTableColumn *)column;
@end


@interface CMRBrowser(ViewInitializer)
- (void)updateThreadsListTableWithNeedingDisplay:(BOOL)display;
- (void)setupThreadsListTable;
- (void)updateTableColumnsMenu;

- (void)setupSplitView;

- (void)updateBoardListViewWithNeedingDisplay:(BOOL)display;
- (void)setupBoardListTable;

- (void)setupFrameAutosaveName;
@end
