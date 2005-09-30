/**
  * $Id: CookieManager.h,v 1.2 2005/09/30 18:52:03 tsawada2 Exp $
  * 
  * CookieManager.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>



@interface CookieManager : NSObject<CMRPropertyListCoding>
{
	@private
	NSDictionary		*_cookies;
}
+ (id) defaultManager;

- (NSDictionary *) cookies;
- (void) setCookies : (NSDictionary *) aCookies;

- (void) setCookiesArray : (NSArray  *) aCookiesArray
				 forHost : (NSString *) aHost;
- (void) removeAllCookies;

//////////////////////////////////////////////////////////////////////
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �P��A�܂��͕����̃N�b�L�[�ݒ���܂Ƃ߂�@"Set-Cookie"�w�b�_��
  * ��͂��A�K�؂Ȑ���Cookie�𐶐����A�z��Ɋi�[���ĕԂ��B
  * 
  * @param    header  �w�b�_
  * @return           Cookie�̔z��(���s���ɂ�nil)
  */
- (NSArray *) scanSetCookieHeader : (NSString *) header;

/**
  * @"Set-Cookie"�ŗv�����ꂽ�N�b�L�[��ێ��B
  * 
  * @param    header    @"Set-Cookie"�w�b�_
  * @param    hostName  �v�����̃z�X�g��
  */
- (void) addCookies : (NSString *) header
         fromServer : (NSString *) hostName;

/**
  * ���M��ɑ���ׂ�URL������ꍇ�̓N�b�L�[�������Ԃ��B
  * 
  * @param    anURL  ���M��URL
  * @param    withBe  Be ���O�C���p�̃N�b�L�[���t���邩�ǂ���
  * @return          �N�b�L�[
  */
- (NSString *) cookiesForRequestURL : (NSURL *) anURL
					   withBeCookie : (BOOL   ) withBe;

/**
  * �����؂�̃N�b�L�[���폜����B
  */
- (void) deleteExpiredCookies;

/**
  * �����؂�̃N�b�L�[���폜���A�ώ����ŕԂ��B
  * 
  * @param    dict  ����
  * @return         �����؂�̃N�b�L�[���폜��������
  */
- (NSMutableDictionary *) dictionaryByDeletingExpiredCookies : (NSDictionary *) dict;

/**
  * �t�@�C���Ƃ��ĕۑ��B
  * 
  * @param    path  �ۑ��ꏊ�̃p�X
  * @param    flag  NO�Ȃ璼�ځA�������ށB
  * @return         ��������YES
  */
- (BOOL) writeToFile : (NSString *) path
          atomically : (BOOL      ) flag;

- (NSDictionary *) dictionaryRepresentation;
@end
