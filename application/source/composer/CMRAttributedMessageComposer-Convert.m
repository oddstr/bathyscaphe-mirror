/**
  * $Id: CMRAttributedMessageComposer-Convert.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRAttributedMessageComposer-Convert.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRAttributedMessageComposer_p.h"



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
/**
  * htmlConvertBlockQuate :
  * 
  * �{����<ul>�^�O�����B
  * 
  * �폜�ΏۃA�h���X�F <ul> http://love.2ch.net/test/read.cgi/gay/1038583608/439 <br> </ul> 
  * -->
  * �폜�ΏۃA�h���X�F
  * 	http://love.2ch.net/test/read.cgi/gay/1038583608/439
  * 
  */
static void htmlConvertBlockQuate(NSMutableAttributedString *mAttrs)
{
	unsigned	length_;
	NSRange		start_;
	NSRange		end_;
	NSRange		search_;
	NSString	*contents_;
	unsigned	needsToBeConvertedBreakLine = 0;
	
	length_ = [mAttrs length];
	if (nil == mAttrs || 0 == length_)
		return;
	
	contents_ = [mAttrs string];
	search_ = NSMakeRange(0, length_);
	start_ = NSMakeRange(0, 0);
	end_ = NSMakeRange(0, 0);
	
	while (1) {
		NSRange		effectiveRange_;
		BOOL		continue_ = YES;
		
		
		start_ = [contents_ rangeOfString : @"<ul>"
							      options : NSLiteralSearch
							        range : search_];
		if (0 == start_.length || NSNotFound == start_.location) {
			
			continue_ = NO;
			break;
		}
		
		effectiveRange_.location = NSMaxRange(start_);
		if (effectiveRange_.location == length_) {
			continue_ = NO;
			goto DeleteULTagElem;
		}
		
		search_.location = effectiveRange_.location;
		search_.length = length_ - search_.location;

		end_ = [contents_ rangeOfString : @"</ul>"
							    options : NSLiteralSearch
							      range : search_];
		if (0 == end_.length || NSNotFound == end_.location) {
			continue_ = NO;
			goto DeleteULTagElem;
		}
		
		effectiveRange_.length = end_.location - effectiveRange_.location;
		if (effectiveRange_.length != 0) {
			NSParagraphStyle		*paraStyle_;
			
			paraStyle_ = [ATTR_TEMPLATE blockQuoteParagraphStyle];
			[mAttrs addAttribute : NSParagraphStyleAttributeName
						   value : paraStyle_
						   range : effectiveRange_];
/*
			[mAttrs addAttribute : NSBackgroundColorAttributeName
						   value : [NSColor lightGrayColor]
						   range : effectiveRange_];
*/
			
			effectiveRange_ = NSMakeRange(0, 0);
		}
		
DeleteULTagElem:
		{
			if (start_.length != 0) {
				//
				// �J�n�^�O
				//
				needsToBeConvertedBreakLine++;
				[mAttrs replaceCharactersInRange : start_
									  withString : COMPOSER_BLEAK_LINE_TAG];
				
				end_.location -= start_.length;
				end_.location += [COMPOSER_BLEAK_LINE_TAG length];
			}
			if (end_.length != 0) {
				[mAttrs deleteCharactersInRange : end_];
			}
		}
		
		if (NO == continue_)
			break;
		
		length_ = [mAttrs length];
		search_.location = end_.location;
		if (length_ == search_.location)
			break;
		
		search_.length = length_ - search_.location;
		
	}
	if (needsToBeConvertedBreakLine != 0)
		htmlConvertBreakLineTag([mAttrs mutableString]);
}


static void convertMessageWith(NSMutableAttributedString *ms, NSString *str, NSDictionary *attributes)
{
	[ms replaceCharactersInRange:[ms range] withString:str];
	
	[ms setAttributes:attributes range:[ms range]];
	[CMXTextParser convertMessageSourceToCachedMessage : [ms mutableString]];
	htmlConvertBlockQuate(ms);
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