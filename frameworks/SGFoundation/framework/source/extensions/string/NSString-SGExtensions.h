//: NSString-SGExtensions.h
/**
  * $Id: NSString-SGExtensions.h,v 1.4 2007/10/20 02:21:29 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>



//
// CFStringEncoding <--> NSStringEncoding
//
#define CF2NSEncoding(x)	CFStringConvertEncodingToNSStringEncoding(x)
#define NS2CFEncoding(x)	CFStringConvertNSStringEncodingToEncoding(x)

//
// CFStringEncoding <--> TextEncoding
//
#define CF2TextEncoding(x)	x
#define Text2CFEncoding(x)	x


@interface NSString(SGExtensionTEC)
// Using TEC
- (id) initWithDataUsingTEC : (NSData     *) theData
                   encoding : (TextEncoding) encoding;
+ (id) stringWithDataUsingTEC : (NSData     *) theData
                     encoding : (TextEncoding) encoding;
@end



@interface NSString(SGExtensions)
+ (id) stringWithData : (NSData         *) data
             encoding : (NSStringEncoding) encoding;

+ (id) stringWithCharacter : (unichar) aCharacter;
- (id) initWithCharacter : (unichar) aCharacter;
/*
+ (id) stringWithCStringNoCopy : (char *  ) cString
 						length : (unsigned) length
				  freeWhenDone : (BOOL    ) freeBuffer;
+ (id) stringWithCStringNoCopy : (char *  ) cString
				  freeWhenDone : (BOOL    ) freeBuffer;
// freeWhenDone == NO
+ (id) stringWithCStringNoCopy : (const char *) cString;
*/

//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
//- (BOOL) isValidURLCharacters;
- (NSString *) stringByDeletingURLScheme : (NSString *) aScheme;


/**
  * レシーバが引数aStringに指定した文字列を含む場合にYESを返す。
  * 
  * @param    aString  探索文字列
  * @return            レシーバが引数aStringに指定した文字列を含む場合にYES
  */
- (BOOL) containsString : (NSString *) aString;

/**
  * レシーバが引数aStringに指定した文字セットを含む場合にYESを返す。
  * 
  * @param    characterSet  探索文字セット
  * @return                 レシーバが引数aStringに指定した文字列を含む場合にYES
  */
- (BOOL) containsCharacterFromSet : (NSCharacterSet *) characterSet;

//Data Using CFStringEncoding
/**
  * レシーバをデータで返す。
  * 
  * @param    anEncoding  CFStringEncoding
  * @return               文字列のデータ
  */
- (NSData *) dataUsingCFEncoding : (CFStringEncoding) anEncoding;

/**
  * レシーバをデータで返す。
  * 
  * @param    anEncoding  CFStringEncoding
  * @param    lossy       失われるデータを無視
  * @return               文字列のデータ
  */
- (NSData *) dataUsingCFEncoding : (CFStringEncoding) anEncoding
            allowLossyConversion : (BOOL            ) lossy;

- (NSRange) rangeOfCharacterSequenceFromSet : (NSCharacterSet *) aSet;
- (NSRange) rangeOfCharacterSequenceFromSet : (NSCharacterSet *) aSet
									options : (unsigned int    ) mask;
- (NSRange) rangeOfCharacterSequenceFromSet : (NSCharacterSet *) aSet
									options : (unsigned int    ) mask
									  range : (NSRange         ) aRange;
- (NSArray *) componentsSeparatedByCharacterSequenceFromSet : (NSCharacterSet *) aCharacterSet;
- (NSArray *) componentsSeparatedByCharacterSequenceInString : (NSString *) characters;
/*!
  * 
  * @return            改行文字を含まない文字列を要素とする配列
  */
/*!
 * @method      componentsSeparatedByNewline
 * @abstract    改行で区切る
 *
 * @discussion  指定された文字列を改行(またはUnicodeの段落区切り文字)
 *              で区切り、それぞれ改行文字を含まない文字列を要素とする
 *              配列を返す。改行を含まない、または末尾が改行の文字列の
 *              場合は、要素がひとつの配列を返す。
 *
 * @result      個々の要素を含む配列オブジェクト
 */
- (NSArray *) componentsSeparatedByNewline;

- (NSString *) stringByReplaceEntityReference;

/**
  * 指定されたcharsをすべて、文字列replacement
  * で置き換える。
  * 
  * @param    chars        置き換えられる文字列
  * @return                新しい文字列
  */
- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement;

/**
  * 指定されたcharsをすべて、文字列replacement
  * で置き換える。
  * 
  * @param    chars        置き換えられる文字列
  * @param    replacement  置換後の文字列
  * @param    options      検索時のオプション
  * @return                新しい文字列
  */
- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement
                                 options : (unsigned int     ) options;

/**
  * 指定されたcharsをすべて、文字列replacement
  * で置き換える。
  * 
  * @param    chars        置き換えられる文字列
  * @param    replacement  置換後の文字列
  * @param    options      検索時のオプション
  * @param    range        置き換える範囲
  * @return                新しい文字列
  */
- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement
                                 options : (unsigned int     ) options
                                   range : (NSRange          ) aRange;

/**
  * レシーバのcharSetに含まれる文字列をすべて削除する。
  * 
  * @param    charSet      置き換えられる文字のセット
  * @return                新しい文字列
  */
- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet;

/**
  * レシーバのcharSetに含まれる文字列をすべて削除する。
  * 
  * @param    charSet      置き換えられる文字のセット
  * @param    range        置き換える範囲
  * @return                新しい文字列
  */
- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet
                                      options : (unsigned int     ) options;

/**
  * レシーバのcharSetに含まれる文字列をすべて削除する。
  * 
  * @param    charSet      置き換えられる文字のセット
  * @param    options      検索時のオプション
  * @param    range        置き換える範囲
  * @return                新しい文字列
  */
- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet
                                      options : (unsigned int     ) options
                                        range : (NSRange          ) aRange;

/**
  * 先頭と末尾の連続する空白文字、タブ、改行を削除
  * した文字列を返す。
  *
  * @return     新しい文字列
  */
- (NSString *) stringByStriped;

/**
  * 先頭の連続する空白文字、タブ、改行を削除
  * した文字列を返す。
  *
  * @return     新しい文字列
  */
- (NSString *) stringByStripedAtStart;

/**
  * 末尾の連続する空白文字、タブ、改行を削除
  * した文字列を返す。
  *
  * @return     新しい文字列
  */
- (NSString *) stringByStripedAtEnd;

- (BOOL) isSameAsString : (NSString *) other;
@end


/*
@interface NSString(WorkingWithPascalString)
+ (id) stringWithPascalString : (ConstStr255Param) pStr;
- (id) initWithPascalString : (ConstStr255Param) pStr;

- (ConstStringPtr) pascalString;
- (BOOL) getPascalString : (StringPtr) buffer
               maxLength : (unsigned ) maxLength;
@end
*/
@interface NSString(StarlightBreakerAddition)
// JellyBeans から移植
- (NSString *) stringWithTruncatingForMenuItemOfWidth: (float) width indent: (BOOL) shouldIndent activeItem: (BOOL) isActiveItem;

// SGBaseUnicode.h から移動（ただし実装方法は全く異なる）
- (NSArray *) componentsSeparatedByTextBreak;
@end
