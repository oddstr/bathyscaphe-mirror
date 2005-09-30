/**
  * $Id: CMRReplyController.h,v 1.2 2005/09/30 18:52:03 tsawada2 Exp $
  * 
  * CMRReplyController.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>
#import "CMRStatusLineWindowController.h"


/* Only useful for statusLine control */
@interface CMRReplyController : CMRStatusLineWindowController
{
	IBOutlet NSComboBox			*_nameComboBox;
	IBOutlet NSTextField		*_mailField;
	IBOutlet NSButton			*_sageButton;
	IBOutlet NSButton			*_deleteMailButton;
	
	IBOutlet NSScrollView		*_scrollView;
	IBOutlet NSTextView			*_textView;
}
- (BOOL) isEndPost;

// working with NSDocument...
- (void) synchronizeDataFromMessenger;
- (void) synchronizeMessengerWithData;

- (IBAction) insertSage : (id) sender;
- (IBAction) deleteMail : (id) sender;
- (IBAction) pasteAsQuotation : (id) sender;
- (IBAction) toggleBeLogin : (id) sender;
@end
