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
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
//- (BOOL) isValidURLCharacters;
- (NSString *) stringByDeletingURLScheme : (NSString *) aScheme;


/**
  * ���V�[�o������aString�Ɏw�肵����������܂ޏꍇ��YES��Ԃ��B
  * 
  * @param    aString  �T��������
  * @return            ���V�[�o������aString�Ɏw�肵����������܂ޏꍇ��YES
  */
- (BOOL) containsString : (NSString *) aString;

/**
  * ���V�[�o������aString�Ɏw�肵�������Z�b�g���܂ޏꍇ��YES��Ԃ��B
  * 
  * @param    characterSet  �T�������Z�b�g
  * @return                 ���V�[�o������aString�Ɏw�肵����������܂ޏꍇ��YES
  */
- (BOOL) containsCharacterFromSet : (NSCharacterSet *) characterSet;

//Data Using CFStringEncoding
/**
  * ���V�[�o���f�[�^�ŕԂ��B
  * 
  * @param    anEncoding  CFStringEncoding
  * @return               ������̃f�[�^
  */
- (NSData *) dataUsingCFEncoding : (CFStringEncoding) anEncoding;

/**
  * ���V�[�o���f�[�^�ŕԂ��B
  * 
  * @param    anEncoding  CFStringEncoding
  * @param    lossy       ������f�[�^�𖳎�
  * @return               ������̃f�[�^
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
  * @return            ���s�������܂܂Ȃ��������v�f�Ƃ���z��
  */
/*!
 * @method      componentsSeparatedByNewline
 * @abstract    ���s�ŋ�؂�
 *
 * @discussion  �w�肳�ꂽ����������s(�܂���Unicode�̒i����؂蕶��)
 *              �ŋ�؂�A���ꂼ����s�������܂܂Ȃ��������v�f�Ƃ���
 *              �z���Ԃ��B���s���܂܂Ȃ��A�܂��͖��������s�̕������
 *              �ꍇ�́A�v�f���ЂƂ̔z���Ԃ��B
 *
 * @result      �X�̗v�f���܂ޔz��I�u�W�F�N�g
 */
- (NSArray *) componentsSeparatedByNewline;

- (NSString *) stringByReplaceEntityReference;

/**
  * �w�肳�ꂽchars�����ׂāA������replacement
  * �Œu��������B
  * 
  * @param    chars        �u���������镶����
  * @return                �V����������
  */
- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement;

/**
  * �w�肳�ꂽchars�����ׂāA������replacement
  * �Œu��������B
  * 
  * @param    chars        �u���������镶����
  * @param    replacement  �u����̕�����
  * @param    options      �������̃I�v�V����
  * @return                �V����������
  */
- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement
                                 options : (unsigned int     ) options;

/**
  * �w�肳�ꂽchars�����ׂāA������replacement
  * �Œu��������B
  * 
  * @param    chars        �u���������镶����
  * @param    replacement  �u����̕�����
  * @param    options      �������̃I�v�V����
  * @param    range        �u��������͈�
  * @return                �V����������
  */
- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement
                                 options : (unsigned int     ) options
                                   range : (NSRange          ) aRange;

/**
  * ���V�[�o��charSet�Ɋ܂܂�镶��������ׂč폜����B
  * 
  * @param    charSet      �u���������镶���̃Z�b�g
  * @return                �V����������
  */
- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet;

/**
  * ���V�[�o��charSet�Ɋ܂܂�镶��������ׂč폜����B
  * 
  * @param    charSet      �u���������镶���̃Z�b�g
  * @param    range        �u��������͈�
  * @return                �V����������
  */
- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet
                                      options : (unsigned int     ) options;

/**
  * ���V�[�o��charSet�Ɋ܂܂�镶��������ׂč폜����B
  * 
  * @param    charSet      �u���������镶���̃Z�b�g
  * @param    options      �������̃I�v�V����
  * @param    range        �u��������͈�
  * @return                �V����������
  */
- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet
                                      options : (unsigned int     ) options
                                        range : (NSRange          ) aRange;

/**
  * �擪�Ɩ����̘A������󔒕����A�^�u�A���s���폜
  * �����������Ԃ��B
  *
  * @return     �V����������
  */
- (NSString *) stringByStriped;

/**
  * �擪�̘A������󔒕����A�^�u�A���s���폜
  * �����������Ԃ��B
  *
  * @return     �V����������
  */
- (NSString *) stringByStripedAtStart;

/**
  * �����̘A������󔒕����A�^�u�A���s���폜
  * �����������Ԃ��B
  *
  * @return     �V����������
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
// JellyBeans ����ڐA
- (NSString *) stringWithTruncatingForMenuItemOfWidth: (float) width indent: (BOOL) shouldIndent activeItem: (BOOL) isActiveItem;

// SGBaseUnicode.h ����ړ��i�������������@�͑S���قȂ�j
- (NSArray *) componentsSeparatedByTextBreak;
@end
