/**
  * $Id: CMRAttributedMessageComposer-Convert.m,v 1.6 2007/03/16 16:26:37 tsawada2 Exp $
  * 
  * CMRAttributedMessageComposer-Convert.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRAttributedMessageComposer_p.h"

#import <OgreKit/OgreKit.h>

void htmlConvertBreakLineTag(NSMutableString *theString)
{
	NSRange		foundRange_;
	NSRange		searchRange_;
	unsigned	repLength_;
	
	if (nil == theString || 0 == [theString length])
		return;
	
	// 2003-09-18 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
	// --------------------------------
	// - [NSMutableString strip] ����
	// ���݂̎����ł�CFStringTrimWhitespace()
	// ���g���邽�߁A���{������ƑS�p�󔒂���������Ă��܂��B
	[theString stripAtStart];
	[theString stripAtEnd];
	
	repLength_ = [DEFAULT_NEWLINE_CHARACTER length];
	searchRange_ = NSMakeRange(0, [theString length]);
	
	while (1) {
		unsigned	index_, length_;
		
		foundRange_ = [theString rangeOfString : COMPOSER_BLEAK_LINE_TAG
						options : (NSLiteralSearch | NSCaseInsensitiveSearch)
						range : searchRange_];
		
		if (0 == foundRange_.length)
			break;
		
		// �s���X�y�[�X
		index_ = foundRange_.location;
		if (index_ > 0) {
			index_--;
			for (; index_ > 0; index_--) {
				if ([theString characterAtIndex : index_] != ' ')
					break;
				foundRange_.location--;
				foundRange_.length++;
			}
		}
		
		// �s���X�y�[�X
		index_ = NSMaxRange(foundRange_);
		length_ = [theString length];
		for (; index_ < length_; index_++) {
			if ([theString characterAtIndex : index_] != ' ')
				break;
			
			foundRange_.length++;
		}
		
		[theString replaceCharactersInRange : foundRange_
								 withString : DEFAULT_NEWLINE_CHARACTER];
		searchRange_.location = foundRange_.location + repLength_;
		searchRange_.length = ([theString length] - searchRange_.location);
	}
}

static void convertMessageWith(NSMutableAttributedString *ms, NSString *str, NSDictionary *attributes)
{
	static NSString				*ulTag_ = nil;
	static OGRegularExpression	*regExp = nil;
	NSRange			start_;
	NSMutableString	*contents_;

	if(!ulTag_) {
		ulTag_ = [NSLocalizedString(@"saku target UL", nil) retain];
	}
	if(!regExp) {
		regExp = [[OGRegularExpression alloc] initWithString: @"ID:\\s?([[[:ascii:]]&&[^\\s]]{8,11})"];
	}
	
	if(ms == nil) return;

	[ms replaceCharactersInRange : [ms range] withString : str];
	[ms setAttributes : attributes range : [ms range]];
	[CMXTextParser convertMessageSourceToCachedMessage : [ms mutableString]];

	if(0 == [ms length] || ms == nil)
		return;

	contents_ = [ms mutableString];
	//start_ = NSMakeRange(0, 0);

	start_ = [contents_ rangeOfString : ulTag_
							  options : NSLiteralSearch];
//	if (0 == start_.length || NSNotFound == start_.location)
//		return;
	if (start_.length != 0) {
		// �t�H�[������̍폜�˗��ō������� <ul> </ul> �^�O���폜	
		[ms addAttribute : NSForegroundColorAttributeName value : [NSColor redColor] range : start_];
		[ms replaceCharactersInRange : start_
						  withString : NSLocalizedString(@"saku target BR", nil)];
		[contents_ replaceOccurrencesOfString : @"<ul> " // ����̔��p�X�y�[�X���݂ō폜
								   withString : @"\n"
									  options : (NSBackwardsSearch | NSLiteralSearch)
										range : NSMakeRange(0, [contents_ length])];

		[contents_ replaceOccurrencesOfString : @"</ul> " // ����̔��p�X�y�[�X���݂ō폜
								   withString : @"\n"
									  options : (NSBackwardsSearch | NSLiteralSearch)
										range : NSMakeRange(0, [contents_ length])];

		[contents_ deleteCharactersInRange : NSMakeRange([contents_ length]-6, 6)]; // ��ԍŌ�� </ul> �����ʏ���
	}

	// �{�����́uID: xxxxxxxxxx�v�Ƃ���������ɂ� Attribute ���d����ŁA�������ɂ�� ID �|�b�v�A�b�v���\�ɂ���
	NSEnumerator *iter_ = [regExp matchEnumeratorInString: contents_];
	if (!iter_) return;
	OGRegularExpressionMatch *eachMatch;
	while (eachMatch = [iter_ nextObject]) {
		NSRange IDRange = [eachMatch rangeOfMatchedString];
		[ms addAttribute:BSMessageIDAttributeName value: [eachMatch substringAtIndex: 1] range: IDRange];
	}
}

@implementation CMRAttributedMessageComposer(Convert)
- (void) convertMessage : (NSString                  *) message
				   with : (NSMutableAttributedString *) buffer
{
	convertMessageWith(buffer, message, [ATTR_TEMPLATE attributesForMessage]);
	[self convertLinkAnchor : buffer];
}
- (void) convertName : (NSString                  *) name
				with : (NSMutableAttributedString *) buffer
{
	convertMessageWith(buffer, name, [ATTR_TEMPLATE attributesForName]);
	[self makeInnerLinkAnchorInNameField : buffer];
}
@end
