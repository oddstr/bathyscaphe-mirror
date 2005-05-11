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

@class AppDefaults;

//�G���[�̎��
typedef enum {
	w2chNoError = 0,			// �G���[�Ȃ�
	w2chNetworkError,			// �T�[�o���G���[��Ԃ���
	w2chLoginError,				// �F�؃G���[
	w2chConnectionError,		// �ڑ����̃G���[
	w2chLoginCanceled,			// ���[�U�ɂ��L�����Z��
	w2chLoginParamsInvalid,		// ID��Pass����
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

