/**
  * $Id: BoardListEditor.h,v 1.1.1.1 2005/05/11 17:51:09 tsawada2 Exp $
  * 
  * BoardListEditor.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */


#import <Cocoa/Cocoa.h>
@class BoardList;



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
	
	BoardList					*_userList;
	BoardList					*_defaultList;
}
- (id) initWithDefaultList : (BoardList *) defaultList 
				  userList : (BoardList *) userList;

- (BoardList *) defaultList;
- (BoardList *) userList;
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
//- (IBAction) changeCreateView : (id) sender;
//- (IBAction) removeAllFromUserList : (id) sender;
//- (IBAction) resetUserList : (id) sender;
@end
