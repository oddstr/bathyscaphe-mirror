//: NSLayoutManager+CMXAdditions.m
/**
  * $Id: NSLayoutManager+CMXAdditions.m,v 1.1.1.1.4.1 2006/01/29 12:58:10 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSLayoutManager+CMXAdditions.h"

#import <SGFoundation/String+Utils.h>

@implementation NSLayoutManager(CMXAdditions)
- (unsigned) performsGlyphGenerationIfNeeded
{
	unsigned		numberOfGlyphs_;
	
	numberOfGlyphs_ = [self numberOfGlyphs];
	if(0 == numberOfGlyphs_)
		return numberOfGlyphs_;
	
	NSAssert2(
		[self isValidGlyphIndex : (numberOfGlyphs_ -1)],
		@"***ERROR*** numberOfGlyphs(%u), but index(%u) was invalid index!?",
		numberOfGlyphs_,
		(numberOfGlyphs_ -1));
	
	return numberOfGlyphs_;
}
- (NSRect) boundingRectForTextContainer : (NSTextContainer *) aContainer
{
	return [self boundingRectForGlyphRange:[self glyphRangeForTextContainer:aContainer] inTextContainer:aContainer];
}

- (BOOL) isValidGlyphRange : (NSRange) glyphRange
{
	if(NO == [self isValidGlyphIndex : glyphRange.location])
		return NO;
	
	if(NO == [self isValidGlyphIndex : NSMaxRange(glyphRange) -1])
		return NO;
	
	return YES;
}
- (unsigned) glyphIndexForCharacterAtIndex : (unsigned) anIndex
{
	NSRange			glyphRange_;
	
	glyphRange_ = [self glyphRangeForCharacterRange:NSMakeRange(anIndex, 1) actualCharacterRange:NULL];
	return glyphRange_.location;
}
@end



@implementation NSLayoutManager(ChangingTextStorage)
- (void) changeTextStorage : (NSTextStorage *) newTextStorage
{
	NSTextStorage		*textStorage_;
	
	textStorage_ = [self textStorage];
	
	[self retain];
	[textStorage_ removeLayoutManager : self];
	[newTextStorage addLayoutManager : self];
	[self autorelease];
	
	if(nil == textStorage_ || nil == newTextStorage)
		return;
	
	if(LAYOUTMANAGER_SHOULD_FIX_BAD_BEHAVIOR){
		unsigned	mask_;
		NSRange		invalidatedRange_;
		
		mask_ = (NSTextStorageEditedCharacters | NSTextStorageEditedAttributes);
		invalidatedRange_ = [newTextStorage range];
		[self textStorage : newTextStorage
				   edited : mask_
					range : invalidatedRange_
		   changeInLength : ([textStorage_ length] * -1)
		 invalidatedRange : invalidatedRange_];
	}
}
@end
