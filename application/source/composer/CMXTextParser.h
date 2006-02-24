/**
  * $Id: CMXTextParser.h,v 1.5 2006/02/24 15:13:21 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
  *
  */

#import <Foundation/Foundation.h>

@class CMRThreadMessage;

enum {
	k2chDATNameIndex			= 0,
	k2chDATMailIndex			,
	k2chDATDateExtraFieldIndex	,
	k2chDATMessageIndex			,
	
	// Optional
	k2chDATTitleIndex			
};


@interface CMXTextParser : NSObject
/**
  *
  * 行を"<>"または","で分割した配列を返す。
  * 区切り文字が","の場合はフィールド中の'@｀'を","に変換
  *
  * 区切り文字が存在しない場合は不当な文字列と見なし、nilを返す。
  *
  * @param    line  行
  * @return         区切り文字で分割した配列
  *
  */
+ (NSArray *) separatedLine : (NSString *) line;

// DAT文字列 --> レスオブジェクト
+ (NSArray *) messageArrayWithDATContents : (NSString  *) DATContens
								baseIndex : (unsigned   ) baseIndex
								    title : (NSString **) tilePtr;
+ (CMRThreadMessage *) messageWithDATLine : (NSString *) theString;
+ (CMRThreadMessage *) messageWithInvalidDATLineDetected : (NSString *) line;

// Entity Reference
// "&amp" --> "&amp;"
+ (void) replaceEntityReferenceWithString : (NSMutableString *) aString;

/*
レスの本文のうち変換できるものは変換してしまう。
不要なHTMLタグを取り除き、改行タグを変換
*/
+ (NSString *) cachedMessageWithMessageSource : (NSString *) aSource;
+ (void) convertMessageSourceToCachedMessage : (NSMutableString *) aSource;



// ----------------------------------------
// CES (Code Encoding Scheme)
// ----------------------------------------
/*
Shift JIS については対応する符号化文字集合として三つの
候補が考えられる。

  - JIS 規格に忠実な JIS X 0208:1997
  - MicroSoft 社の仕様
  - Apple 社の仕様

これらは以下の CFStringEncodings に対応する（括弧内は
CFStringConvertEncodingToIANACharSetName() の返す名前）

  - kCFStringEncodingShiftJIS (SHIFT_JIS)
  - kCFStringEncodingDOSJapanese (CP932)
  - kCFStringEncodingMacJapanese (X-MAC-JAPANESE)

CocoMonar の場合、たとえば新・mac 板では Mac Japanese の
コードが使われるケースもあるため、Shift JIS に関しては
これらすべてに対応するのが現実的だと思われる。

そのため、以下のメソッドでこれらの CFStringEncoding を
返した場合は
(1) まず、そのエンコーディングを試し
(2) それで変換できなければ残りのエンコーディングを次の順番で試す。
(3) 結果的に変換できなければエラー

  - kCFStringEncodingDOSJapanese
  - kCFStringEncodingMacJapanese
  - kCFStringEncodingShiftJIS
----------------------------------------
*/

+ (NSString *) stringWithData : (NSData         *) aData
                   CFEncoding : (CFStringEncoding) enc;



// ----------------------------------------
// URL Encode
// ----------------------------------------
/*!
 * @method      availableURLEncodings
 * @discussion  
 * 
 * 内部でURLエンコードされた文字列をやりとりするときに
 * 用いるエンコーディングの配列（終端：0）
 * 
 * @result      配列（終端：0）
 */
+ (const NSStringEncoding *) availableURLEncodings;
+ (NSString *) stringByURLEncodedWithString : (NSString *) aString;
+ (NSString *) stringByURLDecodedWithString : (NSString *) aString;
+ (NSString *) queryWithDictionary : (NSDictionary *) aDictionary;


+ (CMRThreadMessage *) messageWithDATLineComponentsSeparatedByNewline : (NSArray *) aComponents;

//+ (BOOL) parseDateExtraField : (NSString         *) dateExtra
//            convertToMessage : (CMRThreadMessage *) aMessage;
//+ (BOOL) parseExtraField : (NSString         *) extraField
//        convertToMessage : (CMRThreadMessage *) aMessage;
@end


extern void htmlConvertBreakLineTag(NSMutableString *theString);
