//:CMRReplyDefaultsController.h
/**
  *
  * 
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Mon Sep 16 2002
  *
  */
#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"


@interface CMRReplyDefaultsController : PreferencesController
{
	IBOutlet NSTextField *m_defaultNameField;
	IBOutlet NSTextField *m_defaultMailField;
	
	IBOutlet NSTableView *m_nameListTable;
	IBOutlet NSButton *m_addRowBtn;
	IBOutlet NSButton *m_removeRowBtn;
	
	NSMutableArray *_nameList;
}
@end



@interface CMRReplyDefaultsController(Action)
- (IBAction) changeDefaultName : (id) sender;
- (IBAction) changeDefaultMail : (id) sender;

- (IBAction) addRow : (id) sender;
- (IBAction) removeRow : (id) sender;
@end
