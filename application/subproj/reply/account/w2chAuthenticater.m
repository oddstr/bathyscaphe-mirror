//:w2chAuthenticater.m
/**
  *
  * @see w2chConnectorAlertUtil.h
  * @see Constants.h
  * @see AppDefaults.h
  * @see LoginController.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/04  4:09:21 AM)
  *
  */
#import "w2chAuthenticater_p.h"


//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
#define APP_SEARCH_PREFIX			@"SESSION-ID="
#define STR_COLON					@":"
#define APP_2CH_AUTH_ERROR_STR		@"ERROR"


static AppDefaults	*st_defaults		= nil;
static NSLock		*st_singleton_lock	= nil;



@implementation w2chAuthenticater
+ (void) initialize
{
	if(nil == st_singleton_lock)
		st_singleton_lock = [[NSLock alloc] init];
}

+ (id) defaultAuthenticater
{
	static id st_instance = nil;
	
	if(nil == st_instance){
		UTILAssertNotNil(st_singleton_lock);
		[st_singleton_lock lock];
		if(nil == st_instance){
			st_instance = [[self alloc] init];
		}
		[st_singleton_lock unlock];
	}
	return st_instance;
}


- (id) init
{
	if(self = [super init]){
		[self setRecentStatusCode : 200];
		[self setRecentErrorType : w2chNoError];
	}
	return self;
}

- (void) dealloc
{
	[m_sessionID release];
	[m_monazillaUserAgent release];
	[super dealloc];
}


- (BOOL) runModalForLoginWindow : (NSString **) accountPtr
                       password : (NSString **) passwordPtr
			 shouldUsesKeychain : (BOOL		 *) savePassPtr
{
	NSString			*account_;
	NSString			*password_;
	LoginController		*lgin_;
	BOOL				result_;
	
	if(accountPtr != NULL) *accountPtr = nil;
	if(passwordPtr != NULL) *passwordPtr = nil;
	lgin_ = [[LoginController alloc] init];
	result_ = [lgin_ runModalForLoginWindow : &account_
	                               password : &password_
					     shouldUsesKeychain : savePassPtr];
	[lgin_ release];
	
	if(NO == result_){
		[self setRecentErrorType : w2chLoginCanceled];
		return NO;
	}
	UTILRequireCondition(
		(account_ && [account_ length]),
		error_params_invalid);
	UTILRequireCondition(
		(password_ && [password_ length]),
		error_params_invalid);
	
	if(accountPtr != NULL) *accountPtr = account_;
	if(passwordPtr != NULL) *passwordPtr = password_;
	return YES;
	
	error_params_invalid:{
		[self setRecentErrorType : w2chLoginParamsInvalid];
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
- (BOOL) parseResponseID : (NSString  *) contents
               userAgent : (NSString **) userAgent
               sessionID : (NSString **) sessionID
{
	NSScanner       *scanner_;		//スキャナ
	NSString        *skipped_;		//読み込んだ文字列
	NSMutableString *sid_;			//セッションID
	BOOL             result_ = NO;

	if(nil == contents || 0 == [contents length])
		return result_;
	
	scanner_ = [NSScanner scannerWithString : contents];
	skipped_ = nil;
	sid_ = [NSMutableString string];
	
	if([scanner_ scanUpToString : APP_SEARCH_PREFIX intoString : &skipped_] ||
	   [[scanner_ string] hasPrefix : APP_SEARCH_PREFIX]){
		NSCharacterSet *wsset_;
		
		//この時点でスキャナは@"SESSION-ID="の先頭部分にある。
		[scanner_ scanString : APP_SEARCH_PREFIX intoString : NULL];
		if(NO == [scanner_ scanUpToString : STR_COLON intoString : &skipped_]){
			//必ず成功するはず
			NSAssert(
				0,
				@"Unexpeced!");
		}
		
		//ERROR
		result_ = (NO == [skipped_ isEqualToString : APP_2CH_AUTH_ERROR_STR]);
		if(NO == result_){
			//ログイン時のエラー
			[self setRecentErrorType : w2chLoginError];
		}
		if(userAgent != NULL){
			*userAgent = [[skipped_ copy] autorelease];
		}
		[sid_ appendString : skipped_];
		
		[scanner_ scanString : STR_COLON intoString : NULL];
		[sid_ appendString : STR_COLON];
		
		wsset_ = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		if([scanner_ scanUpToCharactersFromSet : wsset_
								    intoString : &skipped_]){
			//[sid_ appendString : skipped_];
		}else{			
			skipped_ = [[scanner_ string] substringFromIndex : [scanner_ scanLocation]];
		}
		[sid_ appendString : skipped_];
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
- (NSData *) postingDataWithID : (NSString *) userID
                      password : (NSString *) password
{
	NSString *forms_;		//Form形式
	
	if(nil == userID || nil == password) return [NSData data];
	forms_ = [NSString stringWithFormat : APP_X2CH_ID_PW_FORMAT,
										  userID,
										  password];
	
	return [forms_ dataUsingEncoding : [NSString defaultCStringEncoding]];
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
- (BOOL) login : (NSString  *) userID
      password : (NSString  *) password
     userAgent : (NSString **) userAgent
     sessionID : (NSString **) sid
{
	NSURL				*requestURL_;		//認証用CGI
	SGHTTPConnector		*connector_;		//接続オブジェクト
	NSData				*pst_data_;			//送信するデータ
	NSData				*resource_;			//サーバの返した内容(data)
	NSString			*contents_;			//サーバの返した内容(String)
	int					statusCode_;
	
	UTILMethodLog;
	
	UTILDescription(userID);
	UTILDescription(password);
	
	if(userAgent != NULL) *userAgent = nil;
	if(sid != NULL) *sid = nil;
	if(nil == userID || nil == password){
		UTILDebugWrite(@"UserID or password was nil.");
		
		[self setRecentErrorType : w2chNoError];
		return NO;
	}
	
	
	//認証用CGIへと接続するオブジェクトの生成
	requestURL_ = [[self preferences] x2chAuthenticationRequestURL];
	connector_ = [[SGHTTPSecureSocket allocWithZone : [self zone]]
						initWithURL : requestURL_
				      requestMethod : HTTP_METHOD_POST];
	//リクエストヘッダの設定
	pst_data_ = [self postingDataWithID : userID
							   password : password];
	[connector_ writeProperty : @"close"
					   forKey : HTTP_CONNECTION_KEY];
	[connector_ writeProperty : [requestURL_ host]
					   forKey : HTTP_HOST_KEY];
	[connector_ writeProperty : [[self class] userAgentWhenAuthentication]
					   forKey : HTTP_USER_AGENT_KEY];
	[connector_ writeProperty : [[self class] requestHeaderValueForX2chUA]
					   forKey : APP_HTTP_X_2CH_UA_KEY];
	[connector_ writeProperty : HTTP_CONTENT_URL_ENCODED_TYPE
					   forKey : HTTP_CONTENT_TYPE_KEY];
	[connector_ writeProperty : [[NSNumber numberWithInt : [pst_data_ length]] stringValue]
					   forKey : HTTP_CONTENT_LENGTH_KEY];
	[connector_ writeData : pst_data_];
	
	resource_ = [connector_ loadInForeground];
	
	if(nil == resource_ || NSURLHandleLoadFailed == [connector_ status]){
		UTILDebugWrite(@"Connection Error");
		
		[self setRecentErrorType : w2chConnectionError];
		return NO;
	}
	

	{
		SGHTTPResponse		*respose_;
		
		respose_ = [connector_ response];
		UTILDebugWrite1(@"\n%@", [respose_ description]);
	}
	
	statusCode_ = [[connector_ response] statusCode];
	[self setRecentStatusCode : statusCode_];
	if(statusCode_ != 200){
		UTILDebugWrite(@"Connection Error");
		[self setRecentErrorType : w2chNetworkError];
		return NO;
	}
	
	contents_ = [[NSString alloc] initWithData : resource_ 
									  encoding : NSShiftJISStringEncoding];
	[contents_ autorelease];
	return [self parseResponseID : contents_
					   userAgent : userAgent
					   sessionID : sid];
}
@end



@implementation w2chAuthenticater(UserAgent)
+ (NSString *) requestHeaderValueForX2chUA
{
	NSString	*x2chUA_;
	
	UTILAssertNotNil([[self class] preferences]);
	x2chUA_ = [[[self class] preferences] applicationUserAgent];
	UTILAssertNotNil(x2chUA_);
	
	return x2chUA_;
}
+ (NSString *) userAgentWhenAuthentication
{
	return USER_AGENT_WHEN_AUTHENTICATION;
}
+ (NSString *) userAgent
{
	long _libver = (1 << 16);	//暫定措置
	
	// 2ch改造暫定措置 (02.01.20)
	return [NSString stringWithFormat :
					@"Monazilla/%d.%02d (%@)",
					_libver >> 16,
					_libver & 0xffff,
					[self requestHeaderValueForX2chUA]];
}
@end



@implementation w2chAuthenticater(Preferences)
+ (AppDefaults *) preferences
{
	return st_defaults;
}
- (AppDefaults *) preferences
{
	return [[self class] preferences];
}
+ (void) setPreferencesObject : (AppDefaults *) defaults
{
	st_defaults = defaults;
}
- (NSString *) account
{
	return [[[self class] preferences] x2chUserAccount];
}
- (NSString *) password
{
	return [[[self class] preferences] password];
}
@end



@implementation w2chAuthenticater(Status)
- (NSString *) sessionID
{
	if(nil == m_sessionID)
		[self invalidate];
	return m_sessionID;
}
/* Accessor for m_recentStatusCode */
- (int) recentStatusCode
{
	return m_recentStatusCode;
}
- (void) setRecentStatusCode : (int) aRecentStatusCode
{
	m_recentStatusCode = aRecentStatusCode;
}
/* Accessor for m_recentErrorType */
- (w2chAuthenticaterErrorType) recentErrorType
{
	return m_recentErrorType;
}
- (void) setRecentErrorType : (w2chAuthenticaterErrorType) aRecentErrorType
{
	m_recentErrorType = aRecentErrorType;
}
@end



@implementation w2chAuthenticater(Private)
/* Accessor for m_sessionID */
- (void) setSessionID : (NSString *) aSessionID
{
	id tmp;
	
	tmp = m_sessionID;
	m_sessionID = [aSessionID retain];
	[tmp release];
}
/* Accessor for m_monazillaUserAgent */
- (NSString *) monazillaUserAgent
{
	if(nil == m_monazillaUserAgent)
		[self invalidate];
	return m_monazillaUserAgent;
}
- (void) setMonazillaUserAgent : (NSString *) aMonazillaUserAgent
{
	id tmp;
	
	tmp = m_monazillaUserAgent;
	m_monazillaUserAgent = [aMonazillaUserAgent retain];
	[tmp release];
}
@end



@implementation w2chAuthenticater(Invalidate)
- (BOOL) shouldLogin
{
	if(NO == [[self preferences] shouldLoginIfNeeded])
		return NO;
	
	//ユーザIDが入力されていない場合はユーザ側に
	//ログインする意志がないものと判断。
	return ([self account] && [[self account] length] > 0);
}
- (BOOL) updateAccountAndPasswordIfNeeded : (NSString **) newAccountPtr
                                 password : (NSString **) newPasswordPtr
					   shouldUsesKeychain : (BOOL	   *) savePassPtr
{
	if(NO == [self shouldLogin]) return NO;
	
	if([[self preferences] hasAccountInKeychain]){
		if(newAccountPtr != NULL) *newAccountPtr = [self account];
		if(newPasswordPtr != NULL) *newPasswordPtr = [self password];
		if(savePassPtr != NULL) *savePassPtr = NO;
		
		return YES;
	}else{
		return [self runModalForLoginWindow : newAccountPtr
								   password : newPasswordPtr
						 shouldUsesKeychain : savePassPtr];
	}
}
- (NSString *) titleKeyForErrorType : (w2chAuthenticaterErrorType) type
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
- (NSString *) messageKeyForErrorType : (w2chAuthenticaterErrorType) type
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
- (BOOL) invalidate
{
	NSString	*userAgent_	;
	NSString	*account_	;
	NSString	*pw_		;
	NSString	*sid_		;
	BOOL		result_		;
	BOOL		usesKeychain_;
	
	[self setRecentErrorType : w2chNoError];
	[self setMonazillaUserAgent : nil];
	[self setSessionID : nil];
	
	if(NO == [self updateAccountAndPasswordIfNeeded : &account_
										   password : &pw_
								 shouldUsesKeychain : &usesKeychain_]){
		return NO;
	}
	
	UTILRequireCondition(
		(account_ && [account_ length]),
		error_params_invalid);
	UTILRequireCondition(
		(pw_ && [pw_ length]),
		error_params_invalid);
	
	result_ = [self login : account_
		         password : pw_
		        userAgent : &userAgent_
		        sessionID : &sid_];
	if(result_){
		[self setMonazillaUserAgent : userAgent_];
		[self setSessionID : sid_];
		
		if(usesKeychain_){
			[[self preferences] changeAccount : account_
									password : pw_
								usesKeychain : usesKeychain_];
		}
		
	}else{
		NSString		*ok_ = APP_AUTHENTICATER_OK_KEY;
		NSString		*titleKey_;
		NSString		*msgKey_;
		
		titleKey_ = [self titleKeyForErrorType : [self recentErrorType]];
		msgKey_ = [self messageKeyForErrorType : [self recentErrorType]];
		
		if(titleKey_ != nil && msgKey_ != nil){
			NSAlert	*alert_ = [[NSAlert alloc] init];
			
			[alert_ setAlertStyle : NSWarningAlertStyle];
			[alert_ setMessageText : PluginLocalizedStringFromTable(titleKey_, nil, nil)];
			[alert_ setInformativeText : PluginLocalizedStringFromTable(msgKey_, nil, nil)];

			[alert_ addButtonWithTitle : PluginLocalizedStringFromTable(ok_, nil, nil)];
			
			[alert_ runModal];
			
			[alert_ release];
/*			NSRunAlertPanel(
					PluginLocalizedStringFromTable(titleKey_, nil, nil),
					PluginLocalizedStringFromTable(msgKey_, nil, nil),
					PluginLocalizedStringFromTable(ok_, nil, nil),
					nil,
					nil);
*/
		}
	}
	
	return result_;
	
	
	error_params_invalid:{
		[self setRecentErrorType : w2chLoginParamsInvalid];
		return NO;
	}
}
@end