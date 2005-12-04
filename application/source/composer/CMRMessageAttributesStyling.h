//:CMRMessageAttributesStyling.h
/**
  *
  * �X���b�h�̏������Ǘ�����I�u�W�F�N�g�̃C���^�[�t�F�[�X�B
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/04/21  0:03:49 AM)
  *
  */
#import <Cocoa/Cocoa.h>

// ���������N�̃A�h���X������𐶐��B
extern NSString *CMRLocalResLinkWithString(NSString *address);
/* 0-based */
extern NSString *CMRLocalResLinkWithIndex(unsigned anIndex);

// be �v���t�B�[�������N�̓����\���p�A�h���X������𐶐��B
extern NSString *CMRLocalBeProfileLinkWithString(NSString *beProfile);

@protocol CMRMessageAttributesStyling<NSObject>
/*** Text Attributes ***/
- (NSDictionary *) attributesForAnchor;
- (NSDictionary *) attributesForName;
- (NSDictionary *) attributesForItemName;
- (NSDictionary *) attributesForMessage;
- (NSDictionary *) attributesForText;
- (NSDictionary *) attributesForBeProfileLink;
- (NSDictionary *) attributesForHost;

/*** Other Attributes ***/
/* <ul> */
// deprecated in LittleWish and later.
//- (NSParagraphStyle *) blockQuoteParagraphStyle;


/*** Text Attachments ***/
/* Mail Proxy Icon */
- (NSAttributedString *) mailAttachmentStringWithMail : (NSString *) address;
/* �V�����X */
- (NSAttributedString *) lastUpdatedHeaderAttachment;

/* �ȗ����ꂽ���X������܂� */
- (NSTextAttachment *) ellipsisProxyAttachment;
- (NSTextAttachment *) ellipsisDownProxyAttachment;
- (NSTextAttachment *) ellipsisUpProxyAttachment;
@end


//////////////////////////////////////////////////////////////////////
////////////////////// [ �萔��}�N���u�� ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/*** Application Specific Attribute Name ***/
/*!
 * @const       CMRMessageIndexAttributeName
 * @discussion  NSNumber, as an unsigned int
 */
extern NSString *const CMRMessageIndexAttributeName;

/* These attributes are for text attachements. */
/*!
 * @const       CMRMessageLastUpdatedHeaderAttributeName
 * @discussion  NSDate (Last Updated Date)
 */
extern NSString *const CMRMessageLastUpdatedHeaderAttributeName;
/*!
 * @const       CMRMessageProxyAttributeName
 * @discussion  Proxy TextAttachment
 */
extern NSString *const CMRMessageProxyAttributeName;

extern NSString *const CMRMessageBeProfileLinkAttributeName;

/* NSLink Attribute Private Scheme*/
extern NSString *const CMRAttributeInnerLinkScheme;
extern NSString *const CMRAttributesBeProfileLinkScheme;

// Available in TestaRossa and later.
extern NSString *const BSMessageIDAttributeName; // NSString, ID string itself.

/**
  * Text -System �Ŏg�p����f�t�H���g�̏�����
  * �����߂�������Ԃ��B
  * 
  * @return    �f�t�H���g�̏���
  */
extern NSDictionary *UTILDefaultTextAttributes(void);
