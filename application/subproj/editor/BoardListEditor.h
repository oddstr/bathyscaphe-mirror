/**
  * $Id: BoardListEditor.h,v 1.2.4.1 2005/12/12 15:28:28 masakih Exp $
  * 
  * BoardListEditor.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */


#import <Cocoa/Cocoa.h>
@class SmartBoardList;



/*!
 * @header     BoardListEditor
 * @discussion 
 *
 * Editor for BoardList
 */
@interface BoardListEditor : NSWindowController
{
	@private
	IBOutlet NSWindow			*_boardEditSheet;
	//IBOutlet NSTextFieldCell	*_boardEditInfoTextCell;
	IBOutlet NSTextFieldCell	*_boardEditNameCell;
	IBOutlet NSTextFieldCell	*_boardEditURLCell;

	IBOutlet NSWindow			*_categoryEditSheet;
	IBOutlet NSTextField		*_categoryEditNameField;

	IBOutlet NSWindow			*_boardAddSheet;
	IBOutlet NSTextFieldCell	*_boardAddNameCell;
	IBOutlet NSTextFieldCell	*_boardAddURLCell;

	IBOutlet NSOutlineView		*_defaultListTable;
	IBOutlet NSOutlineView		*_userListTable;
	
	IBOutlet NSButton			*_editButton;
	IBOutlet NSButton			*_deleteButton;
	IBOutlet NSButton			*_launchButton;
	IBOutlet NSButton			*_helpButton;
	
	SmartBoardList					*_userList;
	SmartBoardList					*_defaultList;
}
- (id) initWithDefaultList : (SmartBoardList *) defaultList 
				  userList : (SmartBoardList *) userList;

- (SmartBoardList *) defaultList;
- (SmartBoardList *) userList;
- (NSArray *) defaultListWithContentsOfFile : (NSString *) thePath;


- (IBAction) reloadDefaultList : (id) sender;
- (IBAction) launchBW : (id) sender;

- (IBAction) addToUserList : (id) sender;
- (IBAction) moveItem : (id) sender;

- (IBAction) createItem : (id) sender;
- (IBAction) createGroup : (id) sender;
- (IBAction) editUserList : (id) sender;
- (IBAction) removeFromUserList : (id) sender;
- (IBAction) endEditSheet : (id) sender;
- (IBAction) openHelp : (id) sender;
//- (IBAction) removeAllFromUserList : (id) sender;
//- (IBAction) resetUserList : (id) sender;
@end
