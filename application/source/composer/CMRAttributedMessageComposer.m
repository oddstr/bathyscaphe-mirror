/**
  * $Id: CMRAttributedMessageComposer.m,v 1.20 2007/02/17 15:34:10 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
  *
  */

#import "CMRAttributedMessageComposer_p.h"
#import <AppKit/NSTextStorage.h>


// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"

#define kLocalizedFilename			@"MessageComposer"

// KeyValueTemplate.plist
#define	kThreadIndexFormatKey		@"Thread - IndexFormat"
#define	kThreadFieldSeparaterKey	@"Thread - FieldSeparater"
#define kThreadHostFormatKey		@"Thread - Host Format"
//#define kThreadDateFormatKey		@"Thread - DateDescription" // No longer used. (Starlight Breaker)

static NSString *dateStringFromObject(id theDate, NSString *prefix);
static void appendFiledTitle(NSMutableAttributedString *buffer, NSString *title);
static void appendWhiteSpaceSeparator(NSMutableAttributedString *buffer);

#define LOCALIZED_STR(aKey)	NSLocalizedStringFromTable(aKey, kLocalizedFilename, nil)
#define FIELD_NAME				LOCALIZED_STR(@"Name")
#define FIELD_MAIL				LOCALIZED_STR(@"Mail")
#define FIELD_DATE				LOCALIZED_STR(@"Date")
#define FIELD_ID				LOCALIZED_STR(@"ID")
#define FIELD_HOST				LOCALIZED_STR(@"Host")


#pragma mark -

@implementation CMRAttributedMessageComposer

static NSAttributedString	*wSS = nil;

+ (void) initialize 
{
	UTIL_DEBUG_METHOD;
}

+ (id) composerWithContentsStorage : (NSMutableAttributedString *) storage
{
	return [[[self alloc] initWithContentsStorage : storage] autorelease];
}
- (id) initWithContentsStorage : (NSMutableAttributedString *) storage
{
	if (self = [self init]) {
		[self setContentsStorage : storage];
	}
	return self;
}
- (id) init
{
	if (self = [super init]) {
		[self setComposingMask:CMRInvisibleMask compose:NO];
		bs_targetIndex = NSNotFound;
	}
	return self;
}
- (void) dealloc
{
	[_contentsStorage release];
	[_nameCache release];
	[super dealloc];
}

/* Accessor for _contentsStorage */
- (NSMutableAttributedString *) contentsStorage
{
	if (nil == _contentsStorage) {
		_contentsStorage = [[NSTextStorage alloc] init];
	}
	return _contentsStorage;
}
- (void) setContentsStorage : (NSMutableAttributedString *) aContentsStorage
{
	id tmp;
	
	tmp = _contentsStorage;
	_contentsStorage = [aContentsStorage retain];
	[tmp release];
}

/* mask で指定された属性を無視する */
- (UInt32) attributesMask { return _mask; }
- (void) setAttributesMask : (UInt32) mask { _mask = mask; }

/* flag: mask に一致する属性をもつレスを生成するかどうか */
- (void) setComposingMask : (UInt32) mask
				  compose : (BOOL  ) flag
{
	_CCFlags.mask = mask;
	_CCFlags.compose = flag ? 1 : 0;
}

- (void) setComposingTargetIndex: (unsigned int) index
{
	bs_targetIndex = index;
}

- (BOOL) shouldComposeMsgsOnlyForWhichContainsAnchorForTheIdx
{
	return (bs_targetIndex != NSNotFound);
}

#pragma mark Instance Methods

static BOOL messageIsLocalAboned_(CMRThreadMessage *aMessage) 
{
	return ([aMessage isLocalAboned] || ([aMessage isSpam] && kSpamFilterLocalAbonedBehavior == [CMRPref spamFilterBehavior]));
}

- (void) composeThreadMessage : (CMRThreadMessage *) aMessage
{
	NSMutableAttributedString	*ms = [self contentsStorage];
	NSRange						mRange_;
	UInt32						flags_ = [aMessage flags];
	
	if (nil == aMessage)
		return;

	if ((0 == _CCFlags.compose) != (0 == (_CCFlags.mask & flags_))){
		return;
	}
	
	if (flags_ & _mask) {
		UInt32		newFlags_;
		
		newFlags_ = (flags_ & (~_mask));
		[aMessage setFlags : newFlags_];
	}
	
	BOOL	isSpam_ = [aMessage isSpam];
	// 「迷惑レス」：表示しない場合
	if (isSpam_ && kSpamFilterInvisibleAbonedBehavior == [CMRPref spamFilterBehavior])
		return;
	
	mRange_.location = [ms length];
	[super composeThreadMessage : aMessage];
	mRange_.length = [ms length] - mRange_.location;

	if ([self shouldComposeMsgsOnlyForWhichContainsAnchorForTheIdx]) {
		if (NO == [self attrString: [ms attributedSubstringFromRange: mRange_] containsAnchorForMsgIndex: bs_targetIndex]) {
			[ms deleteCharactersInRange: mRange_];
			[aMessage setFlags: flags_];
			return;
		}
	}
	
	if (isSpam_ && (mRange_.length != 0)) {
		//「迷惑レス」は色を変更する
		[ms addAttribute : NSForegroundColorAttributeName
				   value : [CMRPref messageFilteredColor]
				   range : mRange_];
	}
	
	// 属性を元に戻す
	[aMessage setFlags : flags_];
}

- (void) composeIndex : (CMRThreadMessage *) aMessage
{
	NSString					*indexFormat;
	NSMutableAttributedString	*ms = [self contentsStorage];
	NSMutableString				*label_;
	NSRange						mRange_;
	
	indexFormat = SGTemplateResource(kThreadIndexFormatKey);
	if (nil == indexFormat)
		indexFormat = @"%u";
	
	label_ = SGTemporaryString();
	[label_ appendFormat : indexFormat, [aMessage index] +1];
	
	mRange_.location = [ms length];
	[ms appendString:label_ withAttributes:[ATTR_TEMPLATE attributesForText]];
	mRange_.length = [ms length] - mRange_.location;
	
	[ms addAttribute : CMRMessageIndexAttributeName
			   value : [NSNumber numberWithUnsignedInt : [aMessage index]]
			   range : mRange_];
	
	/* 現バージョンではブックマークはフォントを変更するのみ */
	if ([aMessage hasBookmark]) {
		[ms applyFontTraits : (NSBoldFontMask|NSItalicFontMask)
					  range : mRange_];
	}
/*
2004-01-22 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
レス番号にリンクをはると、ポップアップしたレスの内容が大きすぎる場合、
番号が隠れてしまい、メニューを表示できなくなる。
*/
	
	appendWhiteSpaceSeparator(ms);
}

- (void) composeName : (CMRThreadMessage *) aMessage
{
	NSString					*name = [aMessage name];
	NSMutableAttributedString	*ms;
	
	if (nil == _nameCache)
		_nameCache = [[NSMutableAttributedString alloc] init];
	
	if (messageIsLocalAboned_(aMessage)) {
		name = LOCALIZED_STR(@"Abone");
	}
	
	ms = [self contentsStorage];
	appendFiledTitle(ms, FIELD_NAME);
	
	if (name != nil && NO == [name isEmpty]) {
		if (NO == [[_nameCache string] isEqualToString : name]) {
			[_nameCache deleteAll];
			[self convertName:name with:_nameCache];
		}
		
		[ms appendAttributedString : _nameCache];
	}

	appendWhiteSpaceSeparator(ms);
}
- (void) composeMail : (CMRThreadMessage *) aMessage
{
	id		mail = [aMessage mail];
	
	if (messageIsLocalAboned_(aMessage))
		return;
	
	// assume entity reference length > 4,
	// because in the most case, mail is "sage" or empty string
	if (mail != nil && [(NSString*)mail length] > 4) {
		NSMutableString		*tmp = SGTemporaryString();
		
		[tmp setString : mail];
		[CMXTextParser replaceEntityReferenceWithString : tmp];
		mail = tmp;
	}
	
	[self appendMailAttachmentWithAddress : mail];
	[self appendMailAddressWithAddress : mail];

	appendWhiteSpaceSeparator([self contentsStorage]);
}

static void simpleAppendFieldItem(NSMutableAttributedString *ms, NSString *title, NSString *item)
{
	if (nil == item || 0 == [item length]) return;
	
	appendFiledTitle(ms, title);
	[ms appendString:item withAttributes:[ATTR_TEMPLATE attributesForText]];

	appendWhiteSpaceSeparator(ms);
}

- (void) composeDate : (CMRThreadMessage *) aMessage
{
	NSMutableString		*tmp;
	NSString			*dateRep;
	NSString		*anchorStr = nil;

	if (messageIsLocalAboned_(aMessage))
		return;
	
	// message date is nil, if message was aboned.
	if (nil == [aMessage date]) return;
	
	tmp = SGTemporaryString();
	dateRep = [aMessage dateRepresentation];

	if (dateRep) {
		NSRange	anchor_ = [dateRep rangeOfString : @"<a href=" options : (NSCaseInsensitiveSearch|NSLiteralSearch)];
		if (anchor_.length != 0) {
			NSRange anchorEnd_;
			anchorEnd_ = [dateRep rangeOfString : @"</a>" options: (NSCaseInsensitiveSearch|NSLiteralSearch|NSBackwardsSearch)];
			
			if (anchorEnd_.length != 0) {
				anchor_.length = anchorEnd_.location - anchor_.location + anchorEnd_.length;
	
				anchorStr = [dateRep substringWithRange : anchor_];

				[tmp setString : [dateRep substringToIndex : anchor_.location]];
			} else {
				[tmp setString : dateRep];
			}
		} else {
			[tmp setString : dateRep];
		}
	} else {
		[tmp setString: dateStringFromObject([aMessage date], [aMessage datePrefix])];
	}

	simpleAppendFieldItem([self contentsStorage], FIELD_DATE, tmp);

	if (anchorStr) {
		NSDictionary *attr_ = nil;
		NSData *data_ = [anchorStr dataUsingEncoding : NSUnicodeStringEncoding];

		NSMutableAttributedString *result_ = [[NSMutableAttributedString alloc] initWithHTML: data_ documentAttributes: &attr_];
		if(!result_) return;

		NSRange	anchorRange = NSMakeRange(0, [result_ length]);
		NSMutableAttributedString	*contentsStorage_ = [self contentsStorage];

		[result_ removeAttribute : NSUnderlineStyleAttributeName range : anchorRange];
		[result_ addAttributes : [ATTR_TEMPLATE attributesForText] range : anchorRange];

		[contentsStorage_ insertAttributedString:result_ atIndex: ([contentsStorage_ length] -1)];
		[result_ release];
	}
}

- (void) composeID : (CMRThreadMessage *) aMessage
{
	if (messageIsLocalAboned_(aMessage))
		return;

	NSString	*idStr = [aMessage IDString];
	if (nil == idStr || 0 == [idStr length])
		return;

	NSMutableAttributedString	*ms = [self contentsStorage];
	NSRange						idRange;
	
	appendFiledTitle(ms, FIELD_ID);
	
	idRange.location = [ms length];
	[ms appendString : idStr withAttributes : [ATTR_TEMPLATE attributesForText]];
	
	if (![idStr hasPrefix : @"???"]) {
		idRange.length = [ms length] - idRange.location;
		
		[ms addAttribute : BSMessageIDAttributeName
				   value : idStr
				   range : idRange];
	}
	appendWhiteSpaceSeparator(ms);
}

- (void) composeBeProfile : (CMRThreadMessage *) aMessage
{
	NSMutableAttributedString	*mas_;
	NSArray						*tmpAry_ = nil;
	NSString					*beStr_;
	NSMutableAttributedString	*format_;
	int							count_;
	BOOL						makeLink = YES;

	if (messageIsLocalAboned_(aMessage))
		return;
	
	tmpAry_ = [aMessage beProfile];
	if (tmpAry_ == nil) return;

	count_ = [tmpAry_ count];
	if (count_ == 0 || count_ > 2) return;

	if (count_ == 1) {
		// kabunushi yutai
		beStr_ = [tmpAry_ objectAtIndex: 0];
		makeLink = NO;
	} else {
		NSMutableString	*beRep_;
		beRep_ = [[tmpAry_ objectAtIndex : 1] mutableCopy];

		NSRange	fontTag = [beRep_ rangeOfString : @"<font color=" options : (NSCaseInsensitiveSearch|NSLiteralSearch)];
		if (fontTag.length != 0) {
			NSRange fontTagEnd;
			fontTagEnd = [beRep_ rangeOfString : @"</font>" options: (NSCaseInsensitiveSearch|NSLiteralSearch|NSBackwardsSearch)];
			
			if (fontTagEnd.length != 0) {
				fontTag.length = fontTagEnd.location - fontTag.location + fontTagEnd.length;
				[beRep_ replaceCharactersInRange: fontTag withString: LOCALIZED_STR(@"BE_Solitaire")];
			}
		}

		beStr_ = [NSString stringWithFormat: @"?%@", beRep_];
		[beRep_ release];
	}

	format_   = SGTemporaryAttributedString();

	[[format_ mutableString] appendString : beStr_];
	[format_ addAttributes : [ATTR_TEMPLATE attributesForBeProfileLink]
					 range : [format_ range]];

	if (makeLink) {
		[format_ addAttribute : NSLinkAttributeName
						value : CMRLocalBeProfileLinkWithString([tmpAry_ objectAtIndex : 0])
						range : [format_ range]];
	}

	mas_ = [self contentsStorage];

	[mas_ appendAttributedString : format_];

	appendWhiteSpaceSeparator(mas_);
}

- (void) composeHost : (CMRThreadMessage *) aMessage
{
	static NSString						*format_;
	static NSMutableAttributedString	*template_;
	auto   NSMutableAttributedString	*ms;
	auto   NSString						*host = [aMessage host];
	
	UTILRequireCondition(host && [host length], ErrComposeHost);
	UTILRequireCondition(
		NO == messageIsLocalAboned_(aMessage), 
		ErrComposeHost);
	
	format_   = SGTemplateResource(kThreadHostFormatKey);

	ms = [self contentsStorage];
	template_ = SGTemporaryAttributedString();
	[[template_ mutableString] appendFormat:format_, host];
	[template_ addAttributes : [ATTR_TEMPLATE attributesForHost]
					   range : NSMakeRange(0,[[template_ mutableString] length])];

	[ms appendAttributedString : template_];

ErrComposeHost:
	return;
}

- (void) composeMessage : (CMRThreadMessage *) aMessage
{
	NSMutableAttributedString	*ms;
	NSMutableAttributedString	*tmp;
	id							source;
	NSRange						mRange_;
	BOOL						isLocalAboned = messageIsLocalAboned_(aMessage); 
	
	ms = [self contentsStorage];
	tmp = SGTemporaryAttributedString();
	
	// 「ローカルあぼーん」
	if (isLocalAboned) {
		source = [aMessage isSpam]
			? LOCALIZED_STR(@"SpamLocalAbone")
			: LOCALIZED_STR(@"LocalAbone");
	} else {
		source = [aMessage messageSource];
	}
	
	mRange_.location = [tmp length];
	[self convertMessage:source with:tmp];
	if (isLocalAboned) {
		NSRange		linkRange_;
		
		// 「ローカルあぼーん」では内容をポップアップするリンクを追加
		source = LOCALIZED_STR(@"ShowLocalAbone");
		
		linkRange_.location = [tmp length];
		[[tmp mutableString] appendString : source];
		linkRange_.length = [tmp length] - linkRange_.location;

		// 2005-09-08 リンク書式の付与は TextView に任せ、ここでは書式をセットしない		

		[tmp addAttribute : NSLinkAttributeName
				    value : CMRLocalResLinkWithIndex([aMessage index])
				    range : linkRange_];
	}
	mRange_.length = [tmp length] - mRange_.location;
	if ([aMessage isAsciiArt]) {
		// AA
		[tmp addAttribute : NSFontAttributeName
				    value : [CMRPref messageAlternateFont]
				    range : mRange_];
	}
	
	// 
	// 順番通りに書式つき文字列を挿入すると、つづく文字列にまで
	// 本文の書式が適用されてしまうため、まず、改行を挿入し、
	// そのあとで、本文の書式つき文字列を挿入する。
	source = [ms mutableString];
	[source appendString : DEFAULT_NEWLINE_CHARACTER];
	[source appendString : DEFAULT_NEWLINE_CHARACTER];
	[ms insertAttributedString : tmp
					   atIndex : ([ms length] - 1)];
	
	[tmp deleteAll];
}

- (id) getMessages
{
	return [self contentsStorage];
}

- (BOOL) attrString: (NSAttributedString *) substring containsAnchorForMsgIndex: (unsigned int) index
{
	NSString *compareString = [NSString stringWithFormat: @"%@:%u", CMRAttributeInnerLinkScheme, index+1];
//	NSLog(@"attrString:containsAnchorForMsgIndex: (step 1)\n%@", compareString);

    NSRange     range;
    int         i;
	int			cnt = [substring length];
    NSRange rangeLimit=NSMakeRange(0, cnt);

    for(i = 0; i < cnt; i += range.length){
        id aURLString=[substring attribute: NSLinkAttributeName 
                        atIndex:i longestEffectiveRange:&range inRange:rangeLimit];

        if(range.length<=0) break;

        if(aURLString && [aURLString isKindOfClass:[NSString class]]) {
            if([(NSString*)aURLString length]>0 && [(NSString *)aURLString hasPrefix:CMRAttributeInnerLinkScheme]) {
                NSString *convertedString = [(NSString *)aURLString precomposedStringWithCompatibilityMapping];
//				NSLog(@"attrString:containsAnchorForMsgIndex: (step 2)\n%@", convertedString);

				if ([convertedString isEqualToString: compareString]) {
//					NSLog(@"attrString:containsAnchorForMsgIndex: (step 3)\nYES RETURN");
					return YES;
				}
            }
        }
    }
	return NO;
}
@end

#pragma mark -

@implementation CMRAttributedMessageComposer(Mail)
- (void) appendMailAttachmentWithAddress : (NSString *) address
{
	NSAttributedString	*attachment_;

	if (NO == [CMRPref mailAttachmentShown] || nil == address)
		return;
	
	attachment_ = [ATTR_TEMPLATE mailAttachmentStringWithMail : address];
	if (nil == attachment_ || 0 == [attachment_ length]) return;
	
	[[self contentsStorage] appendAttributedString : attachment_];
}
- (void) appendMailAddressWithAddress : (NSString *) address
{
	NSMutableAttributedString	*ms;
	
	if (NO == [CMRPref mailAddressShown] || nil == address)
		return;
	
	ms = [self contentsStorage];

	appendWhiteSpaceSeparator(ms);

	appendFiledTitle(ms, FIELD_MAIL);
	[ms appendString:address withAttributes:[ATTR_TEMPLATE attributesForText]];
}
@end

#pragma mark -

static NSString *dateStringFromObject(id theDate, NSString *prefix)
{
    static CFDateFormatterRef   formatterRef = NULL;

	if ([theDate isKindOfClass : [NSString class]])
		return theDate;
	
	if ([theDate isKindOfClass: [NSDate class]]) {
        NSLog(@"NSDate -> NSString");
        CFStringRef			dayStrRef;

		if (formatterRef == NULL) {
			CFLocaleRef	localeRef = CFLocaleCopyCurrent();
			formatterRef = CFDateFormatterCreate(kCFAllocatorDefault, localeRef, kCFDateFormatterShortStyle, kCFDateFormatterMediumStyle);
			CFRelease(localeRef);
		}

		dayStrRef = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, formatterRef, (CFDateRef)theDate);

		if (dayStrRef != NULL) {
			NSString *dayStr_ = [NSString stringWithString: (NSString *)dayStrRef];
			CFRelease(dayStrRef);
			if (prefix == nil) {
				return dayStr_;
			} else {
				return [NSString stringWithFormat: @"%@ %@", prefix, dayStr_];
			}
		}
    }
	return @"";
}

static void appendWhiteSpaceSeparator(NSMutableAttributedString *buffer)
{
	if (wSS == nil)
		wSS = [[NSAttributedString alloc] initWithString : @" "];

	[buffer appendAttributedString : wSS];
}

static void appendFiledTitle(NSMutableAttributedString *buffer, NSString *title)
{
	static NSString *fieldSeparator = nil;
	static NSMutableString	*tmp = nil;
	
	if (fieldSeparator == nil) {
		fieldSeparator = SGTemplateResource(kThreadFieldSeparaterKey);
		if (fieldSeparator == nil) {
			fieldSeparator = @": ";
		}
	}
	
	if (tmp == nil)
		tmp = [[NSMutableString alloc] init];
	
	[tmp setString : title];
	[tmp appendString: fieldSeparator];
	
	[buffer appendString:tmp withAttributes:[ATTR_TEMPLATE attributesForItemName]];
}
