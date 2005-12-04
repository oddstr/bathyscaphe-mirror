//:CMRAttributedMessageComposer.m
/**
  *
  * @author Takanori Ishikawa, tsawada2
  * @version 1.0.1 (05/09/09  22:36:00 PM)
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
#define kThreadDateFormatKey		@"Thread - DateDescription"


//static NSAttributedString *whiteSpaceSeparater(void);
static void appendDateString(NSMutableString *buffer, id theDate, NSString *prefix, NSDictionary *localeDictionary);
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
	}
	return self;
}
- (void) dealloc
{
	[_contentsStorage release];
	[_nameCache release];
	[_localeDict release];
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

- (NSDictionary *) localeDict
{
	if (nil == _localeDict) {
		NSUserDefaults	*defaults_ = [NSUserDefaults standardUserDefaults];
		NSArray		*tmp_ = [defaults_ arrayForKey : NSShortWeekDayNameArray];
		NSArray		*tmp2_ = [defaults_ arrayForKey : NSWeekDayNameArray];
		_localeDict = [[NSDictionary alloc] initWithObjectsAndKeys : 
							tmp_,  NSShortWeekDayNameArray,
							tmp2_, NSWeekDayNameArray,
							NULL];
	}
	return _localeDict;
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
	
	if ((0 == _CCFlags.compose) != (0 == (_CCFlags.mask & flags_)))
		return;
	
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
	
	//[ms appendAttributedString : whiteSpaceSeparater()];
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
	//[ms appendAttributedString : whiteSpaceSeparater()];
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
	//[[self contentsStorage] appendAttributedString : whiteSpaceSeparater()];
	appendWhiteSpaceSeparator([self contentsStorage]);
}

static void simpleAppendFieldItem(NSMutableAttributedString *ms, NSString *title, NSString *item)
{
	if (nil == item || 0 == [item length]) return;
	
	appendFiledTitle(ms, title);
	[ms appendString:item withAttributes:[ATTR_TEMPLATE attributesForText]];
	//[ms appendAttributedString : whiteSpaceSeparater()];
	appendWhiteSpaceSeparator(ms);
}

- (void) composeDate : (CMRThreadMessage *) aMessage
{
	NSMutableString		*tmp;
	
	if (messageIsLocalAboned_(aMessage))
		return;
	
	// message date is nil, if message was aboned.
	if (nil == [aMessage date]) return;
	
	tmp = SGTemporaryString();
	
	appendDateString(tmp, [aMessage date], [aMessage datePrefix], [self localeDict]);
	simpleAppendFieldItem([self contentsStorage], FIELD_DATE, tmp);
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
	idRange.length = [ms length] - idRange.location;
	
	[ms addAttribute : BSMessageIDAttributeName
			   value : idStr
			   range : idRange];

	//[ms appendAttributedString : whiteSpaceSeparater()];
	appendWhiteSpaceSeparator(ms);
}

- (void) composeBeProfile : (CMRThreadMessage *) aMessage
{
	NSMutableAttributedString	*mas_;
	NSArray						*tmpAry_ = nil;
	NSString					*beRep_;
	NSString					*beStr_;
	NSMutableAttributedString	*format_;
		
	if (messageIsLocalAboned_(aMessage))
		return;
	
	tmpAry_ = [aMessage beProfile];
	if (tmpAry_ == nil || [tmpAry_ count] < 2) return;
	
	beRep_ = [tmpAry_ objectAtIndex : 1];

	if ([[NSScanner scannerWithString : beRep_] scanCharactersFromSet : [NSCharacterSet decimalDigitCharacterSet]
														   intoString : nil])
	{
		beStr_ = [NSString stringWithFormat : @"Lv.%@", beRep_];
	} else {
		beStr_ = [NSString stringWithFormat : @"?%@", beRep_];
	}

	format_   = SGTemporaryAttributedString();

	[[format_ mutableString] appendString : beStr_];
	[format_ addAttributes : [ATTR_TEMPLATE attributesForBeProfileLink]
					 range : [format_ range]];
	[format_ addAttribute : NSLinkAttributeName
					value : CMRLocalBeProfileLinkWithString([tmpAry_ objectAtIndex : 0])
					range : [format_ range]];

	mas_ = [self contentsStorage];

	[mas_ appendAttributedString : format_];
	//[mas_ appendAttributedString : whiteSpaceSeparater()];
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
	//[ms appendAttributedString : whiteSpaceSeparater()];
	appendWhiteSpaceSeparator(ms);

	appendFiledTitle(ms, FIELD_MAIL);
	[ms appendString:address withAttributes:[ATTR_TEMPLATE attributesForText]];
}
@end

#pragma mark -

static void appendDateString(NSMutableString *buffer, id theDate, NSString *prefix, NSDictionary *localeDictionary)
{
	NSCalendarDate		*cdate_;
	
	if (nil == theDate)
		return;
	
	if ([theDate isKindOfClass : [NSCalendarDate class]]) {
		// NSCalendarDate は期待どおりのフォーマットで生成しているはず
		
		// 2005-03-22 tsawada2<ben-sawa@td5.so-net.ne.jp>
		// ビルド時に警告が出るが、NSCalenderDate であることが保証されているので何も問題ない
		[buffer setString : [theDate descriptionWithCalendarFormat : SGTemplateResource(kThreadDateFormatKey)
															locale : localeDictionary]];

		if (prefix != nil) {
			//NSLog(@"appending prefix...");
			[buffer insertString : @" " atIndex : 0];
			[buffer insertString : prefix atIndex : 0];
		}
		return;
	}
	
	if ([theDate isKindOfClass : [NSString class]]) {
		[buffer setString : theDate];
		return;
	}

	cdate_ = [NSCalendarDate dateWithTimeIntervalSince1970 : 
							[theDate timeIntervalSince1970]];

	[cdate_ setCalendarFormat : SGTemplateResource(kThreadDateFormatKey)];
	[buffer setString : [cdate_ descriptionWithLocale : localeDictionary]];
	if (prefix != nil) {
		//NSLog(@"appending prefix...");
		[buffer insertString : @" " atIndex : 0];
		[buffer insertString : prefix atIndex : 0];
	}

	return;
}
/*
static NSAttributedString *whiteSpaceSeparater(void)
{
	return [[[NSAttributedString alloc] initWithString : @"  "] autorelease];
}
*/
static void appendWhiteSpaceSeparator(NSMutableAttributedString *buffer)
{
	NSAttributedString	*wSS = [[NSAttributedString alloc] initWithString : @"  "];

	[buffer appendAttributedString : wSS];
	
	[wSS release];
}

static void appendFiledTitle(NSMutableAttributedString *buffer, NSString *title)
{
	NSString *fieldSeparater;
	static NSMutableString	*tmp ;
	
	fieldSeparater = SGTemplateResource(kThreadFieldSeparaterKey);
	if (nil == fieldSeparater)
		fieldSeparater = @" : ";
	
	if (nil == tmp)
		tmp = [[NSMutableString alloc] init];
	
	[tmp setString : title];
	[tmp appendString : fieldSeparater];
	
	[buffer appendString:tmp withAttributes:[ATTR_TEMPLATE attributesForItemName]];
	//[buffer appendAttributedString : whiteSpaceSeparater()];
	appendWhiteSpaceSeparator(buffer);
}
