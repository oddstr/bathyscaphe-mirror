//: NSCharacterSet-SGExtentions.h
/**
  * $Id: NSCharacterSet-SGExtensions.h,v 1.2 2007/10/20 02:21:29 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


@interface NSCharacterSet(SGExtentions)
// 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
// !"#%&'()*,-./:;?@[\]_{}
+ (NSCharacterSet *) alphanumericPunctuationCharacterSet;


/**
  * URL�Ƃ��Đ����ȕ����̏W��
  * 
  * @return     �����W��
  */
+ (NSCharacterSet *) URLCharacterSet;
//+ (NSCharacterSet *) URLInvertedCharacterSet;

//+ (NSCharacterSet *) URLToBeEscapedCharacterSet;
//+ (NSCharacterSet *) URLToBeNotEscapedCharacterSet;

/**
  * �󔒁A�^�u�A���s�A����сA�S�p�̋󔒕������܂�
  * CharacterSet��Ԃ��B
  * 
  * @return     �S�p�̋󔒕������܂�whitespaceAndNewlineCharacterSet
  */
+ (NSCharacterSet *) extraspaceAndNewlineCharacterSet;

@end
