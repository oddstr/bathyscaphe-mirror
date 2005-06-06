//:CMRBrowser.h
/**
  *
  * 
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Sun Sep 01 2002
  *
  */
#import <Cocoa/Cocoa.h>
#import "CMRThreadViewer.h"
#import "CMRNSSearchField.h"

@class CMRSplitView;
@class ThreadsListTable;
@class CMRThreadsList;
@class CMRAccessorySheetController;


@interface CMRBrowser : CMRThreadViewer
{
	IBOutlet CMRSplitView		*m_splitView;
	
	IBOutlet ThreadsListTable	*m_threadsListTable;
	IBOutlet NSPopUpButton		*m_threadsFilterPopUp;
	
	IBOutlet NSDrawer			*m_boardDrawer;
	IBOutlet NSOutlineView		*m_boardListTable;
	IBOutlet NSButton			*m_brdListActMenuBtn;	
	
	IBOutlet NSMenu				*m_listContextualMenu;
	IBOutlet NSMenu				*m_drawerContextualMenu;

	// Direct Editing BoardList
	IBOutlet NSWindow			*m_drawerItemEditSheet;
	IBOutlet NSTextField		*m_dItemEditSheetTitleField;
	IBOutlet NSTextField		*m_dItemEditSheetMsgField;
	IBOutlet NSTextField		*m_dItemEditSheetLabelField;
	IBOutlet NSTextField		*m_dItemEditSheetInputField;

	IBOutlet NSWindow			*m_drawerItemAddSheet;
	IBOutlet NSTextFieldCell	*m_dItemAddNameField;
	IBOutlet NSTextFieldCell	*m_dItemAddURLField;
	
	NSString					*_filterString;

	CMRNSSearchField			*m_listSorter;
	CMRNSSearchField			*m_listSorterSub;
	
	CMRAccessorySheetController	*m_boardListSheetController;
	CMRAccessorySheetController	*m_listSorterSheetController;
    // note - these can't be connected in IB
    // you'll get, for example, a text view where you meant to get
    // its enclosing scroll view
    id topSubview;
    id bottomSubview;

	
    // Shrinking Drawer
    BOOL                        _needToRestoreWindowSize;
	NSRect						_oldSize;
	NSRect						_oldTListSize;
}
@end



@interface CMRBrowser(Action)
// KeyBinding...
- (IBAction) openSelectedThreads : (id) sender;
- (IBAction) selectThread : (id) sender;
- (IBAction) showSelectedThread : (id) sender;
- (IBAction) reloadThreadsList : (id) sender;
- (IBAction) showOrOpenSelectedThread : (id) sender;

- (BOOL) showsSearchResult;
- (void) clearSearchFilter;

- (void) synchronizeWithSearchField;
- (void) searchThreadWithString : (NSString *) aString;

- (IBAction) selectFilteringMask : (id) sender;
- (IBAction) searchToolbarPopupChanged : (id) sender;
- (IBAction) searchThread : (id) sender;
- (IBAction) showSearchThreadPanel : (id) sender;

- (BOOL) shouldOpenBoardListInSheet;
- (IBAction) beginBoardListSheet : (id) sender;
- (IBAction) toggleBoardDrawer : (id) sender;

- (IBAction) changeBrowserArrangement : (id) sender;

- (IBAction) addDrawerItem : (id) sender;
- (IBAction) addCategoryItem : (id) sender;
- (IBAction) editDrawerItem : (id) sender;
- (IBAction) removeDrawerItem : (id) sender;
- (IBAction) endEditSheet : (id) sender;

// make threadsList view to be first responder;
- (IBAction) focus : (id) sender;

- (void) selectRowWhoseNameIs : (NSString *) brdname_;
@end



extern NSString *const CMRBrowserDidChangeBoardNotification;
