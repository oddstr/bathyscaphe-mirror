//
//  CMRBrowser.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/08/21.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "RBSplitView.h"
#import "CMRThreadViewer.h"

@class BSKFSplitView;
@class ThreadsListTable;
@class BSDBThreadList;
@class AddBoardSheetController;
@class EditBoardSheetController;
@class BoardListItem;

typedef enum _BSThreadDeletionType {
	BSThreadAtBrowserDeletionType	= 0,
	BSThreadAtFavoritesDeletionType = 1,
	BSThreadAtViewerDeletionType	= 2	
} BSThreadDeletionType;

@interface CMRBrowser : CMRThreadViewer {
	IBOutlet RBSplitSubview		*m_boardListSubView;

	IBOutlet BSKFSplitView		*m_splitView;
	
	IBOutlet ThreadsListTable	*m_threadsListTable;
	
	IBOutlet NSOutlineView		*m_boardListTable;
	IBOutlet id					m_splitterBtn;
	IBOutlet id					m_brdListActMenuBtn;
	
	IBOutlet NSMenu				*m_listContextualMenu;
	IBOutlet NSMenu				*m_drawerContextualMenu;
	
	IBOutlet NSSearchField		*m_searchField;

	IBOutlet NSSegmentedControl *m_viewModeSwitcher;
		
	AddBoardSheetController		*m_addBoardSheetController; // added in Lemonade.
	EditBoardSheetController	*m_editBoardSheetController; // added in MeteorSweeper.

    // note - these can't be connected in IB
    // you'll get, for example, a text view where you meant to get
    // its enclosing scroll view
    id topSubview;
    id bottomSubview;
}
@end


@interface CMRBrowser(Action)
// KeyBinding...
- (IBAction)openSelectedThreads:(id)sender;
- (IBAction)selectThread:(id)sender;
- (IBAction)showSelectedThread:(id)sender;
- (IBAction)reloadThreadsList:(id)sender;
- (IBAction)showOrOpenSelectedThread:(id)sender;

- (void)synchronizeWithSearchField;

- (IBAction)searchThread:(id)sender;
- (IBAction)showSearchThreadPanel:(id)sender;

- (IBAction)collapseOrExpandBoardList:(id)sender;

// make threadsList view to be first responder;
- (IBAction)focus:(id)sender;

- (void)selectRowOfName:(NSString *)boardName forceReload:(BOOL)flag; // Available in SilverGull and later.
- (int)searchRowForItemInDeep:(BoardListItem *)boardItem inView:(NSOutlineView *)olView; // Available in SilverGull and later.
@end


@interface CMRBrowser(BoardListEditor)
- (IBAction)addBoardListItem:(id)sender;
- (IBAction)addSmartItem:(id)sender;
- (IBAction)addCategoryItem:(id)sender;
- (IBAction)editBoardListItem:(id)sender;
- (IBAction)removeBoardListItem:(id)sender;
@end


//:CMRBrowser-List.m
@interface CMRBrowser(List)
- (BSDBThreadList *)currentThreadsList;
- (void)setCurrentThreadsList:(BSDBThreadList *)newList;

- (void)showThreadsListForBoard:(id)board;
- (void)showThreadsListForBoard:(id)board forceReload:(BOOL)force;
- (void)showThreadsListWithBoardName:(NSString *)boardName;

// available in Levantine
- (unsigned)selectRowWithThreadPath:(NSString *)filepath byExtendingSelection:(BOOL)flag scrollToVisible:(BOOL)scroll;
@end

extern NSString *const CMRBrowserDidChangeBoardNotification;
extern NSString *const CMRBrowserThListUpdateDelegateTaskDidFinishNotification; // avaiable in Levantine
