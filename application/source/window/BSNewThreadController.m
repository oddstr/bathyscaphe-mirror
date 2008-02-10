//
//  BSNewThreadController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/09.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//

#import "BSNewThreadController.h"
#import "CMRReplyControllerTbDelegate.h"

@implementation BSNewThreadController
- (NSTextField *)newThreadTitleField
{
	return m_newThreadTitleField;
}

- (NSString *)windowNibName
{
	return @"BSNewThreadWindow";
}

- (IBAction)saveAsDefaultFrame:(id)sender
{
	// Not Supported
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
	SEL action_ = [anItem action];
	if (action_ == @selector(saveAsDefaultFrame:)) {
		return NO;
	}

	return [super validateUserInterfaceItem:anItem];
}
@end


@implementation BSNewThreadController(View)
+ (Class)toolbarDelegateImpClass 
{ 
	return [BSNewThreadControllerTbDelegate class];
}

- (void)setupWindowFrameWithMessenger
{
	[self setWindowFrameAutosaveName:@"BathyScaphe:New Thread Window Autosave"];
	[[self window] useOptimizedDrawing:YES];
}

- (void)setupKeyLoops
{
	[[self newThreadTitleField] setNextKeyView:[self nameComboBox]];
	[[self nameComboBox] setNextKeyView:[self mailField]];
	[[self mailField] setNextKeyView:[self sageButton]];
	[[self sageButton] setNextKeyView:[self deleteMailButton]];
	[[self deleteMailButton] setNextKeyView:[self textView]];
	[[self textView] setNextKeyView:[self newThreadTitleField]];
	[[self window] setInitialFirstResponder:[self newThreadTitleField]];
	[[self window] makeFirstResponder:[self newThreadTitleField]];
}
@end
