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
  * �w�肳�ꂽchars�����ׂāA������replacement
  * �Œu��������B
  * 
  * @param    chars        �u���������镶����
  * @param    replacement  �u����̕�����
  * @param    options      �������̃I�v�V����
  * @param    range        �u��������͈�
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
  * ���V�[�o��charSet�Ɋ܂܂�镶��������ׂč폜����B
  * 
  * @param    charSet      �u���������镶���̃Z�b�g
  * @param    options      �������̃I�v�V����
  * @param    range        �u��������͈�
  */
- (void)  deleteCharactersInSet : (NSCharacterSet  *) charSet
                        options : (unsigned int     ) options
                          range : (NSRange          ) aRange;
- (void)  deleteCharactersInSet : (NSCharacterSet  *) charSet;
- (void)  deleteCharactersInSet : (NSCharacterSet  *) charSet
                        options : (unsigned int     ) options;

- (void) deleteAll;

/* �A������󔒕����A�^�u�A���s���폜 */
// CFStringTrimWhitespace 
- (void) strip;
// isspace()
- (void) stripAtStart;
- (void) stripAtEnd;


/* HTML */
// ���ׂẴ^�O���폜
- (void) deleteAllTagElements;
// �G���e�B�e�B�̉���
- (void) replaceEntityReference;
@end
