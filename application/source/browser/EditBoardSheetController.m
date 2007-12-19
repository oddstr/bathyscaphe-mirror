//
//  EditBoardSheetController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/09/04.
//  Copyright 2006-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "EditBoardSheetController.h"
#import "CocoMonar_Prefix.h"
#import "BoardManager.h"
#import "BoardListItem.h"

static NSString *const kEditBoardSheetNibName		= @"EditBoardSheet";
static NSString *const kEditBoardSheetStringsName	= @"BoardListEditor";
static NSString *const kEditBoardSheetHelpAnchor	= @"Browser Edit Drawer Item Help";

static NSString *const kEditDrawerItemMsgForAdditionKey = @"Add Category Msg";
static NSString *const kEditDrawerItemMsgForBoardKey = @"Edit Board Msg";
static NSString *const kEditDrawerItemMsgForCategoryKey = @"Edit Category Msg";

@implementation EditBoardSheetController
- (id)init
{
	if (self = [super initWithWindowNibName:kEditBoardSheetNibName]) {
		[self window];
		m_shouldValidate = NO;
	}
	return self;
}

- (void)dealloc
{
	[m_enteredText release];
	[super dealloc];
}

#pragma mark Accessors
- (NSTextField *)messageField
{
	return m_messageField;
}

- (NSTextField *)warningField
{
	return m_warningField;
}

- (NSString *)enteredText
{
	return m_enteredText;
}

- (void)setEnteredText:(NSString *)someText
{
	[someText retain];
	[m_enteredText release];
	m_enteredText = someText;
}

- (BOOL)partialStringIsValid
{
	return m_partialStringIsValid;
}

- (void)setPartialStringIsValid:(BOOL)flag
{
	m_partialStringIsValid = flag;
}

#pragma mark Actions
- (IBAction)pressOK:(id)sender
{
	[NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (IBAction)pressCancel:(id)sender
{
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (IBAction)pressHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] findString:[self localizedString:kEditBoardSheetHelpAnchor]
										   inBook:[NSBundle applicationHelpBookName]];
}

- (void)beginEditBoardSheetForWindow:(NSWindow *)targetWindow
					   modalDelegate:(id)aDelegate
						 contextInfo:(id)contextInfo
{
	UTILAssertKindOfClass(contextInfo, BoardListItem);

	NSString *name_ = [contextInfo representName];
	NSString *URLStr_ = [[contextInfo url] absoluteString];

	NSString *messageTemplate = [self localizedString:kEditDrawerItemMsgForBoardKey];

	[[self messageField] setStringValue:[NSString localizedStringWithFormat:messageTemplate, name_]];
	[self setEnteredText:URLStr_];
	m_shouldValidate = YES;

	[NSApp beginSheet:[self window]
	   modalForWindow:targetWindow
	    modalDelegate:self
	   didEndSelector:@selector(editBoardSheetDidEnd:returnCode:contextInfo:)
	      contextInfo:[[NSArray alloc] initWithObjects:(aDelegate ? aDelegate : [NSNull null]), contextInfo, nil]];
}

- (void)beginEditCategorySheetForWindow:(NSWindow *)targetWindow
						  modalDelegate:(id)aDelegate
							contextInfo:(id)contextInfo
{
	UTILAssertKindOfClass(contextInfo, BoardListItem);

	NSString *name_ = [contextInfo representName];

	NSString *messageTemplate = [self localizedString:kEditDrawerItemMsgForCategoryKey];

	[[self messageField] setStringValue:[NSString localizedStringWithFormat:messageTemplate, name_]];
	[self setEnteredText:name_];

	[NSApp beginSheet:[self window]
	   modalForWindow:targetWindow
	    modalDelegate:self
	   didEndSelector:@selector(editCategorySheetDidEnd:returnCode:contextInfo:)
	      contextInfo:[[NSArray alloc] initWithObjects:(aDelegate ? aDelegate : [NSNull null]), contextInfo, nil]];
}

- (void)beginAddCategorySheetForWindow:(NSWindow *)targetWindow
						 modalDelegate:(id)aDelegate
						   contextInfo:(id)contextInfo
{
	[[self messageField] setStringValue: [self localizedString: kEditDrawerItemMsgForAdditionKey]];	
	[self setEnteredText:nil];
	[self setPartialStringIsValid:YES];
	
	[NSApp beginSheet:[self window]
	   modalForWindow:targetWindow
		modalDelegate:self
	   didEndSelector:@selector(addCategorySheetDidEnd:returnCode:delegateInfo:)
		  contextInfo:[aDelegate retain]];
}

#pragma mark Utilities
+ (NSString *)localizableStringsTableName
{
	return kEditBoardSheetStringsName;
}

#pragma mark Sheet Delegates
- (void)addCategorySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode delegateInfo:(id)aDelegate
{
	if (NSOKButton == returnCode) {
		[[BoardManager defaultManager] addCategoryOfName:[self enteredText]];
	}

	[sheet close];

	if (aDelegate && [aDelegate respondsToSelector:@selector(controller:didEndSheet:returnCode:)]){
		[aDelegate controller:self didEndSheet:sheet returnCode:returnCode];
	}

	[aDelegate autorelease];
}

- (void)editCategorySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
	UTILAssertKindOfClass(contextInfo, NSArray);
	id delegate_ = [contextInfo objectAtIndex:0];

	if (NSOKButton == returnCode) {
		[[BoardManager defaultManager] editCategoryItem:[contextInfo objectAtIndex:1] newName:[self enteredText]];
	}

	[sheet close];

	if ((delegate_ != [NSNull null]) && [delegate_ respondsToSelector:@selector(controller:didEndSheet:returnCode:)]){
		[delegate_ controller:self didEndSheet:sheet returnCode:returnCode];
	}

	[contextInfo autorelease];
}

- (void)editBoardSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
	UTILAssertKindOfClass(contextInfo, NSArray);
	id delegate_ = [contextInfo objectAtIndex:0];

	m_shouldValidate = NO;
	[[self warningField] setStringValue:@""];

	if (NSOKButton == returnCode) {
		[[BoardManager defaultManager] editBoardItem:[contextInfo objectAtIndex:1] newURLString:[self enteredText]];
	}

	[sheet close];

	if ((delegate_ != [NSNull null]) && [delegate_ respondsToSelector:@selector(controller:didEndSheet:returnCode:)]){
		[delegate_ controller:self didEndSheet:sheet returnCode:returnCode];
	}
	
	[contextInfo autorelease];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	if (!m_shouldValidate) return;

	// 簡単な入力文字列チェックを行う
	NSText *fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	NSString *partialString = [fieldEditor string];
	NSString *error = @"";

	if (![partialString hasPrefix:@"http://"]) {
		error = [self localizedString:@"Validation Error 1"];
		[self setPartialStringIsValid:NO];
	} else if (![partialString hasSuffix:@"/"]) {
		error = [self localizedString:@"Validation Error 2"];
		[self setPartialStringIsValid:NO];
	} else {
		[self setPartialStringIsValid:YES];
	}
	[[self warningField] setStringValue:error];
}
@end
