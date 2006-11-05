//
//  $Id: CMRReplyMessenger-Connector.m,v 1.11 2006/11/05 12:53:48 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/07/04.
//  CMRReplyMessenger.m から分割
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import "CMRReplyMessenger_p.h"
#import "CMRThreadSignature.h"
#import "CMRHostHandler.h"


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
- (NSDictionary *) additionalForms
{
	return _additionalForms;
}
- (void) setAdditionalForms : (NSDictionary *) anAdditionalForms
{
	[anAdditionalForms retain];
	[_additionalForms release];
	_additionalForms = anAdditionalForms;
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
	return [self boardName];
}
- (id) threadIdentifier
{
	return [CMRThreadSignature threadSignatureWithIdentifier:[self formItemKey] BBSName:[self boardName]];
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
- (void) cookieOrContributionCheckSheetDidEnd : (NSAlert *) alert
								   returnCode : (int) returnCode
								  contextInfo : (void *) contextInfo
{
	if (NSAlertFirstButtonReturn == returnCode) {
		[self sendMessage : self withHanaMogeraForms : ([self additionalForms] != nil)];
	}
	[alert release];
}

- (void) beginErrorInformationalAlertSheet : (NSString *) title
								   message : (NSString *) message
							  contribution : (BOOL      ) contribution
{
	NSWindow	*docWindow;
	SEL			didEndSelector;
	NSString	*message_ = message;
	NSArray		*lines_;

	NSAlert		*alert_;
	
	docWindow = [[self replyControllerRespondsTo : @selector(window)] window];
	didEndSelector = contribution ? @selector(cookieOrContributionCheckSheetDidEnd:returnCode:contextInfo:) : nil;
	
	// あまりにも長いエラーメッセージは切り詰める
	lines_ = [message_ componentsSeparatedByNewline];
	if ([lines_ count] > 10) {
		lines_ = [lines_ subarrayWithRange:NSMakeRange(0, 10)];
		message_ = [lines_ componentsJoinedByString : @"\n"];
	}

	alert_ = [[NSAlert alloc] init];
	[alert_ setAlertStyle : NSInformationalAlertStyle];
	[alert_ setMessageText : title];
	[alert_ setInformativeText : message_];
	[alert_ setHelpAnchor : [self localizedString : @"Reply Error Sheet Help Anchor"]];
	[alert_ setShowsHelp : YES];
	
	[alert_ addButtonWithTitle : (contribution ? [self localizedString : @"Try Again"] : @"OK")];
	if(contribution)
		[alert_ addButtonWithTitle : [self localizedString : @"Cancel"]];

	[alert_ beginSheetModalForWindow : docWindow
					   modalDelegate : (contribution ? self : nil)
					  didEndSelector : didEndSelector
					     contextInfo : nil];
}

- (BOOL) isCookieOrContributionCheckError : (SG2chServerError) error
{
	return (k2chContributionCheckErrorType == error.type || k2chSPIDCookieErrorType == error.type);
}

- (void)				  connector : (id<w2chConnect>      ) sender
	resourceDidFailLoadingWithError : (id<w2chErrorHandling>) handler
{
	BOOL		contribution;
	
	[self didFailPosting : [sender HTTPConnector]];
	contribution = [self isCookieOrContributionCheckError : [handler recentError]];
	
	if (contribution) {	// 書き込み確認、クッキー確認
		[self receiveCookiesWithResponse : [sender responseHeaders]];
		
		if ([handler respondsToSelector: @selector(additionalFormsData)]) {
			[self setAdditionalForms : [handler additionalFormsData]];
		}
	}
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
	NSAlert	*alert_ = [[NSAlert alloc] init];

	[alert_ setAlertStyle : NSWarningAlertStyle];
	[alert_ setMessageText : [self localizedString : MESSENGER_ERROR_POST]];
	[alert_ setInformativeText : reason];
	[alert_ addButtonWithTitle : @"OK"];
	
	[alert_ runModal];
	
	[alert_ release];

	[self didFailPosting : [sender HTTPConnector]];
}
@end


@implementation CMRReplyMessenger(SendMeesage)
// メール欄アイコン付きのレスをコピペするとメール欄アイコンが 0xfffc (Object Replacement Character だそうです) に変換されペーストされる。
// これがURLエンコードできないため書き込みに失敗するので、これを削除する。
static inline NSString *removeObjectReplacementCharacter(NSString *str)
{
	return [str stringByReplaceCharacters : [NSString stringWithFormat : @"%C", 0xfffc]
								 toString : @""];
}

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
	return [self formDictionary: replyMessage name: name mail: mail hanamogera: NO];
}

- (NSDictionary *) formDictionary : (NSString *) replyMessage
                             name : (NSString *) name
                             mail : (NSString *) mail
					   hanamogera : (BOOL) addForms
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
	[form_ setNoneNil : removeObjectReplacementCharacter([self stringByReplacingYenBackslashToEntity : replyMessage])
    forKey : key_];

	key_ = [formKeys_ stringForKey : CMRHostFormBBSKey];
	[form_ setNoneNil:[self formItemBBS] forKey:key_];

	key_ = [formKeys_ stringForKey : CMRHostFormIDKey];
	[form_ setNoneNil:[self formItemKey] forKey:key_];

	key_ = [formKeys_ stringForKey : CMRHostFormTimeKey];
	[form_ setNoneNil:time_ forKey:key_];

	// for 2ch (after 2006-05-27, hana=mogera)
	if (addForms && [self additionalForms] != nil)
		[form_ addEntriesFromDictionary: [self additionalForms]];
	
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
	[self sendMessageWithContents: replyMessage name: name mail: mail hanamogera: NO];
}

- (void) sendMessageWithContents : (NSString *) replyMessage
							name : (NSString *) name
							mail : (NSString *) mail
					  hanamogera : (BOOL ) addForms
{
    id<w2chConnect>     connector_;
    NSMutableDictionary *headers_;
    NSString            *referer_;
    NSString            *cookies_;
    NSDictionary        *formDictionary_;
    
    [self setIsEndPost : YES];
    headers_ = [NSMutableDictionary dictionary];
    referer_ = [self refererParameter];
    cookies_ = [[CookieManager defaultManager] cookiesForRequestURL : [self targetURL]
													   withBeCookie : [self shouldSendBeCookie]];

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
                                      mail : mail
								hanamogera : addForms];

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
