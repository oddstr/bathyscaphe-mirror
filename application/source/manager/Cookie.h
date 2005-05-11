//:Cookie.h
/**
  *
  * Cookie�B
  * 
  * Cookie�̎d�l�́ANetscape Communications Corporation �ɂ��A
  * �http://home.netscape.com/newsref/std/cookie_spec.html
  * �ɂČ��J����Ă���B
  * �Ȃ��AHTTP�̎d�l�Ɋ܂܂����̂ł͂Ȃ��B
  *
  * @version 1.0.0d1 (02/03/25  8:27:57 PM)
  *
  */

#import <SGFoundation/SGFoundation.h>



@interface Cookie : SGBaseObject<NSCopying>
{
	// ���O=�l�̃y�A
	NSString *m_name;				//���O
	NSString *m_value;				//�l
	// �I�v�V����
	NSString            *m_path;	//�N�b�L�[���L���ł���URL�͈�
	NSString            *m_domain;	//�N�b�L�[���L���ł���h���C���͈�
	NSString            *m_expires;	//�L������
	BOOL                 m_secure;	//�Z�L�����e�B�̊m�ۂ���Ă��Ȃ�
									//�ꍇ�͎g�p���Ȃ��B
	BOOL                 m_isEnabled;	//�L���E����
}
//////////////////////////////////////////////////////////////////////
/////////////////////// [ �������E��n�� ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �ꎞ�I�u�W�F�N�g�̐����B
  * 
  * @return                 �ꎞ�I�u�W�F�N�g
  */
+ (id) cookie;

/**
  * �ꎞ�I�u�W�F�N�g�̐����B
  * ������\������C���X�^���X�𐶐��A�������B
  * 
  * @param      anyCookies  ������\��
  * @return     �ꎞ�I�u�W�F�N�g
  */
+ (id) cookieWithString : (NSString *) anyCookies;

/**
  * �ꎞ�I�u�W�F�N�g�̐����B
  * �����I�u�W�F�N�g����C���X�^���X�𐶐��A�������B
  * 
  * @param      anyCookies  �����I�u�W�F�N�g
  * @return                 �ꎞ�I�u�W�F�N�g
  */
+ (id) cookieWithDictionary : (NSDictionary *) anyCookies;


/**
  * �w��C�j�V�����C�U�B
  * ������\������C���X�^���X�𐶐��A�������B
  * 
  * @param    anyCookies  ������\��
  * @return               �������ς݂̃C���X�^���X
  */
- (id) initWithString : (NSString *) anyCookies;

/**
  * �w��C�j�V�����C�U�B
  * �����I�u�W�F�N�g����C���X�^���X�𐶐��A�������B
  * 
  * @param    anyCookies  �����I�u�W�F�N�g
  * @return               �������ς݂̃C���X�^���X
  */
- (id) initWithDictionary : (NSDictionary *) anyCookies;

//////////////////////////////////////////////////////////////////////
////////////////////// [ �A�N�Z�T���\�b�h ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_name */
- (NSString *) name;
- (void) setName : (NSString *) aName;
/* Accessor for m_value */
- (NSString *) value;
- (void) setValue : (NSString *) aValue;
/* Accessor for m_path */
- (NSString *) path;
- (void) setPath : (NSString *) aPath;
/* Accessor for m_domain */
- (NSString *) domain;
- (void) setDomain : (NSString *) aDomain;
/* Accessor for m_expires */
- (NSString *) expires;
- (void) setExpires : (NSString *) anExpires;
/* Accessor for m_secure */
- (BOOL) secure;
- (void) setSecure : (BOOL) aSecure;
/* Accessor for m_enabled */
/* Accessor for m_isEnabled */
- (BOOL) isEnabled;
- (void) setIsEnabled : (BOOL) anIsEnabled;
//////////////////////////////////////////////////////////////////////
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * ���V�[�o�̃N�b�L�[���L����URL�Ȃ�YES��Ԃ��B
  * 
  * @param    anURL  �Ώ�URL
  * @return          �N�b�L�[���L����URL�Ȃ�YES
  */
- (BOOL) isAvalilableURL : (NSURL *) anURL;

/**
  * �����؂�̏ꍇ��YES��Ԃ��B
  * �I�����ɔj�������ꍇ�ɂ�whenTerminate = YES
  *
  * @param   whenTerminate   �I�����ɔj�������ꍇ��YES
  * @return                  �����؂�̏ꍇ��YES
  */
- (BOOL) isExpired : (BOOL *) whenTerminate;

/**
  * ���V�[�o�̂������`���ŕԂ��B
  * 
  * @return     �����I�u�W�F�N�g
  */
- (NSDictionary *) dictionaryRepresentation;

//:�A�N�Z�T
/**
  * �L��������Ԃ��B�w�肳��Ă��Ȃ��ꍇ��
  * �A�v���P�[�V�����I�����ɔj�����邱�ƁB
  * 
  * @return     �L������
  */
- (NSDate *) expiresDate;

/**
  * �N�b�L�[��ݒ�B
  * 
  * @param    aValue  �l
  * @param    aName   ���O
  */
- (void) setCookie : (id        ) aValue
           forName : (NSString *) aName;

/**
  * �����񂩂�ϊ��B
  * �I�v�V�������w�肵���ꍇ�́A���������f�����B
  * 
  * ex : @"SPID=XWDtLhNY; expires=1016920836 GMT; path=/"
  * 
  * @param    anyCookies  ������\��
  */
- (void) setCookieWithString : (NSString *) anyCookies;

/**
  * �����I�u�W�F�N�g����ϊ��B
  * �I�v�V�������w�肵���ꍇ�́A���������f�����B
  * 
  * 
  * @param    anyCookies  �����I�u�W�F�N�g
  */
- (void) setCookieWithDictionary : (NSDictionary *) anyCookies;

/**
  * �N�b�L�[�𕶎���ŕ\���������̂�Ԃ��B
  * 
  * @return     ������\��
  */
- (NSString *) stringValue;


@end
