//
//  SG2chErrorHandler.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/15.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "SG2chErrorHandler.h"
#import "SG2chConnector.h"
#import "URLConnector_Prefix.h"

#define k2ch_XCommentTypeFile	@"ReplyErrorCode.plist"
#define IS_HTML(s)	((s) && [(s) rangeOfString:@"<html" options:NSCaseInsensitiveSearch].length != 0)


// Error Code Dictionary
static NSDictionary *replyErrorCodeDictionary(void);

// 2ch_X comment
static NSString *scan2ch_XCommentStringWithHTML(NSString *contents);

// Constants
static NSString *const kHTMLBreakLine = @"<br>";
static NSString *const kHTMLHorizotalLine = @"<br>----------------<br>";

@implementation SG2chErrorHandler
+ (id)handlerWithURL:(NSURL *)anURL
{
	return [[[self alloc] initWithURL:anURL] autorelease];
}

- (id)initWithURL:(NSURL *)anURL
{
	if (![[self class] canInitWithURL:anURL]) {
		[self release];
		return nil;
	}
	if (self = [super init]) {
		[self setRequestURL:anURL];
		[self setAdditionalFormsData:nil];
	}
	return self;
}

- (void)dealloc
{
	[m_requestURL release];
	[m_recentError release];
	[m_additionalFormsData release];
	[super dealloc];
}

+ (BOOL)canInitWithURL:(NSURL *)anURL
{
	const char	*host_;
	NSString	*cgiName_;
	
	host_ = [[anURL host] UTF8String];
	cgiName_ = [[anURL absoluteString] lastPathComponent];
	if (NULL == host_) return NO;
	
	if (is_2channel(host_)) {
		return [cgiName_ isEqualToString:@"bbs.cgi"];
	}
	if (is_machi(host_) || is_jbbs_livedoor(host_)) {
		return [cgiName_ isEqualToString:@"write.cgi"];
	}
/*	if (is_shitaraba(host_)) {
		return [cgiName_ isEqualToString:@"bbs.cgi"];
	}*/
	return NO;
}

- (NSError *)handleErrorWithContents:(NSString *)contents
{
	int	code = k2chUnknownErrorType;
	NSString			*title_		= @"";
	NSString			*message_	= @"";
	NSMutableDictionary	*userInfo = [NSMutableDictionary dictionaryWithCapacity:2];

	if (IS_HTML(contents)) {
		if ([self parseHTMLContents:contents intoTitle:&title_ intoMessage:&message_]) {
			title_ = [title_ stringByStriped];
			message_ = [message_ stringByStriped];
		}
		
		/*error.type*/
		code = [replyErrorCodeDictionary() integerForKey:title_ defaultValue:k2chUnknownErrorType];
		
		// タイトルからエラーを決定できない場合は
		// <!-- 2ch_X:... -->を利用する
		if (k2chUnknownErrorType == code) {
			NSString		*mark_;
			mark_ = scan2ch_XCommentStringWithHTML(contents);
			code = [replyErrorCodeDictionary() integerForKey:mark_ defaultValue:k2chUnknownErrorType];
		}
		
		// hana=mogera
		if (k2chContributionCheckErrorType == code || k2chSPIDCookieErrorType == code) {
			NSDictionary	*tmp_;
			tmp_ = [self scanAdditionalFormsWithHTML:contents];
			if (tmp_) {
				[self setAdditionalFormsData:tmp_];
			}
		}
	} else {
		const char	*host_ = [[[self requestURL] host] UTF8String];
		
		if (is_jbbs_livedoor(host_)/* || is_shitaraba(host_)*/ || is_machi(host_)) {
			/*
			2004-02-25 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
			----------------------------------------
			したらば板は何も返さないか、html 以外
			*/
			/*
			2007-08-08 tsawada2 <ben-sawa@td5.so-net.ne.jp>
			----------------------------------------
			まちBBSも何も返さない？
			*/
			code = k2chNoneErrorType;
		} else if (!contents || [contents isEmpty]) {
			// Server's response contains no data.
			code = k2chEmptyDataErrorType;
			title_ = PluginLocalizedStringFromTable(@"k2chEmptyDataErrorType", nil, nil);
			message_ = PluginLocalizedStringFromTable(@"k2chEmptyDataErrorType", nil, nil);
		}
	}
	
	if (k2chUnknownErrorType == code) {
		title_ = @"ERROR";
		message_ = contents;
		code = k2chAnyErrorType;
	}

	[userInfo setObject:title_ forKey:SG2chErrorTitleErrorKey];
	[userInfo setObject:message_ forKey:SG2chErrorMessageErrorKey];

	[self setRecentError:[NSError errorWithDomain:SG2chErrorHandlerErrorDomain code:code userInfo:userInfo]];
	return [self recentError];
}

- (NSURL *)requestURL
{
	return m_requestURL;
}

- (void)setRequestURL:(NSURL *)aRequestURL
{
	[aRequestURL retain];
	[[self requestURL] release];
	m_requestURL = aRequestURL;
}

- (NSError *)recentError
{
	return m_recentError;
}

- (void)setRecentError:(NSError *)error
{
	[error retain];
	[m_recentError release];
	m_recentError = error;
}

- (NSDictionary *)additionalFormsData
{
	return m_additionalFormsData;
}

- (void)setAdditionalFormsData:(NSDictionary *)anAdditionalFormsData
{
	[anAdditionalFormsData retain];
	[m_additionalFormsData release];
	m_additionalFormsData = anAdditionalFormsData;
}
#pragma mark HTML Utilities

#define HTML_TAG(xpp, tagName, theType)	(theType == [xpp eventType] && [[xpp name] isEqualToString : tagName])

- (id<XmlPullParser>)setUpParserWithInputSource:(NSString *)htmlContents
{
	if (!htmlContents) return nil;
	id<XmlPullParser>	xpp_ = [[[SGXmlPullParser alloc] initHTMLParser] autorelease];

	[xpp_ setInputSource:htmlContents];
	return xpp_;
}

- (BOOL)parseHTMLContents:(NSString *)htmlContents intoTitle:(NSString **)ptitle intoMessage:(NSString **)pbody
{
	id<XmlPullParser>	xpp_ = [self setUpParserWithInputSource:htmlContents];
	if (!xpp_) return NO;

	int					type_;
	NSMutableString		*body_;
	NSString			*title_ = @"";
	
NS_DURING
	body_ = [NSMutableString string];
	while ((type_ = [xpp_ next]) != XMLPULL_END_DOCUMENT) {
		if (HTML_TAG(xpp_, @"body", XMLPULL_START_TAG)) {
			while ((type_ = [xpp_ next]) != XMLPULL_END_DOCUMENT) {
				NSString	*text_;
				
				if (HTML_TAG(xpp_, @"body", XMLPULL_END_TAG))
					break;
				
				text_ = [xpp_ text];
				if (text_) [body_ appendString:text_];
				
				// 改行
				if (HTML_TAG(xpp_, @"br", XMLPULL_START_TAG))
					[body_ appendString:kHTMLBreakLine];
				
				// 区切り線
				if (HTML_TAG(xpp_, @"hr", XMLPULL_START_TAG))
					[body_ appendString:kHTMLHorizotalLine];
			}
		}

		if (HTML_TAG(xpp_, @"head", XMLPULL_START_TAG)) {
			while ((type_ = [xpp_ next]) != XMLPULL_END_DOCUMENT) {
				if (HTML_TAG(xpp_, @"head", XMLPULL_END_TAG)) {
					break;
				} else if (HTML_TAG(xpp_, @"title", XMLPULL_START_TAG)) {
					type_ = [xpp_ next];
					if (XMLPULL_TEXT == type_)
						title_ = [[[xpp_ text] copy] autorelease];
					else
						title_ = @"";
				}
			}
		}
	}
NS_HANDLER
	
	title_ = nil;
	body_ = nil;
	UTILCatchException(XmlPullParserException) {
		NSLog(@"***XMLPULL_EXCEPTION***%@", localException);
		
	} else {
		[localException raise];
	}
	
NS_ENDHANDLER

	if (!title_ && !body_)
		return NO;
	
	[body_ replaceCharacters:@"\n" toString:@""];
	[body_ replaceCharacters:kHTMLBreakLine toString:@"\n"];

	if (ptitle != NULL) *ptitle = title_;
	if (pbody != NULL) *pbody = body_;
	
	return YES;
}

- (NSDictionary *)scanAdditionalFormsWithHTML:(NSString *)htmlContents
{
	id<XmlPullParser>	xpp_ = [self setUpParserWithInputSource:htmlContents];

	int					type_;
	NSMutableDictionary *additionalFormData_ = [[[NSMutableDictionary alloc] init] autorelease];
	NSSet *defaultKeys_ = [NSSet setWithObjects:@"bbs", @"key", @"time", @"FROM", @"mail", @"MESSAGE", @"subject", nil];
	
NS_DURING
	while ((type_ = [xpp_ next]) != XMLPULL_END_DOCUMENT) {
		if (HTML_TAG(xpp_, @"form", XMLPULL_START_TAG)) {
			while ((type_ = [xpp_ next]) != XMLPULL_END_DOCUMENT) {
				if (HTML_TAG(xpp_, @"form", XMLPULL_END_TAG))
					break;
				
				if (HTML_TAG(xpp_, @"input", XMLPULL_START_TAG)) {

					if ([[xpp_ attributeForName:@"type"] isEqualToString:@"hidden"]) {
						NSString *value_ = [xpp_ attributeForName:@"name"];
						if (value_ == NULL) break;

						if (![defaultKeys_ containsObject:value_]) {
							NSString *value2_ = [xpp_ attributeForName:@"value"];
							if (value2_ == NULL) break;
							[additionalFormData_ setObject:value2_ forKey:value_];
						}
					}
				}
			}
		}
	}
NS_HANDLER
	
	UTILCatchException(XmlPullParserException) {
		NSLog(@"***XMLPULL_EXCEPTION***%@", localException);
	} else {
		[localException raise];
	}
	
NS_ENDHANDLER
	if ([additionalFormData_ count] == 0) return nil;
	return additionalFormData_;
}
@end

#pragma mark -
static NSDictionary *replyErrorCodeDictionary(void)
{
	static NSDictionary *typeTbl;
	
	if (!typeTbl) {
		NSString	*filepath_;
		
		filepath_ = [PLUGIN_BUNDLE pathForResourceWithName:k2ch_XCommentTypeFile];
		UTILCAssertNotNil(filepath_);
		typeTbl = [[NSDictionary alloc] initWithContentsOfFile:filepath_];
		UTILCAssertNotNil(typeTbl);
	}
	return typeTbl;
}

static NSString *scan2ch_XCommentStringWithHTML(NSString *contents)
{
	NSScanner		*scanner_;
	NSString		*mark_;
	
	if (!contents) return nil;
	scanner_ = [NSScanner scannerWithString:contents];
	if (!scanner_) return nil;
	
	[scanner_ scanUpToString:@"<!--" intoString:NULL];
	[scanner_ scanString:@"<!--" intoString:NULL];
	[scanner_ scanString:@"2ch_X" intoString:NULL];
	[scanner_ scanString:@":" intoString:NULL];
	
	if (![scanner_ scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&mark_]) {
		return nil;
	}
	return mark_;
}
