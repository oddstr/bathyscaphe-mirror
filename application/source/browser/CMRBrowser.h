/**
  * $Id: CMRBrowser.h,v 1.26 2007/04/15 08:46:10 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
  */
#import <Cocoa/Cocoa.h>
#import "RBSplitView.h"
#import "CMRThreadViewer.h"

@class BSKFSplitView;
@class ThreadsListTable;
@class CMRThreadsList, BSDBThreadList;
@class CMRAccessorySheetController;
@class AddBoardSheetController, EditBoardSheetController;
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
	
	// PrincessBride Addition
	IBOutlet NSSearchField		*m_searchField;
	
	CMRAccessorySheetController	*m_listSorterSheetController;
	
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

- (void) clearSearchFilter;
- (void) synchronizeWithSearchField;
- (BOOL) ifSearchFieldIsInToolbar;

- (IBAction) searchThread : (id) sender;
- (IBAction) showSearchThreadPanel : (id) sender;

- (IBAction) changeBrowserArrangement : (id) sender;
- (IBAction) collapseOrExpandBoardList : (id) sender;

// make threadsList view to be first responder;
- (IBAction) focus : (id) sender;

- (void) selectRowWhoseNameIs : (NSString *) brdname_;
- (int) searchRowForItemInDeep: (BoardListItem *) boardItem fromSource: (id) source forView: (NSOutlineView *) olView;
@end

@interface CMRBrowser(BoardListEditor)
- (IBAction) addDrawerItem : (id) sender;
- (IBAction) addCategoryItem : (id) sender;
- (IBAction) editDrawerItem : (id) sender;
- (IBAction) removeDrawerItem : (id) sender;
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
