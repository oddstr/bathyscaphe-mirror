//
//  AddBoardSheetController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/12.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BoardList;

@interface AddBoardSheetController : NSWindowController {
	IBOutlet NSOutlineView	*m_defaultListOLView;
	IBOutlet NSSearchField	*m_searchField;

	IBOutlet NSTextFieldCell	*m_brdNameField;
	IBOutlet NSTextFieldCell	*m_brdURLField;

	IBOutlet NSButton		*m_OKButton;
	IBOutlet NSButton		*m_cancelButton;
	IBOutlet NSButton		*m_helpButton;
}

- (NSOutlineView *) defaultListOLView;
- (NSSearchField *) searchField;

- (NSTextFieldCell *) brdNameField;
- (NSTextFieldCell *) brdURLField;

- (NSButton *) OKButton;
- (NSButton *) cancelButton;
- (NSButton *) helpButton;

//- (BoardList *) defaultList;
//- (BoardList *) userList;

- (IBAction) searchBoards : (id) sender; 
- (IBAction) openHelp : (id) sender;
- (IBAction) close : (id) sender;
- (void) beginSheetModalForWindow : (NSWindow *) docWindow
					modalDelegate : (id        ) modalDelegate
					  contextInfo : (id		   ) info;
@end
