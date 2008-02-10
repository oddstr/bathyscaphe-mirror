/**
  * $Id: CMRBrowser.h,v 1.33 2008/02/10 14:24:51 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
  */
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

@interface CMRBrowser : CMRThreadViewer
{
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
- (IBAction) openSelectedThreads : (id) sender;
- (IBAction) selectThread : (id) sender;
- (IBAction) showSelectedThread : (id) sender;
- (IBAction) reloadThreadsList : (id) sender;
- (IBAction) showOrOpenSelectedThread : (id) sender;

- (IBAction) selectFilteringMask : (id) sender;

- (void) synchronizeWithSearchField;

- (IBAction) searchThread : (id) sender;
- (IBAction) showSearchThreadPanel : (id) sender;

//- (IBAction) changeBrowserArrangement : (id) sender;
- (IBAction) collapseOrExpandBoardList : (id) sender;

// make threadsList view to be first responder;
- (IBAction) focus : (id) sender;

- (void) selectRowWhoseNameIs : (NSString *) brdname_; // Deprecated. Use -selectRowOfName:forceReload: instead.
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
- (void) changeThreadsFilteringMask : (int) aMask;

- (BSDBThreadList *) currentThreadsList;
- (void) setCurrentThreadsList : (BSDBThreadList *) newList;

- (void) showThreadsListForBoard : (id) board;
- (void) showThreadsListForBoard : (id) board forceReload: (BOOL) force;
- (void) showThreadsListWithBoardName : (NSString *) boardName;

// available in Levantine
- (unsigned) selectRowWithThreadPath : (NSString *) filepath
                byExtendingSelection : (BOOL ) flag
					 scrollToVisible : (BOOL ) scroll;
@end

extern NSString *const CMRBrowserDidChangeBoardNotification;
extern NSString *const CMRBrowserThListUpdateDelegateTaskDidFinishNotification; // avaiable in Levantine
