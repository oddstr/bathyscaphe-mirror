//
//  $Id: NoNameInputController.h,v 1.3 2006/11/05 12:53:47 tsawada2 Exp $
//  NoNameInputController.h - CMRNoNameManager.m から分割
//
//  Created by Tsutomu Sawada on 05/09/11.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NoNameInputController : NSWindowController
{
	IBOutlet NSTextField	*m_titleField;
	NSString				*m_enteredText;
}

- (NSTextField *) titleField;

// For Cocoa Binding
- (NSString *) enteredText;
- (void) setEnteredText: (NSString *) someText;

- (NSString *) askUserAboutDefaultNoNameForBoard: (NSString *) boardName
									 presetValue: (NSString *) aValue;
- (IBAction) ok: (id) sender;
- (IBAction) cancel: (id) sender;

// available in Levantine and later.
- (IBAction) showHelpForNoNameInput: (id) sender;
@end
