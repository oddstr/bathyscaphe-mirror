/**
  * $Id: CMRReplyController.h,v 1.1 2005/05/11 17:51:09 tsawada2 Exp $
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
@end
