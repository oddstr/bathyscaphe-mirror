//: CMXTextParser.h
/**
  * $Id: CMXTextParser.h,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
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
  * �s��"<>"�܂���","�ŕ��������z���Ԃ��B
  * ��؂蕶����","�̏ꍇ�̓t�B�[���h����'@�M'��","�ɕϊ�
  *
  * ��؂蕶�������݂��Ȃ��ꍇ�͕s���ȕ�����ƌ��Ȃ��Anil��Ԃ��B
  *
  * @param    line  �s
  * @return         ��؂蕶���ŕ��������z��
  *
  */
+ (NSArray *) separatedLine : (NSString *) line;

/**
  *
  * 2ch���t������NSDate�𐶐�
  * �s���ȕ�����ł�nil��Ԃ��B
  * [���t�\��]
  *   02/02/05 22:26
  *   2001/08/06(��) 21:45
  * 
  * @param    string  ���O�t�@�C���̓��t��
  * @return           NSDate
  *
  */
+ (id) dateWith2chDateString : (NSString *) theString;

// DAT������ --> ���X�I�u�W�F�N�g
+ (NSArray *) messageArrayWithDATContents : (NSString  *) DATContens
								baseIndex : (unsigned   ) baseIndex
								    title : (NSString **) tilePtr;
+ (CMRThreadMessage *) messageWithDATLine : (NSString *) theString;
+ (CMRThreadMessage *) messageWithInvalidDATLineDetected : (NSString *) line;

// Entity Reference
// "&amp" --> "&amp;"
+ (void) replaceEntityReferenceWithString : (NSMutableString *) aString;

/*
���X�̖{���̂����ϊ��ł�����͕̂ϊ����Ă��܂��B
�s�v��HTML�^�O����菜���A���s�^�O��ϊ�
*/
+ (NSString *) cachedMessageWithMessageSource : (NSString *) aSource;
+ (void) convertMessageSourceToCachedMessage : (NSMutableString *) aSource;



// ----------------------------------------
// CES (Code Encoding Scheme)
// ----------------------------------------
/*
Shift JIS �ɂ��Ă͑Ή����镄���������W���Ƃ��ĎO��
��₪�l������B

  - JIS �K�i�ɒ����� JIS X 0208:1997
  - MicroSoft �Ђ̎d�l
  - Apple �Ђ̎d�l

�����͈ȉ��� CFStringEncodings �ɑΉ�����i���ʓ���
CFStringConvertEncodingToIANACharSetName() �̕Ԃ����O�j

  - kCFStringEncodingShiftJIS (SHIFT_JIS)
  - kCFStringEncodingDOSJapanese (CP932)
  - kCFStringEncodingMacJapanese (X-MAC-JAPANESE)

CocoMonar �̏ꍇ�A���Ƃ��ΐV�Emac �ł� Mac Japanese ��
�R�[�h���g����P�[�X�����邽�߁AShift JIS �Ɋւ��Ă�
����炷�ׂĂɑΉ�����̂������I���Ǝv����B

���̂��߁A�ȉ��̃��\�b�h�ł����� CFStringEncoding ��
�Ԃ����ꍇ��
(1) �܂��A���̃G���R�[�f�B���O������
(2) ����ŕϊ��ł��Ȃ���Ύc��̃G���R�[�f�B���O�����̏��ԂŎ����B
(3) ���ʓI�ɕϊ��ł��Ȃ���΃G���[

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
 * ������URL�G���R�[�h���ꂽ����������Ƃ肷��Ƃ���
 * �p����G���R�[�f�B���O�̔z��i�I�[�F0�j
 * 
 * @result      �z��i�I�[�F0�j
 */
+ (const NSStringEncoding *) availableURLEncodings;
+ (NSString *) stringByURLEncodedWithString : (NSString *) aString;
+ (NSString *) stringByURLDecodedWithString : (NSString *) aString;
+ (NSString *) queryWithDictionary : (NSDictionary *) aDictionary;
@end



@interface CMXTextParser(LowLevelAPIs)
+ (CMRThreadMessage *) messageWithDATLineComponentsSeparatedByNewline : (NSArray *) aComponents;

+ (BOOL) parseDateExtraField : (NSString         *) dateExtra
            convertToMessage : (CMRThreadMessage *) aMessage;
+ (BOOL) parseExtraField : (NSString         *) extraField
        convertToMessage : (CMRThreadMessage *) aMessage;
@end



extern void htmlConvertBreakLineTag(NSMutableString *theString);
