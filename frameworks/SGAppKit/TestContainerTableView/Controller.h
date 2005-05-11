/* Controller */

#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>
#import "ItemController.h"

@interface Controller : NSObject
{
	IBOutlet SGContainerTableView	*m_tableView;
	IBOutlet NSWindow				*m_window;
	
	NSMutableArray					*m_items;
}
- (IBAction) addItem : (id) sender;
- (IBAction) removeItem : (id) sender;

/* Accessor for m_items */
- (NSMutableArray *) items;
- (void) setItems : (NSMutableArray *) anItems;
/* Accessor for m_tableView */
- (SGContainerTableView *) tableView;
/* Accessor for m_window */
- (NSWindow *) window;
@end
