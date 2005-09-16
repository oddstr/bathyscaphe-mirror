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
  * リソースからNSTextAttachmentを作成し、書式つき文字列で返す。
  * 
  * @param    filename  リソースへのパス
  * @return             書式つき文字列
  */
- (NSAttributedString *) attachmentAttributedStringWithImageFile : (NSString *) filename;

// age, sage, address
/**
  * メールアドレスへのリンクを示すアタッチメントを含む書式つき文字列を返す。
  * 
  * @return     メールアドレスへのリンクを示すアタッチメントを含む書式つき文字列
  */
- (NSMutableAttributedString *) mailImageAttachmentString;
- (NSAttributedString *) ageImageAttachmentString;
- (NSAttributedString *) sageImageAttachmentString;
@end

@interface CMRMessageAttributesTemplate(Private)
/**
  * 属性辞書の引数nameで指定された属性を書き換える。
  * valueがnilの場合は消去。
  * 
  * @param    dict   属性辞書
  * @param    name   属性の名前
  * @param    value  属性の値
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