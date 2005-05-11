//: SGHTTPMessage.h
/**
  * $Id: SGHTTPMessage.h,v 1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

@interface SGHTTPMessage : NSObject
{
	@private
	CFHTTPMessageRef  m_message;		//HTTP���b�Z�[�W
}
//////////////////////////////////////////////////////////////////////
/////////////////////// [ �������E��n�� ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * ���ۃN���X�F�w��C�j�V�����C�U
  * �Ϗ�����CFHTTPMessageRef���w�肵�ď������B
  * 
  * @param    messageRef  CFHTTPMessageRef
  * @return               �������ς݂̃C���X�^���X
  */
- (id) initWithHTTPMessageRef : (CFHTTPMessageRef) messageRef;

//////////////////////////////////////////////////////////////////////
////////////////////// [ �A�N�Z�T���\�b�h ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_message */
- (CFHTTPMessageRef) HTTPMessageRef;
- (void) setHTTPMessageRef : (CFHTTPMessageRef) aMessage;

//////////////////////////////////////////////////////////////////////
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �w�b�_��ǉ��B����̃w�b�_���폜����Ƃ��ɂ�
  * value��nil��n���B
  * 
  * @param    value  �w�b�_�l
  * @param    key    �w�b�_���ʎq
  */
- (void) setHeaderFieldValue : (NSString *) value
                      forKey : (NSString *) key;
/**
  * �w�b�_���Q��
  * 
  * @param    key  �w�b�_���ʎq
  * return         �w�b�_
  */
- (NSString *) headerFieldValueForKey : (NSString *) key;

/**
  * ���ׂẴ��N�G�X�g�w�b�_�������Ɏ��߂ĕԂ��B
  * 
  * @return     ���ׂẴ��N�G�X�g�w�b�_
  */
- (NSDictionary *) allHeaderFields;

/**
  * �w�b�_�����S�ɖ������ꍇ��YES��Ԃ��B
  * 
  * @return     �w�b�_�����S�ɖ������Ă���Ȃ�YES
  */
- (BOOL) isHeaderComplete;

/**
  * ���N�G�X�g�̓��e��ݒ�B
  * 
  * @param    body  �{�f�B�̃f�[�^
  */
- (void) writeBody : (NSData *) body;

/**
  * ���N�G�X�g�̓��e���Q�ƁB
  * 
  * @return     �{�f�B�̃f�[�^
  */
- (NSData *) body;

/**
  * �V���A���C�Y�����f�[�^��Ԃ��B
  * 
  * @return     �V���A���C�Y�����f�[�^
  */
- (NSData *) serializedMessage;

/**
  * ���M���e�Ƀf�[�^��ǉ��B
  * 
  * @param    newBytes  �ǉ�����f�[�^
  * @return             ��͎��s���ɂ�NO
  */
- (BOOL) appendBytes : (NSData *) newBytes;

/**
  * ���M���e�Ƀf�[�^��ǉ��B
  * 
  * @param    newBytes     �ǉ�����f�[�^
  * @param    bytesLength  �ǉ�����f�[�^��
  * @return                ��͎��s���ɂ�NO
  */
- (BOOL) appendBytes : (const unsigned *) newBytes
              length : (unsigned        ) bytesLength;

- (NSURL *) requestURL;

- (NSString *) requestMethod;
@end



@interface SGHTTPMessage(HeaderReadOrWrite)
// Error : NSNotFound
- (unsigned) readContentLength;
- (void) writeContentLength : (int) aLength;
@end
