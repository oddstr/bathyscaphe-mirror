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
  * URLとして正当な文字の集合
  * 
  * @return     文字集合
  */
+ (NSCharacterSet *) URLCharacterSet;
//+ (NSCharacterSet *) URLInvertedCharacterSet;

//+ (NSCharacterSet *) URLToBeEscapedCharacterSet;
//+ (NSCharacterSet *) URLToBeNotEscapedCharacterSet;

/**
  * 空白、タブ、改行、および、全角の空白文字を含む
  * CharacterSetを返す。
  * 
  * @return     全角の空白文字も含むwhitespaceAndNewlineCharacterSet
  */
+ (NSCharacterSet *) extraspaceAndNewlineCharacterSet;

@end
