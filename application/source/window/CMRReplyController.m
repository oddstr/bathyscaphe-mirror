#import "CMRReplyController_p.h"



@implementation CMRReplyController
- (id) init
{
	if (self = [super initWithWindowNibName : @"CMRReplyWindow"]) {
		[self setShouldCloseDocument : YES];
		
		// reply window saves window's frame its own. 
		[self setShouldCascadeWindows : NO];
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[super dealloc];
}

- (BOOL) isEndPost
{
	return [[self document] isEndPost];
}
- (id) boardIdentifier
{
	return [[self document] boardIdentifier];
}
- (id) threadIdentifier
{
	return [[self document] threadIdentifier];
}


// working with NSDocument...
- (void) synchronizeDataFromMessenger
{
	CMRReplyMessenger		*document_;
	
	document_ = [self document];
	[[self nameComboBox] setStringValue : [document_ name]];
	[[self mailField] setStringValue : [document_ mail]];
	[[self textView] setString : [document_ replyMessage]];
	
	[self setupButtons];
}
- (void) synchronizeMessengerWithData
{
	CMRReplyMessenger		*document_;
	
	document_ = [self document];
	
	[document_ setName : [[self nameComboBox] stringValue]];
	[document_ setMail : [[self mailField] stringValue]];
	[document_ setReplyMessage : [[self textView] string]];
	[document_ setWindowFrame : [[self window] frame]];

	// deprecated in BathyScaphe 1.0.2
	//[document_ setReplyTextFont : [[self textView] font]];
	//[document_ setReplyTextColor : [[self textView] textColor]];
}

/*** Action ***/
// 「ウインドウの位置と領域を記憶」
- (IBAction) saveAsDefaultFrame : (id) sender;
{
	[CMRPref setReplyWindowDefaultFrameString : 
			[[self window] stringWithSavedFrame]];
}

- (IBAction) insertSage : (id) sender
{
	NSString		*mail_;
	
	mail_ = [[self mailField] stringValue];
	mail_ = [self stringByInsertingSageWithString : mail_];
	
	[[self mailField] setStringValue : mail_];
	[self setupButtons];
}
- (IBAction) deleteMail : (id) sender
{
	if (NO == [self canDeleteMail]) return;
	[[self mailField] setStringValue : @""];
	[self setupButtons];
}
- (IBAction) pasteAsQuotation : (id) sender
{
	NSPasteboard	*pboard_;
	NSString		*quotation_;
	
	pboard_ = [NSPasteboard generalPasteboard];
	quotation_ = [pboard_ stringForType : NSStringPboardType];
	quotation_ = [CMRReplyMessenger stringByQuoted : quotation_];
	
	if (nil == quotation_) return;
	[[self textView] replaceCharactersInRange : [[self textView] selectedRange]
								   withString : quotation_];
}
- (IBAction) reply : (id) sender
{
    if (NO == [[self document] isEndPost])
    	[[self document] sendMessage : sender];
}
- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL		action_;
	
	if (nil == theItem) return NO;
	action_ = [theItem action];
	
	if (@selector(pasteAsQuotation:) == action_) {
		return YES;
	}
	//「レス...」項目を「送信」として利用する。
	if (@selector(reply:) == action_) {
		NSString		*title_;
		
		title_ = [self localizedString:kSendMessageStringKey];
		[theItem setTitle : title_];
		
		return YES;
	}
	return [super validateMenuItem : theItem];
}
@end



@implementation CMRReplyController(ActionSupport)
- (BOOL) canInsertSage
{
	NSString		*mail_;
	
	mail_ = [[self mailField] stringValue];
	
	return (NO == [mail_ containsString : CMRThreadMessage_SAGE_String]);
}
- (BOOL) canDeleteMail
{
	NSString		*mail_;
	
	mail_ = [[self mailField] stringValue];
	return ([mail_ length] > 0);
}

- (NSString *) stringByInsertingSageWithString : (NSString *) mail
{
	NSMutableString		*newMail_;
	NSRange				ageRange_;
	
	if (nil == mail || 0 == [mail length])
		return CMRThreadMessage_SAGE_String;
	
	if ([mail containsString : CMRThreadMessage_SAGE_String])
		return mail;
	
	// --------- Insert sage or replace age ---------
	newMail_ = [[mail mutableCopy] autorelease];
	ageRange_ = [newMail_ rangeOfString : CMRThreadMessage_AGE_String];
	
	if (NSNotFound == ageRange_.location || 0 == ageRange_.length) {
		[newMail_ appendString : CMRThreadMessage_SAGE_String];
	} else {
		[newMail_ replaceCharactersInRange : ageRange_
								withString : CMRThreadMessage_SAGE_String];
	}
	
	return newMail_;
}
@end



@implementation CMRReplyController(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
	return MESSENGER_TABLE_NAME;
}
@end
