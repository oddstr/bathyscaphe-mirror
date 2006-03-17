//
//  $Id: NoNameInputController.h,v 1.2 2006/03/17 21:16:19 tsawada2 Exp $
//  NoNameInputController.h - CMRNoNameManager.m から分割
//
//  Created by Tsutomu Sawada on 05/09/11.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NoNameInputController : NSWindowController
{
	IBOutlet NSTextField	*_messageField;
	IBOutlet NSTextField	*_textField;
}
- (NSString *) askUserAboutDefaultNoNameForBoard : (NSString *) boardName
									 presetValue : (NSString *) aValue;
- (IBAction) ok : (id) sender;
- (IBAction) cancel : (id) sender;

// available in Levantine and later.
- (IBAction) showHelpForNoNameInput : (id) sender;
@end
