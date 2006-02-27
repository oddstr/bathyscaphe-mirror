//: NSCharacterSet+CMXAdditions.m
/**
  * $Id: NSCharacterSet+CMXAdditions.m,v 1.1.1.1.4.1 2006/02/27 17:31:49 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSCharacterSet+CMXAdditions.h"
#import "UtilKit.h"
#import <SGFoundation/NSBundle-SGExtensions.h>

@interface CMRNumberCharacterSet_JP : NSCharacterSet
@end
@implementation CMRNumberCharacterSet_JP : NSCharacterSet
- (BOOL) characterIsMember : (unichar) c
{
	return CMRCharacterIsMemberOfNumeric(c);
}
- (NSData *) bitmapRepresentation
{
	UTILMethodLog;
	return [super bitmapRepresentation];
}
@end



#define kInnerLinkPrefixCharactersFile		@"innerLinkPrefixCharacters.txt"
#define kInnerLinkRangeCharactersFile		@"innerLinkRangeCharacters.txt"
#define kInnerLinkSeparaterCharactersFile	@"innerLinkSeparaterCharacters.txt"
static NSCharacterSet *characterSetFromBundleWithFilename(NSString *filename);



#define PRIV_UTIL_CHARACTER_SET(aFilename)							\
	static	NSCharacterSet	*shared_;								\
	if(nil == shared_)												\
		shared_ = characterSetFromBundleWithFilename(aFilename);	\
	return shared_


@implementation NSCharacterSet(CMRCharacterSetAddition)
+ (NSCharacterSet *) innerLinkPrefixCharacterSet
{
	PRIV_UTIL_CHARACTER_SET(kInnerLinkPrefixCharactersFile);
}
+ (NSCharacterSet *) innerLinkRangeCharacterSet
{
	PRIV_UTIL_CHARACTER_SET(kInnerLinkRangeCharactersFile);
}
+ (NSCharacterSet *) innerLinkSeparaterCharacterSet
{
	PRIV_UTIL_CHARACTER_SET(kInnerLinkSeparaterCharactersFile);
}
+ (NSCharacterSet *) numberCharacterSet_JP
{
	static NSCharacterSet *instance_;
	
	if(nil == instance_)
		instance_ = [[CMRNumberCharacterSet_JP alloc] init];
	
	return instance_;
}
@end
#undef PRIV_UTIL_CHARACTER_SET



static NSCharacterSet *characterSetFromBundleWithFilename(NSString *filename)
{
	NSString	*filepath_;
	NSString	*string_;
	
	//filepath_ = [[NSBundle mainBundle] pathForResourceWithName : filename];
	filepath_ = [[NSBundle bundleForClass : [CMRFileManager class]] pathForResourceWithName : filename];
	if(nil == filepath_) return nil;
	string_ = [NSString stringWithContentsOfFile : filepath_];
	if(nil == string_) return nil;

	return [[NSCharacterSet characterSetWithCharactersInString:string_] copyWithZone : nil];
}
