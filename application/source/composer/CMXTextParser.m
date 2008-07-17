/**
  * $Id: CMXTextParser.m,v 1.29 2008/07/17 14:13:51 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
  *
  */

#import "CMXTextParser.h"
#import "CocoMonar_Prefix.h"
#import "CMRThreadMessage.h"
#import <OgreKit/OgreKit.h>
// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"

static NSString *const CMXTextParserComma					= @",";
static NSString *const CMXTextParser2chSeparater			= @"<>";

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

static void htmlConvertBreakLineTag(NSMutableString *theString)
{
	NSRange		searchRange_;
	
	if (nil == theString || 0 == [theString length])
		return;
	
	// 2003-09-18 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
	// --------------------------------
	// - [NSMutableString strip] ����
	// ���݂̎����ł�CFStringTrimWhitespace()
	// ���g���邽�߁A���{������ƑS�p�󔒂���������Ă��܂��B
	[theString stripAtStart];
	[theString stripAtEnd];
	
	searchRange_ = NSMakeRange(0, [theString length]);
	// �s���E�s���̔��p�X�y�[�X�𓯎��ɍ폜
	[theString replaceOccurrencesOfRegularExpressionString: @" *<br> *"
												withString: @"\n"
												   options: OgreIgnoreCaseOption
													 range: searchRange_];
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
@synchronized([CMXTextParser class]) {
	htmlConvertBreakLineTag(aSource);
	[aSource replaceCharacters:[NSString backslash] toString:[NSString yenmark]];
	htmlConvertDeleteAllTagElements(aSource);
	[self replaceEntityReferenceWithString : aSource];
}
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
//	return [obj stringByURLDecodingUsingEncoding : enc];
	return [obj stringByReplacingPercentEscapesUsingEncoding:enc];
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
static BOOL divideField(NSString *field, NSString **datePart, NSString **milliSecPart, NSString **extraPart, CMRThreadMessage *aMessage)
{
	static OGRegularExpression *regExpForPrefix;
	static OGRegularExpression *regExp;

	if (regExpForPrefix == nil) {
		regExpForPrefix = [[OGRegularExpression alloc] initWithString: @"^(.*),\\d{2,4}"];
	}
	if (regExp == nil) {
		regExp = [[OGRegularExpression alloc] initWithString: @"^(.*\\d{2}:\\d{2})(\\.\\d{2})? ?( <a href=\"http://2ch.se/\">.*</a>)? ?(.*)"];
    }

	// 
	// �܂��͗��؂��","��T���A
	// �u�G���Q��24�N,2005/04/02...�v -> �u2005/04/02...�v�̂悤�ɕςȕ\�L���J�b�g
	//
    OGRegularExpressionMatch *prefixMatch = [regExpForPrefix matchInString: field];
	NSString *tmpPrefix = nil;
    if (prefixMatch) {
		tmpPrefix = [prefixMatch substringAtIndex: 1];
//		[aMessage setDatePrefix: tmpPrefix];
		NSRange cutRange = [prefixMatch rangeOfSubstringAtIndex:1];
		field = [field substringFromIndex:NSMaxRange(cutRange)+1];
    }

    //
    // �����Ƃ���ȊO�𕪊�
    // ���ځ[��Ȃǂ̏ꍇ�ɒ��ӂ��Ȃ���΂Ȃ�Ȃ�
    //
	OGRegularExpressionMatch *match = [regExp matchInString: field];
	if (match) {
		NSString *tmpDate, *tmpMilliSec, *tmpStock, *tmpExtra, *dateRep;
		
		tmpDate = [match substringAtIndex: 1];
		tmpMilliSec = [match substringAtIndex: 2];
		tmpStock = [match substringAtIndex: 3];
		tmpExtra = [match substringAtIndex: 4];
//		NSLog(@"tmpDate<%@> tmpStock<%@> tmpExtra<%@>", tmpDate, (tmpStock != nil) ? tmpStock: @"NULL", tmpExtra);
		if (datePart != NULL) *datePart = tmpDate;
		if (extraPart != NULL) *extraPart = tmpExtra;
		
		if (tmpStock) {
			if (tmpMilliSec) {
				dateRep = [NSString stringWithFormat: @"%@%@ %@", tmpDate,tmpMilliSec, tmpStock];
				if (milliSecPart != NULL) *milliSecPart = tmpMilliSec;
			} else {
				dateRep = [NSString stringWithFormat: @"%@ %@", tmpDate, tmpStock];
			}
		} else {
			if (tmpMilliSec) {
				dateRep = [NSString stringWithFormat: @"%@%@", tmpDate, tmpMilliSec];
				if (milliSecPart != NULL) *milliSecPart = tmpMilliSec;
			} else {
				dateRep = tmpDate;
			}
		}
		[aMessage setDateRepresentation: (tmpPrefix == nil) ? dateRep : [NSString stringWithFormat: @"%@,%@", tmpPrefix, dateRep]];
	} else { // ���ځ[��Ȃǂ̏ꍇ������ɉ��
		NSArray *array = [field componentsSeparatedByString: @" "];
//		if (datePart != NULL) *datePart = [array objectAtIndex: 0]; // ���ځ[��n�̏ꍇ���t�͐ݒ肵�Ȃ�
		if ([array count] > 1 && extraPart != NULL) *extraPart = [array objectAtIndex: 1];
	}

	return YES;
}

// milliSecString sample:
// .45 (comma included, 2 keta)
static id dateWith2chDateString(NSString *theString, NSString *milliSecString)
{
    static CFDateFormatterRef   kDateFormatterStd = NULL;
    static CFDateFormatterRef   kDateFormatterAlt = NULL;

	id					date_ = nil;
	NSMutableString		*dateString_ = nil;
	NSRange				found_;
	
	UTILRequireCondition(theString && [theString length], return_date);

#if DEBUG_LOG
	NSLog(@"dateWith2chDateString: %@", theString);
#endif

    if (kDateFormatterStd == NULL) {
		CFLocaleRef locale = CFLocaleCopyCurrent();
		kDateFormatterStd = CFDateFormatterCreate(NULL, locale, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle);
        kDateFormatterAlt = CFDateFormatterCreate(NULL, locale, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle);

        // �Е��̃t�H�[�}�b�^�̓t�H�[�}�b�g���u�ł����肻���Ȃ��́v�ɌŒ�B
		CFDateFormatterSetFormat(kDateFormatterStd, CFSTR("yy/MM/dd HH:mm:ss"));
        // �����Е��̃t�H�[�}�b�^�́u�c��̉\���v�ɍ��킹�Đ����t�H�[�}�b�g���Ďw�肷��
    }

	// �O��̋󔒂��������A����ɗj�������J�b�R���܂߂ď�������B
	dateString_ = SGTemporaryString();
	[dateString_ setString: theString];

	// OgreKit �Ɋ܂܂�� NSString �J�e�S��
	found_ = [dateString_ rangeOfRegularExpressionString: @"\\(.*\\)"];
	if (found_.length != 0) {
		[dateString_ deleteCharactersInRange: found_];
	}

	// 1/100 -> 1/1000
	if (milliSecString != nil) {
//		NSRange	commaFound_;
//		commaFound_ = [dateString_ rangeOfString: CMXTextParserBSPeriod
//										 options: (NSLiteralSearch|NSBackwardsSearch)];

//		if (commaFound_.location != NSNotFound) {
			[dateString_ appendString: milliSecString];
			[dateString_ appendString: @"0"];

    		CFDateFormatterSetFormat(kDateFormatterAlt, CFSTR("yyyy/MM/dd HH:mm:ss.SSS"));
			date_ = (NSDate *)CFDateFormatterCreateDateFromString(NULL, kDateFormatterAlt, (CFStringRef)dateString_, NULL);

			if(date_) {
				[date_ retain];
				CFRelease((CFDateRef)date_);
				return [date_ autorelease];
			} else {
				goto return_date;
			}
//		}
	}

	// ���������J�n 
	{ 
		date_ = (NSDate *)CFDateFormatterCreateDateFromString(NULL, kDateFormatterStd, (CFStringRef)dateString_, NULL);

		if(date_) {
			[date_ retain];
            CFRelease((CFDateRef)date_);
			return [date_ autorelease];
		} else {
			CFDateFormatterSetFormat(kDateFormatterAlt, CFSTR("yy/MM/dd HH:mm"));
			date_ = (NSDate *)CFDateFormatterCreateDateFromString(NULL, kDateFormatterAlt, (CFStringRef)dateString_, NULL);
			if (date_) {
				[date_ retain];
				CFRelease((CFDateRef)date_);
                return [date_ autorelease];
			}
		}
	}

#if DEBUG_LOG
	NSLog(@"dateWith2chDateString: ret: %@ (src: %@)", date_ ? date_ : @"(nil date)", dateString_);
#endif

return_date:
	return theString;
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

static BOOL _parseExtraField(NSString *extraField, CMRThreadMessage *aMessage)
{
    /*
		2007-03-07 tsawada2<ben-sawa@td5.so-net.ne.jp>
		�ڕW�̊m�F�F���̊֐����ł� Host, ID, BE �� extraField ����T���āAaMessage �̊Y���������Z�b�g����B
		- Host �̗�O�F�u���M���v@�V�x���A�^���M���L���̂�
		- BE �̗�O�F�u����D�ҁv
	*/
	unsigned	length_;

	if (extraField == nil) return YES;
    
    length_ = [extraField length];
    if (length_ < 1) return YES;

	static NSSet	*clientCodeSet;
	static NSString	*kabunushiKey;
	static OGRegularExpression	*regExpForHOST;
	static OGRegularExpression	*regExpForBE;
	static OGRegularExpression	*regExpForID;

    OGRegularExpressionMatch    *matchOfHOST, *matchOfBE, *matchOfID;
    NSRange stockRange;

	/*
		2005-02-03 tsawada2<ben-sawa@td5.so-net.ne.jp>
		extraField �� 0 �܂��� O �ꕶ���̏ꍇ�́A�g�сEPC�̋�ʋL���ƌ��Ȃ��Ē��ڏ���
		���O�t�@�C���̃t�H�[�}�b�g�̌݊����Ȃǂ��l�����āAHost �̒l�Ƃ��ď������邱�Ƃɂ���B
		2005-06-18 �ǉ��F����p2 ����̓��e��ʋL���uP�v����������B
		2005-07-31 �ǉ��F�uo�v������̂��B�m��Ȃ������B
		2006-03-22 �ǉ��F�uQ�v����������炵���B
		2008-07-15 �ǉ��F�ui�v�� iPhone 3G ����̓��e�炵���B
		2008-07-17 �ǉ��F�uI�v�� iPhone Wi-Fi ����̓��e�H
		2ch�����^�T�[�o�E���P�[�V�����\�z��� Part29
		http://qb5.2ch.net/test/read.cgi/operate/1212665493/ �Ƃ��B

	*/
	if (length_ == 1) {
		if (clientCodeSet == nil)
			clientCodeSet = [[NSSet alloc] initWithObjects : @"0", @"O", @"P", @"o", @"Q", @"i", @"I", nil];

		if ([clientCodeSet containsObject : extraField]) {
			[aMessage setHost : extraField];
			return YES;
		}
	}


	if (kabunushiKey == nil)
		kabunushiKey = [NSLocalizedString(@"kabunushi yutai", @"") retain];

	if (regExpForHOST == nil) {
		NSString *string = [NSString stringWithFormat: @"(HOST:|%@:)\\s?(.*)", NSLocalizedString(@"siberia IP field", @"")];
		regExpForHOST = [[OGRegularExpression alloc] initWithString: string];
	}
	
	if (regExpForBE == nil)
		regExpForBE = [[OGRegularExpression alloc] initWithString: @"BE:\\s?(.*)\\s?"];

	if (regExpForID == nil)
		regExpForID = [[OGRegularExpression alloc] initWithString: @"ID:\\s?(\\S*)\\s?"];


	// Search HOST
	matchOfHOST = [regExpForHOST matchInString: extraField];
	if (matchOfHOST != nil) {
		NSRange matchedRange = [matchOfHOST rangeOfMatchedString];
		NSString *hostString = [matchOfHOST substringAtIndex: 2];			
		[aMessage setHost: hostString];

		if (matchedRange.location == 0) return YES;
		extraField = [extraField substringToIndex: matchedRange.location-1]; // HOST �������������Ă��܂�
	}

    // Be ����ъ���D��
	// ����D�҂�T��
	stockRange = [extraField rangeOfString: kabunushiKey options: (NSLiteralSearch|NSBackwardsSearch)];

	if (stockRange.location != NSNotFound) {
		NSArray	*dummyAry_ = [NSArray arrayWithObjects: kabunushiKey, nil];
		[aMessage setBeProfile : dummyAry_];
	} else {
		// BE ��T���iBE �͊���D�҂Ɠ����ɂ͋N���Ȃ��j
		matchOfBE = [regExpForBE matchInString: extraField];
		if (matchOfBE != nil) {
			NSRange matchedBERange = [matchOfBE rangeOfMatchedString];
			NSString *beStr_ = [matchOfBE substringAtIndex: 1];
			[aMessage setBeProfile: [beStr_ componentsSeparatedByString : @"-"]];
			
			if (matchedBERange.location == 0) return YES;
		}
	}

	// Search ID
	matchOfID = [regExpForID matchInString: extraField];
	if (matchOfID != nil) {
		NSString *idString = [matchOfID substringAtIndex: 1];			
		[aMessage setIDString: idString];
	}

    return YES;
}

static BOOL _parseDateExtraField(NSString *dateExtra, CMRThreadMessage *aMessage)
{
	NSString		*datePart_ = nil;
//	NSString		*milliSecPart_ = nil;
	NSString		*extraPart_ = nil;

	if (nil == dateExtra || 0 == [dateExtra length]) return YES;

//	divideField(dateExtra, &datePart_, &milliSecPart_, &extraPart_, aMessage);
	divideField(dateExtra, &datePart_, NULL, &extraPart_, aMessage);

	if (datePart_) {
		id date_;	
//		date_ = dateWith2chDateString(datePart_, milliSecPart_);
		date_ = dateWith2chDateString(datePart_, nil);

		if (nil == date_) {
			NSLog(@"Can't Convert '%@' to Date.", datePart_);
			return NO;
		}
		[aMessage setDate : date_];

	}

	return _parseExtraField(extraPart_, aMessage);
}
@end
