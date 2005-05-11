//: NSString+Japanese.m
/**
  * $Id: NSString+Japanese.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSString+Japanese.h"
#import "UTILKit.h"
#import <SGFoundation/String+Utils.h>
#import <SGFoundation/NSString-SGExtensions.h>



@implementation NSString(JapaneseStringExtensions)
- (NSRange) searchRangeOfString : (NSString *) subString
					    options : (unsigned  ) mask
					      range : (NSRange   ) aRange
{
	if(mask & SGZenkakuHankakuInsensitiveSearch)
		return SGStringSearch_JP(self, subString, mask, aRange);
	
	return [self rangeOfString:subString options:mask range:aRange];
}
@end



NSRange SGStringSearch_JP(NSString *src, NSString *subString, unsigned options, NSRange searchRange)
{
	return [src rangeOfString:subString options:options range:searchRange];
	
/*
ErrSGStringSearch_JP:
	return kNFRange;
*/
}

