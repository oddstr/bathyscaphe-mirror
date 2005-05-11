#import "Controller.h"

#define ITEM_COUNT		5

@implementation Controller
- (void) awakeFromNib
{
	int i;
	
	
	for(i = 0; i < ITEM_COUNT; i++){
		ItemController	*itemController_;
		
		itemController_ = [[ItemController alloc] initWithIndex : i];
		[[self items] addObject : itemController_];
		[itemController_ release];
	}
	[[self tableView] setDataSource : self];
}

- (IBAction) addItem : (id) sender
{
	ItemController	*itemController_;
	
	itemController_ =
		[[ItemController alloc] initWithIndex : [[self items] count]];
	[[self items] addObject : itemController_];
	[itemController_ release];
	[[self tableView] reloadData];
	
	[[self tableView] scrollRowToVisible : [[self items] count] -1];
}
- (IBAction) removeItem : (id) sender
{
	unsigned	cnt;
	
	cnt = [[self items] count];
	if(0 == cnt) return;
	
	[[self items] removeObjectAtIndex : (cnt/2)];
	[[self tableView] reloadData];
}

/* Accessor for m_items */
- (NSMutableArray *) items
{
	if(nil == m_items)
		m_items = [[NSMutableArray alloc] init];
	return m_items;
}
- (void) setItems : (NSMutableArray *) anItems
{
	id tmp;
	
	tmp = m_items;
	m_items = [anItems retain];
	[tmp release];
}
/* Accessor for m_tableView */
- (SGContainerTableView *) tableView
{
	return m_tableView;
}

/* Accessor for m_window */
- (NSWindow *) window
{
	return m_window;
}
@end



@implementation Controller(SGContainerTableViewDataSource)
- (int) numberOfRowsInContainerTableView : (SGContainerTableView *) tbView
{
	return [[self items] count];
}
- (SGContainerView *) containerTableView : (SGContainerTableView *) tbView
                      containerViewAtRow : (int                   ) rowIndex
{
	return [[[self items] objectAtIndex : rowIndex] itemView];
}
@end