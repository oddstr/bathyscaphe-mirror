/**
  * $Id: CMRReplyMessenger.m,v 1.2 2005/06/27 14:08:50 tsawada2 Exp $
  * 
  * CMRReplyMessenger.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRReplyMessenger_p.h"
#import "CMRDocumentFileManager.h"
#import "CMRBBSSignature.h"
#import "CMRThreadSignature.h"
#import "CMRHostHandler.h"



NSString *const CMRReplyMessengerDidFinishPostingNotification = @"CMRReplyMessengerDidFinishPostingNotification";

#define kNewline			@"\n"
#define kQuotationMarksKey	@"quotation marks"



@implementation CMRReplyMessenger(Private)
+ (NSURL *) targetURLWithBoardURL : (NSURL *) boardURL
{
	return [[CMRHostHandler hostHandlerForURL : boardURL]
							writeURLWithBoard : boardURL];
}
+ (NSString *) formItemBBSWithBoardURL : (NSURL *) boardURL
{
	return [[boardURL path] lastPathComponent];
}
+ (NSString *) formItemDirectoryWithBoardURL : (NSURL *) boardURL
{
	return [[[boardURL path] stringByDeletingLastPathComponent] lastPathComponent];
}
@end



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
{ return [self getMutableInfoDictionary]; }

- (void) setReplyMessage : (NSString *) aMessage
{
	[[self getMutableInfoDictionary] setObject : aMessage
						forKey : ThreadPlistContentsMessageKey];
}
- (void) setName : (NSString *) aName
{
	[[self getMutableInfoDictionary] setObject : aName
						forKey : ThreadPlistContentsNameKey];
}
- (void) setMail : (NSString *) aMail
{
	[[self getMutableInfoDictionary] setObject : aMail
						forKey : ThreadPlistContentsMailKey];
}
- (void) setModifiedDate : (NSDate *) aModifiedDate
{
	[[self getMutableInfoDictionary] setObject : aModifiedDate
						forKey : CMRThreadModifiedDateKey];
}
- (void) setWindowFrame : (NSRect) aWindowFrame
{
	[[self getMutableInfoDictionary] setRect : aWindowFrame
					  forKey : CMRThreadWindowFrameKey];
}
//
//	deprecated in BathyScaphe 1.0.2
//
/*
- (void) setReplyTextFont : (NSFont *) aFont;
{
	[[self getMutableInfoDictionary] setFont : aFont
					  forKey : CMRReplyDocumentFontKey];
}
- (void) setReplyTextColor : (NSColor *) aColor
{
	[[self getMutableInfoDictionary] setColor : aColor
					   forKey : CMRReplyDocumentColorKey];
}
*/

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
	/*NSFont		*font_;
	
	font_ = [[self infoDictionary] fontForKey : CMRReplyDocumentFontKey];
	if (nil == font_) font_ = [CMRPref replyFont];
	
	return font_;*/
	return [CMRPref replyFont];
}
- (NSColor *) replyTextColor
{
	/*NSColor		*color_;
	
	color_ = [[self infoDictionary] colorForKey : CMRReplyDocumentColorKey];
	if (nil == color_) color_ = [CMRPref replyTextColor];

	return color_;*/
	return [CMRPref replyTextColor];
}
@end



@implementation CMRReplyMessenger(SendMeesage)
#define XML_YEN_ENTITY		@"&yen;"
- (NSString *) stringByReplacingYenBackslashToEntity : (NSString *) str
{
	NSString	*newstr = str;
	
	newstr = [newstr stringByReplaceCharacters : [NSString backslash]
									  toString : [NSString yenmark]];
	newstr = [newstr stringByReplaceCharacters : [NSString yenmark] 
									  toString : XML_YEN_ENTITY];
	
	return newstr;
}
- (NSDictionary *) formDictionary : (NSString *) replyMessage
                             name : (NSString *) name
                             mail : (NSString *) mail
{
	CMRHostHandler		*handler_;
	NSDictionary		*formKeys_;
	NSString			*key_;
	
	NSMutableDictionary	*form_ = [NSMutableDictionary dictionary];
	NSDate				*date_;
	NSString			*time_;
	
	if (nil == name || nil == mail || nil == replyMessage)
		return nil;
	
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	formKeys_ = [handler_ formKeyDictionary];
	if (nil == formKeys_ || nil == handler_) {
		NSLog(@"Can't find hostHandler for %@", [[self boardURL] stringValue]);
		return nil;
	}
	
	// 2002/12/31
	//「餅つけ」対策
	date_ = [[CMRServerClock sharedInstance] lastAccessedDateForURL : [self targetURL]];
	if (nil == date_) date_ = [NSDate date];
	time_ = [[NSNumber numberWithInt : [date_ timeIntervalSince1970]] stringValue];
	
	
	key_ = [formKeys_ stringForKey : CMRHostFormSubmitKey];
	[form_ setNoneNil:[handler_ submitValue] forKey:key_];
	
	key_ = [formKeys_ stringForKey : CMRHostFormNameKey];
	[form_ setNoneNil:name forKey:key_];
	
	key_ = [formKeys_ stringForKey : CMRHostFormMailKey];
	[form_ setNoneNil:mail forKey:key_];

    // 本文のみ円記号とバッスラッシュを実体参照で置換する。
	key_ = [formKeys_ stringForKey : CMRHostFormMessageKey];
	[form_ setNoneNil : [self stringByReplacingYenBackslashToEntity : replyMessage]
    forKey : key_];

	key_ = [formKeys_ stringForKey : CMRHostFormBBSKey];
	[form_ setNoneNil:[self formItemBBS] forKey:key_];

	key_ = [formKeys_ stringForKey : CMRHostFormIDKey];
	[form_ setNoneNil:[self formItemKey] forKey:key_];

	key_ = [formKeys_ stringForKey : CMRHostFormTimeKey];
	[form_ setNoneNil:time_ forKey:key_];
	
	// for Jbbs_shita
	key_ = [formKeys_ stringForKey : CMRHostFormDirectoryKey];
	if (key_ != nil && NO == [key_ isEmpty])
		[form_ setNoneNil:[self formItemDirectory] forKey:key_];
	
	return form_;
}


- (void) sendMessageWithContents : (NSString *) replyMessage
                            name : (NSString *) name
                            mail : (NSString *) mail
{
    id<w2chConnect>     connector_;
    NSMutableDictionary *headers_;
    NSString            *referer_;
    NSString            *cookies_;
    NSDictionary        *formDictionary_;
    
    [self setIsEndPost : YES];
    headers_ = [NSMutableDictionary dictionary];
    referer_ = [self refererParameter];
    cookies_ = [[CookieManager defaultManager] cookiesForRequestURL : [self targetURL]];


    if (referer_ != nil && [referer_ length] > 0) {
        [headers_ setObject : referer_
                     forKey : HTTP_REFERER_KEY];
    }
    if (cookies_ != nil && [cookies_ length] > 0) {
        [headers_ setObject : cookies_
                     forKey : HTTP_COOKIE_HEADER_KEY];
    }

    //プラグインをロード
    connector_ = [CMRPref w2chConnectWithURL : [self targetURL]
                                  properties : headers_];
    formDictionary_ = [self formDictionary : replyMessage
                                      name : name
                                      mail : mail];

    UTILDebugWrite1(@"targetURL = %@", [[self targetURL] absoluteString]);
    UTILDebugWrite2(@"name = %@, mail = %@", name, mail);
    UTILDebugWrite1(@"referer = %@", referer_);
    UTILDebugWrite1(@"cookie = %@", cookies_);
    UTILDebugWrite1(@"formDictionary = %@", [formDictionary_ description]);
    if (NO == [connector_ writeForm : formDictionary_]) {
        UTILDebugWrite(@"[FATAL] Can't write form data as URL encoded.");
		[self setIsEndPost : NO]; //ユーザが編集して再送信できるように
        return;
    }
    
    [connector_ setDelegate : self];
    [[CMRTaskManager defaultManager] addTask : self];
    _isInProgress = YES;
    
    UTILNotifyName(CMRTaskWillStartNotification);
    [connector_ loadInBackground];
    [self setModifiedDate : [NSDate date]];
}
- (NSString *) refererParameter
{
	NSString *host_;
	
	UTILAssertNotNil([self targetURL]);
	UTILAssertNotNil([self formItemBBS]);
	
	host_ = [[self targetURL] host];
	if (can_readcgi([host_ UTF8String])) {
		
		
	}else if (is_shitaraba([host_ UTF8String])) {
		// http://cgi.shitaraba.com/cgi-bin/bbs.cgi
		// ホストが異なる
		host_ = MESSENGER_SHITARABA_REFERER;
	}
	return [NSString stringWithFormat : MESSENGER_REFERER_FORMAT, 
										host_, 
										[self formItemBBS],
										MESSENGER_REFERER_INDEX_HTML];
}
- (void) receiveCookiesWithResponse : (NSDictionary *) headers
{
	NSString			*set_cookie_;
	
	if (nil == headers || 0 == [headers count]) return;
	set_cookie_ = [headers objectForKey : HTTP_SET_COOKIE_HEADER_KEY];
	if (nil == set_cookie_ || 0 == [set_cookie_ length]) return;
	// クッキーを追加
	[[CookieManager defaultManager] addCookies : set_cookie_
								    fromServer : [[self targetURL] host]];
}
@end

@implementation CMRReplyMessenger(ScriptingSupport)
- (void)setTextStorage : (id) text
{
    // TextEdit　を参考に...
    if ([text isKindOfClass:[NSAttributedString class]]) {
        [[self textStorage] replaceCharactersInRange : NSMakeRange(0, [[self textStorage] length]) withAttributedString : text];
    } else {
        [[self textStorage] replaceCharactersInRange : NSMakeRange(0, [[self textStorage] length]) withString : text];
    }
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
- (IBAction) toggleBeLogin : (id) sender
{
	[CMRPref setShouldLoginBe2chAnyTime : ![CMRPref shouldLoginBe2chAnyTime]];
}

- (BOOL) checkBe2chAccount
{
	NSString	*dmdm_;
	NSString	*mdmd_;
	
	dmdm_ = [CMRPref be2chAccountMailAddress];
	if (dmdm_ == nil || [dmdm_ length] == 0) return NO;

	mdmd_ = [CMRPref be2chAccountCode];
	if (mdmd_ == nil || [mdmd_ length] == 0) return NO;
	
	return YES;
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
	if (action_ == @selector(toggleBeLogin:)) {
		NSString *host_ = [[self targetURL] host];
		
		if (![self checkBe2chAccount]) {
			[theItem setImage : [NSImage imageAppNamed : kImageForLoginOff]];
			[theItem setLabel : [self localizedString : kLabelForLoginOff]];
			[theItem setToolTip : [self localizedString : kToolTipForCantLoginOn]];
			return NO;
		}
		if (!is_2channel([host_ UTF8String])) {
			[theItem setImage : [NSImage imageAppNamed : kImageForLoginOff]];
			[theItem setLabel : [self localizedString : kLabelForLoginOff]];
			[theItem setToolTip : [self localizedString : kToolTipForTrivialLoginOff]];
			return NO;
		}
		if ([host_ isEqualToString : @"be.2ch.net"] || [host_ isEqualToString : @"qa.2ch.net"]) {
			[theItem setImage : [NSImage imageAppNamed : kImageForLoginOn]];
			[theItem setLabel : [self localizedString : kLabelForLoginOn]];
			[theItem setToolTip : [self localizedString : kToolTipForNeededLogin]];
			return NO;
		} else {
			NSString				*title_, *tooltip_;
			NSImage					*image_;
		
			if ([CMRPref shouldLoginBe2chAnyTime]) {
				title_ = [self localizedString : kLabelForLoginOn];
				tooltip_ = [self localizedString : kToolTipForLoginOn];
				image_ = [NSImage imageAppNamed : kImageForLoginOn];
			} else {
				title_ = [self localizedString : kLabelForLoginOff];
				tooltip_ = [self localizedString : kToolTipForLoginOff];
				image_ = [NSImage imageAppNamed : kImageForLoginOff];
			}
			[theItem setImage : image_];
			[theItem setLabel : title_];
			[theItem setToolTip : tooltip_];
			return YES;
		}
	}
	return NO;
}
@end



@implementation CMRReplyMessenger(ConnectClient)
- (void) didFinish : (SGHTTPConnector *) connector
{
    _isInProgress = NO;
    UTILNotifyName(CMRTaskDidFinishNotification);
}
- (void) didFailPosting : (SGHTTPConnector *) connector
{
	[self didFinish : connector];
    [self setIsEndPost : NO]; //再送信を試みることができるように
}
- (void) didFinishPosting : (SGHTTPConnector *) connector
{
    [self didFinish : connector];
    [self receiveCookiesWithResponse : [[connector response] allHeaderFields]];
    [self saveDocument : nil];
    
    [self close];
}


- (void)               connector : (id<w2chConnect>) sender
  resourceDataDidBecomeAvailable : (NSData      *) newBytes
{
	 UTILNotifyName(CMRTaskWillProgressNotification);
}
- (void) connectorResourceDidBeginLoading : (id<w2chConnect>) sender
{
	UTILNotifyName(CMRTaskWillStartNotification);
}

/* 書き込みエラー */
- (void) cookieOrContributionCheckSheetDidEnd : (NSWindow *) sheet
								   returnCode : (int) returnCode
								  contextInfo : (void *) contextInfo
{
	if (NSAlertDefaultReturn == returnCode) {
		[self sendMessage : self];
	}
}

- (void) beginErrorInformationalAlertSheet : (NSString *) title
								   message : (NSString *) message
							  contribution : (BOOL      ) contribution
{
	NSWindow	*docWindow;
	SEL			didEndSelector;
	NSString	*message_ = message;
	NSArray		*lines_;
	
	docWindow = [[self replyControllerRespondsTo : @selector(window)] window];
	didEndSelector = contribution
		? @selector(cookieOrContributionCheckSheetDidEnd:returnCode:contextInfo:)
		: NULL;
	
	// あまりにも長いエラーメッセージは切り詰める
	lines_ = [message_ componentsSeparatedByNewline];
	if ([lines_ count] > 10) {
		lines_ = [lines_ subarrayWithRange:NSMakeRange(0, 10)];
		message_ = [lines_ componentsJoinedByString : @"\n"];
	}
	
	NSBeginInformationalAlertSheet(
				title,
				contribution ? [self localizedString:@"Try Again"] : @"OK",
				contribution ? [self localizedString:@"Cancel"] : nil,
				nil,
				docWindow,
				contribution ? self : nil,
				didEndSelector,	// didEndSelector
				NULL,			// didDismissSelector
				NULL,			// contextInfo
				@"%@", message_);
}
- (BOOL) isCookieOrContributionCheckError : (SG2chServerError) error
{
	return (k2chContributionCheckErrorType == error.type || k2chSPIDCookieErrorType == error.type);
}

- (void) connector                 : (id<w2chConnect>      ) sender
   resourceDidFailLoadingWithError : (id<w2chErrorHandling>) handler
{
	BOOL		contribution;
	
	[self didFailPosting : [sender HTTPConnector]];
	contribution = [self isCookieOrContributionCheckError : [handler recentError]];
	
	if (contribution)	// 書き込み確認、クッキー確認
		[self receiveCookiesWithResponse : [sender responseHeaders]];
	
	[self beginErrorInformationalAlertSheet : [handler recentErrorTitle]
									message : [handler recentErrorMessage]
							   contribution : contribution];
}

- (void) connectorResourceDidFinishLoading : (id<w2chConnect>) sender
{
	[self didFinishPosting : [sender HTTPConnector]];
	UTILNotifyName(CMRReplyMessengerDidFinishPostingNotification);
}


- (void) connectorResourceDidCancelLoading : (id<w2chConnect>) sender
{
	[self didFailPosting : [sender HTTPConnector]];
}


- (void)                     connector : (id<w2chConnect>) sender
      resourceDidFailLoadingWithReason : (NSString      *) reason
{
	NSRunAlertPanel(
		[self localizedString : MESSENGER_ERROR_POST],
		reason,
		nil,
		nil,
		nil);
	[self didFailPosting : [sender HTTPConnector]];
}
@end






@implementation CMRReplyMessenger(PrivateAccessor)
- (CMRReplyController *) replyControllerRespondsTo : (SEL) aSelector
{
	NSEnumerator		*iter_;
	CMRReplyController	*controller_;
	
	iter_ = [[self windowControllers] objectEnumerator];
	while (controller_ = [iter_ nextObject]) {
		if (aSelector != NULL && NO == [controller_ respondsToSelector : aSelector])
			continue;
		if (NO == [controller_ isKindOfClass : [CMRReplyController class]])
			continue;
		
		return controller_;
	}
	return nil;
}

- (NSString *) threadTitle
{
	return [[self infoDictionary] objectForKey : CMRThreadTitleKey];
}
- (NSString *) formItemBBS
{
	return [[self class] formItemBBSWithBoardURL : [self boardURL]];
}
- (NSString *) formItemDirectory
{
	return [[self class] formItemDirectoryWithBoardURL : [self boardURL]];
}
- (NSString *) formItemKey
{
	return [[self infoDictionary] objectForKey : ThreadPlistIdentifierKey];
}
- (id) boardIdentifier
{
	return [CMRBBSSignature BBSSignatureWithName : [self boardName]];
}
- (id) threadIdentifier
{
	return [CMRThreadSignature threadSignatureWithIdentifier:[self formItemKey] BBSSignature:[self boardIdentifier]];
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
