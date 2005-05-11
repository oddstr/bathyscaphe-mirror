//: NSMutableString-SGExtensions.m
/**
  * $Id: NSMutableString-SGExtensions.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/NSMutableString-SGExtensions_p.h>
#import <ctype.h>



@implementation NSMutableString(SGExtensions)
- (void) _replaceCharacters : (id          ) searchObject
                   toString : (NSString   *) toString
                    options : (unsigned int) options
                      range : (NSRange     ) aRange
{
	NSRange		foundRange;
	NSRange		inRange = aRange;
	unsigned	replaceLength = [toString length];
	
	BOOL	fromSet = [searchObject isKindOfClass : [NSCharacterSet class]];
	BOOL	toDelete = (nil == toString || 0 == replaceLength);
	
	if (nil == searchObject)
		return;
	
	// 後方検索は必要ない
	if (options & NSBackwardsSearch) {
		options &= ~NSBackwardsSearch;
	}
	
	while (1) {
		foundRange = fromSet 
			? [self rangeOfCharacterFromSet:searchObject options:options range:inRange]
			: [self rangeOfString:searchObject options:options range:inRange];
		
		if (NSNotFound == foundRange.location || 0 == foundRange.length)
			break;
		
		if (toDelete)
			[self deleteCharactersInRange : foundRange];
		else
			[self replaceCharactersInRange:foundRange withString:toString];
		
		inRange.location = foundRange.location + replaceLength;
		inRange.length = ([self length] - inRange.location);
	}
}

- (void) replaceCharacters : (NSString        *) chars
                  toString : (NSString        *) replacement
{
	[self replaceCharacters : chars
				   toString : replacement
				    options : NSLiteralSearch];
}
- (void) replaceCharacters : (NSString        *) chars
                  toString : (NSString        *) replacement
                   options : (unsigned int     ) options
{
	[self replaceCharacters : chars
				   toString : replacement
				    options : options
				      range : NSMakeRange(0, [self length])];
}
- (void) replaceCharacters : (NSString   *) theString
                  toString : (NSString   *) replacement
                   options : (unsigned int) options
                     range : (NSRange     ) aRange
{
	[self _replaceCharacters : theString
			toString : replacement
			options : options
			range : aRange];
}



- (void)  deleteCharacters : (NSString   *) theString
{
	[self deleteCharacters:theString options:NSLiteralSearch];
}
- (void)  deleteCharacters : (NSString   *) theString
                   options : (unsigned int) options
{
	[self deleteCharacters : theString
				   options : options
				     range : NSMakeRange(0, [self length])];
}
- (void) deleteCharacters : (NSString   *) theString
                  options : (unsigned int) options
                    range : (NSRange     ) aRange
{
	[self _replaceCharacters : theString
			toString : nil
			options : options
			range : aRange];
}



- (void) replaceCharactersInSet : (NSCharacterSet  *) theSet
                       toString : (NSString        *) replacement
                        options : (unsigned int     ) options
                          range : (NSRange          ) aRange
{
	[self _replaceCharacters : theSet
			toString : replacement
			options : options
			range : aRange];
}
- (void) replaceCharactersInSet : (NSCharacterSet  *) theSet
                       toString : (NSString        *) replacement
                        options : (unsigned int     ) options
{
	[self replaceCharactersInSet : theSet
                       toString : replacement
                        options : options
                          range : NSMakeRange(0, [self length])];
}
- (void) replaceCharactersInSet : (NSCharacterSet  *) theSet
                       toString : (NSString        *) replacement
{
	[self replaceCharactersInSet : theSet
                       toString : replacement
                        options : NSLiteralSearch];
}


- (void)  deleteCharactersInSet : (NSCharacterSet  *) charSet
{
	[self deleteCharactersInSet : charSet
                        options : 0];
}
- (void)  deleteCharactersInSet : (NSCharacterSet  *) charSet
                        options : (unsigned int     ) options
{
	[self deleteCharactersInSet : charSet
                        options : options
                          range : NSMakeRange(0, [self length])];
}
- (void)  deleteCharactersInSet : (NSCharacterSet  *) theSet
                        options : (unsigned int     ) options
                          range : (NSRange          ) aRange
{
	[self _replaceCharacters : theSet
			toString : nil
			options : options
			range : aRange];
}




- (void) deleteAll
{
	[self deleteCharactersInRange : NSMakeRange(0, [self length])];
}

- (void) strip
{
	CFStringTrimWhitespace((CFMutableStringRef)self);
}
- (void) stripAtStart
{
	NSRange		wsRange_;
	int			index_, length_;
	
	wsRange_.location = 0;
	length_ = [self length];
	for (index_ = 0; index_ < length_; index_++) {
		if (NO == isspace([self characterAtIndex : index_]))
			break;
	}
	wsRange_.length = index_;
	[self deleteCharactersInRange : wsRange_];
}

- (void) stripAtEnd
{
	NSRange	wsRange_;
	int		index_, length_;
	
	for (index_ = ([self length] -1); index_ >= 0; index_--) {
		if (NO == isspace([self characterAtIndex : index_]))
			break;
	}
	length_ = [self length];
	wsRange_.location = (index_ +1);
	if (wsRange_.location == length_)
		return;
	
	wsRange_.length = length_ - wsRange_.location;
	[self deleteCharactersInRange : wsRange_];
}

// HTML
- (void) deleteAllTagElements
{
	static NSString *s_lt = @"<";
	static NSString *s_gt = @">";
	
	unsigned int length_;
	NSRange      result_;
	NSRange      searchRng_;

	if ((length_ = [self length]) < 2) return;
	searchRng_ = NSMakeRange(0, length_);
	
	while ((result_ = [self rangeOfString : s_lt
								 options : NSLiteralSearch
								   range : searchRng_]).length != 0) {
		NSRange      gtRng_;		//@"<"を検索
		
		//"<"の次から検索
		searchRng_.location = NSMaxRange(result_);
		searchRng_.length = (length_ - searchRng_.location);
		if ((gtRng_ = [self rangeOfString : s_gt
							     options : NSLiteralSearch
								   range : searchRng_]).length == 0) {
			continue;
		}
		
		result_.length = NSMaxRange(gtRng_) - result_.location;
		
		//見つかった範囲は削除される
		searchRng_.location = NSMaxRange(gtRng_);
		searchRng_.length = (length_ - searchRng_.location);
		[self deleteCharactersInRange : result_];
		searchRng_.location -= result_.length;
		length_ = [self length];
	}
}


// @return 置換したあとの長さの変化
- (int) resolveEntityWithEntityRange : (NSRange) entityRange
{
	NSString *entity;
	NSString *newStr;
	
	// エンティティ参照を解決
	entity = [self substringWithRange : entityRange];
	newStr = (NSString*)SGXMLStringForEntityReference((CFStringRef)entity);

	if (newStr != nil) {
		entityRange.location--;
		entityRange.length += 2;
		[self replaceCharactersInRange : entityRange 
							withString : newStr];
		return [newStr length] - entityRange.length;
	}
	return 0;
}

static inline NSRange SGUtilEntityRangeWithAmpSemicologne(unsigned amp, unsigned semicologne)
{
	NSRange   entityRng;
	
	NSCAssert(
		amp < semicologne,
		@"F: must be amp location < semicologne location");
	//エンティティ参照の範囲"&(---);"
	entityRng.location = amp +1;
	entityRng.length = semicologne - entityRng.location;
	
	return entityRng;
}
- (void) replaceEntityReference
{
	NSRange ampRng_, searchRng;
	
	searchRng = NSMakeRange(0, [self length]);
	while ((ampRng_ = [self rangeOfString : @"&" 
								 options : NSLiteralSearch
								   range : searchRng]).length != 0) {
		NSRange		semicologneRng_;

		{
			unsigned	location_;
			
			location_ = NSMaxRange(ampRng_);
			searchRng = NSMakeRange(location_, [self length] - location_);
		}
		
		if ((semicologneRng_ = [self rangeOfString : @";" 
										  options : NSLiteralSearch
											range : searchRng]).length != 0) {
			NSRange	entityRng_;
			
			entityRng_ = SGUtilEntityRangeWithAmpSemicologne(ampRng_.location, semicologneRng_.location);
			
			// 置換しなかった場合は"&"の次から検索するので、検索範囲は変わらない
			int		changeInLength_;
			
			changeInLength_ = [self resolveEntityWithEntityRange : entityRng_];
			if (changeInLength_ != 0) {
				searchRng.location = NSMaxRange(entityRng_) +1;
				searchRng.location += changeInLength_;
				searchRng.length = ([self length] - searchRng.location);
			}
		}
	}
}
@end
