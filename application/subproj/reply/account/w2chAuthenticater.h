//:w2chAuthenticater.h
/**
  *
  * 2ch�̔F�؃T�[�o�Ƃ̃C���^�[�t�F�[�X
  * SSL�F�؂ɂ��ASID���󂯂Ƃ�B
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
  * �F�؃T�[�o�Ƀ��O�C������B
  * 
  * @param    userID     ���[�UID
  * @param    password   �p�X���[�h
  * @param    userAgent  �F�؂��ꂽUser-Agent
  * @param    sid        �F�؂��ꂽID
  * @return              �F�؂ɐ��������ꍇ��YES
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
