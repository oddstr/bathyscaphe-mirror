//:CMRReplyDefaultsController.m
#import "CMRReplyDefaultsController_p.h"
#import "PreferencePanes_Prefix.h"


#define kLabelKey		@"Reply Label"
#define kToolTipKey		@"Reply ToolTip"
#define kImageName		@"Reply"



@implementation CMRReplyDefaultsController
- (NSString *) mainNibName
{
	return REPLYDEFAULTSCONTROLLER_LOAD_NIB_NAME;
}
@end



@implementation CMRReplyDefaultsController(Action)
- (IBAction) changeDefaultName : (id) sender
{
	UTILAssertKindOfClass(sender, NSTextField);
	[[self preferences] setDefaultReplyName : [sender stringValue]];
}
- (IBAction) changeDefaultMail : (id) sender
{
	UTILAssertKindOfClass(sender, NSTextField);
	[[self preferences] setDefaultReplyMailAddress : [sender stringValue]];
}

- (IBAction) addRow : (id) sender
{
	if (nil == _nameList){
		_nameList = [[NSMutableArray alloc] init];
	}
	[_nameList addObject : @""];
	[[self nameListTable] reloadData];
	int rowIndex = ([_nameList count]-1);
	[[self nameListTable] selectRow : rowIndex byExtendingSelection: NO]; //deprecated on 10.3
	[[self nameListTable] editColumn: 0 row:rowIndex withEvent:nil select:YES];//追加された項目を編集可能状態にする
}
- (IBAction) removeRow : (id) sender
{
	int row = [[self nameListTable] selectedRow];
	if (row != -1){
		[_nameList removeObjectAtIndex : row];
		[[self nameListTable] reloadData];
		
		[[self preferences] setDefaultKoteHanList : _nameList];
	} else {
		NSBeep();
	}
}
@end



@implementation CMRReplyDefaultsController(ViewAccessor)
- (NSTextField *) defaultNameField
{
	return m_defaultNameField;
}
- (NSTextField *) defaultMailField
{
	return m_defaultMailField;
}
- (NSTableView *) nameListTable
{
	return m_nameListTable;
}
- (NSButton *) removeRowBtn
{
	return m_removeRowBtn;
}


- (void) setupUIComponents
{
	[self updateUIComponents];
}
- (void) updateUIComponents
{
	NSString		*value_;
	
	if(nil == _contentView || nil == [self preferences]) return;
	
	_nameList = [[[self preferences] defaultKoteHanList] mutableCopy];
	//if(nil == _nameList) NSLog(@"No KoteHan List Found, so we cannot mutablecopy...");
	
	value_ = [[self preferences] defaultReplyName];
	[[self defaultNameField] setStringValue : value_];
	value_ = [[self preferences] defaultReplyMailAddress];
	[[self defaultMailField] setStringValue : value_];
	
	[[self nameListTable] reloadData];
}


//TableView Data Source
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_nameList count];
}

- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(int)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"name"]) {
		return [_nameList objectAtIndex:rowIndex];
    }
	return nil;
}

- (void)tableView:(NSTableView *)aTableView
        setObjectValue:(id)anObject
		forTableColumn:(NSTableColumn *)aTableColumn
        row:(int)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"name"]) {
		// 内容が空でないときのみそれをDefaultKoteHanListに追加／更新する。
		if(![anObject isEqualToString:@""]){
			//NSLog(@"Not Empty, so we replaceObjectAtIndex...");
			[_nameList replaceObjectAtIndex:rowIndex withObject:anObject];

			[[self preferences] setDefaultKoteHanList : _nameList];
		}
    }
}


//TableView Delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int row = [[self nameListTable] selectedRow];
	if (row == -1){
		[[self removeRowBtn] setEnabled : NO];
	} else {
		[[self removeRowBtn] setEnabled : YES];
	}
}

@end



@implementation CMRReplyDefaultsController(Toolbar)
- (NSString *) identifier
{
	return PPReplyDefaultIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(@"Help_Reply");
}
- (NSString *) label
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) paletteLabel
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) toolTip
{
	return PPLocalizedString(kToolTipKey);
}
- (NSString *) imageName
{
	return kImageName;
}
@end

