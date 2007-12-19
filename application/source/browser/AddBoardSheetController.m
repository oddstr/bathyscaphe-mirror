//
//  $Id: AddBoardSheetController.m,v 1.14 2007/12/19 13:20:40 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/12.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import "AddBoardSheetController.h"

#import "SmartBoardList.h"
#import "BoardManager.h"
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

#import "DatabaseManager.h"

#import "UTILKit.h"

static NSString *const kABSNibFileNameKey					= @"AddBoardSheet";
static NSString *const kABSLocalizableStringsFileNameKey	= @"ThreadsList"; 

static NSString *const kABSContextInfoDelegateKey			= @"delegate";
static NSString *const kABSContextInfoObjectKey				= @"object";

@implementation AddBoardSheetController
+ (NSString *) localizableStringsTableName
{
	return kABSLocalizableStringsFileNameKey;
}

- (id) init
{
	if (self = [super initWithWindowNibName : kABSNibFileNameKey]) {
		;
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[_currentSearchStr release];
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
	[[self defaultListOLView] setDoubleAction: @selector(doAddAndClose:)];
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

- (NSString *) currentSearchStr
{
	return _currentSearchStr;
}
- (void) setCurrentSearchStr : (NSString *) newStr
{
	[newStr retain];
	[_currentSearchStr release];
	_currentSearchStr = newStr;
}

#pragma mark IBActions

- (IBAction) searchBoards : (id) sender
{
	[self showMatchedItemsWithCurrentSearchStr];
}

- (IBAction) openHelp : (id) sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : [self localizedString : @"Boards list"]
											   inBook : [NSBundle applicationHelpBookName]];
}

- (IBAction) close : (id) sender
{
	[NSApp endSheet : [self window]
		 returnCode : NSCancelButton];
}

- (IBAction) doAddAndClose : (id) sender
{
	BOOL	shouldClose;
	//NSLog(@"%@",[sender description]);
	if (sender == [self defaultListOLView]) { //  Maybe OLView doucle-clicked
		if ([[self defaultListOLView] clickedRow] == -1) return; // Maybe double click table column!!
		
		shouldClose = [self addToUserListFromOLView: sender];
	} else {
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
	[info_ setNoneNil : modalDelegate forKey : kABSContextInfoDelegateKey];
	[info_ setNoneNil : info forKey : kABSContextInfoObjectKey];
	
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
		id item_;		
		
		item_ = [[self defaultListOLView] itemAtRow : [def_index_ intValue]];
		if (NO == [[[BoardManager defaultManager] userList] addItem : item_
														afterObject : nil])
		{
			NSString     *name_;
			name_ = [item_ name];
			[error_names_ addObject : name_];
		}
	}

//	[[[BoardManager defaultManager] userList] postBoardListDidChangeNotification];

	if ([error_names_ count] > 0) {
		NSString *message_;
		
		message_ = [error_names_ componentsJoinedByString : [self localizedString : @"ErrNamesSeparater"]];
		message_ = [NSString stringWithFormat : [self localizedString : @"ErrNamesCover"],  message_];

		NSBeep();
		[[NSAlert alertWithMessageText: [self localizedString : @"Same Name Exists"]
						defaultButton : [self localizedString : @"Cancel"]
					  alternateButton : nil
						  otherButton : nil
			informativeTextWithFormat : [self localizedString : @"%@ are not added to your Boards List."], message_] runModal];
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
		NSBeep();
		return NO;
	} else {
		id userList = [[BoardManager defaultManager] userList];

		if ([userList itemForName : name_]) {
			NSBeep();
			[[NSAlert alertWithMessageText : [self localizedString : @"Same Name Exists"]
							 defaultButton : [self localizedString : @"Cancel"]
						   alternateButton : nil
							   otherButton : nil
				 informativeTextWithFormat : [self localizedString : @"So could not add to your Boards List."]] runModal];
			return NO;
		}

		DatabaseManager *DBM = [DatabaseManager defaultManager];
		unsigned boardID = [DBM boardIDForURLString:url_];
		if(boardID == NSNotFound) {
			[DBM registerBoardName:name_ URLString:url_];
		} else {
			[DBM renameBoardID:boardID toName:name_]; // 過去に同じ URL の掲示板を登録した経験有り -- IDを再利用、名前だけ新しくする
		}

		newItem_ = [BoardListItem boardListItemWithURLString:url_];

		[userList addItem : newItem_ afterObject : nil];
		return YES;
	}
}

- (void) showMatchedItems : (NSString *) keyword
{
	id				newSource_;

	if (keyword == nil || [keyword isEqualToString: @""]) {
		newSource_ = [[BoardManager defaultManager] defaultList];
	} else {
		newSource_ = [[[BoardManager defaultManager] filteredListWithString: keyword] retain];
	}
	
	[[self defaultListOLView] setDataSource: newSource_];
	[[self defaultListOLView] reloadData];
}

- (void) showMatchedItemsWithCurrentSearchStr
{
	[self showMatchedItems: [self currentSearchStr]];
}

- (void) cleanUpUI
{
	[self setCurrentSearchStr: @""];
	[self showMatchedItemsWithCurrentSearchStr];

	[[self brdNameField] setStringValue : @""];
	[[self brdURLField] setStringValue : @""];
	[m_warningField setStringValue:@""];

	[[self OKButton] setEnabled : NO];
	
	[[self defaultListOLView] deselectAll : self];
	[[self window] makeFirstResponder: [self searchField]];
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
	delegate_ = [infoDict_ objectForKey : kABSContextInfoDelegateKey];
	userInfo_ = [infoDict_ objectForKey : kABSContextInfoObjectKey];
	
	[infoDict_ autorelease];
	[sheet close];
	// 今は必要ない
	/*if(delegate_ != nil && [delegate_ respondsToSelector : sel_]){
		[delegate_ controller : self
				  sheetDidEnd : sheet 
				  contextInfo : userInfo_];
	}*/
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
		[m_warningField setStringValue:@""];
	} else {
		[[self OKButton] setEnabled : NO];
	}
}

- (void) windowWillClose : (NSNotification *) aNotification
{
	[self cleanUpUI];
}

- (void) controlTextDidBeginEditing : (NSNotification *) aNotification
{
	[[self defaultListOLView] deselectAll : self];
}

- (void) controlTextDidChange : (NSNotification *) aNotification
{
/*	if (![[[self brdNameField] stringValue] isEqualToString : @""] && ![[[self brdURLField] stringValue] isEqualToString : @""]) {
		[[self OKButton] setEnabled : YES];
	} else {
		[[self OKButton] setEnabled : NO];
	}*/
	NSString *partialBoardName = [[self brdNameField] stringValue];
	NSString *partialURL = [[self brdURLField] stringValue];

	if ([partialBoardName isEqualToString:@""]) {
		[m_warningField setStringValue:NSLocalizedStringFromTable(@"Validation Error 3", @"BoardListEditor", @"")];
		[[self OKButton] setEnabled:NO];
		return;
	} else if ([partialURL isEqualToString:@""]) {
		[m_warningField setStringValue:NSLocalizedStringFromTable(@"Validation Error 4", @"BoardListEditor", @"")];
		[[self OKButton] setEnabled:NO];
		return;
	} else if (![partialURL hasPrefix:@"http://"]) {
		[m_warningField setStringValue:NSLocalizedStringFromTable(@"Validation Error 1", @"BoardListEditor", @"")];
		[[self OKButton] setEnabled:NO];
		return;
	} else if (![partialURL hasSuffix:@"/"]) {
		[m_warningField setStringValue:NSLocalizedStringFromTable(@"Validation Error 2", @"BoardListEditor", @"")];
		[[self OKButton] setEnabled:NO];
		return;
	}		
	[m_warningField setStringValue:@""];
	[[self OKButton] setEnabled:YES];
}

- (void) boardListDidChange : (NSNotification *) notification
{
    UTILAssertNotificationName(
        notification,
        CMRBBSListDidChangeNotification);
    
	if ([notification object] == [[BoardManager defaultManager] defaultList]) {
		[self showMatchedItemsWithCurrentSearchStr];
	}
}
@end
