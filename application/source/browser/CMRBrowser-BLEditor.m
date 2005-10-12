// CMRBrowser-BLEditor.m
//
// CMRBrowser-Action.m, CMRBrowser-ViewAccessor.m から分割
//
// Created on 05/10/11.
#import "CMRBrowser_p.h"
#import "AddBoardSheetController.h"

@implementation CMRBrowser(BoardListEditor)
#pragma mark Accessors

- (NSWindow *) drawerItemEditSheet
{
	return m_drawerItemEditSheet;
}
- (NSTextField *) dItemEditSheetMsgField
{
	return m_dItemEditSheetMsgField;
}
- (NSTextField *) dItemEditSheetLabelField
{
	return m_dItemEditSheetLabelField;
}
- (NSTextField *) dItemEditSheetInputField
{
	return m_dItemEditSheetInputField;
}
- (NSTextField *) dItemEditSheetTitleField
{
	return m_dItemEditSheetTitleField;
}

#pragma mark IBActions and private methods

- (IBAction) addDrawerItem : (id) sender
{
	[[self addBoardSheetController] beginSheetModalForWindow : [self window]
											   modalDelegate : self
												 contextInfo : nil];
}

- (void) controller : (AddBoardSheetController *) aController
		sheetDidEnd : (NSWindow					 *) sheet
		contextInfo : (id						  ) info;
{
	// Currently, we have nothing to do here.
}


- (IBAction) addCategoryItem : (id) sender
{
	[[self dItemEditSheetTitleField] setStringValue : [self localizedString : kAddCategoryTitleKey]];
	[[self dItemEditSheetMsgField]   setStringValue : [self localizedString : kEditDrawerItemMsgForAdditionKey]];
	[[self dItemEditSheetLabelField] setStringValue : [self localizedString : kEditDrawerItemTitleForCategoryKey]];
	[[self dItemEditSheetInputField] setStringValue : @""];
	
	[NSApp beginSheet : [self drawerItemEditSheet]
	   modalForWindow : [self window]
		modalDelegate : self
	   didEndSelector : @selector(_drawerAddCategorySheetDidEnd:returnCode:contextInfo:)
		  contextInfo : nil];
}

- (IBAction) editDrawerItem : (id) sender
{
	int	rowIndex_ = [[self boardListTable] selectedRow];

	NSDictionary	*item_;
	NSString	*name_;

	item_ = [[self boardListTable] itemAtRow : rowIndex_];
	name_ = [item_ objectForKey : BoardPlistNameKey];
	
	[[self dItemEditSheetTitleField] setStringValue : [self localizedString : kEditDrawerTitleKey]];
	if ([BoardList isBoard : item_]) {
		[[self dItemEditSheetMsgField]   setStringValue :
					 [NSString localizedStringWithFormat: [self localizedString : kEditDrawerItemMsgForBoardKey],name_]];
		[[self dItemEditSheetLabelField] setStringValue : [self localizedString : kEditDrawerItemTitleForBoardKey]];
		[[self dItemEditSheetInputField] setStringValue : [item_ objectForKey : BoardPlistURLKey]];

	} else if ([BoardList isCategory : item_]) {
		[[self dItemEditSheetMsgField]   setStringValue :
					 [NSString localizedStringWithFormat: [self localizedString : kEditDrawerItemMsgForCategoryKey],name_]];
		[[self dItemEditSheetLabelField] setStringValue : [self localizedString : kEditDrawerItemTitleForCategoryKey]];
		[[self dItemEditSheetInputField] setStringValue : name_];
	}
	
	[NSApp beginSheet : [self drawerItemEditSheet]
	   modalForWindow : [self window]
		modalDelegate : self
	   didEndSelector : @selector(_drawerItemEditSheetDidEnd:returnCode:contextInfo:)
		  contextInfo : item_];
}

- (IBAction) removeDrawerItem : (id) sender
{
	int	rowIndex_ = [[self boardListTable] selectedRow];
	NSDictionary	*item_;
	item_ = [[self boardListTable] itemAtRow : rowIndex_];
		
	NSBeep();
	NSBeginAlertSheet(
		[self localizedString : kRemoveDrawerItemTitleKey],
		[self localizedString : kDeleteOKBtnKey],
		nil,
		[self localizedString : kDeleteCancelBtnKey],
		[self window],
		self,
		@selector(_drawerItemDeletionSheetDidEnd:returnCode:contextInfo:),
		NULL,
		item_,
		[self localizedString : kRemoveDrawerItemMsgKey],[item_ objectForKey : BoardPlistNameKey]
	);
}

- (IBAction) endEditSheet : (id) sender
{	
	[NSApp endSheet : [sender window]
		 returnCode : ([sender tag] == 1) ? NSOKButton : NSCancelButton];
}

#pragma mark Private (Sheet delegate) methods

- (void) _drawerAddCategorySheetDidEnd : (NSWindow *) sheet
							returnCode : (int       ) returnCode
						   contextInfo : (id) contextInfo
{
	if (NSOKButton == returnCode) {

		NSMutableDictionary *newItem_;
		NSString *name_;
		id userList = [[BoardManager defaultManager] userList];
	
		name_ = [[self dItemEditSheetInputField] stringValue];

		if ([name_ isEqualToString : @""]) {
			NSBeep();
			[sheet close];
			return;
		}

		if ([userList containsItemWithName : name_ ofType : (BoardListFavoritesItem | BoardListCategoryItem)]) {
			[sheet close];	
			NSBeep();
			NSBeginInformationalAlertSheet(
				[self localizedString : @"Same Name Exists"],
				[self localizedString : @"OK"], nil, nil, [self window], self, NULL, NULL, nil,
				[self localizedString : @"So cannot add category."]
			);
			return;
		}

		int rowIndex;
		id selectedItem;
	
		newItem_ = [NSMutableDictionary dictionaryWithObjectsAndKeys :
					name_, BoardPlistNameKey, [NSMutableArray array], BoardPlistContentsKey, nil];
	
		rowIndex = [[self boardListTable] selectedRow];
		selectedItem = (rowIndex >= 0) ? [[self boardListTable] itemAtRow : rowIndex]: nil;
	
		if (nil == selectedItem || [BoardList isFavorites : selectedItem]) {
			[[userList boardItems] addObject : newItem_];
			[userList postBoardListDidChangeNotification];
		} else {
			[userList addItem:newItem_ afterObject:selectedItem];
		}
		[[self boardListTable] reloadData];
	}
	[sheet close];
}

- (void) _drawerItemEditSheetDidEnd : (NSWindow *) sheet
						 returnCode : (int       ) returnCode
						contextInfo : (NSDictionary *) contextInfo
{
	if (NSOKButton == returnCode) {

		NSString *value_;
		value_ = [[self dItemEditSheetInputField] stringValue];

		id userList = [[BoardManager defaultManager] userList];

		NSMutableDictionary *newItem_;
		NSString *oldname_;

		if ([value_ isEqualToString : @""]) {
			NSBeep();
			[sheet close];
			return;
		}
		
		if ([BoardList isBoard : contextInfo]) {

			newItem_ = (NSMutableDictionary *)contextInfo;
			oldname_ = [newItem_ objectForKey : BoardPlistNameKey];
		
			[userList item : newItem_
				   setName : oldname_
					setURL : value_];
						   
		} else if ([BoardList isCategory : contextInfo]) {

			newItem_ = (NSMutableDictionary *)contextInfo;
			oldname_ = [newItem_ objectForKey : BoardPlistNameKey];
		
			if ([userList containsItemWithName : value_ ofType : (BoardListFavoritesItem | BoardListCategoryItem)] && (NO == [oldname_ isEqualToString : value_])) {
				[sheet close];
				NSBeep();
				NSBeginInformationalAlertSheet(
					[self localizedString : @"Same Name Exists"],
					[self localizedString : @"OK"], nil, nil, [self window], self, NULL, NULL, nil,
					[self localizedString : @"So cannot change name."]
				);
				return;
			}
			[userList item : newItem_
				   setName : value_
					setURL : nil];
		}
		[[self boardListTable] reloadData];
	}
	[sheet close];
}

- (void) _drawerItemDeletionSheetDidEnd : (NSWindow *) sheet
							 returnCode : (int       ) returnCode
							contextInfo : (NSDictionary *) contextInfo
{
	switch (returnCode) {
	case NSAlertDefaultReturn:
		[[[BoardManager defaultManager] userList] removeItemWithName : [contextInfo objectForKey : BoardPlistNameKey]
															  ofType : [[BoardList class] typeForItem : contextInfo]];
		[[self boardListTable] reloadData];
		[[self boardListTable] deselectAll : nil];
		break;
	default:
		break;
	}
}
@end