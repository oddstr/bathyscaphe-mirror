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
	IBOutlet NSScrollView		*_scrollView;

	IBOutlet NSPopUpButton		*m_templateInsertionButton;
	
	NSTextView			*_textView;
}

// working with NSDocument...
- (void)synchronizeMessengerWithData;

- (IBAction)insertSage:(id)sender;
- (IBAction)deleteMail:(id)sender;
- (IBAction)pasteAsQuotation:(id)sender;
- (IBAction)insertTextTemplate:(id)sender;
@end


@interface CMRReplyController(View)
- (NSComboBox *)nameComboBox;
- (NSTextField *)mailField;
- (NSTextView *)textView;
- (NSScrollView *)scrollView;
- (NSButton *)sageButton;
- (NSButton *)deleteMailButton;
- (NSPopUpButton *)templateInsertionButton;
@end
