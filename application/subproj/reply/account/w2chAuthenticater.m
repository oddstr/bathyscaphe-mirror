//
//  w2chAuthenticater.m
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/10/20.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "w2chAuthenticater_p.h"

#define APP_SEARCH_PREFIX			@"SESSION-ID="
#define STR_COLON					@":"
#define APP_2CH_AUTH_ERROR_STR		@"ERROR"


static AppDefaults	*st_defaults		= nil;

@implementation w2chAuthenticater
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultAuthenticater);

- (id)init
{
	if(self = [super init]){
		[self setRecentStatusCode:200];
		[self setRecentErrorType:w2chNoError];
	}
	return self;
}

- (void)dealloc
{
	[m_sessionID release];
	[super dealloc];
}

- (BOOL)runModalForLoginWindow:(NSString **)accountPtr password:(NSString **)passwordPtr shouldUsesKeychain:(BOOL *)savePassPtr
{
	NSString			*account_;
	NSString			*password_;
	LoginController		*lgin_;
	BOOL				result_;
	
	if(accountPtr != NULL) *accountPtr = nil;
	if(passwordPtr != NULL) *passwordPtr = nil;

	lgin_ = [[LoginController alloc] init];
	result_ = [lgin_ runModalForLoginWindow:&account_ password:&password_ shouldUsesKeychain:savePassPtr];
	[lgin_ release];
	
	if (!result_) {
		[self setRecentErrorType:w2chLoginCanceled];
		return NO;
	}

	UTILRequireCondition((account_ && [account_ length]), error_params_invalid);
	UTILRequireCondition((password_ && [password_ length]), error_params_invalid);
	
	if (accountPtr != NULL) *accountPtr = account_;
	if (![self account] && account_) [[[self class] preferences] setX2chUserAccount:account_];
	if (passwordPtr != NULL) *passwordPtr = password_;
	return YES;
	
error_params_invalid: {
		[self setRecentErrorType:w2chLoginParamsInvalid];
		return NO;
	}
}


/**
  * サーバから返されたセッションIDを解析し、IDとUserAgent
  * を取得。サーバがエラーを返した場合はNOを返す。
  * 
  * @param    contents    サーバから返された内容
  * @param    userAgent   UserAgent
  * @param    sessionID   セッションID
  * @return               サーバがエラーを返した場合はNOを返す。
  */
- (BOOL)parseResponseID:(NSString *)contents userAgent:(NSString **) userAgent sessionID:(NSString **)sessionID
{
	NSScanner       *scanner_;		//スキャナ
	NSString        *skipped_;		//読み込んだ文字列
	NSMutableString *sid_;			//セッションID
	BOOL             result_ = NO;

	if (!contents || [contents length] == 0) return result_;
	
	scanner_ = [NSScanner scannerWithString:contents];
	skipped_ = nil;
	sid_ = [NSMutableString string];
	
	if([scanner_ scanUpToString:APP_SEARCH_PREFIX intoString:&skipped_] ||
	   [[scanner_ string] hasPrefix:APP_SEARCH_PREFIX]) {
		NSCharacterSet *wsset_;
		
		//この時点でスキャナは@"SESSION-ID="の先頭部分にある。
		[scanner_ scanString:APP_SEARCH_PREFIX intoString:NULL];
		if (![scanner_ scanUpToString:STR_COLON intoString:&skipped_]) {
			//必ず成功するはず
			NSAssert(0, @"Unexpeced!");
		}
		
		//ERROR
		result_ = (NO == [skipped_ isEqualToString:APP_2CH_AUTH_ERROR_STR]);
		if (!result_) {
			//ログイン時のエラー
			[self setRecentErrorType:w2chLoginError];
		}
		if(userAgent != NULL){
			*userAgent = [[skipped_ copy] autorelease];
		}
		[sid_ appendString:skipped_];
		
		[scanner_ scanString:STR_COLON intoString:NULL];
		[sid_ appendString:STR_COLON];
		
		wsset_ = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		if ([scanner_ scanUpToCharactersFromSet:wsset_ intoString:&skipped_]) {
			//[sid_ appendString : skipped_];
		} else {
			skipped_ = [[scanner_ string] substringFromIndex:[scanner_ scanLocation]];
		}
		[sid_ appendString:skipped_];
		if(sessionID != NULL){
			*sessionID = sid_;
		}
	}else{
		result_ = NO;
	}
	return result_;
}

/**
  * 認証サーバに送信するデータを生成し、返す。
  * 
  * @param    userID    ユーザID
  * @param    password  パスワード
  * @return             送信するデータ
  */
- (NSData *)postingDataWithID:(NSString *)userID password:(NSString *)password
{
	NSString *forms_;		//Form形式
	
	if (!userID || !password) return [NSData data];
	forms_ = [NSString stringWithFormat:APP_X2CH_ID_PW_FORMAT, userID, password];
	
	return [forms_ dataUsingEncoding:[NSString defaultCStringEncoding]];
}

/**
  * 認証サーバにログインする。
  * 
  * @param    userID     ユーザID
  * @param    password   パスワード
  * @param    userAgent  認証されたUser-Agent
  * @param    sid        認証されたID
  * @return              認証に成功した場合はYES
  */
- (BOOL)login:(NSString  *)userID
	 password:(NSString  *)password
	userAgent:(NSString **)userAgent
	sessionID:(NSString **)sid
{
	NSURL				*requestURL_;		//認証用CGI
	NSMutableURLRequest *request_;
	NSURLResponse		*returningResponse_;

	NSData				*pst_data_;			//送信するデータ
	NSData				*resource_;			//サーバの返した内容(data)
	NSString			*contents_;			//サーバの返した内容(String)
	int					statusCode_;
	
	UTILMethodLog;
	
	UTILDescription(userID);
	UTILDescription(password);
	
	if (userAgent != NULL) *userAgent = nil;
	if (sid != NULL) *sid = nil;
	if (!userID || !password) {
		UTILDebugWrite(@"UserID or password was nil.");
		
		[self setRecentErrorType:w2chNoError];
		return NO;
	}
	
	//認証用CGIへと接続するオブジェクトの生成
	requestURL_ = [[self preferences] x2chAuthenticationRequestURL];

	request_ = [NSMutableURLRequest requestWithURL:requestURL_ cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	[request_ setHTTPMethod:HTTP_METHOD_POST];
	[request_ setHTTPShouldHandleCookies:NO];

	//リクエストヘッダの設定
	pst_data_ = [self postingDataWithID:userID password:password];

	[request_ setValue:@"close" forHTTPHeaderField:HTTP_CONNECTION_KEY];
	[request_ setValue:[requestURL_ host] forHTTPHeaderField:HTTP_HOST_KEY];
	[request_ setValue:USER_AGENT_WHEN_AUTHENTICATION forHTTPHeaderField:HTTP_USER_AGENT_KEY];
	[request_ setValue:[NSBundle applicationUserAgent] forHTTPHeaderField:APP_HTTP_X_2CH_UA_KEY];
	[request_ setValue:HTTP_CONTENT_URL_ENCODED_TYPE forHTTPHeaderField:HTTP_CONTENT_TYPE_KEY];
	[request_ setValue:[[NSNumber numberWithInt:[pst_data_ length]] stringValue] forHTTPHeaderField:HTTP_CONTENT_LENGTH_KEY];
	[request_ setHTTPBody:pst_data_];

	resource_ = [NSURLConnection sendSynchronousRequest:request_ returningResponse:&returningResponse_ error:NULL];
	
	if (!resource_) {
		UTILDebugWrite(@"Connection Error");
		
		[self setRecentErrorType:w2chConnectionError];
		return NO;
	}	

	UTILDebugWrite1(@"\n%@", [returningResponse_ description]);
	
	statusCode_ = [(NSHTTPURLResponse *)returningResponse_ statusCode];
	[self setRecentStatusCode:statusCode_];
	if (statusCode_ != 200) {
		UTILDebugWrite(@"Connection Error");
		[self setRecentErrorType:w2chNetworkError];
		return NO;
	}

	contents_ = [[[NSString alloc] initWithData:resource_ encoding:NSShiftJISStringEncoding] autorelease];

	return [self parseResponseID:contents_ userAgent:userAgent sessionID:sid];
}

#pragma mark Preferences
+ (AppDefaults *)preferences
{
	return st_defaults;
}

- (AppDefaults *)preferences
{
	return [[self class] preferences];
}

+ (void)setPreferencesObject:(AppDefaults *)defaults
{
	st_defaults = defaults;
}

- (NSString *)account
{
	return [[[self class] preferences] x2chUserAccount];
}

- (NSString *)password
{
	return [[[self class] preferences] password];
}

#pragma mark Accessors
- (NSString *)sessionID
{
	// 2008-04-29 tsawada2
	// セッションIDの取得から24時間以上経過している場合は、再ログインを試みる
	if (!m_sessionID || fabs([_lastLoggedInDate timeIntervalSinceNow]) > 60*60*24) {
		[self invalidate];
	}
	return m_sessionID;
}

- (void)setSessionID:(NSString *)aSessionID
{
	if (!aSessionID) {
		[_lastLoggedInDate release];
		_lastLoggedInDate = nil;
	} else {
		_lastLoggedInDate = [[NSDate date] retain];
	}
	[aSessionID retain];
	[m_sessionID release];
	m_sessionID = aSessionID;
}

- (int)recentStatusCode
{
	return m_recentStatusCode;
}

- (void)setRecentStatusCode:(int)aRecentStatusCode
{
	m_recentStatusCode = aRecentStatusCode;
}

- (w2chAuthenticaterErrorType)recentErrorType
{
	return m_recentErrorType;
}

- (void)setRecentErrorType:(w2chAuthenticaterErrorType)aRecentErrorType
{
	m_recentErrorType = aRecentErrorType;
}
@end


@implementation w2chAuthenticater(Invalidate)
- (BOOL)updateAccountAndPasswordIfNeeded:(NSString **)newAccountPtr
								password:(NSString **)newPasswordPtr
					  shouldUsesKeychain:(BOOL *)savePassPtr
{
	if (![[self preferences] shouldLoginIfNeeded]) return NO;
	
	if ([self account] && [[self preferences] hasAccountInKeychain]) {
		if(newAccountPtr != NULL) *newAccountPtr = [self account];
		if(newPasswordPtr != NULL) *newPasswordPtr = [self password];
		if(savePassPtr != NULL) *savePassPtr = NO;
		
		return YES;
	} else {
		return [self runModalForLoginWindow:newAccountPtr
								   password:newPasswordPtr
						 shouldUsesKeychain:savePassPtr];
	}
}

static inline NSString *titleKeyForErrorType(w2chAuthenticaterErrorType type)
{
	switch (type){
	case w2chNoError:
		return nil;
		break;
	case w2chNetworkError:
		return APP_AUTHENTICATER_ERR_NW_TITLE;
		break;
	case w2chLoginError:
		return APP_AUTHENTICATER_ERR_LOGIN_TITLE;
		break;
	case w2chConnectionError:
		return APP_AUTHENTICATER_ERR_CONNECT_TITLE;
		break;
	default:
		return nil;
		break;
	}
	return nil;
}

static inline NSString *messageKeyForErrorType(w2chAuthenticaterErrorType type)
{
	switch (type){
	case w2chNoError:
		return nil;
		break;
	case w2chNetworkError:
		return APP_AUTHENTICATER_ERR_NW_MSG;
		break;
	case w2chLoginError:
		return APP_AUTHENTICATER_ERR_LOGIN_MSG;
		break;
	case w2chConnectionError:
		return APP_AUTHENTICATER_ERR_CONNECT_MSG;
		break;
	default:
		return nil;
		break;
	}
	return nil;
}

- (BOOL)invalidate
{
	NSString	*account_;
	NSString	*pw_;
	NSString	*sid_;
	BOOL		result_;
	BOOL		usesKeychain_;
	
	[self setRecentErrorType:w2chNoError];
	[self setSessionID:nil];
	
	if (![self updateAccountAndPasswordIfNeeded:&account_ password:&pw_ shouldUsesKeychain:&usesKeychain_]) {
		return NO;
	}
	
	UTILRequireCondition((account_ && [account_ length]), error_params_invalid);
	UTILRequireCondition((pw_ && [pw_ length]), error_params_invalid);
	
	result_ = [self login:account_ password:pw_ userAgent:NULL sessionID:&sid_];

	if (result_) {
		[self setSessionID:sid_];
		if (usesKeychain_) [[self preferences] changeAccount:account_ password:pw_ usesKeychain:usesKeychain_];
	} else {
		NSString		*titleKey_;
		NSString		*msgKey_;
		
		titleKey_ = titleKeyForErrorType([self recentErrorType]);
		msgKey_ = messageKeyForErrorType([self recentErrorType]);
		
		if (titleKey_ && msgKey_){
			NSAlert	*alert_ = [[[NSAlert alloc] init] autorelease];
			
			[alert_ setAlertStyle:NSWarningAlertStyle];
			[alert_ setMessageText:PluginLocalizedStringFromTable(titleKey_, nil, nil)];
			[alert_ setInformativeText:PluginLocalizedStringFromTable(msgKey_, nil, nil)];
			[alert_ runModal];
		}
	}
	
	return result_;

error_params_invalid: {
		[self setRecentErrorType:w2chLoginParamsInvalid];
		return NO;
	}
}
@end
