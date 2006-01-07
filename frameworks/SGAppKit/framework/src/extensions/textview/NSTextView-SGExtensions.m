//: NSTextView-SGExtensions.m
/**
  * $Id: NSTextView-SGExtensions.m,v 1.2 2006/01/07 11:56:50 tsawada2 Exp $
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
@end
