//
//  CMRReplyMessenger-Connector.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/07/04.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyMessenger_p.h"
#import "CMRThreadSignature.h"
#import "CMRHostHandler.h"


@implementation CMRReplyMessenger(Private)
+ (NSURL *)targetURLWithBoardURL:(NSURL *)boardURL
{
	return [[CMRHostHandler hostHandlerForURL:boardURL] writeURLWithBoard:boardURL];
}

+ (NSString *)formItemBBSWithBoardURL:(NSURL *)boardURL
{
	return [[boardURL path] lastPathComponent];
}

+ (NSString *)formItemDirectoryWithBoardURL:(NSURL *)boardURL
{
	return [[[boardURL path] stringByDeletingLastPathComponent] lastPathComponent];
}

- (NSDictionary *)additionalForms
{
	return _additionalForms;
}

- (void)setAdditionalForms:(NSDictionary *)anAdditionalForms
{
	[anAdditionalForms retain];
	[_additionalForms release];
	_additionalForms = anAdditionalForms;
}
@end


@implementation CMRReplyMessenger(PrivateAccessor)
- (CMRReplyController *)replyControllerRespondsTo:(SEL)aSelector
{
	NSEnumerator		*iter_;
	CMRReplyController	*controller_;
	
	iter_ = [[self windowControllers] objectEnumerator];
	while (controller_ = [iter_ nextObject]) {
		if (aSelector != NULL && ![controller_ respondsToSelector:aSelector]) continue;
		if (![controller_ isKindOfClass:[CMRReplyController class]]) continue;
		
		return controller_;
	}
	return nil;
}

- (NSString *)threadTitle
{
	return [[self infoDictionary] objectForKey:CMRThreadTitleKey];
}

- (NSString *)formItemBBS
{
	return [[self class] formItemBBSWithBoardURL:[self boardURL]];
}

- (NSString *)formItemDirectory
{
	return [[self class] formItemDirectoryWithBoardURL:[self boardURL]];
}

- (NSString *)formItemKey
{
	return [[self infoDictionary] objectForKey:ThreadPlistIdentifierKey];
}

- (id)threadIdentifier
{
	return [CMRThreadSignature threadSignatureWithIdentifier:[self formItemKey] BBSName:[self boardName]];
}
@end


@implementation CMRReplyMessenger(ConnectClient)
- (void)didFinish
{
    [self setIsInProgress:NO];
    UTILNotifyName(CMRTaskDidFinishNotification);
}

- (void)didFailPosting
{
	[self didFinish];
    [self setIsEndPost:NO]; //再送信を試みることができるように
}

- (void)didFinishPosting:(id<w2chConnect>)sender
{
	[self didFinish];
	[self receiveCookiesWithResponse:(NSHTTPURLResponse *)[sender response]];
    [self saveDocument:nil];

    [self close];

	UTILNotifyName(CMRReplyMessengerDidFinishPostingNotification);
}

/* 書き込みエラー */
- (void)cookieOrContributionCheckSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (NSAlertFirstButtonReturn == returnCode) {
		[self sendMessage:self withHanaMogeraForms:([self additionalForms] != nil)];
	}
}

- (void)beginErrorInformationalAlertSheet:(NSError *)error contribution:(BOOL)contribution
{
	SEL			didEndSelector;
	NSString	*message_ = [[error userInfo] objectForKey:SG2chErrorMessageErrorKey];
	NSArray		*lines_;
	NSAlert		*alert_;
	
	didEndSelector = contribution ? @selector(cookieOrContributionCheckSheetDidEnd:returnCode:contextInfo:) : nil;
	
	// あまりにも長いエラーメッセージは切り詰める
	lines_ = [message_ componentsSeparatedByNewline];
	if ([lines_ count] > 10) {
		lines_ = [lines_ subarrayWithRange:NSMakeRange(0, 10)];
		message_ = [lines_ componentsJoinedByString:@"\n"];
	}

	alert_ = [[[NSAlert alloc] init] autorelease];
	[alert_ setAlertStyle:NSInformationalAlertStyle];
	[alert_ setMessageText:[[error userInfo] objectForKey:SG2chErrorTitleErrorKey]];
	[alert_ setInformativeText:message_];
	[alert_ setHelpAnchor:[self localizedString:@"Reply Error Sheet Help Anchor"]];
	[alert_ setShowsHelp:YES];

	[alert_ addButtonWithTitle:(contribution ? [self localizedString:@"Try Again"]:@"OK")];
	if (contribution) {
		[alert_ addButtonWithTitle:[self localizedString:@"Cancel"]];
	}
	[alert_ beginSheetModalForWindow:[self windowForSheet]
					   modalDelegate:(contribution ? self : nil)
					  didEndSelector:didEndSelector
					     contextInfo:nil];
}

- (BOOL)isCookieOrContributionCheckError:(NSError *)error
{
	int code = [error code];
	return (k2chContributionCheckErrorType == code || k2chSPIDCookieErrorType == code);
}

static inline NSString *labelForFieldName(NSString *key)
{
	// ZANTEI
	if ([key isEqualToString:@"FROM"]) {
		return NSLocalizedStringFromTable(@"FailedURLEncodingFROMFieldLabel", @"Messenger", nil);
	} else if ([key isEqualToString:@"mail"]) {
		return NSLocalizedStringFromTable(@"FailedURLEncodingmailFieldLabel", @"Messenger", nil);
	} else if ([key isEqualToString:@"MESSAGE"]) {
		return NSLocalizedStringFromTable(@"FailedURLEncodingMESSAGEFieldLabel", @"Messenger", nil);
	}

	return key;
}

- (void)connector:(id<w2chConnect>)sender didFailURLEncoding:(NSArray *)contextInfo
{
	NSAlert	*alert_ = [[[NSAlert alloc] init] autorelease];
	NSString *messageTemplate = [self localizedString:@"FailedURLEncodingAlertMessage"];

	[alert_ setAlertStyle:NSWarningAlertStyle];
	[alert_ setMessageText:[NSString stringWithFormat:messageTemplate, labelForFieldName([contextInfo objectAtIndex:0])]];
	[alert_ setInformativeText:[self localizedString:@"FailedURLEncodingAlertInformative"]];
	
	[alert_ beginSheetModalForWindow:[self windowForSheet]
					   modalDelegate:self
					  didEndSelector:nil
					     contextInfo:nil];
}	

- (void)connector:(id<w2chConnect>)sender resourceDidFailLoadingWithErrorHandler:(id<w2chErrorHandling>)handler
{
	BOOL	contribution;
	
	[self didFailPosting];

	contribution = [self isCookieOrContributionCheckError:[handler recentError]];
	
	if (contribution) {	// 書き込み確認、クッキー確認
		[self receiveCookiesWithResponse:(NSHTTPURLResponse *)[sender response]];
		[self setAdditionalForms:[handler additionalFormsData]];
	}

	[self beginErrorInformationalAlertSheet:[handler recentError] contribution:contribution];
}

- (void)connectorResourceDidFinishLoading:(id<w2chConnect>)sender
{
	[self didFinishPosting:sender];
}

- (void)connectorResourceDidCancelLoading:(id<w2chConnect>)sender
{
	[self didFailPosting];
}

- (void)connector:(id<w2chConnect>)sender resourceDidFailLoadingWithError:(NSError *)error
{
	[self didFailPosting];

	NSAlert	*alert_ = [[[NSAlert alloc] init] autorelease];

	[alert_ setAlertStyle:NSWarningAlertStyle];
	[alert_ setMessageText:[self localizedString:MESSENGER_ERROR_POST]];
	[alert_ setInformativeText:[error localizedDescription]];
	
	[alert_ beginSheetModalForWindow:[self windowForSheet]
					   modalDelegate:self
					  didEndSelector:nil
					     contextInfo:nil];
}
@end


@implementation CMRReplyMessenger(SendMeesage)
// メール欄アイコン付きのレスをコピペするとメール欄アイコンが 0xfffc (Object Replacement Character だそうです) に変換されペーストされる。
// これがURLエンコードできないため書き込みに失敗するので、これを削除する。
static inline NSString *removeObjectReplacementCharacter(NSString *str)
{
	return [str stringByReplaceCharacters:[NSString stringWithFormat:@"%C", 0xfffc] toString:@""];
}

#define XML_YEN_ENTITY		@"&yen;"
- (NSString *)stringByReplacingYenBackslashToEntity:(NSString *)str
{
	NSString	*newstr = str;
	
	newstr = [newstr stringByReplaceCharacters:[NSString backslash] toString:[NSString yenmark]];
	newstr = [newstr stringByReplaceCharacters:[NSString yenmark] toString:XML_YEN_ENTITY];
	
	return newstr;
}

- (NSDictionary *)formDictionary:(NSString *)replyMessage name:(NSString *)name mail:(NSString *)mail
{
	return [self formDictionary:replyMessage name:name mail:mail hanamogera:NO];
}

- (NSDictionary *)formDictionary:(NSString *)replyMessage name:(NSString *)name mail:(NSString *)mail hanamogera:(BOOL)addForms
{
	CMRHostHandler		*handler_;
	NSDictionary		*formKeys_;
	NSString			*key_;
	
	NSMutableDictionary	*form_ = [NSMutableDictionary dictionary];
	NSDate				*date_;
	NSString			*time_;
	
	if (!name || !mail || !replyMessage) return nil;

	handler_ = [CMRHostHandler hostHandlerForURL:[self boardURL]];
	formKeys_ = [handler_ formKeyDictionary];
	if (!formKeys_ || !handler_) {
		NSLog(@"Can't find hostHandler for %@", [[self boardURL] stringValue]);
		return nil;
	}
	
	// 2002/12/31
	//「餅つけ」対策
	date_ = [[CMRServerClock sharedInstance] lastAccessedDateForURL:[self targetURL]];
	if (!date_) date_ = [NSDate date];
	time_ = [[NSNumber numberWithInt:[date_ timeIntervalSince1970]] stringValue];
	
	
	key_ = [formKeys_ stringForKey:CMRHostFormSubmitKey];
	[form_ setNoneNil:[handler_ submitValue] forKey:key_];
	
	key_ = [formKeys_ stringForKey:CMRHostFormNameKey];
	[form_ setNoneNil:name forKey:key_];
	
	key_ = [formKeys_ stringForKey:CMRHostFormMailKey];
	[form_ setNoneNil:mail forKey:key_];

    // 本文のみ円記号とバッスラッシュを実体参照で置換する。
	key_ = [formKeys_ stringForKey:CMRHostFormMessageKey];
	[form_ setNoneNil:removeObjectReplacementCharacter([self stringByReplacingYenBackslashToEntity:replyMessage]) forKey:key_];

	key_ = [formKeys_ stringForKey:CMRHostFormBBSKey];
	[form_ setNoneNil:[self formItemBBS] forKey:key_];

	key_ = [formKeys_ stringForKey:CMRHostFormIDKey];
	[form_ setNoneNil:[self formItemKey] forKey:key_];

	key_ = [formKeys_ stringForKey:CMRHostFormTimeKey];
	[form_ setNoneNil:time_ forKey:key_];

	// for 2ch (after 2006-05-27, hana=mogera)
	if (addForms && [self additionalForms]) {
		[form_ addEntriesFromDictionary:[self additionalForms]];
	}
	// for Jbbs_shita
	key_ = [formKeys_ stringForKey:CMRHostFormDirectoryKey];
	if (key_ && ![key_ isEmpty]) {
		[form_ setNoneNil:[self formItemDirectory] forKey:key_];
	}
	return form_;
}

- (void)sendMessageWithContents:(NSString *)replyMessage name:(NSString *)name mail:(NSString *)mail
{
	[self sendMessageWithContents:replyMessage name:name mail:mail hanamogera:NO];
}

- (void)sendMessageWithContents:(NSString *)replyMessage name:(NSString *)name mail:(NSString *)mail hanamogera:(BOOL)addForms
{
    id<w2chConnect>     connector_;
    NSMutableDictionary *headers_;
    NSString            *referer_;
    NSString            *cookies_;
    NSDictionary        *formDictionary_;

    [self setIsEndPost:YES];
    headers_ = [NSMutableDictionary dictionary];
    referer_ = [self refererParameter];
    cookies_ = [[CookieManager defaultManager] cookiesForRequestURL:[self targetURL] withBeCookie:[self shouldSendBeCookie]];

    if (referer_ && [referer_ length] > 0) {
        [headers_ setObject:referer_ forKey:HTTP_REFERER_KEY];
    }
    if (cookies_ && [cookies_ length] > 0) {
        [headers_ setObject:cookies_ forKey:HTTP_COOKIE_HEADER_KEY];
    }

    //プラグインをロード
    connector_ = [CMRPref w2chConnectWithURL:[self targetURL] properties:headers_];
	[connector_ setDelegate:self];
    formDictionary_ = [self formDictionary:replyMessage name:name mail:mail hanamogera:addForms];

    UTILDebugWrite1(@"targetURL = %@", [[self targetURL] absoluteString]);
    UTILDebugWrite2(@"name = %@, mail = %@", name, mail);
    UTILDebugWrite1(@"referer = %@", referer_);
    UTILDebugWrite1(@"cookie = %@", cookies_);
    UTILDebugWrite1(@"formDictionary = %@", [formDictionary_ description]);

    if (![connector_ writeForm:formDictionary_]) {
        UTILDebugWrite(@"[FATAL] Can't write form data as URL encoded.");
		[self setIsEndPost:NO]; //ユーザが編集して再送信できるように
		return;
    }
    
    [[CMRTaskManager defaultManager] addTask:self];
    [self setIsInProgress:YES];
    
    UTILNotifyName(CMRTaskWillStartNotification);
    [connector_ loadInBackground];
    [self setModifiedDate:[NSDate date]];
}

- (NSString *)refererParameter
{
	NSString *host_;
	
	UTILAssertNotNil([self targetURL]);
	UTILAssertNotNil([self formItemBBS]);
	
	host_ = [[self targetURL] host];

/*	if (can_readcgi([host_ UTF8String])) {
		;
	} else if (is_shitaraba([host_ UTF8String])) {
		// http://cgi.shitaraba.com/cgi-bin/bbs.cgi
		// ホストが異なる
		host_ = MESSENGER_SHITARABA_REFERER;
	}*/
	return [NSString stringWithFormat:MESSENGER_REFERER_FORMAT, host_, [self formItemBBS], MESSENGER_REFERER_INDEX_HTML];
}

- (void)receiveCookiesWithResponse:(NSHTTPURLResponse *)response
{
	NSDictionary	*headers = [response allHeaderFields];	
	NSString		*cookies;
	
	if (!headers || [headers count] == 0) return;

	cookies = [headers objectForKey:HTTP_SET_COOKIE_HEADER_KEY];
	if (!cookies || [cookies length] == 0) return;

	[[CookieManager defaultManager] addCookies:cookies fromServer:[[response URL] host]];
}
@end
