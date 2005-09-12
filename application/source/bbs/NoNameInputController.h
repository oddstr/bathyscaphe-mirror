//
//  NoNameInputController.h
//  CMRNoNameManager.m ‚©‚ç•ªŠ„
//
//  Created by Tsutomu Sawada on 05/09/11.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
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
@end
