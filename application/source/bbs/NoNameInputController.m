//
//  NoNameInputController.m
//  CMRNoNameManager.m から分割
//
//  Created by Tsutomu Sawada on 05/09/11.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "NoNameInputController.h"
#import "CocoMonar_Prefix.h"

/* .nib file name */
#define kNoNameInputControllerNib	@"CMRNoNameInput"

@implementation NoNameInputController
- (id) init
{
	return [self initWithWindowNibName : kNoNameInputControllerNib];
}

- (IBAction) ok : (id) sender
{
	[NSApp stopModalWithCode : NSOKButton];
}

- (IBAction) cancel : (id) sender
{
	[NSApp stopModalWithCode : NSCancelButton];
}

- (NSString *) askUserAboutDefaultNoNameForBoard : (NSString *) boardName
									 presetValue : (NSString *) aValue
{
	NSString		*s = nil;
	int				code;
	
	[self window];
	
	UTILAssertNotNil(boardName);
	
	s = [_messageField stringValue];
	s = [NSString stringWithFormat : s, boardName];
	[_messageField setStringValue : s];
	
	[_textField setStringValue : aValue ? aValue : @""];
	
	code = [NSApp runModalForWindow : [self window]];
	
	[[self window] close];
	return (NSOKButton == code)
			? [[[_textField stringValue] copy] autorelease]
			: nil;
}
@end
