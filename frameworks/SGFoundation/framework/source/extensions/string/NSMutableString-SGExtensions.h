//: NSMutableString-SGExtensions.h
/**
  * $Id: NSMutableString-SGExtensions.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/NSString.h>



@interface NSMutableString(SGExtensions)
/**
  * 指定されたcharsをすべて、文字列replacement
  * で置き換える。
  * 
  * @param    chars        置き換えられる文字列
  * @param    replacement  置換後の文字列
  * @param    options      検索時のオプション
  * @param    range        置き換える範囲
  */
- (void) replaceCharacters : (NSString   *) chars
                  toString : (NSString   *) replacement
                   options : (unsigned int) options
                     range : (NSRange     ) aRange;
- (void) replaceCharacters : (NSString *) chars
                  toString : (NSString *) replacement;
- (void) replaceCharacters : (NSString   *) chars
                  toString : (NSString   *) replacement
                   options : (unsigned int) options;


- (void) deleteCharacters : (NSString   *) theString
                  options : (unsigned int) options
                    range : (NSRange     ) aRange;
- (void)  deleteCharacters : (NSString   *) theString;
- (void)  deleteCharacters : (NSString   *) theString
                   options : (unsigned int) options;

- (void) replaceCharactersInSet : (NSCharacterSet  *) theSet
                       toString : (NSString        *) replacement
                        options : (unsigned int     ) options
                          range : (NSRange          ) aRange;
- (void) replaceCharactersInSet : (NSCharacterSet  *) theSet
                       toString : (NSString        *) replacement
                        options : (unsigned int     ) options;
- (void) replaceCharactersInSet : (NSCharacterSet  *) theSet
                       toString : (NSString        *) replacement;

/**
  * レシーバのcharSetに含まれる文字列をすべて削除する。
  * 
  * @param    charSet      置き換えられる文字のセット
  * @param    options      検索時のオプション
  * @param    range        置き換える範囲
  */
- (void)  deleteCharactersInSet : (NSCharacterSet  *) charSet
                        options : (unsigned int     ) options
                          range : (NSRange          ) aRange;
- (void)  deleteCharactersInSet : (NSCharacterSet  *) charSet;
- (void)  deleteCharactersInSet : (NSCharacterSet  *) charSet
                        options : (unsigned int     ) options;

- (void) deleteAll;

/* 連続する空白文字、タブ、改行を削除 */
// CFStringTrimWhitespace 
- (void) strip;
// isspace()
- (void) stripAtStart;
- (void) stripAtEnd;


/* HTML */
// すべてのタグを削除
- (void) deleteAllTagElements;
// エンティティの解決
- (void) replaceEntityReference;
@end
