//
//  NSCharacterSet+CMXAdditions.h
//  BathyScaphe (CocoMonar Framework)
//
//  Updated by Tsutomu Sawada on 07/10/18.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet(CMRCharacterSetAddition)
+ (NSCharacterSet *)innerLinkPrefixCharacterSet;
+ (NSCharacterSet *)innerLinkRangeCharacterSet;
+ (NSCharacterSet *)innerLinkSeparaterCharacterSet;

/*
0 - 9 ０ - ９
日本語以外の環境だとdecimalDigitCharacterSetが
全角数字を認識しないようなので
*/
+ (NSCharacterSet *)numberCharacterSet_JP;
@end

#define k_JP_0_Unichar	0xff10U
#define k_JP_9_Unichar	0xff19U

FOUNDATION_STATIC_INLINE BOOL CMRCharacterIsMemberOfNumeric(unichar c)
{
	return (('0' <= c && c <= '9') || (k_JP_0_Unichar <= c && c <= k_JP_9_Unichar));
}

FOUNDATION_STATIC_INLINE unichar CMRConvertToNumericCharacter(unichar c)
{
	return ((k_JP_0_Unichar <= c && c <= k_JP_9_Unichar) ? (c - (k_JP_0_Unichar - '0')) : c);
}
