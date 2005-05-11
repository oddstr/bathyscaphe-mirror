//: NSTextView+CMXAdditions.m
/**
  * $Id: NSTextView+CMXAdditions.m,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSTextView+CMXAdditions.h"




@implementation NSTextView(CMXAppAdditions)
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
	
	// GlyphÇê∂ê¨ÇµÇ»Ç¢ÉÅÉ\ÉbÉh
	glyphRange_ = 
	  [lm glyphRangeForBoundingRectWithoutAdditionalLayout : visibleRect_ 
	  					   inTextContainer : container_];
	charRange_ = [lm characterRangeForGlyphRange : glyphRange_
									   actualGlyphRange : NULL];
	
	return charRange_;
}
@end
