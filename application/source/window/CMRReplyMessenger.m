//
//  CMRReplyMessenger.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/15.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyMessenger_p.h"
#import "CMRDocumentFileManager.h"
#import "BoardManager.h"

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

- (NSMutableDictionary *)mutableInfoDictionary
{
	if (!_attributes) {
		_attributes = [[NSMutableDictionary alloc] init];
	}
	return _attributes;
}

- (void)replaceInfoDictionary:(NSDictionary *)newDict
{
	id		tmp;
	
	tmp = _attributes;
	_attributes = [newDict mutableCopy];
	[tmp release];
}

- (NSDictionary *)textAttributes
{
	BSThreadViewTheme *theme = [CMRPref threadViewTheme];
	return [NSDictionary dictionaryWithObjectsAndKeys:[theme replyFont], NSFontAttributeName, [theme replyColor], NSForegroundColorAttributeName, nil];
}

- (NSDictionary *)infoDictionary
{
	return [self mutableInfoDictionary];
}

- (void)setReplyMessage:(NSString *)aMessage
{
	[[self mutableInfoDictionary] setObject:aMessage forKey:ThreadPlistContentsMessageKey];
}

- (void)setName:(NSString *)aName
{
	[[self mutableInfoDictionary] setObject:aName forKey:ThreadPlistContentsNameKey];
}

- (void)setMail:(NSString *)aMail
{
	[[self mutableInfoDictionary] setObject:aMail forKey:ThreadPlistContentsMailKey];
}

- (void)setModifiedDate:(NSDate *)aModifiedDate
{
	[[self mutableInfoDictionary] setObject:aModifiedDate forKey:CMRThreadModifiedDateKey];
}

- (void)setWindowFrame:(NSRect)aWindowFrame
{
	[[self mutableInfoDictionary] setRect:aWindowFrame forKey:CMRThreadWindowFrameKey];
}

- (NSTextStorage *)textStorage
{
	if (!_textStorage) {
		_textStorage = [[NSTextStorage alloc] init];
	}
	return _textStorage;
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

- (void)setMessageContents:(NSString *)aContents replyTo:(unsigned)anIndex
{
	[self append:aContents quote:YES replyTo:anIndex];
}
/* 
	string  contents will be added
	quote   quote this string
	anIndex add anchor to index (no anchor if NSNotFound)
 */
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
}

- (BOOL)isEndPost
{
	return _isEndPost;
}

- (void)setIsEndPost:(BOOL)anIsEndPost
{
	_isEndPost = anIsEndPost;
}

- (BOOL)shouldSendBeCookie
{
	return _shouldSendBeCookie;
}

- (void)setShouldSendBeCookie:(BOOL)sendBeCookie
{
	_shouldSendBeCookie = sendBeCookie;
}

#pragma mark NSDocument methods
- (NSString *)displayName
{
	return [NSString stringWithFormat:[self localizedString:REPLY_MESSENGER_WINDOW_TITLE_FORMAT], [self formItemTitle]];
}

- (void)makeWindowControllers
{
	NSWindowController		*controller_;
	
	controller_ = [[CMRReplyController alloc] init];
	[self addWindowController:controller_];
	[controller_ release];
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

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)aType
{
	if ([aType isEqualToString:CMRReplyDocumentType]) {
		NSDictionary		*dict_;
		NSArray				*documentAttributeKeys_;
		NSEnumerator		*iter_;
		NSString			*key_;
		
		documentAttributeKeys_ = [CMRReplyDocumentFileManager documentAttributeKeys];
		iter_ = [documentAttributeKeys_ objectEnumerator];
		dict_ = [NSDictionary dictionaryWithContentsOfFile:fileName];
		
		while (key_ = [iter_ nextObject]) {
			if (![dict_ objectForKey:key_]) {
				return NO;
			}
		}
		
		[self replaceInfoDictionary:dict_];
		[self synchronizeWindowControllersFromDocument];

		[self setUpBeLoginSetting];

		return (dict_ != nil);
	}
	return NO;
}

- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)type
{
	if ([type isEqualToString:CMRReplyDocumentType]) {
		NSArray				*documentAttributeKeys_;
		NSEnumerator		*iter_;
		NSString			*key_;
		
		[self synchronizeDocumentContentsWithWindowControllers];
		if ([self isEndPost]) {
			[self setReplyMessage:@""];
		}
		documentAttributeKeys_ = [CMRReplyDocumentFileManager documentAttributeKeys];
		iter_ = [documentAttributeKeys_ objectEnumerator];
		
		while (key_ = [iter_ nextObject]) {
			if (![[self infoDictionary] objectForKey:key_])
				return NO;
		}

		return [[self infoDictionary] writeToFile:fileName atomically:YES];
	}
	return NO;
}
@end


@implementation CMRReplyMessenger(Attributes)
- (NSString *)boardName
{
	return [[self infoDictionary] objectForKey:ThreadPlistBoardNameKey];
}

- (NSString *)formItemTitle
{
	return [self threadTitle];
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

- (void)synchronizeDocumentContentsWithWindowControllers
{
	CMRReplyController	*controller_;
	
	controller_ = [self replyControllerRespondsTo:@selector(synchronizeMessengerWithData)];
	[controller_ synchronizeMessengerWithData];
}

- (void)synchronizeWindowControllersFromDocument
{
	CMRReplyController	*controller_;
	
	controller_ = [self replyControllerRespondsTo:@selector(synchronizeDataFromMessenger)];
	[controller_ synchronizeDataFromMessenger];
}

- (NSString *)replyMessage
{
	return [[self infoDictionary] objectForKey:ThreadPlistContentsMessageKey];
}

- (NSString *)name
{
	return [[self infoDictionary] objectForKey:ThreadPlistContentsNameKey];
}

- (NSString *)mail
{
	return [[self infoDictionary] objectForKey:ThreadPlistContentsMailKey];
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
@end


@implementation CMRReplyMessenger(ScriptingSupport)
- (NSRange)selectedTextRange
{
	CMRReplyController *controller = [self replyControllerRespondsTo:@selector(textView)];
	return [[controller textView] selectedRange];
}

- (void)setTextStorage:(id)text
{
	NSAttributedString *tmp_;
    // NSAttributedString で渡された場合、一度書式を剥奪し、改めて書き込みウインドウのフォントとカラーを書式として付与する
    if ([text isKindOfClass:[NSAttributedString class]]) {
		NSString *tmpStr_ = [(NSAttributedString *)text string];
		tmp_ = [[NSAttributedString alloc] initWithString:tmpStr_ attributes:[self textAttributes]];		
    } else {
		tmp_ = [[NSAttributedString alloc] initWithString:(NSString *)text attributes:[self textAttributes]];
    }

	[[self textStorage] replaceCharactersInRange:NSMakeRange(0, [[self textStorage] length]) withAttributedString:tmp_];
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
	[[self textStorage] replaceCharactersInRange:[self selectedTextRange] withString:stringValue];
}

- (NSString *)targetURLAsString
{
	return [[self targetURL] stringValue];
}
@end


@implementation CMRReplyMessenger(Action)
- (void) sendMessage:(id)sender withHanaMogeraForms:(BOOL)withForms
{
	[self synchronizeDocumentContentsWithWindowControllers];
	[self sendMessageWithContents:[self replyMessage]
							 name:[self name]
							 mail:[self mail]
					   hanamogera:withForms];
}

- (IBAction)sendMessage:(id)sender
{
	[self sendMessage:sender withHanaMogeraForms:NO];
}

- (IBAction)revealInFinder:(id)sender
{
	NSString *path = [self fileName];
	if (!path) {
		NSBeep();
		return;
	}
	[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:[path stringByDeletingLastPathComponent]];
}
// override
- (IBAction)saveDocumentAs:(id)sender
{
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		// すり替え
		[self saveDocument:sender];
	} else {
		[super saveDocumentAs:sender];
	}
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	SEL		action_ = [theItem action];
	
	if (action_ == @selector(sendMessage:)) {
		return (![self isEndPost]);
	}
	if (action_ == @selector(saveDocument:)) {
		return ([self isDocumentEdited]);
	}
	return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(sendMessage:)) {
		return (![self isEndPost]);
	}
	
	if(action_ == @selector(saveDocumentAs:)) {
		[theItem setTitle:[self localizedString:@"Save Menu Item"]];
		return ([self isDocumentEdited]);
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
		statusStr_ = [NSString stringWithFormat:[self localizedString:MESSENGER_SEND_MESSAGE], [self formItemTitle]];
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

// from 0.0 to 100.0
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
