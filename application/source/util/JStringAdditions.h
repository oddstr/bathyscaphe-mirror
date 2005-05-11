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
  * 半角文字を全角文字に変換して返す。
  * 半角カナは全角かなに変換される。
  * 
  * @return    全角文字列（かな）
  */
- (NSString *) ZHiraString;

/**
  * 半角文字を全角文字に変換して返す。
  * 半角カナは全角カナに変換される。
  * 
  * @return    全角文字列（カナ）
  */
- (NSString *) ZKanaString;

/**
  * できるだけ半角文字に変換して返す。
  *
  * @return     半角文字
  */
- (NSString *) HString;

/**
  * 全角・半角を無視して、文字列の検索を行う。
  * 
  * @param    aString  検索文字列
  * @param    option   オプション
  * @param    aRange   検索範囲
  * @return            結果
  */
- (NSRange) rangeOfStringZHInsensitive : (NSString   *) aString
                               options : (unsigned int) option
                                 range : (NSRange     ) aRange;

- (NSRange) rangeOfString : (NSString *) subString
				  options : (unsigned  ) mask
				    range : (NSRange   ) aRange
	HanZenKakuInsensitive : (BOOL      ) flag;

@end
