//
//  CMRReplyMessenger.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/15.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyMessenger_p.h"
#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import "CMRDocumentFileManager.h"
#import "CMRThreadSignature.h"

NSString *const CMRReplyMessengerDidFinishPostingNotification = @"CMRReplyMessengerDidFinishPostingNotification";

#define kNewline			@"\n"
#define kQuotationMarksKey	@"quotation marks"

@implementation CMRReplyMessenger
- (void)dealloc
{
	[_textStorage release];
	[_attributes release];
	[_additionalForms release];
	[super dealloc];
}

- (void)replaceInfoDictionary:(NSDictionary *)newDict
{
	id		tmp;
	
	tmp = _attributes;
	_attributes = [newDict mutableCopy];
	[tmp release];
}

+ (NSString *)stringByQuoted:(NSString *)string
{
	NSString	*mark_;
	id			quotation_;
	
	NSArray			*allLines_;
	NSEnumerator	*iter_;
	NSString		*line_;
	BOOL			markLast = NO;
	
	if (!string || [string isEmpty])
		return string;
	
	quotation_ = [NSMutableString string];
	mark_ = [self localizedString:kQuotationMarksKey];
	
	allLines_ = [string componentsSeparatedByNewline];
	markLast = (NO == [[allLines_ lastObject] isEmpty]);
	iter_ = [allLines_ objectEnumerator];
	while (line_ = [iter_ nextObject]) {
		if (!markLast && line_ == [allLines_ lastObject])
			break;
		
		[quotation_ appendString:mark_];
		[quotation_ appendString:line_];
		[quotation_ appendString:kNewline];
	}
	
	quotation_ = [quotation_ copy];
	return [quotation_ autorelease];
}

- (void)append:(NSString *)string quote:(BOOL)quote replyTo:(unsigned)anIndex
{
	id				textStorage_;
	
	if (!string) return;
	if (quote) string = [[self class] stringByQuoted:string];

	textStorage_ = [self textStorage];
	if (anIndex != NSNotFound) {
		// 2005-02-01 tsawada2<ben-sawa@td5.so-net.ne.jp>
		// 既にtextStorage_ の先頭にレスアンカーが記載されているなら、レスアンカーは付加しない
		if (![[textStorage_ string] hasPrefix:[NSString stringWithFormat:@">>%u",anIndex+1]]) {
			string = [NSString stringWithFormat:@">>%u\n%@", anIndex+1, string];
		}
	}

	[textStorage_ beginEditing];
	[textStorage_ appendString:string withAttributes:[self textAttributes]];
	[textStorage_ endEditing];
	[self updateChangeCount:NSChangeDone];
}

- (void)updateReplyMessage
{
	[self setReplyMessage:[[self textStorage] string]];
}

- (void)setUpBeLoginSetting
{
	BSBeLoginPolicyType	policy_;
	NSString			*bName_ = [self boardName];
	BOOL				tmp = NO;
	BoardManager		*bM_ = [BoardManager defaultManager];

	policy_	 = [bM_ typeOfBeLoginPolicyForBoard:bName_];

	if (policy_ == BSBeLoginTriviallyNeeded) {
		tmp = YES;
	} else if (policy_ == BSBeLoginDecidedByUser) {
		tmp = [bM_ alwaysBeLoginAtBoard:bName_];
	}

	[self setShouldSendBeCookie:tmp];
}

#pragma mark Accessors
- (NSTextStorage *)textStorage
{
	if (!_textStorage) {
		_textStorage = [[NSTextStorage alloc] init];
	}
	return _textStorage;
}

- (NSDictionary *)textAttributes
{
	BSThreadViewTheme *theme = [CMRPref threadViewTheme];
	return [NSDictionary dictionaryWithObjectsAndKeys:[theme replyFont], NSFontAttributeName, [theme replyColor], NSForegroundColorAttributeName, nil];
}

- (id)threadIdentifier
{
	return [CMRThreadSignature threadSignatureWithIdentifier:[self formItemKey] boardName:[self boardName]];
}

- (NSString *)datIdentifier
{
	return [self formItemKey];
}

- (NSURL *)boardURL
{
	return [[BoardManager defaultManager] URLForBoardName:[self boardName]];
}

- (NSURL *)targetURL
{
	return [[self class] targetURLWithBoardURL:[self boardURL]];
}
- (NSString *)boardName
{
	return [[self infoDictionary] objectForKey:ThreadPlistBoardNameKey];
}

- (NSString *)name
{
	return [[self infoDictionary] objectForKey:ThreadPlistContentsNameKey];
}

- (void)setName:(NSString *)aName
{
	NSUndoManager	*undoManager = [self undoManager];
	id tmp = [self name];
	[self setValueConsideringNilValue:aName forPlistKey:ThreadPlistContentsNameKey];

	[undoManager registerUndoWithTarget:self selector:@selector(setName:) object:tmp];
	[undoManager setActionName:[self localizedString:@"setName_Undo_Name"]];
}

- (NSString *)mail
{
	return [[self infoDictionary] objectForKey:ThreadPlistContentsMailKey];
}

- (void)setMail:(NSString *)aMail
{
	NSUndoManager	*undoManager = [self undoManager];
	id tmp = [self mail];
	[self setValueConsideringNilValue:aMail forPlistKey:ThreadPlistContentsMailKey];

	[undoManager registerUndoWithTarget:self selector:@selector(setMail:) object:tmp];
	[undoManager setActionName:[self localizedString:@"setMail_Undo_Name"]];
}

- (NSDate *)modifiedDate
{
	id		modifiedDate_;
	
	modifiedDate_ = [[self infoDictionary] objectForKey:CMRThreadModifiedDateKey];
	if (!modifiedDate_ || ![modifiedDate_ isKindOfClass:[NSDate class]]) {
		return [NSDate date];
	}
	return modifiedDate_;
}

- (NSRect)windowFrame
{
	return [[self infoDictionary] rectForKey:CMRThreadWindowFrameKey];
}

- (void)setWindowFrame:(NSRect)aWindowFrame
{
	[[self mutableInfoDictionary] setRect:aWindowFrame forKey:CMRThreadWindowFrameKey];
}

- (BOOL)isEndPost
{
	return _isEndPost;
}

#pragma mark NSDocument methods
- (NSString *)displayName
{
	return [NSString stringWithFormat:[self localizedString:REPLY_MESSENGER_WINDOW_TITLE_FORMAT], [self threadTitle]];
}

- (void)makeWindowControllers
{
	NSWindowController		*controller_;
	
	controller_ = [[CMRReplyController alloc] init];
	[self addWindowController:controller_];
	[controller_ release];
}

//- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)aType
- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if ([typeName isEqualToString:CMRReplyDocumentType]) {
		NSDictionary		*dict_;
		NSArray				*documentAttributeKeys_;
		NSEnumerator		*iter_;
		NSString			*key_;
		
		documentAttributeKeys_ = [CMRReplyDocumentFileManager documentAttributeKeys];
		iter_ = [documentAttributeKeys_ objectEnumerator];
//		dict_ = [NSDictionary dictionaryWithContentsOfFile:fileName];
		dict_ = [NSDictionary dictionaryWithContentsOfURL:absoluteURL];

		if (!dict_) return NO;

		while (key_ = [iter_ nextObject]) {
			if (![dict_ objectForKey:key_]) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					[self localizedString:@"CantReadDocErr_Reason_201"], NSLocalizedDescriptionKey,
					[NSString stringWithFormat:[self localizedString:@"CantReadDocErr_Suggestion_20x"], [absoluteURL path]],
						NSLocalizedRecoverySuggestionErrorKey,
					absoluteURL, NSURLErrorKey, NULL];
				*outError = [NSError errorWithDomain:BSBathyScapheErrorDomain code:BSDocumentReadRequiredAttrNotFoundError userInfo:userInfo];
				return NO;
			}
		}
		
		[self replaceInfoDictionary:dict_];
		[self setUpBeLoginSetting];

		[[self textStorage] beginEditing];
		[[self textStorage] appendString:[self replyMessage] withAttributes:[self textAttributes]];
		[[self textStorage] endEditing];

		return YES;
	}
	return NO;
}

//- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)type
- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if ([typeName isEqualToString:CMRReplyDocumentType]) {
		NSArray				*documentAttributeKeys_;
		NSEnumerator		*iter_;
		NSString			*key_;
		
		[self synchronizeDocumentContentsWithWindowControllers];
		if ([self isEndPost]) {
			[self setReplyMessage:nil];
		}
		documentAttributeKeys_ = [CMRReplyDocumentFileManager documentAttributeKeys];
		iter_ = [documentAttributeKeys_ objectEnumerator];
		
		while (key_ = [iter_ nextObject]) {
			if (![[self infoDictionary] objectForKey:key_]) {
				if (outError != NULL) {
					NSDictionary *userInfo = [NSDictionary dictionary];
					outError = [NSError errorWithDomain:BSBathyScapheErrorDomain code:BSDocumentWriteRequiredAttrNotFoundError userInfo:userInfo];
				}
				return NO;
			}
		}

//		return [[self infoDictionary] writeToFile:fileName atomically:YES];
		return [[self infoDictionary] writeToURL:absoluteURL atomically:YES];
	}
	return NO;
}
@end


@implementation CMRReplyMessenger(ScriptingSupport)
- (NSRange)selectedTextRange
{
	CMRReplyController *controller = [self replyControllerRespondsTo:@selector(textView)];
	return [[controller textView] selectedRange];
}

- (void)setTextStorage:(id)text
{
	NSTextStorage		*textStorage = [self textStorage];
	NSAttributedString	*attrString;
	NSString			*baseString;

	if ([text isKindOfClass:[NSAttributedString class]]) {
		baseString = [(NSAttributedString *)text string];
	} else {
		baseString = text;
	}

	attrString = [[NSAttributedString alloc] initWithString:baseString attributes:[self textAttributes]];
	[textStorage beginEditing];
	[textStorage setAttributedString:attrString];
	[textStorage endEditing];
	[self updateChangeCount:NSChangeDone];
}

- (NSTextStorage *)selectedText
{
	NSAttributedString* attrString;
	attrString = [[self textStorage] attributedSubstringFromRange:[self selectedTextRange]];
	NSTextStorage * storage = [[NSTextStorage alloc] initWithAttributedString:attrString];
	return [storage autorelease];
}

- (void)setSelectedText:(id)text
{
	NSString *stringValue;
	if ([text isKindOfClass:[NSAttributedString class]]) {
		stringValue = [(NSAttributedString *)text string];
	} else {
		stringValue = (NSString *)text;
	}
	[[self textStorage] beginEditing];
	[[self textStorage] replaceCharactersInRange:[self selectedTextRange] withString:stringValue];
	[[self textStorage] endEditing];
	[self updateChangeCount:NSChangeDone];
}

- (NSString *)targetURLAsString
{
	return [[self targetURL] absoluteString];
}
@end


@implementation CMRReplyMessenger(Action)
- (IBAction)sendMessage:(id)sender
{
	[self startSendingMessage];
}

- (IBAction)toggleBeLogin:(id)sender
{
	[self setShouldSendBeCookie:(![self shouldSendBeCookie])];
}

- (IBAction)revealInFinder:(id)sender
{
	NSString *path = [self fileName];
	[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:[path stringByDeletingLastPathComponent]];
}

- (IBAction)openBBSInBrowser:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[self boardURL] inBackground:[CMRPref openInBg]];
}

- (IBAction)showLocalRules:(id)sender
{
	NSWindowController *foo = [[BoardManager defaultManager] localRulesPanelControllerForBoardName:[self boardName]];
	[foo showWindow:self];
}

- (IBAction)saveDocumentAs:(id)sender
{
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		// すり替え
		[self saveDocument:sender];
	} else {
		[super saveDocumentAs:sender];
	}
}

- (IBAction)reply:(id)sender
{
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		// すり替え
		[self sendMessage:sender];
	}
}

#pragma mark UI Validation
- (BOOL)validateToggleBeLoginItem:(NSToolbarItem *)theItem
{
	BSBeLoginPolicyType policy_ = [[BoardManager defaultManager] typeOfBeLoginPolicyForBoard:[self boardName]];
	
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
		
			if ([self shouldSendBeCookie]) {
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

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	SEL		action_ = [theItem action];
	
	if (action_ == @selector(toggleBeLogin:)) {
		return [self validateToggleBeLoginItem:theItem];
	}
	if (action_ == @selector(sendMessage:)) {
		return (![self isEndPost] && [[self textStorage] length]);
	}

	if (action_ == @selector(saveDocument:)) {
		return [self isDocumentEdited];
	}

	if (action_ == @selector(showLocalRules:)) {
		[theItem setLabel:NSLocalizedStringFromTable(@"ShowLocalRules Label", @"ToolbarItems", nil)];
		return YES;
	}

	return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(reply:)) {
		[theItem setTitle:[self localizedString:@"Send Message"]];
		return (![self isEndPost] && [[self textStorage] length]);
	}
/*
	if (action_ == @selector(sendMessage:)) {
		return (![self isEndPost] && [[self textStorage] length]);
	}
*/	
	if (action_ == @selector(saveDocumentAs:)) {
		[theItem setTitle:[self localizedString:@"Save Menu Item"]];
		return [self isDocumentEdited];
	}
	
	if (action_ == @selector(revealInFinder:)) {
		return ([self fileName]);
	}
	
	if (action_ == @selector(openBBSInBrowser:)) {
		return YES;
	}

	if (action_ == @selector(showLocalRules:)) {
		BoardManager *bm = [BoardManager defaultManager];
		[theItem setTitle:[bm isKeyWindowForBoardName:[self boardName]] ? NSLocalizedString(@"Hide Local Rules", @"")
																		: NSLocalizedString(@"Show Local Rules", @"")];
		return YES;
	}

	return [super validateMenuItem:theItem];
}
@end


@implementation CMRReplyMessenger(CMRTaskImplementation)
- (NSString *)identifier
{
	return [self description];
}

- (NSString *)title
{
	return [self displayName];
}

- (NSString *)message
{
	NSString *statusStr_;
	
	if ([self isInProgress]) {
		statusStr_ = [NSString stringWithFormat:[self localizedString:MESSENGER_SEND_MESSAGE], [self threadTitle]];
	} else {
		statusStr_ = [self localizedString:MESSENGER_END_POST];
	}
	return statusStr_;
}

- (BOOL)isInProgress
{
	return _isInProgress;
}

- (void)setIsInProgress:(BOOL)isInProgress
{
	_isInProgress = isInProgress;
}

- (double)amount
{
	return -1;
}

- (IBAction)cancel:(id)sender
{
	;
}
@end


@implementation CMRReplyMessenger(CMRLocalizableStringsOwner)
+ (NSString *)localizableStringsTableName
{
	return MESSENGER_TABLE_NAME;
}
@end
