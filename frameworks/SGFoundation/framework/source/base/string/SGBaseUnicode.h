//: SGBaseUnicode.h
/**
  * $Id: SGBaseUnicode.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */
/*!
 * @header     SGBaseUnicode
 * @discussion Unicode Utilities, see aloso Carbon UnicodeUtilities.h
 */

#ifndef SGBASEUNICODE_INCLUDEDD

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

SG_DECL_BEGIN



@class SGBaseRangeArray;

/*!
 * @function      SGUnicodeGetTextLength
 * @abstract      Unicode文字列の文字数を得る
 *
 * @discussion    
 *
 * Unicode文字列をクラスタ文字単位で扱うために使います。
 * クラスタ文字とはひとつのテキスト要素として複数のcode point のことです。
 * SGUnicodeGetTextLengthは返り値として、クラスタも１と数えた場合の文字数を
 * 返し、引数のclusterRangesPtrがNULLでない場合は、各文字のUniChar範囲の配列オブ
 * ジェクトへのポインタを設定します。なんらかのエラー発生時にはNSNotFoundを返しま
 * す。
 *
 * See Also; UCFindTextBreak(...) in UnicodeUtilities.h 
 *
 * @param  textObj    文字列
 * @param  rangesPtr  範囲の配列へのポインタ
 * @result            文字数
 */
SG_EXPORT
unsigned SGUnicodeGetTextLength(NSString *textObj, SGBaseRangeArray **rangesPtr);

SG_EXPORT
unsigned SGUnicodeCountBreaks(NSString *textObj, UCTextBreakType breakType, SGBaseRangeArray **rangesPtr);


@interface NSString(SGFoundationUnicode)
- (NSArray *) componentsSeparatedByTextBreak : (UCTextBreakType) breakType;
- (NSArray *) componentsSeparatedByTextBreak;
@end


SG_DECL_END

#endif /* SGBASEUNICODE_INCLUDEDD */
