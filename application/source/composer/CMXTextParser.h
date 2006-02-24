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


+ (CMRThreadMessage *) messageWithDATLineComponentsSeparatedByNewline : (NSArray *) aComponents;

//+ (BOOL) parseDateExtraField : (NSString         *) dateExtra
//            convertToMessage : (CMRThreadMessage *) aMessage;
//+ (BOOL) parseExtraField : (NSString         *) extraField
//        convertToMessage : (CMRThreadMessage *) aMessage;
@end


extern void htmlConvertBreakLineTag(NSMutableString *theString);
