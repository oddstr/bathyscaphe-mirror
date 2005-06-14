//: CMXTextParser.m
/**
  * $Id: CMXTextParser.m,v 1.2 2005/06/14 18:37:36 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMXTextParser.h"
#import "CocoMonar_Prefix.h"
#import "CMRThreadMessage.h"
#import "CMXTemplateResources.h"

// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"

/*!
@defined     DATE2CH_CALENDAR_FORMAT
@discussion  2channel Data Format
 */
#define DATE2CH_CALENDAR_FORMAT		@"%y/%m/%d %H:%M"
#define DATE2CH_CALENDAR_FORMAT_2		@"%y/%m/%d %H:%M:%S"

/*!
@defined     THREAD_HEADER_TITLE_INDEX
@discussion  the index of thread's title
 */
#define THREAD_HEADER_TITLE_INDEX	4


static NSString *const CMXTextParserDate2chSeparater		= @"(";

#if PATCH
static NSString *const CMXTextParserDate2chSeparater_close = @")";
static char c_CMXTextParserDate2chSeparater_close = ')';
#endif

static NSString *const CMXTextParserDate2chSample			= @"01/02/05 22:26";
static NSString *const CMXTextParserComma					= @",";

#define kAvailableURLCFEncodingsNSArrayKey		@"System - AvailableURLCFEncodings"

#pragma mark -

// teri�n�ȊO��'@�M'��','�ɕϊ�
static NSString *fnc_stringWillConvertToComma(void)
{
	static NSString *st_cnv;
	
	if (nil == st_cnv) {
		unichar c[] = {'@', 0xff40};	// '@�M'
		st_cnv = [[NSString alloc] initWithCharacters : c 
							length : UTILNumberOfCArray(c)];
	}
	return st_cnv;
}
static void separetedLineByConvertingComma(NSString *theString, NSMutableArray *fields)
{
	NSArray			*separated_;
	NSEnumerator	*iter_;
	NSString		*string_;
	NSString		*replace_;
	
	UTILCAssertNotNil(theString);
	UTILCAssertNotNil(fields);
	
	replace_ = fnc_stringWillConvertToComma();
	separated_ = [theString componentsSeparatedByString : CMXTextParserComma];
	if ([separated_ count] < 2) return;
	
	iter_ = [separated_ objectEnumerator];
	
	while (string_ = [iter_ nextObject]) {
		
		if ([string_ containsString : replace_]) {
			string_ = [string_ stringByReplaceCharacters : replace_
												toString : CMXTextParserComma];
		}
		[fields addObject : string_];
	}
}

#pragma mark -

@implementation CMXTextParser
+ (NSArray *) separatedLine : (NSString *) theString
{
	NSMutableArray	*components_;
	NSRange			searchRange_;
	NSRange			field_;
	unsigned		length_;
	
	components_ = SGTemporaryArray();
	
	length_ = [theString length];
	searchRange_ = NSMakeRange(0, length_);
	field_ = NSMakeRange(0, 0);
	
	while (1) {
		NSRange			found_;
		
		found_ = [theString rangeOfString : @"<>"
								  options : NSLiteralSearch
								    range : searchRange_];
		
		if (NSNotFound == found_.location || 0 == found_.length) {
			if (0 == [components_ count]) {
				//
				// "<>"�ȊO�̋�؂蕶��
				//
				separetedLineByConvertingComma(theString, components_);
				if (0 == [components_ count])
					return nil;
				
				return components_;
			}
			break;
		}
		
		field_.length = found_.location - field_.location;
		
		if (0 == field_.length)
			[components_ addObject : @""];
		else
			[components_ addObject : [theString substringWithRange : field_]];
		
		searchRange_.location = NSMaxRange(found_);
		searchRange_.length = length_ - searchRange_.location;
		
		field_.location = searchRange_.location;
	}
	
	//
	// �����B�����Ȃ���΋󕶎�
	//
	[components_ addObject : 
		[theString substringFromIndex : searchRange_.location]];
	
	return [[components_ copy] autorelease];
}


+ (id) dateWith2chDateString : (NSString *) theString
{
	id					date_ = nil;
	NSMutableString		*dateString_ = nil;
	NSRange				found_;
	
	int sec = 0;
	BOOL flagSec = NO;
	//
	// �u�����v
	// 
	// 02/02/05 22:26
	// 2001/08/06(��) 21:45 
	// 
	UTILRequireCondition(theString && [theString length], return_date);

#if DEBUG_LOG
	NSLog(@"dateWith2chDateString: %@", theString);
#endif
	
	// 
	// �O��̋󔒂��������A2001/08/06(��) 21:45�`����
	// 01/08/06 21:45�ɕϊ�����B
	// 
	dateString_ = SGTemporaryString();
	[dateString_ setString : theString];
	[dateString_ strip];
	
	found_ = [dateString_ rangeOfString : CMXTextParserDate2chSeparater];
	if (found_.length != 0) {
		// 2001/08/06(��) 21:45�`�� --> 2001/08/06 21:45
		NSRange		weekday_;		// �j����

#if PATCH
		NSRange  weekday_close_;
		int week_len = 0;
#endif

		weekday_.location = found_.location;
		weekday_.length = 3;
#if PATCH
		week_len = NSMaxRange(weekday_);
		if ([dateString_ length] >= week_len && [dateString_ characterAtIndex: week_len-1] != c_CMXTextParserDate2chSeparater_close) {
			weekday_.length = [dateString_ length] - weekday_.location;
			weekday_close_ = [dateString_ rangeOfString: CMXTextParserDate2chSeparater_close options: NSLiteralSearch range: weekday_];
			if (weekday_close_.location != NSNotFound)
				weekday_.length = NSMaxRange(weekday_close_) - weekday_.location;
			else
				weekday_.length = 3;
		}
#endif
		if (NSMaxRange(weekday_) > [dateString_ length])
			goto return_date;
			[dateString_ deleteCharactersInRange : weekday_];
	}


	// 2001/08/06 21:45:00�`�� --> 2001/08/06 21:45 (sec�ێ�)
	{
		int t_dateString_len = [dateString_ length];

		if (t_dateString_len >= 8 && ([dateString_ characterAtIndex: t_dateString_len - 3] == ':' && [dateString_ characterAtIndex: t_dateString_len - 6] == ':')) {
			int c10, c1;

			c10 = [dateString_ characterAtIndex: t_dateString_len - 2];
			c1 = [dateString_ characterAtIndex: t_dateString_len - 1];

			sec = (c10 - '0') * 10;
			sec += c1 - '0';
			if (sec < 0 || 60 <= sec)
				sec = 0; // fault
			else flagSec = YES;
				
#if DEBUG_LOG
			NSLog (@"sec: %d", sec);
#endif
			[dateString_ deleteCharactersInRange : NSMakeRange(t_dateString_len - 3, 3)];
		}
	}
	
	if ([dateString_ length] > [CMXTextParserDate2chSample length]) {
		// 
		// 2001/08/06 21:45 --> 01/08/06 21:45
		// 
		[dateString_ deleteCharactersInRange : NSMakeRange(0, 2)];
	}
	
	if (flagSec) {
		NSString * t_dateString;
		
		t_dateString = [NSString stringWithFormat: @"%@:%02d", dateString_, sec];
		date_ = [NSCalendarDate dateWithString : t_dateString
								calendarFormat : DATE2CH_CALENDAR_FORMAT_2];
	} else {
		date_ = [NSCalendarDate dateWithString : dateString_
								calendarFormat : DATE2CH_CALENDAR_FORMAT];
	}

#if DEBUG_LOG
	NSLog(@"dateWith2chDateString: ret: %@ (src: %@)", date_, dateString_);
#endif

return_date:
	if (!date_)
		date_ = theString; // ���ꗬ��
	
	return date_;
}

/*
���X�̖{���̂����ϊ��ł�����͕̂ϊ����Ă��܂��B
�s�v��HTML�^�O����菜���A���s�^�O��ϊ�
*/
+ (NSString *) cachedMessageWithMessageSource : (NSString *) aSource
{
	NSMutableString		*tmp;
	NSString			*result;
	
	tmp = [aSource mutableCopy];
	[self convertMessageSourceToCachedMessage : tmp];
	
	result = [[tmp copy] autorelease];
	[tmp release];
	
	return result;
}



/*
2004-02-29 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
----------------------------------------
���N�����+ �̖���������u<���M�́L>�i�L�E�ցE�M�j�i�M�n�L�@ �j����v
�� CocoMonar �ŏ�肭�\������Ȃ��B

�ǂ��� '<', '>' �����̎Q�ƂŒu��������ꂸ�ɂ��̂܂� dat �ɋL�^����Ă���̂�
���炵���B����������̏ꍇ�ɂ��̃`�F�b�N�������Ă���B

����ɔ����āA�^�O���� ASCII �Ɍ��肵�Ă����B

*/
#define ELEM_NAME_BUFSIZE 31
static void htmlConvertDeleteAllTagElements(NSMutableString *theString)
{
	unsigned int	strLen_;
	NSRange			result_;
	NSRange			searchRange_;
	BOOL			shouldDelete = YES;
	
	if ((strLen_ = [theString length]) < 2) 
		return;
	
	searchRange_ = NSMakeRange(0, strLen_);
	
	while ((result_ = [theString rangeOfString : @"<"
								 options : NSLiteralSearch
								   range : searchRange_]).length != 0) {
		NSRange		gtRange_;		// ">"
		
		// "<"�̎����猟��
		searchRange_.location = NSMaxRange(result_);
		searchRange_.length = (strLen_ - searchRange_.location);
		if ((gtRange_ = [theString rangeOfString : @">"
							     options : NSLiteralSearch
								   range : searchRange_]).length == 0) {
			continue;
		}
		
		result_.length = NSMaxRange(gtRange_) - result_.location;

		searchRange_.location = NSMaxRange(gtRange_);
		searchRange_.length = (strLen_ - searchRange_.location);
		
		// �폜���Ȃ��v�f
		{
			unsigned	i, max;
			unichar		c = '\0';
			char		tagName[ELEM_NAME_BUFSIZE +1];
			int			bufidx = 0;
			
			i = result_.location +1;
			max = NSMaxRange(result_);
			NSCAssert(result_.length >= 2, @"result_.length >= 2");
			
			// skip first blank spaces and '/'
			for (; i < max; i++) {
				c = [theString characterAtIndex : i];
				if (!isspace(c & 0x7f) && c != '/') break;
			}
			if (i >= max) {
				shouldDelete = YES;
				goto FASE_DELETE;
			}
			
			// now c points first character of element's tagName
			for (; i < max; i++) {
				c = [theString characterAtIndex : i];
				
				if (isspace(c & 0x7f) || '/' == c || '>' == c) { 
					break;
				}
				// tag name must be ASCII characters
				// or must be less than ELEM_NAME_BUFSIZE
				if (c > 0x7f || bufidx >= ELEM_NAME_BUFSIZE) {
					shouldDelete = NO;
					break;
				}
				tagName[bufidx++] = (c & 0x7f);
				
			}
			tagName[bufidx++] = '\0';
			// now tagName buffer contains elements tagName
			
			// <ul> 
			if (0 == nsr_strcasecmp(tagName, "ul"))
				shouldDelete = NO;
		}
FASE_DELETE:
		if (NO == shouldDelete) continue;
		
		
		// �폜
		{
			[theString deleteCharactersInRange : result_];
			searchRange_.location -= result_.length;
			strLen_ = [theString length];
		}
	}
}
+ (void) convertMessageSourceToCachedMessage : (NSMutableString *) aSource
{
	htmlConvertBreakLineTag(aSource);
	[aSource replaceCharacters:[NSString backslash] toString:[NSString yenmark]];
	htmlConvertDeleteAllTagElements(aSource);
	[self replaceEntityReferenceWithString : aSource];
}

+ (NSArray *) messageArrayWithDATContents : (NSString  *) DATContens
								baseIndex : (unsigned   ) baseIndex
								    title : (NSString **) tilePtr
{
	NSMutableArray		*messageArray_;
	id					contents_;
	NSArray				*lineArray_;
	NSEnumerator		*iter_;
	NSString			*line_;
	unsigned			index_ = baseIndex;
	
	// Extra Data
	NSString			*title_     = nil;
	
	
	UTILRequireCondition(
		DATContens != nil && NO == [DATContens isEmpty],
		ErrConvert);
	if (tilePtr != NULL) *tilePtr = nil;
	
	// �O��̋󔒂���菜���A�s�ŕ���
	messageArray_ = [NSMutableArray array];
	contents_ = SGTemporaryString();
	[contents_ appendString : DATContens];
	
	[contents_ strip];
	lineArray_ = [contents_ componentsSeparatedByNewline];
	contents_ = nil;
	
	iter_ = [lineArray_ objectEnumerator];
	while (line_ = [iter_ nextObject]) {
		CMRThreadMessage	*message_;
		NSArray				*components_;
		
		components_ = [self separatedLine : line_];
		message_ = [self messageWithDATLineComponentsSeparatedByNewline : components_];
		
		if (nil == message_) {
			// ��͂Ɏ��s
			if (line_ != nil && NO == [line_ isEmpty]) {
				UTILDebugWrite1(
					@"ERROR:parseDATFieldWithLine(Index = %d)",
					index_);
			}
			continue;
		}
		[message_ setIndex : index_];
		[messageArray_ addObject : message_];
		index_++;
		
		// �^�C�g����T��
		if ([components_ count] > k2chDATTitleIndex && nil == title_ && tilePtr != NULL) {
			title_ = [components_ objectAtIndex : k2chDATTitleIndex];
			title_ = [title_ stringByReplaceEntityReference];
			*tilePtr = title_;
		}
	}
	
	return messageArray_;
	
ErrConvert:
	return nil;
}

+ (CMRThreadMessage *) messageWithDATLine : (NSString *) theString
{
	NSArray				*components_;
	
	components_ = [self separatedLine : theString];
	return [self messageWithDATLineComponentsSeparatedByNewline : components_];
}
+ (CMRThreadMessage *) messageWithInvalidDATLineDetected : (NSString *) line
{
	NSArray				*components_;
	NSString			*contents_;
	CMRThreadMessage	*message_ = nil;
	
	components_ = [self separatedLine : line];
	contents_ = [components_ componentsJoinedByString : @"\n"];
	contents_ = [contents_ stringByStriped];
	if (nil == contents_ || [contents_ isEmpty])
		return nil;
	
	message_ = [[[CMRThreadMessage alloc] init] autorelease];
	[message_ setName : @""];
	[message_ setMail : @""];
	[message_ setIDString : @""];
	[message_ setMessageSource : contents_];
	[message_ setInvalid : YES];
	
	return message_;
}
// Entity Reference
// "&amp" --> "&amp;"
#define kInvalidAmpEntity	@"&amp"
#define kAmpEntity			@"&amp;"
#define kAmpEntityLength	4
static void resolveInvalidAmpEntity(NSMutableString *aSource)
{
	NSMutableString	*src_ = aSource;
	unsigned		srcLength_;
	NSRange			result;
	NSRange			searchRng;
	
	srcLength_ = [src_ length];
	searchRng = [src_ range];
	while ((result = [src_ rangeOfString : kInvalidAmpEntity
							    options : NSLiteralSearch
							      range : searchRng]).length != 0) {
		unsigned	nextIndex_;
		char		c;
		
		nextIndex_ = NSMaxRange(result);
		if (nextIndex_ >= srcLength_) break;
		c = ([src_ characterAtIndex : nextIndex_] & 0x7f);
		if (c != ';') {
			[src_ replaceCharactersInRange : result
							    withString : kAmpEntity];
			result.length = kAmpEntityLength;
		}
		srcLength_ = [src_ length];
		searchRng.location = NSMaxRange(result);
		searchRng.length = (srcLength_ - searchRng.location);
	}
}
+ (void) replaceEntityReferenceWithString : (NSMutableString *) aString
{
	resolveInvalidAmpEntity(aString);
	[aString replaceEntityReference];
}

#pragma mark -

// ----------------------------------------
// CES (Code Encoding Scheme)
// ----------------------------------------
+ (NSString *) stringWithData : (NSData         *) aData
                   CFEncoding : (CFStringEncoding) enc;
{
	CFStringEncoding ShiftJISFamily[] = {
		kCFStringEncodingDOSJapanese,	/* CP932 (Windows) */
		kCFStringEncodingMacJapanese,	/* X-MAC-JAPANESE (Mac) */
		kCFStringEncodingShiftJIS,		/* SHIFT_JIS (JIS) */
	};
	
	int			i, cnt;
	NSString	*result = nil;
	
	
	UTIL_DEBUG_METHOD;
	
	cnt = UTILNumberOfCArray(ShiftJISFamily);
	// ShiftJIS ���H
	for (i = 0; i < cnt; i++) {
		if (ShiftJISFamily[i] == enc) {
			ShiftJISFamily[i] = ShiftJISFamily[0];
			ShiftJISFamily[0] = enc;
			
			goto SHIFT_JIS;
		}
	}
	goto OTHER_ENCODINGS;
	
SHIFT_JIS:
	UTIL_DEBUG_WRITE2(@"Encoding(0x%X):%@ is ShiftJIS",
		enc, 
		(NSString*)CFStringConvertEncodingToIANACharSetName(enc));
	
	for (i = 0; i < cnt; i++) {
		CFStringEncoding	SJISEnc = ShiftJISFamily[i];
		
		UTIL_DEBUG_WRITE2(@"  Using CES (0x%X):%@", SJISEnc, 
		  (NSString*)CFStringConvertEncodingToIANACharSetName(SJISEnc));
		
		result = (NSString*) CFStringCreateWithBytes(
				NULL,
				(const UInt8 *) [aData bytes],
				(CFIndex) [aData length],
				SJISEnc,
				false);
		if (result != nil) {
			UTIL_DEBUG_WRITE1(@"Success -- text length:%u",
				[result length]);
			
			break;
		}
	}
	goto RET_RESULT;
	
OTHER_ENCODINGS:
	UTIL_DEBUG_WRITE2(@"  Using CES (0x%X):%@", enc, 
	  (NSString*)CFStringConvertEncodingToIANACharSetName(enc));
	result = (NSString*) CFStringCreateWithBytes(
			NULL,
			(const UInt8 *) [aData bytes],
			(CFIndex) [aData length],
			enc,
			false);
	
RET_RESULT:
	
	if (nil == result) {
		UTIL_DEBUG_WRITE2(@"We can't convert bytes into unicode characters, \n"
		@"but we can use TEC instead of CFStringCreateWithBytes()\n"
		@"  Using CES (0x%X):%@",
		enc, (NSString*)CFStringConvertEncodingToIANACharSetName(enc));
		
		result = [[NSString alloc] initWithDataUsingTEC : aData 
								encoding : CF2TextEncoding(enc)];
	}
	return [result autorelease];
}



// ----------------------------------------
// URL Encode
// ----------------------------------------
static NSStringEncoding *allocateAvailableURLEncodings(void)
{
	NSArray				*nsArray_;
	NSStringEncoding	*rawArray_ = NULL;
	size_t				memSize_;
	int					i, cnt;
	
	nsArray_ = CMXTemplateResource(kAvailableURLCFEncodingsNSArrayKey, nil);
	UTILCAssertNotNil(nsArray_);
	
	cnt = [nsArray_ count];
	memSize_ = (sizeof(NSStringEncoding) * (cnt +1));
	rawArray_ = malloc(memSize_);
	UTILCAssertNotNil(rawArray_);
	
	// 0�I�[
	rawArray_[cnt] = 0;
	for (i = 0; i < cnt; i++) {
		NSNumber			*encoding_;
		CFStringEncoding	cfEncoding_;
		
		encoding_ = [nsArray_ objectAtIndex : i];
		UTILCAssertKindOfClass(encoding_, NSNumber);
		
		cfEncoding_ = [encoding_ unsignedLongValue];
		NSCAssert1(
			cfEncoding_ != kCFStringEncodingInvalidId,
			@"CFStringEncoding(%lu) was Invalid.",
			cfEncoding_);
		if (0 == cfEncoding_) {
			cfEncoding_ = kCFStringEncodingMacJapanese;
		}
		
		rawArray_[i] = CF2NSEncoding(cfEncoding_);
	}
	return rawArray_;
}
+ (const NSStringEncoding *) availableURLEncodings
{
	static NSStringEncoding *kAvailableURLEncodings;
	
	if (NULL == kAvailableURLEncodings) {
		kAvailableURLEncodings = allocateAvailableURLEncodings();
	}
	return kAvailableURLEncodings;
}
+ (id) stringWithObject : (id) obj
 usingAvailableURLEncodings : (id(*)(id, NSStringEncoding)) func
{
	NSString				*converted_   = nil;
	const NSStringEncoding	*available_ = NULL;
	
	if (nil == obj) return nil;
	
	available_ = [self availableURLEncodings];
	if (NULL == available_) return nil;
	
	for (; *available_ != 0; available_++) {
		converted_ = func(obj, (*available_));
		if (converted_ != nil) break;
	}
	
	return converted_;
}
static id fnc_stringByURLEncodingUsingEncoding(id obj, NSStringEncoding enc)
{
	return [obj stringByURLEncodingUsingEncoding : enc];
}
static id fnc_stringByURLDecodingUsingEncoding(id obj, NSStringEncoding enc)
{
	return [obj stringByURLDecodingUsingEncoding : enc];
}
static id fnc_queryUsingEncoding(id obj, NSStringEncoding enc)
{
	return [obj queryUsingEncoding : enc];
}


+ (NSString *) stringByURLEncodedWithString : (NSString *) aString
{
	return [self stringWithObject:aString usingAvailableURLEncodings:fnc_stringByURLEncodingUsingEncoding];
}
+ (NSString *) stringByURLDecodedWithString : (NSString *) aString
{
	return [self stringWithObject:aString usingAvailableURLEncodings:fnc_stringByURLDecodingUsingEncoding];
}
+ (NSString *) queryWithDictionary : (NSDictionary *) aDictionary
{
	return [self stringWithObject:aDictionary usingAvailableURLEncodings:fnc_queryUsingEncoding];
}
@end

#pragma mark -

@implementation CMXTextParser(LowLevelAPIs)
static BOOL isAbonedDateField(NSString *dateExtra)
{
	NSArray	*tempArray_;
	
	// 
	// ���e�Ҏ��g���������񂾂킯�ł͂Ȃ��A���t���`�F�b�N���A
	// "���ځ[��"���ǂ����𔻒肷��B
	// 
	
	if (nil == dateExtra || 0 == [dateExtra length])
		return YES;

	//
	// dateExtra �� ":" ���܂܂�Ȃ���΁A���t������ł͂Ȃ��Ɣ��f
	// �i����Ȕ���@��100%���S���S�Ƃ͒f���ł��Ȃ����A�܂����Ԃ�OK�j
	//
	tempArray_ = [dateExtra componentsSeparatedByString : @":"]; // �ςȕ��@���Ȃ�
	return ([tempArray_ count] == 1);
}


static BOOL divideDateExtraField(
					NSString *field,
					NSString **datePart,
					NSString **extraPart,
					NSString **datePrefixPart)
{
	unsigned	length_;
	unsigned	substringIndex_;
	NSRange		found_;
	NSRange		search_;
	
	// 
	// �܂��͗��؂��","��T���A
	// �u�G���Q��24�N,2005/04/02...�v -> �u2005/04/02...�v�̂悤�ɕςȕ\�L���J�b�g
	// CocoMonar �� Date As Date �|���V�[�ɏ�����A�ςȗ��\�����邱�Ƃɂ͂������Ȃ��B
	// 
	length_ = [field length];
	search_ = NSMakeRange(0, length_);
	found_ = [field rangeOfString : @","
						  options : NSLiteralSearch
						    range : search_];
	
	if (0 != found_.length || NSNotFound != found_.location) {
		
		// �܂����Ƃ͎v�����AID��","���܂܂�Ă����̂����o�����̂�������Ȃ��̂Ń`�F�b�N
		// ","�̑O�ɋ󔒋�؂肪�܂܂�Ă��邩�ǂ����H
		NSRange	check_;
		check_ = [field rangeOfString : @" "
							  options : NSLiteralSearch
							    range : NSMakeRange(0, found_.location)];
								
		if (0 == check_.length || NSNotFound == check_.location) {
			NSLog(@"After April Fool Time ',' found.");
			*datePrefixPart = [field substringToIndex : found_.location];
			field = [field substringFromIndex : found_.location+1];
			
			// field ���ύX���ꂽ�̂ŁA�͈͂Ȃǂ��Đݒ�
			length_ = [field length];
			search_ = NSMakeRange(0, length_);
		}
	}

	// 
	// �܂��͎�����":"��T��
	// 
	found_ = [field rangeOfString : @":"
						  options : NSLiteralSearch
						    range : search_];
	
	if (0 == found_.length || NSNotFound == found_.location) {
		NSLog(@"Time ':' not found.");
		return NO;
	}
	
	//
	// �󔒋�؂�
	//
	search_.location = NSMaxRange(found_);
	if (search_.location == length_)
		goto only_date_field;
	search_.length = length_ - search_.location;
	
	found_ = [field rangeOfString : @" "
						  options : NSLiteralSearch
						    range : search_];
	
	if (0 == found_.length || NSNotFound == found_.location)
		goto only_date_field;
	
	substringIndex_ = found_.location;
	if (datePart != NULL)
		*datePart = [field substringToIndex : substringIndex_];
	
	if (length_ != substringIndex_ -1)
		substringIndex_++;
	
	if (extraPart != NULL)
		*extraPart = [field substringFromIndex : substringIndex_];
	
	return YES;
	
only_date_field:
	if (datePart != NULL) *datePart = field;
	if (extraPart != NULL) *extraPart = @"";
		
	return YES;
}

+ (CMRThreadMessage *) messageWithDATLineComponentsSeparatedByNewline : (NSArray *) aComponents
{
	CMRThreadMessage	*message_ = nil;
	NSString			*dateExtra_;
	
	if (nil == aComponents)
		return nil;
	if ([aComponents count] <= k2chDATMessageIndex) {
		
		UTILDebugWrite2(@"Array count must be at least %u or more, but was %d",
				k2chDATMessageIndex, [aComponents count]);
		
		return nil;
	}
	
	message_ = [[CMRThreadMessage alloc] init];
	dateExtra_ = [aComponents objectAtIndex : k2chDATDateExtraFieldIndex];
	
	if (nil == [self parseDateExtraField : dateExtra_
			           convertToMessage : message_]) {
		[message_ release];
		return nil;
	}
	[message_ setName : [aComponents objectAtIndex : k2chDATNameIndex]];
	
	// �Ƃ��ǂ����[������"0"�̂Ƃ�������
	// read.cgi�͂����\�����Ȃ��̂Ŗ������邩�ǂ����B�B�B
	[message_ setMail : [aComponents objectAtIndex : k2chDATMailIndex]];
	[message_ setMessageSource : [aComponents objectAtIndex : k2chDATMessageIndex]];
		
	return [message_ autorelease];
}

+ (BOOL) parseExtraField : (NSString         *) extraField
        convertToMessage : (CMRThreadMessage *) aMessage
{
	unsigned	length_;
	NSRange		found_;
	NSRange		search_;
	NSString	*siberiaIPKey;
	
	length_ = [extraField length];
	if (nil == extraField || 0 == length_)
		return YES;

	/* 2005-02-03 tsawada2<ben-sawa@td5.so-net.ne.jp>
	   extraField �� 0 �܂��� O �ꕶ���̏ꍇ�́A�g�сEPC�̋�ʋL���ƌ��Ȃ��Ē��ڏ���
	   ���O�t�@�C���̃t�H�[�}�b�g�̌݊����Ȃǂ��l�����āAHost �̒l�Ƃ��ď������邱�Ƃɂ���B
	*/
	if ([extraField isEqualToString : @"0"] || [extraField isEqualToString : @"O"]) {
		[aMessage setHost : extraField];
		return YES;
	}
	
	search_ = NSMakeRange(0, length_);
	siberiaIPKey = NSLocalizedString(@"siberia IP field", @"siberia IP field");	// �V�x���A������Ȃǂŏo�Ă���u���M��:�v�Ƃ���������

	while (1) {
		NSRange		substringRange_;
		NSString	*name_;
		NSString	*value_;
		
		// 
		// �܂��͍��ڂ̖��O�^�l��؂蕶����":"��T��
		// 
		found_ = [extraField rangeOfString : @":"
							       options : NSLiteralSearch
							         range : search_];
		if (0 == found_.length || NSNotFound == found_.location)
			return YES;
		
		substringRange_.location = search_.location;
		substringRange_.length = found_.location - search_.location;
		
		// ���ږ�
		name_ = [extraField substringWithRange : substringRange_];
		search_.location = NSMaxRange(found_);
		while (1) {
			char	c;
			
			if (search_.location == length_)
				goto error_invalid_format;
			
			c = ([extraField characterAtIndex : search_.location] & 0x7f);
			if (!isspace(c)) break;
			
			search_.location++;
		}
		search_.length = length_ - search_.location;
		
		// 
		// ���ڋ�؂蕶����" "��T��
		// 
		found_ = [extraField rangeOfString : @" "
							       options : NSLiteralSearch
							         range : search_];
		if (0 == found_.length || NSNotFound == found_.location) {
			value_ = [extraField substringFromIndex : search_.location];
		} else {
			substringRange_.location = search_.location;
			substringRange_.length = found_.location - search_.location;
			
			value_ = [extraField substringWithRange : substringRange_];
		}
		
/*
		UTILDescription(extraField);
		UTILDescription(name_);
		UTILDescription(value_);
*/
		if ([name_ rangeOfString : @"ID"].length != 0) {
			[aMessage setIDString : value_];
		}else if ([name_ rangeOfString : @"BE"].length != 0) {
			// be
			//NSLog(@"Be: %@", value_);
			if ([value_ hasSuffix : @">"]) {
				// in 'be.2ch.net/be' the Be-ID format is different from other boards.
				value_ = [value_ substringToIndex : ([value_ length]-1)];
				//NSLog(@"trimed: %@", value_);
				[aMessage setBeProfile : [value_ componentsSeparatedByString : @":"]];
			} else {
				// standard be profile ID format
				[aMessage setBeProfile : [value_ componentsSeparatedByString : @"-"]];
			}
		}else if ([name_ rangeOfString : @"HOST"].length != 0 || [name_ rangeOfString : siberiaIPKey].length != 0) {
			[aMessage setHost : value_];
		} else {
			;
		}
		
		if (0 == found_.length || NSNotFound == found_.location) {
			break;
		} else {
			search_.location = NSMaxRange(found_);
			if (search_.location == length_)
				goto error_invalid_format;
			
			search_.length = length_ - search_.location;
		}
	}
	return YES;
	
	error_invalid_format:
		return NO;
}
+ (BOOL) parseDateExtraField : (NSString         *) dateExtra
            convertToMessage : (CMRThreadMessage *) aMessage
{
	NSString		*datePart_ = nil;
	NSString		*extraPart_ = nil;
	id				date_;
	NSString		*prefixPart_ = nil;

	if (isAbonedDateField(dateExtra)) {
		NSLog(@"It is Aboned.");
		return YES;
	}
	
	
	if (NO == divideDateExtraField(dateExtra, &datePart_, &extraPart_, &prefixPart_)) {
		NSLog(@"Can't Divide Date And Extra");
		return NO;
	}
	
	date_ = [[self class] dateWith2chDateString : datePart_];
	if (nil == date_) {
		NSLog(@"Can't Convert '%@' to Date.", datePart_);
		return NO;
	}
	
	if (prefixPart_ != nil) {
		NSLog(@"date prefix : %@", prefixPart_);
		[aMessage setDatePrefix : prefixPart_];
	}
	[aMessage setDate : date_];
	//NSLog(@"extraPart_ is %@.",extraPart_);
	[self parseExtraField:extraPart_ convertToMessage:aMessage];
	
	return YES;
}
@end