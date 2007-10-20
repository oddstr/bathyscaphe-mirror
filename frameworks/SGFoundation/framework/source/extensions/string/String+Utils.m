//: String+Utils.m
/**
  * $Id: String+Utils.m,v 1.2 2007/10/20 02:21:29 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/String+Utils.h>
#import <SGFoundation/NSString-SGExtensions.h>
#import <SGFoundation/NSCharacterSet-SGExtensions.h>
//#import <SGFoundation/SGBase64.h>
#import <SGFoundation/SGURLEscape.h>
#import "UTILKit.h"



@implementation NSObject(SGStringUtils)
- (NSString *) stringValue
{
	return [self description];
}
@end



@implementation NSString(SGStringUtils)
+ (NSString *) yenmark
{
	static NSString *yen;
	
	if(nil == yen)
		yen = [[NSString alloc] initWithCharacter:0xa5];

	return yen;
}
+ (NSString *) backslash
{
	return @"\\";
}


- (BOOL) isEmpty
{
	return (0 == [self length]);
}
- (NSRange) range
{
	return NSMakeRange(0, [self length]);
}

- (BOOL) boolValue
{
	if([self intValue] > 0) return YES;
	return ((NSOrderedSame == [self caseInsensitiveCompare : @"yes"]) || (NSOrderedSame == [self caseInsensitiveCompare : @"true"]));
}
- (NSString *) stringValue
{
	return self;
}
- (unsigned) hexIntValue
{
	unsigned	value_;
	
	if(NO == [[NSScanner scannerWithString:self] scanHexInt:&value_])
		return 0;
	return value_;
}
- (unsigned) unsignedIntValue
{
	int		tmp;
	
	tmp = [self intValue];
	if(tmp < 0) return 0;
	
	return (unsigned int)tmp;
}
@end



@implementation NSAttributedString(SGStringUtils)
- (BOOL) isEmpty
{
	return (0 == [self length]);
}
- (NSRange) range
{
	return NSMakeRange(0, [self length]);
}
- (NSString *) stringValue
{
	return [self string];
}
@end



@implementation NSData(SGNetEncoding)
/*- (NSString *) stringByUsingBase64Encoding
{
	int		ret;
	char	*s;
	
	ret = SGBase64Encode([self bytes], [self length], &s);
	if(-1 == ret)
		return nil;
	
	return [[[NSString alloc] 
				initWithCStringNoCopy : s
				length : ret
				freeWhenDone : YES] autorelease];
}*/
// URL Encoding
- (NSString *) stringByUsingURLEncoding
{
	char	*s;
	
	s = SGURLEscape((const char *)[self bytes], [self length]);
	if(NULL == s)
		return nil;
	
/*	return [[[NSString alloc] 
				initWithCStringNoCopy : s
				length : strlen(s)
				freeWhenDone : YES] autorelease];*/
	return [[[NSString alloc] initWithBytesNoCopy:s length:strlen(s) encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}
@end



@implementation NSString(SGNetEncoding)
/*- (NSData *) dataUsingBase64Decoding
{
	int			len;
	const char	*s;
	char		*buf  = NULL;
	id			data_ = nil;
	
	s = [self UTF8String];
	buf = malloc(strlen(s));
	len = SGBase64Decode(s, buf);
	if(len < 0) return nil;
	
	data_ = [NSData dataWithBytesNoCopy : buf
								 length : len
						   freeWhenDone : YES];
	
	return data_;
}


- (NSString *) stringByEncodingBase64UsingEncoding : (NSStringEncoding) encoding
{
	return [[self dataUsingEncoding:encoding] stringByUsingBase64Encoding];
}
- (NSString *) stringByDecodingBase64UsingEncoding : (NSStringEncoding) encoding;
{
	return [NSString stringWithData:[self dataUsingBase64Decoding] encoding:encoding];
}*/
// URL Encoding
/*- (NSData *) dataUsingURLDecoding
{
	const char	*s;
	char		*buf  = NULL;
	id			data_ = nil;
	
	s = [self UTF8String];
	buf = SGURLUnescape(s, strlen(s));
	if(NULL == buf)
		return nil;
	
	data_ = [NSData dataWithBytesNoCopy : buf
								 length : strlen(buf)
						   freeWhenDone : YES];
	
	return data_;
}*/
- (NSString *) stringByURLEncodingUsingEncoding : (NSStringEncoding) encoding
{
//	NSCharacterSet		*cset_;
	
    if([self isEmpty])
		return self;
/*	
	cset_ = [NSCharacterSet URLToBeEscapedCharacterSet];
	if(NO == [self containsCharacterFromSet : cset_])
		return self;*/
	
	return [[self dataUsingEncoding:encoding] stringByUsingURLEncoding];
}
/*- (NSString *) stringByURLDecodingUsingEncoding : (NSStringEncoding) encoding
{
	if([self isEmpty]) return @"";
	
	return [NSString stringWithData : [self dataUsingURLDecoding]
						   encoding : encoding];
}*/
@end



@implementation NSDictionary(SGNetEncoding)
- (NSString *) queryUsingEncoding : (NSStringEncoding) encoding
{
	NSEnumerator		*keyIter_;
	NSMutableString		*recordQuery_;
	id					key_;
	
	recordQuery_ = [NSMutableString string];
	keyIter_ = [self keyEnumerator];
	while(key_ = [keyIter_ nextObject]){
		id			value_;
		
		[recordQuery_ appendString:[key_ description]];
		
		value_ = [self objectForKey : key_];
		if(value_ != nil){
			NSString	*escaped_;
			
			value_ = ([value_ respondsToSelector : @selector(stringValue)])
						? [value_ stringValue]
						: [value_ description];
			
			escaped_ = [value_ stringByURLEncodingUsingEncoding : encoding];
			if(nil == escaped_) return nil;
			
			[recordQuery_ appendFormat : @"=%@", escaped_];
		}
		[recordQuery_ appendString:@"&"];
	}
	
	if(keyIter_ != nil){
		[recordQuery_ deleteCharactersInRange : 
						NSMakeRange([recordQuery_ length] -1, 1)];
	}
	return recordQuery_;
}
@end
