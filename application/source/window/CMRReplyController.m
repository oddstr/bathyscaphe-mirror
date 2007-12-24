//
//  CMRReplyController.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/11/05.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyController_p.h"
#import "CMRThreadMessage.h"
#import "BSReplyControllerValueTransformer.h"

@implementation CMRReplyController
+ (void)initialize
{
	if (self == [CMRReplyController class]) {
		id transformer = [[[BSNotNilOrEmptyValueTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"BSNotNilOrEmptyValueTransformer"];

		id transformer2 = [[[BSNotContainsSAGEValueTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer2 forName:@"BSNotContainsSAGEValueTransformer"];
	}
}

- (id)init
{
	if (self = [super initWithWindowNibName:@"CMRReplyWindow"]) {
		[self setShouldCloseDocument:YES];
		[self setShouldCascadeWindows:NO]; // reply window saves window's frame its own.
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[self mailField] unbind:@"value"];
	[[self textView] unbind:@"font"];
	[CMRPref removeObserver:self forKeyPath:@"threadViewTheme.replyBackgroundColor"];
	[CMRPref removeObserver:self forKeyPath:@"threadViewTheme.replyColor"];
	[super dealloc];
}
/*
- (BOOL)isEndPost
{
	return [[self document] isEndPost];
}

- (id)threadIdentifier
{
	return [[self document] threadIdentifier];
}
*/
#pragma mark Working with CMRReplyMessenger
- (void)synchronizeMessengerWithData
{
	NSWindow *window = [self window];
	
	if (![window makeFirstResponder:window]) {
		[window endEditingFor:nil];
	}

	[[self document] updateReplyMessage];
	[[self document] setWindowFrame:[window frame]];
}

#pragma mark IBActions
static inline NSString *stringByInsertingSageWithString(NSString *mail)
{
	NSMutableString		*newMail_;
	NSRange				ageRange_;
	
	if (!mail || [mail length] == 0) {
		return CMRThreadMessage_SAGE_String;
	}
	if ([mail containsString:CMRThreadMessage_SAGE_String]) {
		return mail;
	}
	// --------- Insert sage or replace age ---------
	newMail_ = [[mail mutableCopy] autorelease];
	ageRange_ = [newMail_ rangeOfString:CMRThreadMessage_AGE_String];
	
	if (NSNotFound == ageRange_.location || ageRange_.length == 0) {
		[newMail_ appendString:CMRThreadMessage_SAGE_String];
	} else {
		[newMail_ replaceCharactersInRange:ageRange_ withString:CMRThreadMessage_SAGE_String];
	}
	
	return newMail_;
}

- (IBAction)saveAsDefaultFrame:(id)sender
{
	[CMRPref setReplyWindowDefaultFrameString:[[self window] stringWithSavedFrame]];
}

- (IBAction)insertSage:(id)sender
{
	NSString		*mail_;
	
	mail_ = [[self document] mail];
	[[self document] setMail:stringByInsertingSageWithString(mail_)];
}

- (IBAction)deleteMail:(id)sender
{
	[[self document] setMail:nil];
}

- (IBAction)pasteAsQuotation:(id)sender
{
	NSPasteboard	*pboard_;
	NSString		*quotation_;
	
	pboard_ = [NSPasteboard generalPasteboard];
	quotation_ = [pboard_ stringForType:NSStringPboardType];
	quotation_ = [CMRReplyMessenger stringByQuoted:quotation_];
	
	if (!quotation_) return;

	NSTextView	*textView_ = [self textView];
	NSRange		selectedTextRange_ = [textView_ selectedRange];

	// 2007-03-21 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	// -[NSTextView replaceCharactersInRange:withString:] はそのままでは Undo をサポートしない。
	// Undo を適切に行えるようにするには、-[NSTextView shouldChangeTextInRange:replacementString:] と -[NSTextView didChangeText]
	// で挟んでやる必要がある。
	if ([textView_ shouldChangeTextInRange:selectedTextRange_ replacementString:quotation_]) {
		[textView_ replaceCharactersInRange:selectedTextRange_ withString:quotation_];
		[textView_ didChangeText];
	}
}

- (IBAction)insertTextTemplate:(id)sender
{
	UTILAssertRespondsTo(sender, @selector(representedObject));

	id	rep = [sender representedObject];
	UTILAssertNotNil(rep);
	UTILAssertKindOfClass(rep, NSString);

	NSString	*templateString = [[BSReplyTextTemplateManager defaultManager] templateForDisplayName:rep];
	if (!templateString) return;

	NSTextView	*textView_ = [self textView];
	NSRange		selectedTextRange_ = [textView_ selectedRange];

	if ([textView_ shouldChangeTextInRange:selectedTextRange_ replacementString:templateString]) {
		[textView_ replaceCharactersInRange:selectedTextRange_ withString:templateString];
		[textView_ didChangeText];
	}
}

#pragma mark UI Validation
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(pasteAsQuotation:)) {
		NSPasteboard *pboard = [NSPasteboard generalPasteboard];
		return [[pboard types] containsObject:NSStringPboardType];
	}

	return [super validateUserInterfaceItem:theItem];
}
@end
