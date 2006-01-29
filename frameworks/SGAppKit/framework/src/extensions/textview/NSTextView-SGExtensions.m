//: NSTextView-SGExtensions.m
/**
  * $Id: NSTextView-SGExtensions.m,v 1.1.1.1.4.2 2006/01/29 12:58:10 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSTextView-SGExtensions_p.h"
#import <SGFoundation/SGFoundation.h>


@implementation NSTextView(TextStorageAttributes)
- (id) attribute : (NSString	 *) aName
		 atPoint : (NSPoint		  ) aPoint 
  effectiveRange : (NSRangePointer) aRangePtr
{
	NSTextStorage		*content_    = [self textStorage];
	NSLayoutManager		*lmanager_   = [self layoutManager];
	NSTextContainer		*tcontainer_ = [self textContainer];
	unsigned		glyphIndex_;
	unsigned		charIndex_;
	
	UTILRequireCondition(
		[self mouse:aPoint inRect:[self bounds]],
		no_attribute);
	
	glyphIndex_ = [lmanager_ glyphIndexForPoint : aPoint
								inTextContainer : tcontainer_
				 fractionOfDistanceThroughGlyph : NULL];
	UTILRequireCondition(
		glyphIndex_ < [lmanager_ numberOfGlyphs],
		no_attribute);
	
	charIndex_ = [lmanager_ characterIndexForGlyphAtIndex : glyphIndex_];
	UTILRequireCondition(
		charIndex_ < [[content_ string] length],
		no_attribute);
	
	return [content_ attribute : aName
					   atIndex : charIndex_
				effectiveRange : aRangePtr];
	
no_attribute:
	if(aRangePtr != NULL) *aRangePtr = kNFRange;
	return nil;
}

- (id) attribute : (NSString	 *) aName
		 atPoint : (NSPoint		  ) aPoint 
  longestEffectiveRange : (NSRangePointer) aRangePtr
  inRange : (NSRange) rangeLimit
{
	NSTextStorage		*content_    = [self textStorage];
	NSLayoutManager		*lmanager_   = [self layoutManager];
	NSTextContainer		*tcontainer_ = [self textContainer];
	unsigned		glyphIndex_;
	unsigned		charIndex_;
	
	UTILRequireCondition(
		[self mouse:aPoint inRect:[self bounds]],
		no_attribute);
	
	glyphIndex_ = [lmanager_ glyphIndexForPoint : aPoint
								inTextContainer : tcontainer_
				 fractionOfDistanceThroughGlyph : NULL];
	UTILRequireCondition(
		glyphIndex_ < [lmanager_ numberOfGlyphs],
		no_attribute);
	
	charIndex_ = [lmanager_ characterIndexForGlyphAtIndex : glyphIndex_];
	UTILRequireCondition(
		charIndex_ < [[content_ string] length],
		no_attribute);
	
	return [content_ attribute : aName
					   atIndex : charIndex_
				longestEffectiveRange : aRangePtr
				inRange : rangeLimit];
	
no_attribute:
	if(aRangePtr != NULL) *aRangePtr = kNFRange;
	return nil;
}

#pragma mark From CMXAdditions
- (NSRect) boundingRectForCharacterInRange : (NSRange) aRange
{
	NSLayoutManager		*lm  = [self layoutManager];
	NSTextContainer		*container_ = [self textContainer];
	unsigned int		count_;
	NSRange				glyphRange_;
	
	count_ = [[self string] length];
	if(NSNotFound == aRange.location || NSMaxRange(aRange) > count_) 
		return NSZeroRect;
	
	glyphRange_ = [lm glyphRangeForCharacterRange : aRange
							 actualCharacterRange : NULL];
	return [lm boundingRectForGlyphRange : glyphRange_
								inTextContainer : container_];
}
- (NSRange) characterRangeForDocumentVisibleRect
{
	NSRect				visibleRect_;
	NSRange				glyphRange_;
	NSRange				charRange_;
	NSLayoutManager		*lm;
	NSTextContainer		*container_;
	
	visibleRect_ = [[self enclosingScrollView] documentVisibleRect];
	lm = [self layoutManager];
	container_ = [self textContainer];
	
	// Glyphを生成しないメソッド
	glyphRange_ = 
	  [lm glyphRangeForBoundingRectWithoutAdditionalLayout : visibleRect_ 
	  					   inTextContainer : container_];
	charRange_ = [lm characterRangeForGlyphRange : glyphRange_
									   actualGlyphRange : NULL];
	
	return charRange_;
}
@end
