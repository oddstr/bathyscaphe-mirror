//
//  CMRReplyController.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/11/05.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyController_p.h"

@implementation CMRReplyController
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
	[[self textView] unbind:@"font"];
	[CMRPref removeObserver:self forKeyPath:@"threadViewTheme.replyBackgroundColor"];
	[CMRPref removeObserver:self forKeyPath:@"threadViewTheme.replyColor"];
	[super dealloc];
}

- (NSPopUpButton *)templateInsertionButton
{
	return m_templateInsertionButton;
}

- (BOOL)isEndPost
{
	return [[self document] isEndPost];
}

- (id)threadIdentifier
{
	return [[self document] threadIdentifier];
}

#pragma mark Working with NSDocument
- (void)synchronizeDataFromMessenger
{
	CMRReplyMessenger		*document_;
	
	document_ = [self document];
	[[self nameComboBox] setStringValue:[document_ name]];
	[[self mailField] setStringValue:[document_ mail]];
	[[self textView] setString:[document_ replyMessage]];

	[self setupButtons];
}

- (void)synchronizeMessengerWithData
{
	CMRReplyMessenger		*document_;
	
	document_ = [self document];
	
	[document_ setName:[[self nameComboBox] stringValue]];
	[document_ setMail:[[self mailField] stringValue]];
	[document_ setReplyMessage:[[self textView] string]];
	[document_ setWindowFrame:[[self window] frame]];
}

#pragma mark IBActions
// 「ウインドウの位置と領域を記憶」
- (IBAction)saveAsDefaultFrame:(id)sender
{
	[CMRPref setReplyWindowDefaultFrameString:[[self window] stringWithSavedFrame]];
}

- (IBAction)insertSage:(id)sender
{
	NSString		*mail_;
	
	mail_ = [[self mailField] stringValue];
	mail_ = [self stringByInsertingSageWithString:mail_];

	[[self mailField] setStringValue:mail_];
	[self setupButtons];
}

- (IBAction)deleteMail:(id)sender
{
	if (![self canDeleteMail]) return;
	[[self mailField] setStringValue:@""];
	[self setupButtons];
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

- (IBAction)reply:(id)sender
{
    if (![[self document] isEndPost]) {
		[[self document] sendMessage:sender];
	}
}

- (IBAction)toggleBeLogin:(id)sender
{
	[[self document] setShouldSendBeCookie:(NO == [[self document] shouldSendBeCookie])];
}

- (NSString *)bugReportingTemplate:(NSRangePointer)selectionRangePtr
{
	NSString *base = [self localizedString:@"BugReportTemplate"];
	NSString *replacedString;
	NSBundle	*bundle = [NSBundle mainBundle];
	NSString *marker = [self localizedString:@"BugReportMarker"];
	NSDictionary *dict = [[CMRPref installedPreviewerBundle] infoDictionary];

	replacedString = [NSString stringWithFormat:base, 
						[[NSProcessInfo processInfo] operatingSystemVersionString],
						[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
						[bundle objectForInfoDictionaryKey:@"CFBundleVersion"],
						[dict objectForKey:@"CFBundleIdentifier"],
						[dict objectForKey:@"CFBundleVersion"],
						marker];

	NSRange range = [replacedString rangeOfString:marker options:(NSLiteralSearch|NSBackwardsSearch)];
	if (selectionRangePtr != NULL) *selectionRangePtr = range;
	return replacedString;
}

- (IBAction)insertTextTemplate:(id)sender
{
	NSRange		newSelectionRange;
	NSString	*templateString = [self bugReportingTemplate:NULL];
	NSTextView	*textView_ = [self textView];
	NSRange		selectedTextRange_ = [textView_ selectedRange];

	if ([textView_ shouldChangeTextInRange:selectedTextRange_ replacementString:templateString]) {
		[textView_ replaceCharactersInRange:selectedTextRange_ withString:templateString];
		[textView_ didChangeText];
	}

	newSelectionRange = [[textView_ string] rangeOfString:[self localizedString:@"BugReportMarker"] options:(NSLiteralSearch|NSBackwardsSearch)];
	[textView_ setSelectedRange:newSelectionRange];
}

- (IBAction)customizeTextTemplates:(id)sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert setMessageText:[self localizedString:@"CustomizeTemplateAlertTitle"]];
	[alert setInformativeText:[self localizedString:@"CustomizeTemplateAlertMsg"]];
	[alert runModal];
}

#pragma mark Validation
- (BOOL)validateToggleBeLoginItem:(NSToolbarItem *)theItem
{
	BSBeLoginPolicyType policy_ = [[BoardManager defaultManager] typeOfBeLoginPolicyForBoard:[[self document] boardName]];
	
	switch(policy_) {
		case BSBeLoginNoAccountOFF:
		{
			[theItem setImage:[NSImage imageAppNamed:kImageForLoginOff]];
			[theItem setLabel:[self localizedString:kLabelForLoginOff]];
			[theItem setToolTip:[self localizedString:kToolTipForCantLoginOn]];
			return NO;
		}
		case BSBeLoginTriviallyOFF:
		{
			[theItem setImage:[NSImage imageAppNamed:kImageForLoginOff]];
			[theItem setLabel:[self localizedString:kLabelForLoginOff]];
			[theItem setToolTip:[self localizedString:kToolTipForTrivialLoginOff]];
			return NO;
		}
		case BSBeLoginTriviallyNeeded:
		{
			[theItem setImage:[NSImage imageAppNamed:kImageForLoginOn]];
			[theItem setLabel:[self localizedString:kLabelForLoginOn]];
			[theItem setToolTip:[self localizedString:kToolTipForNeededLogin]];
			return NO;
		}
		case BSBeLoginDecidedByUser: 
		{
			NSString				*title_, *tooltip_;
			NSImage					*image_;
		
			if ([[self document] shouldSendBeCookie]) {
				title_ = [self localizedString:kLabelForLoginOn];
				tooltip_ = [self localizedString:kToolTipForLoginOn];
				image_ = [NSImage imageAppNamed:kImageForLoginOn];
			} else {
				title_ = [self localizedString:kLabelForLoginOff];
				tooltip_ = [self localizedString:kToolTipForLoginOff];
				image_ = [NSImage imageAppNamed:kImageForLoginOff];
			}
			[theItem setImage:image_];
			[theItem setLabel:title_];
			[theItem setToolTip:tooltip_];
			return YES;
		}
	}
	return NO;
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)theItem
{
	SEL action_ = [theItem action];
	if (action_ == @selector(toggleBeLogin:)) {
		return [self validateToggleBeLoginItem:(NSToolbarItem *)theItem];
	} else if (action_ == @selector(pasteAsQuotation:)) {
		return YES;
	} else if (action_ == @selector(reply:)) { //「レス...」項目を「送信」として利用する。
		NSString		*title_;
		
		title_ = [self localizedString:kSendMessageStringKey];
		[theItem setTitle:title_];
		
		return YES;
	}

	return [super validateUserInterfaceItem:theItem];
}
@end


@implementation CMRReplyController(ActionSupport)
- (BOOL)canInsertSage
{
	NSString		*mail_;
	
	mail_ = [[self mailField] stringValue];
	
	return (NO == [mail_ containsString:CMRThreadMessage_SAGE_String]);
}

- (BOOL)canDeleteMail
{
	NSString		*mail_;
	
	mail_ = [[self mailField] stringValue];
	return ([mail_ length] > 0);
}

- (NSString *)stringByInsertingSageWithString:(NSString *)mail
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
@end


@implementation CMRReplyController(CMRLocalizableStringsOwner)
+ (NSString *)localizableStringsTableName
{
	return MESSENGER_TABLE_NAME;
}
@end
