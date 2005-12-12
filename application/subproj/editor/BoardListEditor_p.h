#import "BoardListEditor.h"

//#import "BoardList.h"
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

#import "UTILKit.h"


@interface BoardListEditor(ViewAccessor)
- (NSWindow *) boardEditSheet;
//- (NSTextFieldCell *) boardEditInfoTextCell;
- (NSTextFieldCell *) boardEditNameCell;
- (NSTextFieldCell *) boardEditURLCell;
- (NSWindow *) categoryEditSheet;
- (NSTextField *) categoryEditNameField;
- (NSWindow *) boardAddSheet;
- (NSTextFieldCell *) boardAddNameCell;
- (NSTextFieldCell *) boardAddURLCell;
- (NSOutlineView *) defaultListTable;
- (NSOutlineView *) userListTable;
- (NSButton *) editButton;
- (NSButton *) deleteButton;

- (void) setupUIComponents;
- (void) setupListTables;
- (void) setupButtons;
@end

