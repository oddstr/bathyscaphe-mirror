//
//  $Id: NoNameInputController.h,v 1.1.2.1 2006/04/10 17:10:21 masakih Exp $
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
