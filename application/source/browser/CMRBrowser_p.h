//:CMRBrowser_p.h/**  *  * @see SGTextAccessoryFieldController.h  *  * @author Takanori Ishikawa  * @author http://www15.big.or.jp/~takanori/  * @version 1.0.0d1 (02/11/08  7:36:04 PM)  *  */#import "CMRBrowser.h"#import "CMRThreadViewer_p.h";#import "CMXPreferences.h"#import "BoardManager.h";#import "BoardList.h"#import "Browser.h"#import "CMRThreadDocument.h"#import "CMRBrowserTemplateKeys.h"#import "CMRBrowserTbDelegate.h";#import "CMRSplitView.h";#import "CMRThreadsList.h";#import "ThreadsListTable.h";#import "CMXScrollView.h";#import "CMXDateFormatter.h";//#import "CMRThreadsListSorter.h";#import "CMRAccessorySheetController.h";#define APP_BROWSER_WINDOW_AUTOSAVE_NAME			@"CocoMonar:Browser Window Autosave"#define APP_BROWSER_SPVIEW_AUTOSAVE_NAME			@"CocoMonar:Browser SplitView Autosave"#define APP_BROWSER_STATUSLINE_IDENTIFIER			@"Browser"#define APP_BROWSER_THREADSLIST_TABLE_AUTOSAVE_NAME	@"CocoMonar:ThreadsListTable Autosave"#define APP_BROWSER_BOARDLIST_OLVIEW_AUTOSAVE_NAME	@"BoardListTable Autosave"#define STATUS_HEADER_IMAGE_NAME					@"Status_header"#define APP_BROWSER_LIST_CHOOSE_COLUMN_IMAGE_NAME	@"chooseColumn"#define STATUS_HEADER_IMAGE_WIDTH					18.0f// 「掲示板を表示」項目の画像#define kOpenBoardImageName					@"openBoard"#define kOpenBoardSheetImageName			@"openBoardSheet"#define kCloseBoardImageName				@"closeBoard"// 前回最後に開いていた掲示板を開くよう指示する通知#define kSelectLastBBSNotification @"kSelectLastBBSNotification"#define APP_DRAWER_FIX_BAD_BEHAVIOR_10_1_X_TIME_INTERVAL	1.0#define kEditDrawerTitleKey					@"Edit Title"#define kAddCategoryTitleKey				@"Add Category Title"#define kEditDrawerItemMsgForAdditionKey			@"Add Category Msg"#define kEditDrawerItemMsgForBoardKey			@"Edit Board Msg"#define kEditDrawerItemTitleForBoardKey			@"PleaseInputURL"#define kEditDrawerItemMsgForCategoryKey			@"Edit Category Msg"#define kEditDrawerItemTitleForCategoryKey			@"PleaseInputName"#define kRemoveDrawerItemTitleKey			@"Browser Del Drawer Item Title"#define kRemoveDrawerItemMsgKey				@"Browser Del Drawer Item Message"@interface CMRBrowser(CMRLocalizableStringsOwner)- (NSString *) localizedShowBoardSheetString;- (NSString *) localizedOpenBoardString;- (NSString *) localizedCloseBoardString;@end//:CMRBrowser-List.m@interface CMRBrowser(List)- (void) updateStatusLineBoardInfo;- (void) changeThreadsFilteringMask : (int) aMask;- (CMRThreadsList *) currentThreadsList;- (void) setCurrentThreadsList : (CMRThreadsList *) newList;- (void) showThreadsListForBoard : (NSDictionary *) board;- (void) showThreadsListWithBBSSignature : (CMRBBSSignature *) aSignature;@end@interface CMRBrowser(Table)- (void) changeHighLightedTableColumnTo : (NSString *) columnIdentifier_ isAscending : (BOOL) isAscending;/* 選択できなければ -1 */- (unsigned) selectCurrentThreadWithMask : (int) mask;- (unsigned) selectRowWithCurrentThread;- (unsigned) selectRowWithThreadPath : (NSString *) filepath		        byExtendingSelection : (BOOL      ) flag;@end@interface CMRBrowser(ActionSupport)- (BOOL) shouldOpenBoardListInSheet;@end//:CMRBrowser-Delegate.m@interface CMRBrowser(NotificationPrivate)- (void) boardManagerUserListDidChange : (NSNotification *) notification;- (void) threadsListDidFinishUpdate : (NSNotification *) notification;- (void) threadsListDidChange : (NSNotification *) notification;// CMRFavoritesManagerDidLinkFavoritesNotification//- (void) favoritesManagerDidLinkFavorites : (NSNotification *) notification;// CMRFavoritesManagerDidRemoveFavoritesNotification//- (void) favoritesManagerDidRemoveFavorites : (NSNotification *) notification;@end//:CMRBrowser-ViewAccessor.m@interface CMRBrowser(ViewAccessor)/* Accessor for m_splitView */- (CMRSplitView *) splitView;/* Accessor for m_threadsListTable */- (ThreadsListTable *) threadsListTable;/* Accessor for m_threadsListScrollView */- (CMXScrollView *) threadsListScrollView;/* Accessor for m_threadsFilterPopUp */- (NSPopUpButton *) threadsFilterPopUp;/* Accessor for m_boardDrawer */- (NSDrawer *) boardDrawer;/* Accessor for m_boardListTable */- (NSOutlineView *) boardListTable;//- (NSButton *) brdListActionBtn;- (NSButton *) brdListActMenuBtn;- (NSMenu *) listContextualMenu;- (NSMenu *) drawerContextualMenu;- (NSWindow *) drawerItemEditSheet;- (NSTextField *) dItemEditSheetMsgField;- (NSTextField *) dItemEditSheetLabelField;- (NSTextField *) dItemEditSheetInputField;- (NSTextField *) dItemEditSheetTitleField;- (NSWindow *) drawerItemAddSheet;- (NSTextFieldCell *) dItemAddSheetNameField;- (NSTextFieldCell *) dItemAddSheetURLField;//- (NSView *) searchToolbarItem;- (id) searchToolbarItem;//- (NSPopUpButton *) searchPopUp;- (NSTextField *) searchTextField;- (CMRNSSearchField *) listSorter;- (CMRNSSearchField *) listSorterSub;- (CMRAccessorySheetController *) boardListSheetController;- (CMRAccessorySheetController *) listSorterSheetController;@end@interface CMRBrowser(UIComponents)- (void) setupLoadedComponents;- (BOOL) ifSearchFieldIsInToolbar;@end@interface CMRBrowser(TableColumnInitializer)- (NSArray *) defaultColumnsArray;- (id) defaultColumnsArrayPropertyListRep;- (NSTableColumn *) defaultTableColumnWithIdentifier : (NSString *) anIdentifer;- (NSTableColumn *) tableColumnWithPropertyListRep : (id) rep;- (void) createDefaultTableColumnsWithTableView : (NSTableView *) tableView;- (void) setupTableColumn : (NSTableColumn *) column;@end@interface CMRBrowser(ViewInitializer)- (void) updateDefaultsWithTableView : (NSTableView *) tbview;- (void) setupSplitView;- (void) setupThreadsListTable;- (void) setupThreadsListScrollView;- (void) setupThreadsFilterPopUp;- (void) setupChooseColumnPopUp;- (void) setupBoardDrawer;- (void) setupBoardDrawerState : (id) sender;- (void) setupBoardListTable;- (void) setupFrameAutosaveName;- (void) setUpBoardListToolButtons;@end