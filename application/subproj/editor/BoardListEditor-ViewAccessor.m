/**
 * $Id: BoardListEditor-ViewAccessor.m,v 1.1 2005/05/11 17:51:09 tsawada2 Exp $
 * 
 * BoardListEditor-ViewAccessor.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "BoardListEditor_p.h"



@implementation BoardListEditor(ViewAccessor)
- (NSWindow *) boardEditSheet { return _boardEditSheet; }
- (NSWindow *) categoryEditSheet { return _categoryEditSheet; }
- (NSWindow *) boardAddSheet { return _boardAddSheet; }

//- (NSTextFieldCell *) boardEditInfoTextCell { return _boardEditInfoTextCell; }
- (NSTextFieldCell *) boardEditNameCell { return _boardEditNameCell; }
- (NSTextFieldCell *) boardEditURLCell { return _boardEditURLCell; }
- (NSTextField *) categoryEditNameField { return _categoryEditNameField; }
- (NSTextFieldCell *) boardAddNameCell { return _boardAddNameCell; }
- (NSTextFieldCell *) boardAddURLCell { return _boardAddURLCell; }
- (NSOutlineView *) defaultListTable { return _defaultListTable; }
- (NSOutlineView *) userListTable { return _userListTable; }
- (NSButton *) editButton { return _editButton; }
- (NSButton *) deleteButton { return _deleteButton; }
- (NSButton *) launchButton { return _launchButton; }

- (void) setupUIComponents
{
	[self setupListTables];
	[self setupButtons];
}

- (void) setupListTables
{
	[[NSNotificationCenter defaultCenter]
		addObserver : self
		selector : @selector(boardListDidChange:)
		name : CMRBBSListDidChangeNotification
		object : [self userList]];
	[[NSNotificationCenter defaultCenter]
		addObserver : self
		selector : @selector(boardListDidChange:)
		name : CMRBBSListDidChangeNotification
		object : [self defaultList]];
	
	[[self userListTable] setDataSource : [self userList]];
	[[self userListTable] setDelegate : self]; //2004-05-17 re-added
	[[self defaultListTable] setDataSource : [self defaultList]];

	// D & D
	[[self userListTable] registerForDraggedTypes : 
		[NSArray arrayWithObjects : 
						CMRBBSListItemsPboardType,
						NSFilenamesPboardType,
						nil]];
}
- (void) setupButtons
{
	BOOL	enable_;
	
	enable_ = ([[self userListTable] numberOfSelectedRows] > 0);
	if(enable_){
		NSDictionary *item_;
		
		item_ = [[self userListTable] itemAtRow : [[self userListTable] selectedRow]];
		if([[[self userList] class] isFavorites : item_]){
			enable_ = NO;
		}
	}
	[[self editButton] setEnabled : enable_];
	[[self deleteButton] setEnabled : enable_];
}

- (void) outlineViewSelectionDidChange : (NSNotification *) notification
{
    UTILAssertNotificationName(
        notification,
        NSOutlineViewSelectionDidChangeNotification);
    
    if ([[notification object] isEqual : [self userListTable]])
        [self setupButtons];
}
- (void) boardListDidChange : (NSNotification *) notification
{
    UTILAssertNotificationName(
        notification,
        CMRBBSListDidChangeNotification);
    
    if ([notification object] == [self userList])
        [[self userListTable] reloadData];
    else if ([notification object] == [self defaultList])
        [[self defaultListTable] reloadData];
}

@end
