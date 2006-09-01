//: NSCharacterSet-SGExtentions.m
/**
  * $Id: NSCharacterSet-SGExtensions.m,v 1.1.1.1.4.2 2006/09/01 13:46:58 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSCharacterSet-SGExtensions.h"
#import "PrivateDefines.h"


// Custom Character Set
@interface SGURLCharacterSet : NSCharacterSet
@end
@interface SGInvertedURLCharacterSet : NSCharacterSet
@end
@interface SGURLToBeNotEscapedCharacterSet : NSCharacterSet
@end
@interface SGURLToBeEscapedCharacterSet : NSCharacterSet
@end



@implementation NSCharacterSet(SGExtentions)
+ (NSCharacterSet *) alphanumericPunctuationCharacterSet
{
	NSRange		lcEnglishRange;
	
	lcEnglishRange.location = (unsigned int)' ';
	lcEnglishRange.length = ((unsigned int)'~') - lcEnglishRange.location;
	
	return [NSCharacterSet characterSetWithRange:lcEnglishRange];
}
+ (NSCharacterSet *) URLCharacterSet
{
	static NSCharacterSet *charSet = nil;
	if(nil == charSet)
		charSet = [[SGURLCharacterSet alloc] init];
	
	return charSet;
}

+ (NSCharacterSet *) URLInvertedCharacterSet
{
	static NSCharacterSet *cset_ = nil;
	
	if(nil == cset_){
		NSCharacterSet	*tmp_;
		
		tmp_ = [[self URLCharacterSet] invertedSet];
		NSAssert(tmp_ != nil, @"NSCharacterSet#URLCharacterSet return nil.");
		cset_ = [tmp_ copy];
	}
	return cset_;
}
+ (NSCharacterSet *) URLToBeEscapedCharacterSet
{
	static NSCharacterSet *charSet = nil;

	if(nil == charSet)
		charSet = [[SGURLToBeEscapedCharacterSet alloc] init];
	
	return charSet;
}
+ (NSCharacterSet *) URLToBeNotEscapedCharacterSet
{
	static NSCharacterSet *charSet = nil;

	if(nil == charSet)
		charSet = [[SGURLToBeNotEscapedCharacterSet alloc] init];
	
	return charSet;
}
+ (NSCharacterSet *) extraspaceAndNewlineCharacterSet
{
	static NSCharacterSet *st_finalCharSet = nil;
	
	if(nil == st_finalCharSet){
		NSMutableCharacterSet	*workingSet;
		
		workingSet = 
			[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
		[workingSet addCharactersInRange : NSMakeRange(0x3000, 1)];
		st_finalCharSet = [workingSet copy];
		[workingSet release];
	}
	return st_finalCharSet;
}

@end



#define ACCEPTABLE_ASCII_BASE		32
#define ACCEPTABLE_ASCII_LENGTH		96

/* URL Strings */
static const BOOL	isURLCharactersASCII[ACCEPTABLE_ASCII_LENGTH] =
  // 0 1 2 3 4 5 6 7 8 9 A B C D E F           0123456789ABCDEF
//	{0,0,0,1,0,1,1,0,0,0,1,1,1,1,1,1,	// 2x   !"#$%&'()*+,-./
	{0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,	// 2x   !"#$%&'()*+,-./
	 1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,	// 3x  0123456789:;<=>?
	 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,	// 4x  @ABCDEFGHIJKLMNO
//	 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,	// 5X  PQRSTUVWXYZ[\]^_
	 1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,	// 5X  PQRSTUVWXYZ[\]^_
	 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,	// 6x  `abcdefghijklmno
	 1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,0 };	// 7X  pqrstuvwxyz{|}~	DEL

static const BOOL	toBeNotEscapedASCII[ACCEPTABLE_ASCII_LENGTH] =
  // 0 1 2 3 4 5 6 7 8 9 A B C D E F           0123456789ABCDEF
	{0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,0,	// 2x   !"#$%&'()*+,-./
	 1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,	// 3x  0123456789:;<=>?
	 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,	// 4x  @ABCDEFGHIJKLMNO
	 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,	// 5X  PQRSTUVWXYZ[\]^_
	 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,	// 6x  `abcdefghijklmno
	 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0 };	// 7X  pqrstuvwxyz{|}~	DEL

static inline unsigned char unichar2AcceptableASCII(unichar aCharacter)
{
	if(aCharacter < ACCEPTABLE_ASCII_BASE)
		return 0;
	if(aCharacter >= ACCEPTABLE_ASCII_BASE + ACCEPTABLE_ASCII_LENGTH)
		return 0;
	
	return (unsigned char)(aCharacter - ACCEPTABLE_ASCII_BASE);
}



@implementation SGURLCharacterSet
- (BOOL) characterIsMember : (unichar) c
{
	return (isURLCharactersASCII[unichar2AcceptableASCII(c)]);
}
- (NSCharacterSet *) invertedSet
{
	return [[[SGInvertedURLCharacterSet alloc] init] autorelease];
}
- (id) copyWithZone : (NSZone *) aZone
{
	return [self retain];
}
@end



@implementation SGInvertedURLCharacterSet
- (BOOL) characterIsMember : (unichar) c
{
	return (!isURLCharactersASCII[unichar2AcceptableASCII(c)]);
}
- (NSCharacterSet *) invertedSet
{
	return [[[SGURLCharacterSet alloc] init] autorelease];
}
- (id) copyWithZone : (NSZone *) aZone
{
	return [self retain];
}
@end



@implementation SGURLToBeNotEscapedCharacterSet
- (BOOL) characterIsMember : (unichar) c
{
	return (toBeNotEscapedASCII[unichar2AcceptableASCII(c)]);
}
- (NSCharacterSet *) invertedSet
{
	return [[[SGURLToBeEscapedCharacterSet alloc] init] autorelease];
}
- (id) copyWithZone : (NSZone *) aZone
{
	return [self retain];
}
@end



@implementation SGURLToBeEscapedCharacterSet
- (BOOL) characterIsMember : (unichar) c
{
	return (!toBeNotEscapedASCII[unichar2AcceptableASCII(c)]);
}
- (NSCharacterSet *) invertedSet
{
	return [[[SGURLToBeNotEscapedCharacterSet alloc] init] autorelease];
}
- (id) copyWithZone : (NSZone *) aZone
{
	return [self retain];
}
@end
