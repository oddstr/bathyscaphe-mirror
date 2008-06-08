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
#import "w2chConnect.h"

@class AppDefaults;

@interface w2chAuthenticater : NSObject<w2chAuthenticationStatus>
{
	NSString		*m_sessionID;
	
	int 						m_recentStatusCode;
	w2chAuthenticaterErrorType	m_recentErrorType;
@private
	NSDate	*_lastLoggedInDate;
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

+ (AppDefaults *) preferences;
- (AppDefaults *) preferences;
+ (void) setPreferencesObject : (AppDefaults *) defaults;
- (NSString *) account;
- (NSString *) password;
@end

#define k2chAuthSessionIDKey	@"sid"
