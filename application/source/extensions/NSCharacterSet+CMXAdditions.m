//
//  NSCharacterSet+CMXAdditions.m
//  BathyScaphe (CocoMonar Framework)
//
//  Updated by Tsutomu Sawada on 07/10/18.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "NSCharacterSet+CMXAdditions.h"

@class CMRFileManager;

#define kInnerLinkPrefixCharactersFile		@"innerLinkPrefixCharacters"
#define kInnerLinkRangeCharactersFile		@"innerLinkRangeCharacters"
#define kInnerLinkSeparaterCharactersFile	@"innerLinkSeparaterCharacters"

static NSCharacterSet *characterSetFromBundleWithFilename(NSString *filename);
static NSCharacterSet *characterSetFromNumbersJP(void);

#define PRIV_UTIL_CHARACTER_SET(aFilename)						\
	static	NSCharacterSet	*shared_;							\
	if(!shared_)												\
		shared_ = characterSetFromBundleWithFilename(aFilename);\
	return shared_


@implementation NSCharacterSet(CMRCharacterSetAddition)
+ (NSCharacterSet *)innerLinkPrefixCharacterSet
{
	PRIV_UTIL_CHARACTER_SET(kInnerLinkPrefixCharactersFile);
}

+ (NSCharacterSet *)innerLinkRangeCharacterSet
{
	PRIV_UTIL_CHARACTER_SET(kInnerLinkRangeCharactersFile);
}

+ (NSCharacterSet *)innerLinkSeparaterCharacterSet
{
	PRIV_UTIL_CHARACTER_SET(kInnerLinkSeparaterCharactersFile);
}

+ (NSCharacterSet *)numberCharacterSet_JP
{
	static NSCharacterSet *instance_;
	
	if(!instance_) {
		instance_ = characterSetFromNumbersJP();
	}
	return instance_;
}
@end
#undef PRIV_UTIL_CHARACTER_SET


static NSCharacterSet *characterSetFromBundleWithFilename(NSString *filename)
{
	NSString	*filepath_;
	NSString	*string_;
	
	filepath_ = [[NSBundle bundleForClass:[CMRFileManager class]] pathForResource:filename ofType:@"txt"];
	if (!filepath_) return nil;
	string_ = [NSString stringWithContentsOfFile:filepath_];
	if (!string_) return nil;

	return [[NSCharacterSet characterSetWithCharactersInString:string_] copyWithZone:nil];
}

static NSCharacterSet *characterSetFromNumbersJP(void)
{
	unsigned short numbuf[20];
	int i;
	for (i = 0; i < 10; i++) {
		numbuf[     i] = (unsigned short)i + '0';
		numbuf[10 + i] = (unsigned short)i + (unsigned short)k_JP_0_Unichar;
	}

	NSString *numString = [NSString stringWithCharacters:numbuf length:20];
	if (!numString) return nil;
	
	return [[NSCharacterSet characterSetWithCharactersInString:numString] copyWithZone:nil];
}
