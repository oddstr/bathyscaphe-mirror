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

/*- (BoardList *) defaultList
{
	return _defaultList;
}
- (BoardList *) userList
{
	return _userList;
}*/

#pragma mark IBActions
- (IBAction) searchBoards : (id) sender
{
}
- (IBAction) openHelp : (id) sender
{
}
- (IBAction) close : (id) sender
{
	[NSApp endSheet : [self window]
		 returnCode : NSCancelButton];
}
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

- (void) boardListDidChange : (NSNotification *) notification
{
    UTILAssertNotificationName(
        notification,
        CMRBBSListDidChangeNotification);
    
	if ([notification object] == [[BoardManager defaultManager] defaultList])
        [[self defaultListOLView] reloadData];
}

@end
