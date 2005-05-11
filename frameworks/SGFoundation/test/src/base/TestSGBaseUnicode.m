//: TestSGBaseUnicode.m
/**
  * $Id: TestSGBaseUnicode.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestSGBaseUnicode.h"


static size_t uni_strlen(ConstUniCharArrayPtr ptr);


@implementation TestSGBaseUnicode
- (void) setUp
{
	;
}
- (void) tearDown
{
	;
}

- (void) test_simple
{
	NSString	*test = @"12345";
	unsigned	nUnicodeElem_;
	
	nUnicodeElem_ = SGUnicodeGetTextLength(test, NULL);
	
	[self assertInt:nUnicodeElem_ equals:[test length] message:test];
}
- (void) test_soLongString
{
	NSString	*test = @" Defines the buffer and related fields used for in-line buffer access of characters in CFString objects. Do not access the fields directly as they might change between releases.";
	unsigned	nUnicodeElem_;
	
	nUnicodeElem_ = SGUnicodeGetTextLength(test, NULL);
	
	[self assertInt:nUnicodeElem_ equals:[test length] message:test];
}
- (void) test_simple_range
{
	NSString				*test = @"12345";
	unsigned				nUnicodeElem_;
	SGBaseRangeArray		*rangeArray_;
	SGBaseRangeEnumerator	*enumerator_;
	
	nUnicodeElem_ = SGUnicodeGetTextLength(test, &rangeArray_);
	
	[self assertNotNil : rangeArray_];
	[self assertInt:[rangeArray_ count] equals:[test length]];
	enumerator_ = [rangeArray_ enumerator];
	
	while([enumerator_ hasNext]){
		NSRange		range_;
		
		range_ = [enumerator_ next];
		[self assertInt:range_.length equals:1];
	}
	
	[self assertInt:nUnicodeElem_ equals:[test length] message:test];
}



- (void) test_001
{
	NSString			*text_;
	
	static UniChar test_cases[][11] = {
		{'1', '2'},
		{ 0x0041, 0x0300, 0x0041, 0x0300 },
		{ 0x304B, 0x3099, 0x304B, 0x3099 },
		{ 0x0061, 0x0323, 0x0302, 0x0061, 0x0323, 0x0302 },
		{ 0xD842, 0xDFB7, 0xD842, 0xDFB7 },
		{ 0x3042, 0x20DD, 0x3042, 0x20DD },
		{ 0xF862, 0x6709, 0x9650, 0x4F1A, 0x793E, 0xF862, 0x6709, 0x9650, 0x4F1A, 0x793E, 0 }
	};
	
	int i, cnt;
	
	cnt = sizeof(test_cases) / sizeof(UniChar[11]);
	
	for(i = 0; i < cnt; i++){
		UniChar			*uc;
		unsigned		len_;
		SGBaseRangeArray		*rangeArray_;
	
		
		uc = test_cases[i];
		len_ = uni_strlen(uc);
		text_ = [[NSString alloc] 
			initWithCharactersNoCopy:uc length:len_ freeWhenDone:NO];
		
		len_ = SGUnicodeGetTextLength(text_, &rangeArray_);
		[self assertTrue : 2 == len_
				  format : @"TextElem must be count 2 index(%u)", i];
		
		[self assertNotNil : rangeArray_];
		[self assertInt : [rangeArray_ count]
				equals : len_
				   format : @"rangeArray count. index(%u)", i];
		
		[text_ autorelease];
		
	}

}

@end



static size_t uni_strlen(ConstUniCharArrayPtr ptr)
{
	UniCharCount	cnt = 0;
	
	for(cnt = 0; *ptr++ != 0; cnt++)
		;
	
	return cnt;
}
