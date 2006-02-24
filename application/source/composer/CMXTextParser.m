/**
  * $Id: CMXTextParser.m,v 1.15 2006/02/24 15:13:21 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
  *
  */

#import "CMXTextParser.h"
#import "CocoMonar_Prefix.h"
#import "CMRThreadMessage.h"

// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"

/*!
@defined     DATE2CH_CALENDAR_FORMAT
@discussion  2channel Data Format
*/
#define DATE2CH_CALENDAR_FORMAT_LATE2005	@"%Y/%m/%d %H:%M:%S.%F"
#define DATE2CH_CALENDAR_FORMAT_SEC			@"%y/%m/%d %H:%M:%S"
#define DATE2CH_CALENDAR_FORMAT_SEC_4KETA	@"%Y/%m/%d %H:%M:%S"
#define DATE2CH_CALENDAR_FORMAT				@"%y/%m/%d %H:%M"
#define DATE2CH_CALENDAR_FORMAT_4KETA		@"%Y/%m/%d %H:%M"

static NSString *const CMXTextParserDate2chSeparater		= @"(";
static NSString *const CMXTextParserDate2chSeparater_close  = @")";
static char c_CMXTextParserDate2chSeparater_close = ')';

static NSString *const CMXTextParserComma					= @",";
static NSString *const CMXTextParser2chSeparater			= @"<>";

static NSString *const CMXTextParserBSPeriod				= @".";
static NSString *const CMXTextParserBSZero					= @"0";
static NSString *const CMXTextParserBSColon					= @":";
static NSString *const CMXTextParserBSSpace					= @" ";

#define kAvailableURLCFEncodingsNSArrayKey		@"System - AvailableURLCFEncodings"

static BOOL _parseDateExtraField(NSString *dateExtra, CMRThreadMessage *aMessage);

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


@implementation CMXTextParser
+ (NSArray *) separatedLine : (NSString *) theString
{
	NSArray				*components_;
	components_ = [theString componentsSeparatedByString : CMXTextParser2chSeparater];

	if ([components_ count] == 1) {
		NSMutableArray	*commaComponents_ = [NSMutableArray arrayWithCapacity : 2];
		separetedLineByConvertingComma(theString, commaComponents_);
		if ((commaComponents_ == nil) || (0 == [commaComponents_ count]))
			return nil;

		return commaComponents_;
	}

	return components_;
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
	
	if ((strLen_ = [theString length]) < 2) 
		return;

	searchRange_ = NSMakeRange(0, strLen_);
	
	while ((result_ = [theString rangeOfString : @"<"
								 options : NSLiteralSearch
								   range : searchRange_]).length != 0) {
		NSRange		gtRange_;			// ">"
		BOOL		shouldDelete = YES;	// 2005-11-16 tsawada2 : shouldDelete �̓��[�v�̐擪�ɖ߂邽�тɍď��������Ȃ��ƃ_��
		
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
			if (0 == nsr_strcasecmp(tagName, "ul")) {
				shouldDelete = NO;
			}
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

#pragma mark Entity Reference
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

#pragma mark CES (Code Encoding Scheme)

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

#pragma mark URL Encode

static NSStringEncoding *allocateAvailableURLEncodings(void)
{
	NSArray				*nsArray_;
	NSStringEncoding	*rawArray_ = NULL;
	size_t				memSize_;
	int					i, cnt;
	
	nsArray_ = SGTemplateResource(kAvailableURLCFEncodingsNSArrayKey);
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

#pragma mark Low Level APIs

static BOOL isAbonedDateField(NSString *dateExtra)
{
	// 
	// ���e�Ҏ��g���������񂾂킯�ł͂Ȃ��A���t���`�F�b�N���A
	// "���ځ[��"���ǂ����𔻒肷��B
	// 
	if (nil == dateExtra || 0 == [dateExtra length])
		return YES;

	NSRange		check_;	

	// ������Ɂu:�v���܂܂�Ȃ���΁A���ځ[��Ɣ��f
	check_ = [dateExtra rangeOfString : CMXTextParserBSColon
							  options : NSLiteralSearch];

	return (check_.length == 0);
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
	// 
	length_ = [field length];
	search_ = NSMakeRange(0, length_);
	found_ = [field rangeOfString : CMXTextParserComma
						  options : NSLiteralSearch
						    range : search_];
	
	if (0 != found_.length || NSNotFound != found_.location) {
		
		// �܂����Ƃ͎v�����AID��","���܂܂�Ă����̂����o�����̂�������Ȃ��̂Ń`�F�b�N
		// ","�̑O�ɋ󔒋�؂肪�܂܂�Ă��邩�ǂ����H
		NSRange	check_;
		check_ = [field rangeOfString : CMXTextParserBSSpace
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
	found_ = [field rangeOfString : CMXTextParserBSColon
						  options : NSLiteralSearch
						    range : search_];
	
	//
	// �󔒋�؂�
	//
	search_.location = NSMaxRange(found_);
	if (search_.location == length_)
		goto only_date_field;
	search_.length = length_ - search_.location;
	
	found_ = [field rangeOfString : CMXTextParserBSSpace
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

static id dateWith2chDateString(NSString *theString)
{
	id					date_ = nil;
	NSMutableString		*dateString_ = nil;
	NSRange				found_;
	
	UTILRequireCondition(theString && [theString length], return_date);

#if DEBUG_LOG
	NSLog(@"dateWith2chDateString: %@", theString);
#endif

	// �O��̋󔒂��������A����ɗj�������J�b�R���܂߂ď�������B
	dateString_ = SGTemporaryString();
	[dateString_ setString : theString];
	//[dateString_ strip]; // parseDateExtraField: convertToMessage: ���Ő�ɂ���Ă��܂�
	
	found_ = [dateString_ rangeOfString : CMXTextParserDate2chSeparater];

	if (found_.length != 0) {
		// 2001/08/06(��) 21:45 --> 2001/08/06 21:45
		NSRange			weekday_;
		NSRange			weekday_close_;
		int				week_len = 0;
		unsigned int	cur_len = [dateString_ length];

		weekday_.location = found_.location;
		weekday_.length = 3;
		week_len = NSMaxRange(weekday_);

		if (cur_len >= week_len && [dateString_ characterAtIndex: week_len-1] != c_CMXTextParserDate2chSeparater_close) {
			weekday_.length = cur_len - weekday_.location;
			weekday_close_ = [dateString_ rangeOfString : CMXTextParserDate2chSeparater_close
												options : NSLiteralSearch
												  range : weekday_];

			if (weekday_close_.location != NSNotFound)
				weekday_.length = NSMaxRange(weekday_close_) - weekday_.location;
			else
				weekday_.length = 3;
		}

		if (NSMaxRange(weekday_) > cur_len)
			goto return_date;

		[dateString_ deleteCharactersInRange : weekday_];
	}

	// 1/100 -> 1/1000
	{
		NSRange	commaFound_;
		commaFound_ = [dateString_ rangeOfString : CMXTextParserBSPeriod
										 options : NSLiteralSearch | NSBackwardsSearch];

		if (commaFound_.location != NSNotFound) {
			[dateString_ appendString : CMXTextParserBSZero];
			date_ = [NSCalendarDate dateWithString : dateString_
									calendarFormat : DATE2CH_CALENDAR_FORMAT_LATE2005];
			if(date_)
				return date_;
			else
				goto return_date;
		}
	}

	// ���������J�n 
	{
		// ���Ԃ��d�v�B����������B�N��2���\�L���Ɏ������ƁB
		date_ = [NSCalendarDate dateWithString : dateString_
								calendarFormat : DATE2CH_CALENDAR_FORMAT_SEC];
		if(date_) return date_;
		date_ = [NSCalendarDate dateWithString : dateString_
								calendarFormat : DATE2CH_CALENDAR_FORMAT_SEC_4KETA];
		if(date_) return date_;
		date_ = [NSCalendarDate dateWithString : dateString_
								calendarFormat : DATE2CH_CALENDAR_FORMAT];
		if(date_) return date_;
		date_ = [NSCalendarDate dateWithString : dateString_
								calendarFormat : DATE2CH_CALENDAR_FORMAT_4KETA];
		if(date_) return date_;	
	}

#if DEBUG_LOG
	NSLog(@"dateWith2chDateString: ret: %@ (src: %@)", date_, dateString_);
#endif

return_date:
	return theString;
}


static BOOL _parseStockPartFromExtraField(NSString *extraPart_, NSString **stockPart_)
{
	if(extraPart_ == nil) return NO;
	unsigned	exPartLen = [extraPart_ length];

	if(exPartLen < 10) return NO; // " <a href="
	
	if([extraPart_ hasPrefix : @" <a href="]) {
		NSRange hoge_;

		hoge_ = [extraPart_ rangeOfString : @" " options : NSLiteralSearch range : NSMakeRange(9,exPartLen-9)];
		
		*stockPart_ = [extraPart_ substringToIndex : hoge_.location];
		extraPart_ = [extraPart_ substringFromIndex : hoge_.location];
		
		return YES;
	}
	
	return NO;
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
	
	//if (NO == [self parseDateExtraField : dateExtra_
	//		           convertToMessage : message_]) {
	if (NO == _parseDateExtraField(dateExtra_, message_)) {
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

//+ (BOOL) parseExtraField : (NSString         *) extraField
//        convertToMessage : (CMRThreadMessage *) aMessage
static BOOL _parseExtraField(NSString *extraField, CMRThreadMessage *aMessage)
{
	unsigned	length_;
	NSRange		found_;
	NSRange		search_;
	
	length_ = [extraField length];

	if (nil == extraField || 0 == length_)
		return YES;

	static NSSet	*clientCodeSet;
	static NSString	*siberiaIPKey;

	/*
		2005-02-03 tsawada2<ben-sawa@td5.so-net.ne.jp>
		extraField �� 0 �܂��� O �ꕶ���̏ꍇ�́A�g�сEPC�̋�ʋL���ƌ��Ȃ��Ē��ڏ���
		���O�t�@�C���̃t�H�[�}�b�g�̌݊����Ȃǂ��l�����āAHost �̒l�Ƃ��ď������邱�Ƃɂ���B
		2005-06-18 �ǉ��F����p2 ����̓��e��ʋL���uP�v����������B
		2005-07-31 �ǉ��F�uo�v������̂��B�m��Ȃ������B
	*/
	if (length_ == 1) {
		if (clientCodeSet == nil)
			clientCodeSet = [[NSSet alloc] initWithObjects : @"0", @"O", @"P", @"o", nil];

		if ([clientCodeSet containsObject : extraField]) {
			[aMessage setHost : extraField];
			return YES;
		}
	}

	// �V�x���A������Ȃǂŏo�Ă���u���M��:�v�Ƃ���������
	if (siberiaIPKey == nil)
		siberiaIPKey = [NSLocalizedString(@"siberia IP field", @"siberia IP field") retain];
	
	{
		NSRange		hostRange_;
		
		// ���K����"HOST:"��T��
		// HOST �����ɂ́A���̏��iBE:��ID:�Ȃǁj�͂������Ȃ��Ɖ��肵�Ă���B
		hostRange_ = [extraField rangeOfString : @"HOST:"
									   options : NSLiteralSearch | NSBackwardsSearch];

		if (hostRange_.location != NSNotFound) {
			NSString	*hostStr_ = [extraField substringFromIndex : (hostRange_.location+5)];
			
			// �܂�BBS�ȂǂŁA"HOST: xxx.yyy.jp"�̂悤��":"�̂��Ƃ�" "�����邱�Ƃ�����B������폜
			if ([hostStr_ hasPrefix : CMXTextParserBSSpace]) hostStr_ = [hostStr_ substringFromIndex : 1];

			[aMessage setHost : hostStr_];
			
			if (hostRange_.location == 0) return YES; // HOST: ���O�ɕ����񂪖����Ȃ�����I��
			extraField = [extraField substringToIndex : (hostRange_.location-1)]; // extraField ���� host �������
			length_ = [extraField length]; // length ���Đݒ�
		}
	}

	search_ = NSMakeRange(0, length_);

	while (1) {
		NSRange		substringRange_;
		NSString	*name_;
		NSString	*value_;

		// 
		// �܂��͍��ڂ̖��O�^�l��؂蕶����":"��T��
		//
		found_ = [extraField rangeOfString : CMXTextParserBSColon
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
		found_ = [extraField rangeOfString : CMXTextParserBSSpace
							       options : NSLiteralSearch
							         range : search_];
		if (0 == found_.length || NSNotFound == found_.location) {
			value_ = [extraField substringFromIndex : search_.location];
		} else {
			substringRange_.location = search_.location;
			substringRange_.length = found_.location - search_.location;
			
			value_ = [extraField substringWithRange : substringRange_];
		}
		
		UTILDescription(extraField);
		UTILDescription(name_);
		UTILDescription(value_);

		if ([name_ rangeOfString : @"ID"].length != 0) {
			[aMessage setIDString : value_];
		}else if ([name_ rangeOfString : @"BE"].length != 0) {
			//
			// be profile link
			//
			if ([value_ hasSuffix : @">"]) {
				// in 'be.2ch.net/be' the Be-ID format is different from other boards.
				value_ = [value_ substringToIndex : ([value_ length]-1)];
				[aMessage setBeProfile : [value_ componentsSeparatedByString : CMXTextParserBSColon]];
			} else {
				// standard be profile ID format
				[aMessage setBeProfile : [value_ componentsSeparatedByString : @"-"]];
			}
		}else if ([name_ rangeOfString : siberiaIPKey].length != 0) {
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
	return YES;//NO;
}

//+ (BOOL) parseDateExtraField : (NSString         *) dateExtra
//            convertToMessage : (CMRThreadMessage *) aMessage
static BOOL _parseDateExtraField(NSString *dateExtra, CMRThreadMessage *aMessage)
{
	NSString		*datePart_ = nil;
	NSString		*extraPart_ = nil;
	id				date_;
	NSString		*prefixPart_ = nil;
	
	NSString		*stockPart_ = nil;

	if (isAbonedDateField(dateExtra)) {
		//NSLog(@"It is Aboned.");
		return YES;
	}
	
	
	if (NO == divideDateExtraField(dateExtra, &datePart_, &extraPart_, &prefixPart_)) {
		NSLog(@"Can't Divide Date And Extra");
		return NO;
	}
	
	NSMutableString *tmpDatePart_ = [datePart_ mutableCopy];
	
	CFStringTrimWhitespace((CFMutableStringRef)tmpDatePart_);

	date_ = dateWith2chDateString(tmpDatePart_);

	if (nil == date_) {
		NSLog(@"Can't Convert '%@' to Date.", datePart_);
		return NO;
	}
	
	if (prefixPart_ != nil) {
		UTILDescription(prefixPart_);
		[aMessage setDatePrefix : prefixPart_];
		[tmpDatePart_ insertString : CMXTextParserComma atIndex : 0];
		[tmpDatePart_ insertString : prefixPart_ atIndex : 0];
	}

	UTILDescription(extraPart_);
	if (_parseStockPartFromExtraField(extraPart_, &stockPart_)) {
		UTILDescription(stockPart_);
		[tmpDatePart_ appendString : stockPart_];
	}

	UTILDescription(tmpDatePart_);
	[aMessage setDateRepresentation : tmpDatePart_];
	[tmpDatePart_ release];

	[aMessage setDate : date_];

	UTILDescription(extraPart_);

	return _parseExtraField(extraPart_, aMessage);
}
@end