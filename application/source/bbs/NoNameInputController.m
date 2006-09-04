//
//  $Id: NoNameInputController.m,v 1.2.4.1 2006/09/04 16:34:39 tsawada2 Exp $
//  NoNameInputController.m - CMRNoNameManager.m から分割
//
//  Created by Tsutomu Sawada on 05/09/11.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import "NoNameInputController.h"
#import "CocoMonar_Prefix.h"

#define kNoNameInputControllerNib	@"CMRNoNameInput"
#define kNoNameInputHelpAnchor		@"bs_noname_input_dialog"

@implementation NoNameInputController
- (id) init
{
	return [self initWithWindowNibName : kNoNameInputControllerNib];
}

- (void) dealloc
{
	[m_enteredText release];
	[super dealloc];
}

- (NSTextField *) titleField
{
	return m_titleField;
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

- (IBAction) ok : (id) sender
{
	[NSApp stopModalWithCode : NSOKButton];
}

- (IBAction) cancel : (id) sender
{
	[NSApp stopModalWithCode : NSCancelButton];
}

- (IBAction) showHelpForNoNameInput : (id) sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : kNoNameInputHelpAnchor
											   inBook : [NSBundle applicationHelpBookName]];
}

- (NSString *) askUserAboutDefaultNoNameForBoard : (NSString *) boardName
									 presetValue : (NSString *) aValue
{
	NSString		*title, *newTitle;
	int				code;

	UTILAssertNotNil(boardName);
	
	[self setEnteredText: aValue ? aValue : nil];	

	[self window]; // これがないと次の行で stringValue が nil を返してしまうよ！
	title = [[self titleField] stringValue];
	newTitle = [NSString stringWithFormat: title, boardName];
	[[self titleField] setStringValue: newTitle];

	code = [NSApp runModalForWindow : [self window]];
	
	[[self window] close];
	return (NSOKButton == code) ? [[[self enteredText] copy] autorelease] : nil;
}
@end
