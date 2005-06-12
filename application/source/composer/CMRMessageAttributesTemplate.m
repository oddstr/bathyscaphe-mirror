//:CMRMessageAttributesTemplate.m
/**
  *
  * @see AppDefaults.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/06  0:08:36 AM)
  *
  */
#import "CMRMessageAttributesTemplate_p.h"
#import "CocoMonar_Prefix.h"
#import "CMXImageAttachmentCell.h"
#import "CMRAttachmentCell.h"
#import "CMXTemplateResources.h"



@implementation CMRMessageAttributesTemplate
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedTemplate);


+ (NSDictionary *) defaultAttributes
{
	static NSDictionary *st_defaultAttributes;
	
	if(nil == st_defaultAttributes){
		NSAttributedString		*temp_;
		NSDictionary			*attrs_;
		
		temp_ = [[NSAttributedString alloc] initWithString : @"a"];
		attrs_ = [temp_ attributesAtIndex:([temp_ length] -1) effectiveRange:NULL];
		[temp_ release];
		temp_ = nil;
		
		if(nil == attrs_)
			attrs_ = [NSDictionary dictionary];
		
		st_defaultAttributes = [attrs_ copy];
	}
	return st_defaultAttributes;
}

- (void) dealloc
{
	[_messageAttributesForAnchor release];
	[_messageAttributesForName release];
	[_messageAttributesForTitle release];
	[_messageAttributes release];
	[_messageAttributesForText release];
	[_messageAttributesForBeProfileLink release];
	[_messageAttributesForHost release];
	[_blockQuoteParagraphStyle release];
	
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////
////////////////// CMRMessageAttributesStylist ///////////////////////
//////////////////////////////////////////////////////////////////////
/* アンカーの書式 */
- (NSDictionary *) attributesForAnchor
{
	return [self messageAttributesForAnchor];
}

/* 名前欄の書式 */
- (NSDictionary *) attributesForName
{
	return [self messageAttributesForName];
}

/* 項目名の書式 */
- (NSDictionary *) attributesForItemName
{
	return [self messageAttributesForTitle];
}

/* 本文の書式 */
- (NSDictionary *) attributesForMessage
{
	return [self messageAttributes];
}

/* 標準の書式 */
- (NSDictionary *) attributesForText
{
	return [self messageAttributesForText];
}
- (NSDictionary *) attributesForBeProfileLink
{
	return [self messageAttributesForBeProfileLink];
}
- (NSDictionary *) attributesForHost
{
	return [self messageAttributesForHost];
}

/*** Other Attributes ***/
/* <ul> */
- (NSParagraphStyle *) blockQuoteParagraphStyle
{
	float		indent_;
	
	if(_blockQuoteParagraphStyle != nil)
		return _blockQuoteParagraphStyle;
	
	indent_ = [CMRPref messageHeadIndent];
	indent_ *= 2;
	_blockQuoteParagraphStyle = [self messageParagraphStyleWithIndent : indent_];
	[_blockQuoteParagraphStyle retain];
	
	return _blockQuoteParagraphStyle;
}

/*** Text Attachments ***/
- (NSAttributedString *) mailAttachmentStringWithMail : (NSString *) address
{
	NSAttributedString			*attachment_;
	NSString					*address_;
	
	address_ = [address stringByStriped];
	if(nil == address_ || 0 == [address_ length]) return nil;
	
	if([address_ isEqualToString : CMRThreadMessage_AGE_String]){
		attachment_ = [self ageImageAttachmentString];
	}else if([address_ isEqualToString : CMRThreadMessage_SAGE_String]){
		attachment_ = [self sageImageAttachmentString];
	}else{
		NSMutableAttributedString	*attrs_;
		NSMutableString				*mstr_;
		NSRange						rng_;
		
		attrs_ = [self mailImageAttachmentString];
		rng_ = NSMakeRange(0, [attrs_ length]);
		mstr_ = [[NSMutableString allocWithZone : nil] initWithString : @"mailto:"];
		[mstr_ appendString : address_];
		[attrs_ addAttribute : NSLinkAttributeName
					   value : mstr_
					   range : rng_];
		attachment_ = [[attrs_ copyWithZone : nil] autorelease];
		[mstr_ release];
	}
	return attachment_;
}
- (NSAttributedString *) lastUpdatedHeaderAttachment
{
	static NSAttributedString	*st_lastUpdatedHeaderAttachment;
	
	if(nil == st_lastUpdatedHeaderAttachment){
		NSAttributedString				*attachment_;
		NSMutableAttributedString		*mattachment_;
		
		attachment_ = [self attachmentAttributedStringWithImageFile : kUpdatedHeaderImageName];
		mattachment_ = [attachment_ mutableCopyWithZone : nil];
		[mattachment_ appendString : @"\n"
					withAttributes : [NSDictionary empty]];
		st_lastUpdatedHeaderAttachment = [mattachment_ copyWithZone : nil];
		[mattachment_ release];
	}
	if(nil == st_lastUpdatedHeaderAttachment){
		st_lastUpdatedHeaderAttachment = [[NSAttributedString alloc] init];
	}
	return st_lastUpdatedHeaderAttachment;
}
/* 省略されたレスがあります */
- (NSTextAttachment *) ellipsisProxyAttachmentWithName : (NSString *) aName mouseDown:(NSString *) mouseDownImg mouseOver:(NSString *) mouseOverImg
{
	NSImage				*img;
	NSTextAttachment	*attachment_;
	CMRAttachmentCell	*cell_;
	
	attachment_ =  [[NSTextAttachment alloc] init];
	
	img = [NSImage imageAppNamed : aName];
	cell_ = [[CMRAttachmentCell alloc] initImageCell : img];
	img = [NSImage imageAppNamed : mouseDownImg];
	[cell_ setMouseDownImage : img];
	img = [NSImage imageAppNamed : mouseOverImg];
	[cell_ setMouseOverImage : img];
	
	[attachment_ setAttachmentCell : cell_];
	[cell_ release];
	
	return [attachment_ autorelease];
}
- (NSTextAttachment *) ellipsisProxyAttachment
{
	return [self ellipsisProxyAttachmentWithName : kEllipsisProxyImage
					mouseDown:kEllipsisMouseDownImage 
					mouseOver:kEllipsisMouseOverImage];
}
- (NSTextAttachment *) ellipsisDownProxyAttachment
{
	return [self ellipsisProxyAttachmentWithName : kEllipsisDownProxyImage
					mouseDown:kEllipsisDownMouseDownImage 
					mouseOver:kEllipsisDownMouseOverImage];
}
- (NSTextAttachment *) ellipsisUpProxyAttachment
{
	return [self ellipsisProxyAttachmentWithName : kEllipsisUpProxyImage
					mouseDown:kEllipsisUpMouseDownImage 
					mouseOver:kEllipsisUpMouseOverImage];
}
@end



@implementation CMRMessageAttributesTemplate(Attributes)
/* Accessor for _messageAttributesForAnchor */
- (void) setAttributeForAnchor : (NSString *) name
                         value : (id        ) value
{
	[self setAttributeInDictionary : [self messageAttributesForAnchor]
					 attributeName : name
					         value : value];
}

/* Accessor for _messageAttributesForName */
- (void) setAttributeForName : (NSString *) name
                       value : (id        ) value
{
	[self setAttributeInDictionary : [self messageAttributesForName]
					 attributeName : name
					         value : value];
}

/* Accessor for _messageAttributesForTitle */
- (void) setAttributeForTitle : (NSString *) name
                        value : (id        ) value
{
	[self setAttributeInDictionary : [self messageAttributesForTitle]
					 attributeName : name
					         value : value];
}

/* Accessor for _messageAttributes */
- (void) setAttributeForMessage : (NSString *) name
                          value : (id        ) value
{
	[self setAttributeInDictionary : [self messageAttributes]
					 attributeName : name
					         value : value];
}
/* Accessor for _messageAttributesForText */
- (void) setAttributeForText : (NSString *) name
					   value : (id        ) value
{
	[self setAttributeInDictionary : [self messageAttributesForText]
					 attributeName : name
					         value : value];
	if([name isEqualToString : NSFontAttributeName]){
		// 名前欄と共通
		[self setAttributeForName : name
							value : value];
	}
}
- (void) setAttributeForBeProfileLink : (NSString *) name
                        value : (id        ) value
{
	[self setAttributeInDictionary : [self messageAttributesForBeProfileLink]
					 attributeName : name
					         value : value];
}
- (void) setAttributeForHost : (NSString *) name
                        value : (id        ) value
{
	[self setAttributeInDictionary : [self messageAttributesForHost]
					 attributeName : name
					         value : value];
}

- (void) setMessageHeadIndent : (float) anIndent
{
	[self setAttributeInDictionary : [self messageAttributes]
					 attributeName : NSParagraphStyleAttributeName
							 value : [self messageParagraphStyleWithIndent : anIndent]];
}
- (void) setHasAnchorUnderline : (BOOL) flag
{
	[self setAttributeInDictionary : [self messageAttributesForAnchor]
					 attributeName : NSUnderlineStyleAttributeName
							 value : [self underlineStyleWithBool : flag]];
}
@end



@implementation CMRMessageAttributesTemplate(AttachmentTemplate)
- (NSAttributedString *) attachmentAttributedStringWithImageFile : (NSString *) anImageName
{
	NSImage						*image_;
	NSTextAttachment			*attachment_;
	NSAttributedString			*attrs_ = nil;
	CMXImageAttachmentCell		*cell_;
	NSNumber					*alignment_;
	
	UTILRequireCondition(
		anImageName && NO == [anImageName isEmpty],
		ErrCreateAttachment);
	
	image_ = [NSImage imageAppNamed : anImageName];
	UTILRequireCondition(image_, ErrCreateAttachment);
	
	// 画像リソースをNSTextAttachmentにする。
	// Text Attachment Cellの設定
	attachment_ =  [[NSTextAttachment alloc] init];
	cell_ = [[CMXImageAttachmentCell alloc] initImageCell : image_];
	alignment_ = CMXTemplateResource(kMailIconAlignment, @"Alignment");
	UTILAssertKindOfClass(alignment_, NSNumber);
	[cell_ setImageAlignment : [alignment_ intValue]];
	
	[attachment_ setAttachmentCell : cell_];
	[cell_ release];
	
	UTILRequireCondition(attachment_ && cell_, ErrCreateAttachment);
	
	attrs_ = [NSAttributedString attributedStringWithAttachment : attachment_];
	[attachment_ release];
	UTILRequireCondition(attrs_, ErrCreateAttachment);
	
ErrCreateAttachment:

	return attrs_;
}

/**
  * メールアドレスへのリンクを示すアタッチメントを含む書式つき文字列を返す。
  * 
  * @return     メールアドレスへのリンクを示すアタッチメントを含む書式つき文字列
  */
- (NSMutableAttributedString *) mailImageAttachmentString
{
	static NSMutableAttributedString *st_mailAttachmentAttrs;		//アタッチメント
	
	if(nil == st_mailAttachmentAttrs){
		NSAttributedString	*attrs_ = nil;				// 書式つき文字列
		
		attrs_ = [self attachmentAttributedStringWithImageFile : kMailImageFileName];
		st_mailAttachmentAttrs = [attrs_ mutableCopyWithZone : nil];
	}
	if(nil == st_mailAttachmentAttrs){
		NSString *mailStr_;
		
		// リソースへのパスを取得できなかった場合は
		// 通常の文字で代用する。
		mailStr_ = [NSString stringWithCharacter : 0x25a0];		//■
		st_mailAttachmentAttrs 
		  = [[NSMutableAttributedString allocWithZone : nil]
									   initWithString : mailStr_];
	}
	return st_mailAttachmentAttrs;
}

- (NSAttributedString *) ageImageAttachmentString
{
	static NSAttributedString *st_mailAttachmentAttrs;		//アタッチメント
	
	if(nil == st_mailAttachmentAttrs){
		NSAttributedString	*attrs_ = nil;				// 書式つき文字列
		
		attrs_ = [self attachmentAttributedStringWithImageFile : kAgeImageFileName];
		st_mailAttachmentAttrs = [attrs_ copyWithZone : nil];
	}
	if(nil == st_mailAttachmentAttrs){
		// リソースへのパスを取得できなかった場合は
		// 通常の文字で代用する。
		st_mailAttachmentAttrs = [[NSAttributedString allocWithZone : nil]
														initWithString : @"(+)"];
	}
	return st_mailAttachmentAttrs;
}
- (NSAttributedString *) sageImageAttachmentString
{
	static NSAttributedString *st_mailAttachmentAttrs;		//アタッチメント
	
	if(nil == st_mailAttachmentAttrs){
		NSAttributedString	*attrs_ = nil;				// 書式つき文字列
		
		attrs_ = [self attachmentAttributedStringWithImageFile : kSageImageFileName];
		st_mailAttachmentAttrs = [attrs_ copyWithZone : nil];
	}
	if(nil == st_mailAttachmentAttrs){
		// リソースへのパスを取得できなかった場合は
		// 通常の文字で代用する。
		st_mailAttachmentAttrs = [[NSAttributedString allocWithZone : nil]
														initWithString : @"(-)"];
	}
	return st_mailAttachmentAttrs;
}

@end



@implementation CMRMessageAttributesTemplate(Private)
- (void) setAttributeInDictionary : (NSMutableDictionary *) dict
                    attributeName : (NSString            *) name
                            value : (id                   ) value
{
	if(nil == dict || nil == name) return;
	
	if(nil == value){
		[dict removeObjectForKey : name];
	}else{
		[dict setObject : value
				 forKey : name];
	}
}

/* Accessor for _messageAttributesForAnchor */
- (NSMutableDictionary *) messageAttributesForAnchor
{
	if(nil == _messageAttributesForAnchor){
		BOOL		hasUnderline_;
		
		_messageAttributesForAnchor = 
			[[[self class] defaultAttributes] mutableCopyWithZone : nil];
		[self setAttributeInDictionary : _messageAttributesForAnchor
						 attributeName : NSForegroundColorAttributeName
								 value : [CMRPref messageAnchorColor]];
		
		hasUnderline_ = [CMRPref hasMessageAnchorUnderline];
		[self setAttributeInDictionary : _messageAttributesForAnchor
						 attributeName : NSUnderlineStyleAttributeName
								 value : [self underlineStyleWithBool : hasUnderline_]];
	}
	return _messageAttributesForAnchor;
}

/* Accessor for _messageAttributesForName */
- (NSMutableDictionary *) messageAttributesForName
{
	if(nil == _messageAttributesForName){
		_messageAttributesForName = 
			[[[self class] defaultAttributes] mutableCopyWithZone : nil];
		[self setAttributeInDictionary : _messageAttributesForName
						 attributeName : NSForegroundColorAttributeName
								 value : [CMRPref messageNameColor]];
		// フォントは標準テキストと同じ。
		[self setAttributeInDictionary : _messageAttributesForName
						 attributeName : NSFontAttributeName
								 value : [CMRPref threadsViewFont]];
	}
	return _messageAttributesForName;

}

/* Accessor for _messageAttributesForTitle */
- (NSMutableDictionary *) messageAttributesForTitle
{
	if(nil == _messageAttributesForTitle){
		_messageAttributesForTitle = 
			[[[self class] defaultAttributes] mutableCopyWithZone : nil];
		[self setAttributeInDictionary : _messageAttributesForTitle
						 attributeName : NSForegroundColorAttributeName
								 value : [CMRPref messageTitleColor]];
		[self setAttributeInDictionary : _messageAttributesForTitle
						 attributeName : NSFontAttributeName
								 value : [CMRPref messageTitleFont]];
	}
	return _messageAttributesForTitle;
}

/* Accessor for _messageAttributes */
- (NSMutableDictionary *) messageAttributes
{
	if(nil == _messageAttributes){
		float					indent_;
		NSParagraphStyle		*messageParagraphStyle_;
		
		indent_ = [CMRPref messageHeadIndent];
		messageParagraphStyle_ = [self messageParagraphStyleWithIndent : indent_];
		
		_messageAttributes = 
			[[[self class] defaultAttributes] mutableCopyWithZone : nil];
		[self setAttributeInDictionary : _messageAttributes
						 attributeName : NSParagraphStyleAttributeName
								 value : messageParagraphStyle_];
		[self setAttributeInDictionary : _messageAttributes
						 attributeName : NSForegroundColorAttributeName
								 value : [CMRPref messageColor]];
		[self setAttributeInDictionary : _messageAttributes
						 attributeName : NSFontAttributeName
								 value : [CMRPref messageFont]];
	}
	return _messageAttributes;
}

/* Accessor for _messageAttributesForText */
- (NSMutableDictionary *) messageAttributesForText
{
	if(nil == _messageAttributesForText){
		_messageAttributesForText = 
			[[[self class] defaultAttributes] mutableCopyWithZone : nil];
		
		[self setAttributeInDictionary : _messageAttributesForText
						 attributeName : NSFontAttributeName
								 value : [CMRPref threadsViewFont]];
		[self setAttributeInDictionary : _messageAttributesForText
						 attributeName : NSForegroundColorAttributeName
								 value : [CMRPref threadsViewColor]];
	}
	return _messageAttributesForText;
}
- (NSMutableDictionary *) messageAttributesForBeProfileLink
{
	if(nil == _messageAttributesForBeProfileLink){
		_messageAttributesForBeProfileLink = 
			[[[self class] defaultAttributes] mutableCopyWithZone : nil];
	/*	[self setAttributeInDictionary : _messageAttributesForBeProfileLink
						 attributeName : NSForegroundColorAttributeName
								 value : [CMRPref messageAnchorColor]];
		
		hasUnderline_ = [CMRPref hasMessageAnchorUnderline];
		[self setAttributeInDictionary : _messageAttributesForBeProfileLink
						 attributeName : NSUnderlineStyleAttributeName
								 value : [self underlineStyleWithBool : hasUnderline_]];*/
		[self setAttributeInDictionary : _messageAttributesForBeProfileLink
						 attributeName : NSFontAttributeName
								 value : [CMRPref messageBeProfileFont]];
	}
	return _messageAttributesForBeProfileLink;
}
- (NSMutableDictionary *) messageAttributesForHost
{
	if(nil == _messageAttributesForHost){
		_messageAttributesForHost = 
			[[[self class] defaultAttributes] mutableCopyWithZone : nil];
		[self setAttributeInDictionary : _messageAttributesForHost
						 attributeName : NSForegroundColorAttributeName
								 value : [CMRPref messageHostColor]];
		[self setAttributeInDictionary : _messageAttributesForHost
						 attributeName : NSFontAttributeName
								 value : [CMRPref messageHostFont]];
	}
	return _messageAttributesForHost;
}

- (NSParagraphStyle *) messageParagraphStyleWithIndent : (float) anIndent
{
	NSMutableParagraphStyle *paraStyle_;
	
	paraStyle_ = 
	  [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle_ setFirstLineHeadIndent : anIndent];
	[paraStyle_ setHeadIndent : anIndent];
	
	return [paraStyle_ autorelease];
}

- (id) underlineStyleWithBool : (BOOL) hasUnderline
{
	if(NO == hasUnderline) return nil;
	
	return [NSNumber numberWithUnsignedInt : NSSingleUnderlineStyle];
}
@end