//
//  EditBoardSheetController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/09/04.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "EditBoardSheetController.h"
#import "CocoMonar_Prefix.h"
#import "BoardManager.h"
#import "BoardListItem.h"

static NSString *const kEditBoardSheetNibName		= @"EditBoardSheet";
static NSString *const kEditBoardSheetStringsName	= @"ThreadViewer"; // 今のところ共用
static NSString *const kEditBoardSheetHelpAnchor	= @"Browser Edit Drawer Item Help";

static NSString *const kEditDrawerTitleKey = @"Edit Title";
static NSString *const kAddCategoryTitleKey = @"Add Category Title";

static NSString *const kEditDrawerItemMsgForAdditionKey = @"Add Category Msg";

static NSString *const kEditDrawerItemMsgForBoardKey = @"Edit Board Msg";
static NSString *const kEditDrawerItemTitleForBoardKey = @"PleaseInputURL";

static NSString *const kEditDrawerItemMsgForCategoryKey = @"Edit Category Msg";
static NSString *const kEditDrawerItemTitleForCategoryKey = @"PleaseInputName";

@implementation EditBoardSheetController
- (id) init
{
	if (self = [super initWithWindowNibName: kEditBoardSheetNibName]) {
		[self window];
	}
	return self;
}

- (void) dealloc
{
	[m_enteredText release];
	[super dealloc];
}

#pragma mark Accessors
- (NSTextField *) titleField
{
	return m_titleField;
}
- (NSTextField *) messageField
{
	return m_messageField;
}
- (NSTextField *) labelField
{
	return m_labelField;
}

- (NSString *) enteredText
{
	return m_enteredText;
}
- (void) setEnteredText: (NSString *) someText
{
	[someText retain];
	[m_enteredText release];
	m_enteredText = someText;
}

#pragma mark Actions
- (IBAction) pressOK: (id) sender
{
	[NSApp endSheet: [self window] returnCode: NSOKButton];
}
- (IBAction) pressCancel: (id) sender
{
	[NSApp endSheet: [self window] returnCode: NSCancelButton];
}
- (IBAction) pressHelp: (id) sender
{
	[[NSHelpManager sharedHelpManager] findString: [self localizedString: kEditBoardSheetHelpAnchor]
										   inBook: [NSBundle applicationHelpBookName]];
}

- (void) beginEditBoardSheetForWindow: (NSWindow *) targetWindow
						modalDelegate: (id) aDelegate
						  contextInfo: (id) contextInfo
{
	UTILAssertKindOfClass(contextInfo, BoardListItem);

	NSString *name_ = [contextInfo representName];
	NSString *URLStr_ = [[contextInfo url] absoluteString];

	NSString *messageTemplate = [self localizedString: kEditDrawerItemMsgForBoardKey];

	[[self titleField] setStringValue: [self localizedString: kEditDrawerTitleKey]];
	[[self messageField] setStringValue: [NSString localizedStringWithFormat: messageTemplate, name_]];
	[[self labelField] setStringValue: [self localizedString: kEditDrawerItemTitleForBoardKey]];
	
	[self setEnteredText: URLStr_];

	[NSApp beginSheet: [self window]
	   modalForWindow: targetWindow
	    modalDelegate: self
	   didEndSelector: @selector(editBoardSheetDidEnd:returnCode:contextInfo:)
	      contextInfo: [[NSArray alloc] initWithObjects: (aDelegate ? aDelegate : [NSNull null]), name_, nil]];
}

- (void) beginEditCategorySheetForWindow: (NSWindow *) targetWindow
						   modalDelegate: (id) aDelegate
							 contextInfo: (id) contextInfo
{
	UTILAssertKindOfClass(contextInfo, NSString);

	NSString *messageTemplate = [self localizedString: kEditDrawerItemMsgForCategoryKey];

	[[self titleField] setStringValue: [self localizedString: kEditDrawerTitleKey]];
	[[self messageField] setStringValue: [NSString localizedStringWithFormat: messageTemplate, contextInfo]];
	[[self labelField] setStringValue: [self localizedString: kEditDrawerItemTitleForCategoryKey]];
	
	[self setEnteredText: contextInfo];
	
	[NSApp beginSheet: [self window]
	   modalForWindow: targetWindow
	    modalDelegate: self
	   didEndSelector: @selector(editCategorySheetDidEnd:returnCode:contextInfo:)
	      contextInfo: [[NSArray alloc] initWithObjects: (aDelegate ? aDelegate : [NSNull null]), contextInfo, nil]];
}

- (void) beginAddCategorySheetForWindow: (NSWindow *) targetWindow
						  modalDelegate: (id) aDelegate
						    contextInfo: (id) contextInfo
{
	[[self titleField] setStringValue: [self localizedString: kAddCategoryTitleKey]];
	[[self messageField] setStringValue: [self localizedString: kEditDrawerItemMsgForAdditionKey]];
	[[self labelField] setStringValue: [self localizedString: kEditDrawerItemTitleForCategoryKey]];
	
	[self setEnteredText: nil];
	
	[NSApp beginSheet: [self window]
	   modalForWindow: targetWindow
		modalDelegate: self
	   didEndSelector: @selector(addCategorySheetDidEnd:returnCode:delegateInfo:)
		  contextInfo: [aDelegate retain]];
}

#pragma mark Utilities
+ (NSString *) localizableStringsTableName
{
	return kEditBoardSheetStringsName;
}

#pragma mark Sheet Delegates
- (void) addCategorySheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode delegateInfo: (id) aDelegate
{
	if (NSOKButton == returnCode) {
		[[BoardManager defaultManager] addCategoryOfName: [self enteredText]];
	}

	[sheet close];

	if(aDelegate && [aDelegate respondsToSelector: @selector(controller:didEndSheet:returnCode:)]){
		[aDelegate controller: self didEndSheet: sheet returnCode: returnCode];
	}
	
	[aDelegate autorelease];
}

- (void) editCategorySheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (id) contextInfo
{
	UTILAssertKindOfClass(contextInfo, NSArray);
	id delegate_ = [contextInfo objectAtIndex: 0];

	if (NSOKButton == returnCode) {
		[[BoardManager defaultManager] editCategoryOfName: [contextInfo objectAtIndex: 1] newName: [self enteredText]];
	}
	
	[sheet close];

	if((delegate_ != [NSNull null]) && [delegate_ respondsToSelector: @selector(controller:didEndSheet:returnCode:)]){
		[delegate_ controller: self didEndSheet: sheet returnCode: returnCode];
	}
	
	[contextInfo autorelease];
}

- (void) editBoardSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (id) contextInfo
{
	UTILAssertKindOfClass(contextInfo, NSArray);
	id delegate_ = [contextInfo objectAtIndex: 0];

	if (NSOKButton == returnCode) {
		[[BoardManager defaultManager] editBoardOfName: [contextInfo objectAtIndex: 1] newURLString: [self enteredText]];
	}
	
	[sheet close];

	if((delegate_ != [NSNull null]) && [delegate_ respondsToSelector: @selector(controller:didEndSheet:returnCode:)]){
		[delegate_ controller: self didEndSheet: sheet returnCode: returnCode];
	}
	
	[contextInfo autorelease];
}
@end
