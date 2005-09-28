//:CMRMessageAttributesTemplate.h
/**
  *
  * スレッドの標準的な書式を管理するオブジェクト
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/04/21  0:12:41 AM)
  *
  */
#import <Cocoa/Cocoa.h>
#import "CMRMessageAttributesStyling.h"



@interface CMRMessageAttributesTemplate : NSObject<CMRMessageAttributesStyling>
{
	NSMutableDictionary *_messageAttributesForAnchor;	//リンクの書式
	NSMutableDictionary *_messageAttributesForName;	//名前の書式
	NSMutableDictionary *_messageAttributesForTitle;	//項目のタイトル書式
	NSMutableDictionary *_messageAttributesForText;	//標準の書式
	NSMutableDictionary *_messageAttributes;			//メッセージの書式
	
	NSMutableDictionary *_messageAttributesForBeProfileLink;	//Be プロフィールリンクの書式
	NSMutableDictionary *_messageAttributesForHost;	//Hostの書式
	
	NSParagraphStyle	*_blockQuoteParagraphStyle;
}
+ (NSDictionary *) defaultAttributes;
+ (id) sharedTemplate;
@end




@interface CMRMessageAttributesTemplate(Attributes)
/* Accessor for _messageAttributesForAnchor */
- (void) setAttributeForAnchor : (NSString *) name
                         value : (id        ) value;

/* Accessor for _messageAttributesForName */
- (void) setAttributeForName : (NSString *) name
                       value : (id        ) value;

/* Accessor for _messageAttributesForTitle */
- (void) setAttributeForTitle : (NSString *) name
                        value : (id        ) value;

/* Accessor for _messageAttributes */
- (void) setAttributeForMessage : (NSString *) name
                          value : (id        ) value;

/* Accessor for _messageAttributesForText */
- (void) setAttributeForText : (NSString *) name
					   value : (id        ) value;

- (void) setAttributeForBeProfileLink : (NSString *) name
								value : (id        ) value;
					   
- (void) setAttributeForHost : (NSString *) name
					   value : (id        ) value;
					   
- (void) setMessageHeadIndent : (float) anIndent;
- (void) setHasAnchorUnderline : (BOOL) flag;

// Added in LeafTicket.
- (void) setMessageIdxSpacingBefore : (float) beforeValue
					andSpacingAfter : (float) afterValue;
@end
