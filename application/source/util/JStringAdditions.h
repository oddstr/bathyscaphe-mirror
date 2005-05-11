//: JStringAdditions.h
/**
  * $Id: JStringAdditions.h,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * JStringAdditions.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>



@interface NSString(JStringAdditions)
/**
  * ���p������S�p�����ɕϊ����ĕԂ��B
  * ���p�J�i�͑S�p���Ȃɕϊ������B
  * 
  * @return    �S�p������i���ȁj
  */
- (NSString *) ZHiraString;

/**
  * ���p������S�p�����ɕϊ����ĕԂ��B
  * ���p�J�i�͑S�p�J�i�ɕϊ������B
  * 
  * @return    �S�p������i�J�i�j
  */
- (NSString *) ZKanaString;

/**
  * �ł��邾�����p�����ɕϊ����ĕԂ��B
  *
  * @return     ���p����
  */
- (NSString *) HString;

/**
  * �S�p�E���p�𖳎����āA������̌������s���B
  * 
  * @param    aString  ����������
  * @param    option   �I�v�V����
  * @param    aRange   �����͈�
  * @return            ����
  */
- (NSRange) rangeOfStringZHInsensitive : (NSString   *) aString
                               options : (unsigned int) option
                                 range : (NSRange     ) aRange;

- (NSRange) rangeOfString : (NSString *) subString
				  options : (unsigned  ) mask
				    range : (NSRange   ) aRange
	HanZenKakuInsensitive : (BOOL      ) flag;

@end
