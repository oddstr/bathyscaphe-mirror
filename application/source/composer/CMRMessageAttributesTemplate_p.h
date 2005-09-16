//:CMRMessageAttributesTemplate_p.h
#import "CMRMessageAttributesTemplate.h"

#import <SGAppKit/SGAppKit.h>

#import "AppDefaults.h"
#import "CMRThreadMessage.h"


/*** attachment's image ***/
#define kSageImageFileName		@"sage"
#define kAgeImageFileName		@"age"
#define kMailImageFileName		@"mailAttachment"
#define kUpdatedHeaderImageName	@"lastUpdatedHeader"
/* ellipsis */
#define kEllipsisProxyImage			@"EllipsisProxy"
#define kEllipsisMouseDownImage		@"EllipsisMouseDown"
#define kEllipsisMouseOverImage		@"EllipsisMouseOver"

#define kEllipsisDownProxyImage			@"EllipsisDownProxy"
#define kEllipsisDownMouseDownImage		@"EllipsisDownMouseDown"
#define kEllipsisDownMouseOverImage		@"EllipsisDownMouseOver"

#define kEllipsisUpProxyImage			@"EllipsisUpProxy"
#define kEllipsisUpMouseDownImage		@"EllipsisUpMouseDown"
#define kEllipsisUpMouseOverImage		@"EllipsisUpMouseOver"

/* template */
#define kMailIconAlignment		@"Thread - MailIconAlignment"



@interface CMRMessageAttributesTemplate(AttachmentTemplate)
/**
  * ���\�[�X����NSTextAttachment���쐬���A������������ŕԂ��B
  * 
  * @param    filename  ���\�[�X�ւ̃p�X
  * @return             ������������
  */
- (NSAttributedString *) attachmentAttributedStringWithImageFile : (NSString *) filename;

// age, sage, address
/**
  * ���[���A�h���X�ւ̃����N�������A�^�b�`�����g���܂ޏ������������Ԃ��B
  * 
  * @return     ���[���A�h���X�ւ̃����N�������A�^�b�`�����g���܂ޏ�����������
  */
- (NSMutableAttributedString *) mailImageAttachmentString;
- (NSAttributedString *) ageImageAttachmentString;
- (NSAttributedString *) sageImageAttachmentString;
@end

@interface CMRMessageAttributesTemplate(Private)
/**
  * ���������̈���name�Ŏw�肳�ꂽ����������������B
  * value��nil�̏ꍇ�͏����B
  * 
  * @param    dict   ��������
  * @param    name   �����̖��O
  * @param    value  �����̒l
  */
- (void) setAttributeInDictionary : (NSMutableDictionary *) dict
                    attributeName : (NSString            *) name
                            value : (id                   ) value;

/* Accessor for m_messageAttributesForAnchor */
- (NSMutableDictionary *) messageAttributesForAnchor;
/* Accessor for m_messageAttributesForName */
- (NSMutableDictionary *) messageAttributesForName;
/* Accessor for m_messageAttributesForTitle */
- (NSMutableDictionary *) messageAttributesForTitle;
/* Accessor for m_messageAttributesForText */
- (NSMutableDictionary *) messageAttributesForText;
/* Accessor for m_messageAttributes */
- (NSMutableDictionary *) messageAttributes;

- (NSMutableDictionary *) messageAttributesForBeProfileLink;
- (NSMutableDictionary *) messageAttributesForHost;

- (NSParagraphStyle *) messageParagraphStyleWithIndent : (float) anIndent;
- (NSParagraphStyle *) indexParagraphStyleWithSpacingBefore : (float) beforeSpace
											andSpacingAfter : (float) afterSpace;
- (NSNumber *) underlineStyleWithBool : (BOOL) hasUnderline;
@end