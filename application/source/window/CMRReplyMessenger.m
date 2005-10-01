/**
  * $Id: CMRReplyMessenger.m,v 1.5 2005/10/01 15:08:57 tsawada2 Exp $
  * 
  * CMRReplyMessenger.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRReplyMessenger_p.h"
#import "CMRDocumentFileManager.h"
#import "BoardManager.h"

NSString *const CMRReplyMessengerDidFinishPostingNotification = @"CMRReplyMessengerDidFinishPostingNotification";

#define kNewline			@"\n"
#define kQuotationMarksKey	@"quotation marks"


@implementation CMRReplyMessenger
- (void) dealloc
{
	[_textStorage release];
	[_attributes release];
	[super dealloc];
}


- (NSMutableDictionary *) getMutableInfoDictionary
{
	if (nil == _attributes)
		_attributes = [[NSMutableDictionary alloc] init];
	
	return _attributes;
}
- (void) replaceInfoDictionary : (NSDictionary *) newDict
{
	id		tmp;
	
	tmp = _attributes;
	_attributes = [newDict mutableCopy];
	[tmp release];
}


- (NSDictionary *) textAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys : 
					[self replyTextFont], 
					NSFontAttributeName,
					[self replyTextColor], 
					NSForegroundColorAttributeName,
					nil];
}
- (NSDictionary *) infoDictionary
{
	return [self getMutableInfoDictionary];
}

- (void) setReplyMessage : (NSString *) aMessage
{
	[[self getMutableInfoDictionary] setObject : aMessage forKey : ThreadPlistContentsMessageKey];
}
- (void) setName : (NSString *) aName
{
	[[self getMutableInfoDictionary] setObject : aName forKey : ThreadPlistContentsNameKey];
}
- (void) setMail : (NSString *) aMail
{
	[[self getMutableInfoDictionary] setObject : aMail forKey : ThreadPlistContentsMailKey];
}
- (void) setModifiedDate : (NSDate *) aModifiedDate
{
	[[self getMutableInfoDictionary] setObject : aModifiedDate forKey : CMRThreadModifiedDateKey];
}
- (void) setWindowFrame : (NSRect) aWindowFrame
{
	[[self getMutableInfoDictionary] setRect : aWindowFrame forKey : CMRThreadWindowFrameKey];
}

- (NSTextStorage *) textStorage
{
	if (nil == _textStorage) {
		_textStorage = [[NSTextStorage alloc] init];
	}
	
	return _textStorage;
}
+ (NSString *) stringByQuoted : (NSString *) string
{
	NSString	*mark_;
	id			quotation_;
	
	NSArray			*allLines_;
	NSEnumerator	*iter_;
	NSString		*line_;
	BOOL			markLast = NO;
	
	if (nil == string || [string isEmpty])
		return string;
	
	quotation_ = [NSMutableString string];
	mark_ = [self localizedString : kQuotationMarksKey];
	
	allLines_ = [string componentsSeparatedByNewline];
	markLast = (NO == [[allLines_ lastObject] isEmpty]);
	iter_ = [allLines_ objectEnumerator];
	while (line_ = [iter_ nextObject]) {
		if (NO == markLast && line_ == [allLines_ lastObject])
			break;
		
		[quotation_ appendString : mark_];
		[quotation_ appendString : line_];
		[quotation_ appendString : kNewline];
	}
	
	quotation_ = [quotation_ copy];
	return [quotation_ autorelease];
}

- (void) setMessageContents : (NSString *) aContents
					replyTo : (unsigned  ) anIndex
{
	[self append:aContents quote:YES replyTo:anIndex];
}
/* 
	string  contents will be added
	quote   quote this string
	anIndex add anchor to index (no anchor if NSNotFound)
 */
- (void) append : (NSString *) string
		  quote : (BOOL      ) quote
		replyTo : (unsigned  ) anIndex
{
	id				textStorage_;
	
	if (nil == string) return;
	if (quote) string = [[self class] stringByQuoted : string];
	
	textStorage_ = [self textStorage];
	if (anIndex != NSNotFound) {
		// 2005-02-01 tsawada2<ben-sawa@td5.so-net.ne.jp>
		// 既にtextStorage_ の先頭にレスアンカーが記載されているなら、レスアンカーは付加しない
		// （textStorage_ が空だったとしても別にエラーにはならないようだ）
		if (![[textStorage_ string] hasPrefix : [NSString stringWithFormat : @">>%u",anIndex+1]]){
			string = [NSString stringWithFormat : @">>%u\n%@", anIndex+1, string];
		}
	}
	
	[textStorage_ beginEditing];
	[textStorage_ appendString:string withAttributes:[self textAttributes]];
	[textStorage_ endEditing];
}

- (BOOL) isEndPost
{
	return _isEndPost;
}
- (void) setIsEndPost : (BOOL) anIsEndPost
{
	_isEndPost = anIsEndPost;
}
#pragma mark PrincessBride Additions
- (BOOL) shouldSendBeCookie
{
	return _shouldSendBeCookie;
}
- (void) setShouldSendBeCookie : (BOOL) sendBeCookie
{
	_shouldSendBeCookie = sendBeCookie;
}

#pragma mark NSDocument methods

- (NSString *) displayName
{
	return [NSString stringWithFormat : 
				[self localizedString : REPLY_MESSENGER_WINDOW_TITLE_FORMAT],
				[self formItemTitle]];
}

- (void) makeWindowControllers
{
	NSWindowController		*controller_;
	
	controller_ = [[CMRReplyController alloc] init];
	[self addWindowController : controller_];
	[controller_ release];
}

- (void) setUpBeLoginSetting
{
	NSString	*bName_ = [self boardName];
	NSString	*host_ = [[self targetURL] host];

	if (![self checkBe2chAccount] || !is_2channel([host_ UTF8String])) {
		[self setShouldSendBeCookie : NO];
		return;
	}

	if ([host_ isEqualToString : @"be.2ch.net"] || [host_ isEqualToString : @"qa.2ch.net"]) {
		[self setShouldSendBeCookie : YES];
		return;
	}
	
	[self setShouldSendBeCookie : [[BoardManager defaultManager] alwaysBeLoginAtBoard : bName_]];
}

- (BOOL) readFromFile : (NSString *) fileName
			   ofType : (NSString *) aType
{
	if ([aType isEqualToString : CMRReplyDocumentType]) {
		NSDictionary		*dict_;
		NSArray				*documentAttributeKeys_;
		NSEnumerator		*iter_;
		NSString			*key_;
		
		documentAttributeKeys_ = [CMRReplyDocumentFileManager documentAttributeKeys];
		iter_ = [documentAttributeKeys_ objectEnumerator];
		dict_ = [NSDictionary dictionaryWithContentsOfFile : fileName];
		
		while (key_ = [iter_ nextObject]) {
			if (nil == [dict_ objectForKey : key_])
				return NO;
		}
		
		[self replaceInfoDictionary : dict_];
		[self synchronizeWindowControllersFromDocument];
		// ここで be ログインの設定をする？（be ログインの設定をスレごとに記憶することはしない。
		// あくまでも板ごとの設定（それがなければ、グローバルな設定）に従う。
		[self setUpBeLoginSetting];
		return (dict_ != nil);
	}
	return NO;
}
- (BOOL) writeToFile : (NSString *) fileName
			  ofType : (NSString *) type
{
	if ([type isEqualToString : CMRReplyDocumentType]) {
		NSArray				*documentAttributeKeys_;
		NSEnumerator		*iter_;
		NSString			*key_;
		
		[self synchronizeDocumentContentsWithWindowControllers];
		if ([self isEndPost])
			[self setReplyMessage : @""];
		
		documentAttributeKeys_ = [CMRReplyDocumentFileManager documentAttributeKeys];
		iter_ = [documentAttributeKeys_ objectEnumerator];
		
		while (key_ = [iter_ nextObject]) {
			if (nil == [[self infoDictionary] objectForKey : key_])
				return NO;
		}
		
		return [[self infoDictionary] writeToFile:fileName atomically:YES];
	}
	return NO;
}
@end



@implementation CMRReplyMessenger(Attributes)
- (NSString *) boardName
{
	return [[self infoDictionary] objectForKey : ThreadPlistBoardNameKey];
}
- (NSString *) formItemTitle
{
	return [self threadTitle];
}
- (NSURL *) boardURL
{
	return [[BoardManager defaultManager] URLForBoardName : [self boardName]];
}
- (NSURL *) targetURL
{
	return [[self class] targetURLWithBoardURL : [self boardURL]];
}
- (void) synchronizeDocumentContentsWithWindowControllers
{
	CMRReplyController	*controller_;
	
	controller_ = [self replyControllerRespondsTo : @selector(synchronizeMessengerWithData)];
	[controller_ synchronizeMessengerWithData];
}
- (void) synchronizeWindowControllersFromDocument
{
	CMRReplyController	*controller_;
	
	controller_ = [self replyControllerRespondsTo : @selector(synchronizeDataFromMessenger)];
	[controller_ synchronizeDataFromMessenger];
}



- (NSString *) replyMessage
{
	return [[self infoDictionary] objectForKey : ThreadPlistContentsMessageKey];
}
- (NSString *) name
{
	return [[self infoDictionary] objectForKey : ThreadPlistContentsNameKey];
}
- (NSString *) mail
{
	return [[self infoDictionary] objectForKey : ThreadPlistContentsMailKey];
}
- (NSDate *) modifiedDate
{
	id		modifiedDate_;
	
	modifiedDate_ = [[self infoDictionary] objectForKey : CMRThreadModifiedDateKey];
	if (nil == modifiedDate_ || NO == [modifiedDate_ isKindOfClass : [NSDate class]])
		return [NSDate date];
	
	return modifiedDate_;
}
- (NSRect) windowFrame
{
	return [[self infoDictionary] rectForKey : CMRThreadWindowFrameKey];
}
- (NSFont *) replyTextFont
{
	return [CMRPref replyFont];
}
- (NSColor *) replyTextColor
{
	return [CMRPref replyTextColor];
}
@end


@implementation CMRReplyMessenger(ScriptingSupport)
- (void)setTextStorage : (id) text
{
	NSAttributedString *tmp_;
    // NSAttributedString で渡された場合、一度書式を剥奪し、改めて書き込みウインドウのフォントとカラーを書式として付与する
    if ([text isKindOfClass:[NSAttributedString class]]) {
		NSString *tmpStr_ = [(NSAttributedString *)text string];
		tmp_ = [[NSAttributedString alloc] initWithString : tmpStr_ attributes : [self textAttributes]];		
    } else {
		tmp_ = [[NSAttributedString alloc] initWithString : (NSString *)text attributes : [self textAttributes]];
    }

	[[self textStorage] replaceCharactersInRange : NSMakeRange(0, [[self textStorage] length]) withAttributedString : tmp_];
}
- (NSString *) targetURLAsString
{
	return [[self targetURL] stringValue];
}
@end

@implementation CMRReplyMessenger(Action)
- (IBAction) sendMessage : (id) sender
{

	[self synchronizeDocumentContentsWithWindowControllers];
	[self sendMessageWithContents : [self replyMessage]
							 name : [self name]
							 mail : [self mail]];
}
- (IBAction) openLogfile : (id) sender
{
	[[NSWorkspace sharedWorkspace]
				openFile : [self fileName]
		 withApplication : @"Property List Editor.app"];
}

- (BOOL) validateToolbarItem : (NSToolbarItem *) theItem
{
	SEL		action_;
	
	if (nil == theItem) return NO;

	action_ = [theItem action];
	
	if (action_ == @selector(openLogfile:)) return YES;
	if (action_ == @selector(sendMessage:)) {
		return (NO == [self isEndPost]);
	}
	if (action_ == @selector(saveDocument:)) {
		return ([self isDocumentEdited]);
	}
	return NO;
}
@end


@implementation CMRReplyMessenger(CMRTaskImplementation)
- (NSString *) identifier
{
	return [self description];
}

- (NSString *) title
{
	return [self displayName];
}
- (NSString *) message
{
	NSString *statusStr_;
	
	if ([self isInProgress]) {
		statusStr_ = 
		  [NSString stringWithFormat : 
				[self localizedString : MESSENGER_SEND_MESSAGE],
				[self formItemTitle]];
	} else {
		statusStr_ = [self localizedString : MESSENGER_END_POST];
	}
	return statusStr_;
}

- (BOOL) isInProgress
{
	return _isInProgress;
}

// from 0.0 to 100.0
- (double) amount
{
	return -1;
}
- (IBAction) cancel : (id) sender
{
	;
}
@end


@implementation CMRReplyMessenger(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
	return MESSENGER_TABLE_NAME;
}
@end
