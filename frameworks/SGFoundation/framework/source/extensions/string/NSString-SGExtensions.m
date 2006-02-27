//: NSString-SGExtensions.m
/**
  * $Id: NSString-SGExtensions.m,v 1.1.1.1.4.1 2006/02/27 17:31:50 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/NSString-SGExtensions.h>
#import <SGFoundation/String+Utils.h>
#import <SGFoundation/NSMutableString-SGExtensions.h>
#import <SGFoundation/NSCharacterSet-SGExtensions.h>
#import "UTILKit.h"



@implementation NSString(SGExtensions)
+ (id) stringWithData : (NSData         *) data
             encoding : (NSStringEncoding) encoding
{
	return [[[self alloc] initWithData : data 
	                          encoding : encoding] autorelease];
}


+ (id) stringWithCharacter : (unichar) aCharacter
{
	return [[[self alloc] initWithCharacter : aCharacter] autorelease];
}
- (id) initWithCharacter : (unichar) aCharacter
{
	return [self initWithCharacters : &aCharacter length : 1];
}

+ (id) stringWithCStringNoCopy : (char *  ) cString
 						length : (unsigned) length
				  freeWhenDone : (BOOL    ) freeBuffer
{
	return [[[self allocWithZone:[self zone]] initWithCStringNoCopy:cString length:length freeWhenDone:freeBuffer] autorelease];
}
+ (id) stringWithCStringNoCopy : (char *  ) cString
				  freeWhenDone : (BOOL    ) freeBuffer
{
	return (cString != NULL) ? [self stringWithCStringNoCopy:cString length:strlen(cString) freeWhenDone:freeBuffer] : nil;
}
// freeWhenDone == NO
+ (id) stringWithCStringNoCopy : (const char *) cString
{
	return [self stringWithCStringNoCopy:(char *)cString freeWhenDone:NO];
}

//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////

- (BOOL) isValidURLCharacters
{
	BOOL	contains_;
	
	if([self isEmpty]) return NO;
	
	contains_ = [self containsCharacterFromSet : 
					[NSCharacterSet URLInvertedCharacterSet]];

	return (NO == contains_);
}
- (NSString *) stringByDeletingURLScheme : (NSString *) aScheme
{
	NSScanner *scanner_;
	NSString  *context_;
	
	if([self isEmpty] || nil == aScheme || [aScheme isEmpty])
		return self;
	
	scanner_ = [NSScanner scannerWithString : self];
	[scanner_ setCaseSensitive : NO];
	if(NO == [scanner_ scanString : aScheme
					   intoString : NULL]){
		return nil;
	}
	//@":"とそれにつづく空白をスキップし、アドレスを読み込む
	if(NO == [scanner_ scanString : @":"
					   intoString : NULL]){
		return nil;
	}
	[scanner_ scanCharactersFromSet : [NSCharacterSet whitespaceCharacterSet]
						 intoString : NULL];
	context_ = [[scanner_ string] substringFromIndex : [scanner_ scanLocation]];
	
	return [context_ stringByStripedAtEnd];
}
//Check whether contains character
- (BOOL) containsString : (NSString *) aString
{
	return ([self rangeOfString : aString].length != 0);
}


- (BOOL) containsCharacterFromSet : (NSCharacterSet *) characterSet
{
	NSRange		range_;
	
	range_ = [self rangeOfCharacterFromSet : characterSet];
	return (range_.length != 0 && range_.location != NSNotFound);
}

//Data Using CFStringEncoding

- (NSData *) dataUsingCFEncoding : (CFStringEncoding) anEncoding;
{
	return [self dataUsingCFEncoding : anEncoding
			    allowLossyConversion : NO];
}


- (NSData *) dataUsingCFEncoding : (CFStringEncoding) anEncoding
            allowLossyConversion : (BOOL            ) lossy;
{
	return [(id)CFStringCreateExternalRepresentation(kCFAllocatorDefault,
													(CFStringRef)self, 
													anEncoding, 
													lossy?TRUE:FALSE) autorelease];
}

- (NSRange) rangeOfCharacterSequenceFromSet : (NSCharacterSet *) aSet
{
	return [self rangeOfCharacterSequenceFromSet:aSet options:0];
}
- (NSRange) rangeOfCharacterSequenceFromSet : (NSCharacterSet *) aSet
									options : (unsigned int    ) mask
{
	return [self rangeOfCharacterSequenceFromSet:aSet options:mask range:[self range]];
}
- (NSRange) rangeOfCharacterSequenceFromSet : (NSCharacterSet *) aSet
									options : (unsigned int    ) mask
									  range : (NSRange         ) aRange
{
	NSRange		result_;
	unsigned	maxRange_;
	BOOL		backward_;
	
	result_ = [self rangeOfCharacterFromSet:aSet options:mask range:aRange];
	if(NSNotFound == result_.location || 0 == result_.length)
		return result_;
	
	maxRange_ = NSMaxRange(aRange);
	backward_ = (mask & NSBackwardsSearch);
	
	while(1){
		unsigned	index_;
		
		index_ = backward_ ? result_.location : NSMaxRange(result_);
		if(backward_){
			if(0 == index_ || aRange.location == index_)
				break;
			index_--;
		}else{
			if(index_ >= maxRange_)
				break;
		}
		if(NO == [aSet characterIsMember : [self characterAtIndex : index_]])
			break;
		
		if(backward_)
			result_.location--;
		
		result_.length++;
	}
	return result_;
}
- (NSArray *) componentsSeparatedByCharacterSequenceFromSet : (NSCharacterSet *) aCharacterSet
{
	NSMutableArray		*components_;
	NSRange				result_;
	NSRange				searchRange_;
	unsigned			srcLength_;
	
	components_ = [NSMutableArray array];
	if(nil == aCharacterSet){
		[components_ addObject : self];
		return components_;
	}
	srcLength_ = [self length];
	searchRange_ = [self range];
	while((result_ = [self rangeOfCharacterSequenceFromSet : aCharacterSet
										   options : 0
											 range : searchRange_]).length != 0){
		NSRange		subrange_ = searchRange_;
		
		subrange_.length = result_.location - subrange_.location;
		
		[components_ addObject : [self substringWithRange : subrange_]];
		searchRange_.location = NSMaxRange(result_);
		searchRange_.length = (srcLength_ - searchRange_.location);
	}
	
	if(srcLength_ == searchRange_.length)
		[components_ addObject : self];
	else if(0 == searchRange_.length)
		[components_ addObject : @""];
	else
		[components_ addObject : [self substringWithRange : searchRange_]];
	
	return components_;
}
- (NSArray *) componentsSeparatedByCharacterSequenceInString : (NSString *) characters
{
	if(nil == characters)
		return [NSArray arrayWithObject:self];
	if([characters length] <= 1)
		return [self componentsSeparatedByString : characters];
	return [self componentsSeparatedByCharacterSequenceFromSet : 
				[NSCharacterSet characterSetWithCharactersInString : characters]];
}

- (NSArray *) componentsSeparatedByNewline
{
	NSMutableArray *lines;				// 行毎に詰めていく配列
	NSRange         lineRng;			// 行の範囲
	unsigned int    startIndex;			// 最初の文字のインデックス
	unsigned int    lineEndIndex;		// 次の行（段落）の最初の文字のインデックス
	unsigned int    contentsEndIndex;	// 最初の改行文字のインデックス
	unsigned int    len;				// 文字列の長さ
	
	
	lines = [NSMutableArray array];
	len = [self length];
	lineRng = NSMakeRange(0, 0);
	// 行毎に範囲を求め、切り出した文字列を
	// 配列に詰めていく。
	do{
		[self getLineStart : &startIndex
		               end : &lineEndIndex
		       contentsEnd : &contentsEndIndex
		          forRange : lineRng];
		
		lineRng.location = startIndex;
		lineRng.length = (contentsEndIndex - startIndex);
		
		// 文字列を行単位で切り出し、配列の末尾へ
		[lines addObject : [self substringWithRange : lineRng]];
		
		// 調べる範囲を次の行の先頭へ持っていく。
		lineRng.location = lineEndIndex;
		lineRng.length = 0;
	}while(lineRng.location < len);
	
	if(len > 0){
		unichar		c;
		
		c = [self characterAtIndex : len -1];
		if('\n' == c ||'\r' == c)
			[lines addObject : @""];
	}
	return lines;
}


- (NSString *) stringByReplaceEntityReference
{
	NSMutableString *mstr_;
	if(NO == [self containsString : @"&"]) return self;
	
	mstr_ = [self mutableCopyWithZone : [self zone]];
	[mstr_ replaceEntityReference];
	return [mstr_ autorelease];
}


- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement
{
	return [self stringByReplaceCharacters : chars
					              toString : replacement
						           options : NSLiteralSearch];
}


- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement
                                 options : (unsigned int     ) options
{
	return [self stringByReplaceCharacters : chars
					              toString : replacement
						           options : options
				                     range : NSMakeRange(0, [self length])];
}


- (NSString *) stringByReplaceCharacters : (NSString        *) chars
                                toString : (NSString        *) replacement
                                 options : (unsigned int     ) options
                                   range : (NSRange          ) aRange
{
	NSMutableString *mstr_;
	
	if(NO == [self containsString : chars]) return self;
	mstr_ = [self mutableCopyWithZone : [self zone]];
	[mstr_ replaceCharacters : chars
	                toString : replacement
					 options : options
					   range : aRange];
	return [mstr_ autorelease];
}


- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet
{
	return [self stringByDeleteCharactersInSet : charSet
                                       options : 0];
}


- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet
                                      options : (unsigned int     ) options
{
	return [self stringByDeleteCharactersInSet : charSet
                                       options : options
                                         range : NSMakeRange(0, [self length])];
}


- (NSString *)  stringByDeleteCharactersInSet : (NSCharacterSet  *) charSet
                                      options : (unsigned int     ) options
                                        range : (NSRange          ) aRange
{
	NSMutableString *mstr_;
	
	if(NO == [self containsCharacterFromSet : charSet]) return self;
	
	mstr_ = [self mutableCopyWithZone : [self zone]];
	[mstr_ deleteCharactersInSet : charSet
					     options : options
					       range : aRange];
	return [mstr_ autorelease];
}



- (NSString *) stringByStriped
{
	NSMutableString *mstr_;
	
	mstr_ = [self mutableCopyWithZone : [self zone]];
	[mstr_ strip];
	return [mstr_ autorelease];
}


- (NSString *) stringByStripedAtStart
{
	NSMutableString *mstr_;
	
	mstr_ = [self mutableCopyWithZone : [self zone]];
	[mstr_ stripAtStart];
	return [mstr_ autorelease];
}


- (NSString *) stringByStripedAtEnd
{
	NSMutableString *mstr_;
	
	mstr_ = [self mutableCopyWithZone : [self zone]];
	[mstr_ stripAtEnd];
	return [mstr_ autorelease];
}

- (BOOL) isSameAsString : (NSString *) other
{
	return (NSOrderedSame == [self compare : other]);
}
@end



@implementation NSString(WorkingWithPascalString)
+ (id) stringWithPascalString : (ConstStr255Param) pStr
{
	return [[[self alloc] initWithPascalString : pStr] autorelease];
}
- (id) initWithPascalString : (ConstStr255Param) pStr
{
	NSLog(@"method initWithPascalString: is deprecated in BathyScaphe 1.2 and later.");
	return nil;//[self initWithCString:&pStr[1] length:pStr[0]];
}
- (ConstStringPtr) pascalString
{
	// ほとんど成功しないみたいだ。
	return CFStringGetPascalStringPtr(
					(CFStringRef) self,
					NS2CFEncoding([[self class] defaultCStringEncoding]));
}
- (BOOL) getPascalString : (StringPtr) buffer
               maxLength : (unsigned ) maxLength
{
	return CFStringGetPascalString(
					(CFStringRef) self,
					buffer,
					maxLength,
					NS2CFEncoding([[self class] defaultCStringEncoding]));
}
@end


//////////////////////////////////////////////////////////////////////
////////////////////// [ NSString-->FSSpec ] /////////////////////////
//////////////////////////////////////////////////////////////////////
// 一応動く
/*
@interface NSString(String2FSSpec)
- (BOOL) getFSSpec : (FSSpec *) fsSpecPtr;
@end



@implementation NSString(String2FSSpec)
- (BOOL) getFSSpec : (FSSpec *) fsSpecPtr
{
	NSString	*filepath_;
	FSRef		parentRef_;
	FSSpec		dirSpec_;
	Boolean		isDirectory_;
	OSStatus	err;
	
	filepath_ = [self stringByDeletingLastPathComponent];
	err = FSPathMakeRef(
			[filepath_ fileSystemRepresentation],
			&parentRef_,
			&isDirectory_);
	require_noerr(err, ErrGetFSSpec);
	if(NO == isDirectory_) goto ErrGetFSSpec;
	
	err = FSGetCatalogInfo(
			&parentRef_,
			(kFSCatInfoNodeID | kFSCatInfoVolume),
			NULL,
			NULL,
			&dirSpec_,
			NULL);
	require_noerr(err, ErrGetFSSpec);
	
	FSSpec		fileSpec_;
	Str255		nmBuffer_;
	size_t		bufLength_;
	Boolean		result_;
	
	bufLength_ = (sizeof(nmBuffer_) / nmBuffer_[0]);
	filepath_ = [self lastPathComponent];
	result_ = [filepath_ getFileSystemRepresentation : nmBuffer_  +1
										   maxLength : bufLength_ -1];
	if(NO == result_) goto ErrGetFSSpec;

	nmBuffer_[0] = strlen(nmBuffer_ +1);
	err = FSMakeFSSpec(
			dirSpec_.vRefNum, 
			dirSpec_.parID, 
			nmBuffer_, 
			&fileSpec_);
	if(err != noErr && err != fnfErr) goto ErrGetFSSpec;
	
	if(fsSpecPtr != NULL)
		*fsSpecPtr = fileSpec_;
	
	return YES;
	
ErrGetFSSpec:
	return NO;
}
@end
*/
