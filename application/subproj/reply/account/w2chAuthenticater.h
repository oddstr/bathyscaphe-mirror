//:w2chAuthenticater.h
/**
  *
  * 2chの認証サーバとのインターフェース
  * SSL認証により、SIDを受けとる。
  *
  * @version 1.0.0d1 (02/03/03  10:04:18 PM)
  *
  */
#import <Foundation/Foundation.h>

@class AppDefaults;

//エラーの種類
typedef enum {
	w2chNoError = 0,			// エラーなし
	w2chNetworkError,			// サーバがエラーを返した
	w2chLoginError,				// 認証エラー
	w2chConnectionError,		// 接続時のエラー
	w2chLoginCanceled,			// ユーザによるキャンセル
	w2chLoginParamsInvalid,		// IDかPassが空
} w2chAuthenticaterErrorType;



@interface w2chAuthenticater : NSObject
{
	NSString		*m_sessionID;
	NSString		*m_monazillaUserAgent;
	
	int 						m_recentStatusCode;
	w2chAuthenticaterErrorType	m_recentErrorType;
}
+ (id) defaultAuthenticater;


- (BOOL) runModalForLoginWindow : (NSString **) accountPtr
                       password : (NSString **) passwordPtr
			 shouldUsesKeychain : (BOOL		 *) savePassPtr;

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
     sessionID : (NSString **) sid;
@end



@interface w2chAuthenticater(UserAgent)
+ (NSString *) requestHeaderValueForX2chUA;
+ (NSString *) userAgentWhenAuthentication;
+ (NSString *) userAgent;
@end



@interface w2chAuthenticater(Preferences)
+ (AppDefaults *) preferences;
- (AppDefaults *) preferences;
+ (void) setPreferencesObject : (AppDefaults *) defaults;
- (NSString *) account;
- (NSString *) password;
@end



@interface w2chAuthenticater(Status)
- (NSString *) sessionID;

/* Accessor for m_recentStatusCode */
- (int) recentStatusCode;
- (void) setRecentStatusCode : (int) aRecentStatusCode;
/* Accessor for m_recentErrorType */
- (w2chAuthenticaterErrorType) recentErrorType;
- (void) setRecentErrorType : (w2chAuthenticaterErrorType) aRecentErrorType;
@end



#define k2chAuthSessionIDKey	@"sid"

