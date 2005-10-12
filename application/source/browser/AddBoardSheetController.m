//
//  AddBoardSheetController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/12.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "AddBoardSheetController.h"

#import "BoardList.h"
#import "BoardManager.h"
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

#import "UTILKit.h"

@implementation AddBoardSheetController
- (id) init
{
	if (self = [super initWithWindowNibName : @"AddBoardSheet"]) {
		;
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[super dealloc];
}

- (void) awakeFromNib
{
	[[NSNotificationCenter defaultCenter]
		addObserver : self
		selector : @selector(boardListDidChange:)
		name : CMRBBSListDidChangeNotification
		object : [[BoardManager defaultManager] defaultList]];

	[[self defaultListOLView] setDataSource : [[BoardManager defaultManager] defaultList]];
	[[self defaultListOLView] setAutoresizesOutlineColumn : NO];
	[[self defaultListOLView] setVerticalMotionCanBeginDrag : NO];
	[[self OKButton] setEnabled : NO];
}

#pragma mark Accessors
- (NSOutlineView *) defaultListOLView
{
	return m_defaultListOLView;
}
- (NSSearchField *) searchField
{
	return m_searchField;
}

- (NSTextFieldCell *) brdNameField
{
	return m_brdNameField;
}
- (NSTextFieldCell *) brdURLField
{
	return m_brdURLField;
}

- (NSButton *) OKButton
{
	return m_OKButton;
}
- (NSButton *) cancelButton
{
	return m_cancelButton;
}
- (NSButton *) helpButton
{
	return m_helpButton;
}

#pragma mark IBActions

- (IBAction) searchBoards : (id) sender
{
}
- (IBAction) openHelp : (id) sender
{
	[[NSHelpManager sharedHelpManager] findString:@"Boards List" inBook:@"BathyScaphe Help"];
}
- (IBAction) close : (id) sender
{
	[NSApp endSheet : [self window]
		 returnCode : NSCancelButton];
}
- (IBAction) doAddAndClose : (id) sender
{
	BOOL	shouldClose;

	if ([[self defaultListOLView] selectedRow] == -1) {
		shouldClose = [self addToUserListFromForm : sender];
	} else {
		NSString *name_;
		NSString *url_;

		name_ = [[self brdNameField] stringValue];
		url_  = [[self brdURLField] stringValue];
		
		if ([name_ isEqualToString : @""] && [url_ isEqualToString : @""]) {
			shouldClose = [self addToUserListFromOLView : sender];
		} else {
			shouldClose = [self addToUserListFromForm : sender];
		}
	}

	if (shouldClose)
		[NSApp endSheet : [self window] returnCode : NSOKButton];
}

#pragma mark Other Actions

- (void) beginSheetModalForWindow : (NSWindow *) docWindow
					modalDelegate : (id        ) modalDelegate
					  contextInfo : (id		   ) info
{
	NSMutableDictionary		*info_;
	
	info_ = [NSMutableDictionary dictionary];
	[info_ setNoneNil:modalDelegate forKey:@"delegate"];
	[info_ setNoneNil:info forKey:@"contextInfo"];
	
	[NSApp beginSheet : [self window]
	   modalForWindow : docWindow
		modalDelegate : self
	   didEndSelector : @selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo : [info_ retain]];
}

- (BOOL) addToUserListFromOLView : (id) sender
{
	NSEnumerator *def_iter_;
	NSNumber     *def_index_;
	
	NSMutableArray *error_names_;
	
	error_names_ = [NSMutableArray array];
	
	def_iter_ = [[self defaultListOLView] selectedRowEnumerator];
	
	while (def_index_ = [def_iter_ nextObject]) {
		NSDictionary *item_;		
		
		item_ = [[self defaultListOLView] itemAtRow : [def_index_ intValue]];
		if (NO == [[[BoardManager defaultManager] userList] addItem : item_
														afterObject : nil])
		{
			NSString     *name_;
			name_ = [item_ objectForKey : @"Name"];
			[error_names_ addObject : name_];
		}
	}

	[[[BoardManager defaultManager] userList] postBoardListDidChangeNotification];

	if ([error_names_ count] > 0) {
		NSString *message_;
		
		message_ = [error_names_ componentsJoinedByString:@"\", \""];
		message_ = [NSString stringWithFormat : @"\"%@\"",  message_];

		[[NSAlert alertWithMessageText: @"Same Name Exists"
						defaultButton: @"Cancel"
					  alternateButton: nil
						  otherButton: nil
			informativeTextWithFormat: @"%@ are not added to your Boards List.", message_] runModal];
		return NO;
	}
	return YES;
}

- (BOOL) addToUserListFromForm : (id) sender
{
	NSDictionary *newItem_;
	NSString *name_;
	NSString *url_;

	name_ = [[self brdNameField] stringValue];
	url_  = [[self brdURLField] stringValue];
		
	if ([name_ isEqualToString : @""]|[url_ isEqualToString : @""]) {
		// 名前またはURLが入力されていない場合は中止
		NSBeep();
		return NO;
	} else {
		id userList = [[BoardManager defaultManager] userList];

		if ([userList containsItemWithName : name_ ofType : (BoardListBoardItem | BoardListFavoritesItem)]) {
			NSBeep();
			[[NSAlert alertWithMessageText: @"Same Name Exists"
							 defaultButton: @"Cancel"
						   alternateButton: nil
							   otherButton: nil
				 informativeTextWithFormat: @"So could not add to your Boards List."] runModal];
			return NO;
		}
		newItem_ = [NSDictionary dictionaryWithObjectsAndKeys :
							name_, BoardPlistNameKey, url_, BoardPlistURLKey, nil];

		[userList addItem:newItem_ afterObject:nil];
		[userList postBoardListDidChangeNotification];
		return YES;
	}
}

#pragma mark Delegate & Notifications
- (void) sheetDidEnd : (NSWindow *) sheet
		  returnCode : (int       ) returnCode
		 contextInfo : (void     *) contextInfo
{
	NSDictionary	*infoDict_;
	id				delegate_;
	id				userInfo_;
	SEL				sel_;
	
	infoDict_ = (NSDictionary *)contextInfo;
	UTILAssertKindOfClass(infoDict_, NSDictionary);
	
	sel_ = @selector(controller:sheetDidEnd:contextInfo:);
	delegate_ = [infoDict_ objectForKey : @"delegate"];
	userInfo_ = [infoDict_ objectForKey : @"contextInfo"];
	
	[infoDict_ autorelease];
	[sheet close];
	
	if(delegate_ != nil && [delegate_ respondsToSelector : sel_]){
		[delegate_ controller : self
				  sheetDidEnd : sheet 
				  contextInfo : userInfo_];
	}
}

- (void) outlineViewSelectionDidChange : (NSNotification *) notification
{
    UTILAssertNotificationName(
        notification,
        NSOutlineViewSelectionDidChangeNotification);

	if ([[self defaultListOLView] selectedRow] != -1) {
		[[self OKButton] setEnabled : YES];
		[[self brdNameField] setStringValue : @""];
		[[self brdURLField] setStringValue : @""];
	} else {
		[[self OKButton] setEnabled : NO];
	}
}

- (void)controlTextDidBeginEditing : (NSNotification *) aNotification
{
	[[self defaultListOLView] deselectAll : self];
}

- (void)controlTextDidChange : (NSNotification *) aNotification
{
	if (![[[self brdNameField] stringValue] isEqualToString : @""] && ![[[self brdURLField] stringValue] isEqualToString : @""]) {
		[[self OKButton] setEnabled : YES];
	} else{
		[[self OKButton] setEnabled : NO];
	}
}

- (void) boardListDidChange : (NSNotification *) notification
{
    UTILAssertNotificationName(
        notification,
        CMRBBSListDidChangeNotification);
    
	if ([notification object] == [[BoardManager defaultManager] defaultList])
        [[self defaultListOLView] reloadData];
}

@end
