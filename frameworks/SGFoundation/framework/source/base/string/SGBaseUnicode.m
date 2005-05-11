//: SGBaseUnicode.m
/**
  * $Id: SGBaseUnicode.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBaseUnicode.h"
#import "PrivateDefines.h"
#import <SGFoundation/SGFoundationBase.h>



#define UNICHAR_BUFFER_SIZE		256


static unsigned UnicodeCountBreaks_(
        CFStringRef cfStr,
        UCTextBreakType breakType,
        SGBaseRangeArray *rangesPtr /* can be NULL */
				)
{
	UniCharCount		textLength_;
	CFRange				range_;
	OSStatus			status_;
	TextBreakLocatorRef locator_;
	
	UniChar				*textPtr_;
	size_t				freeWhenDone_ = 0;
	UniChar				textBuffer_[UNICHAR_BUFFER_SIZE];
	
	UTILCAssertNotNil(cfStr);
	textLength_ = CFStringGetLength(cfStr);
	range_ = CFRangeMake(0, textLength_);
	
	/* GetCharacters */
	
	textPtr_ = (UniChar*)CFStringGetCharactersPtr(cfStr);
	if(NULL == textPtr_){
		
		if(range_.length <= UNICHAR_BUFFER_SIZE){
			freeWhenDone_ = 0;
			textPtr_ = textBuffer_;
		}else{
			freeWhenDone_ = sizeof(UniChar) * range_.length;
			textPtr_ = SGBaseZoneMalloc(NULL, freeWhenDone_);
		}
		
		CFStringGetCharacters(cfStr, range_, textPtr_);
	}
	UTILRequireCondition(textPtr_ != NULL, ErrOccurred);
	
	status_ = UCCreateTextBreakLocator (
				NULL, 
				0, 
				(breakType), 
				&locator_);
	UTILRequireCondition(noErr == status_, ErrUCCreateTextBreakLocator);
	
	UniCharArrayOffset	startOffset_	= 0;
	UniCharArrayOffset	breakOffset_	= 0;
	UniCharCount		CountUniChars_	= 0;
	
	while(breakOffset_ < textLength_){
		NSRange		cRange_;
		
		status_ = UCFindTextBreak(
					locator_, 
					(breakType), 
					(kUCTextBreakLeadingEdgeMask | kUCTextBreakIterateMask), 
					textPtr_, 
					textLength_,
					startOffset_, 
					&breakOffset_);
		UTILRequireCondition(noErr == status_, ErrUCFindTextBreak);
		
		cRange_ = NSMakeRange(startOffset_, breakOffset_ - startOffset_);
		[rangesPtr append : cRange_];
		
		CountUniChars_++;
		startOffset_ = breakOffset_;
	}
	
	status_ = UCDisposeTextBreakLocator(&locator_);
	UTILRequireCondition(noErr == status_, ErrUCDisposeTextBreakLocator);
	
	if(freeWhenDone_)
		SGBaseZoneFree(NULL, textPtr_, freeWhenDone_);
	
	return CountUniChars_;
	
	ErrUCFindTextBreak:
	ErrUCDisposeTextBreakLocator:
	ErrUCCreateTextBreakLocator:
	ErrOccurred:
		
		if(freeWhenDone_)
			SGBaseZoneFree(NULL, textPtr_, freeWhenDone_);
		
		return NSNotFound;
}

unsigned SGUnicodeGetTextLength(
					NSString			*textObj,
					SGBaseRangeArray	**rangesPtr
				)
{
    return SGUnicodeCountBreaks(textObj, kUCTextBreakClusterMask, rangesPtr);
}
unsigned SGUnicodeCountBreaks(NSString *textObj, UCTextBreakType breakType, SGBaseRangeArray **rangesPtr)
{
	unsigned			count_;
	SGBaseRangeArray	*clusterRanges_;
	
	UTILRequireCondition(textObj, can_not_locate);
	clusterRanges_ = (NULL == rangesPtr)
					? nil
					: [[[SGBaseRangeArray alloc] init] autorelease];
	
	count_ = UnicodeCountBreaks_(
					(CFStringRef)textObj,
                    breakType,
					clusterRanges_);
	
	if(rangesPtr != NULL)
		*rangesPtr = clusterRanges_;
	
	return count_;
	
	can_not_locate:
		return NSNotFound;
}



@implementation NSString(SGFoundationUnicode)
- (NSArray *) componentsSeparatedByTextBreak
{ return [self componentsSeparatedByTextBreak:kUCTextBreakClusterMask]; }
- (NSArray *) componentsSeparatedByTextBreak : (UCTextBreakType) breakType
{
	unsigned				nUnicodeElem_;
	NSMutableArray			*array_;
	SGBaseRangeArray		*rangeArray_;
	SGBaseRangeEnumerator	*enumerator_;
	
	nUnicodeElem_ = SGUnicodeCountBreaks(self, breakType, &rangeArray_);
	
	UTILAssertNotNil(rangeArray_);
	NSAssert(
		nUnicodeElem_ != NSNotFound && [rangeArray_ count],
		@"***ERROR*** can't locate Unicode Text Break");
	
	array_ = [NSMutableArray array];
	enumerator_ = [rangeArray_ enumerator];
	while([enumerator_ hasNext]){
		NSRange		range_;
		NSString	*comp_;
		
		range_ = [enumerator_ next];
		NSAssert2(
			NSMaxRange(range_) <= [self length],
			@"***OUT OF BOUNDS*** length=%u but was %@",
			[self length],
			NSStringFromRange(range_));
		
		comp_ = [self substringWithRange : range_];
		[array_ addObject : comp_];
	}
	
	return array_;
}
@end

