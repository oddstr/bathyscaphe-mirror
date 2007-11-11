//
//  CMRReplyController.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/11/05.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "CMRStatusLineWindowController.h"


@interface CMRReplyController : CMRStatusLineWindowController
{
	IBOutlet NSComboBox			*_nameComboBox;
	IBOutlet NSTextField		*_mailField;
	IBOutlet NSButton			*_sageButton;
	IBOutlet NSButton			*_deleteMailButton;

	IBOutlet NSPopUpButton		*m_templateInsertionButton;
	
	IBOutlet NSScrollView		*_scrollView;
	IBOutlet NSTextView			*_textView;
}
- (BOOL)isEndPost;
- (NSPopUpButton *)templateInsertionButton;

// working with NSDocument...
- (void)synchronizeDataFromMessenger;
- (void)synchronizeMessengerWithData;

- (IBAction)insertSage:(id)sender;
- (IBAction)deleteMail:(id)sender;
- (IBAction)pasteAsQuotation:(id)sender;
- (IBAction)toggleBeLogin:(id)sender;

- (IBAction)insertTextTemplate:(id)sender;
- (IBAction)customizeTextTemplates:(id)sender;
@end
