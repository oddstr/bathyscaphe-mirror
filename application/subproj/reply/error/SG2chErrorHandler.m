/**
  * $Id: SG2chErrorHandler.m,v 1.1.1.1.4.1 2006/09/01 13:46:54 masakih Exp $
  * 
  * SG2chErrorHandler.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
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
+ (id) handlerWithURL : (NSURL *) anURL
{
	return [[[self alloc] initWithURL : anURL] autorelease];
}
- (id) initWithURL : (NSURL *) anURL
{
	if (NO == [[self class] canInitWithURL : anURL]) {
		[self release];
		return nil;
	}
	if (self = [super init]) {
		[self setRequestURL : anURL];
		[self setAdditionalFormsData: nil];
	}
	return self;
}

- (void) dealloc
{
	[m_requestURL release];
	[m_recentErrorTitle release];
	[m_recentErrorMessage release];
	[m_additionalFormsData release];
	[super dealloc];
}

+ (BOOL) canInitWithURL : (NSURL *) anURL
{
	const char	*host_;
	NSString	*cgiName_;
	
	host_ = [[anURL host] UTF8String];
	cgiName_ = [[anURL absoluteString] lastPathComponent];
	if (NULL == host_) return NO;
	
	if (is_2channel(host_))
		return [cgiName_ isEqualToString : @"bbs.cgi"];
	
	if (is_machi(host_) || is_jbbs_shita(host_))
		return [cgiName_ isEqualToString : @"write.cgi"];
	
	if (is_shitaraba(host_))
		return [cgiName_ isEqualToString : @"bbs.cgi"];
	
	return NO;
}

- (w2chConnectMode) requestMode
{
	return kw2chConnectPOSTMessageMode;
}

- (SG2chServerError) handleErrorWithContents : (NSString  *) contents
                                       title : (NSString **) ptitle
                                     message : (NSString **) pmessage
{
	SG2chServerError	error;
	NSString			*title_		= @"";
	NSString			*message_	= @"";
	
	error = SGMake2chServerError(
				k2chUnknownErrorType,
				[self requestMode],
				0);

	if (IS_HTML(contents)) {
		if ([self parseHTMLContents: contents intoTitle: &title_ intoMessage: &message_]) {
			title_ = [title_ stringByStriped];
			message_ = [message_ stringByStriped];
		}
		
		error.type = [replyErrorCodeDictionary() integerForKey : title_
									defaultValue : k2chUnknownErrorType];
		
		// タイトルからエラーを決定できない場合は
		// <!-- 2ch_X:... -->を利用する
		if (k2chUnknownErrorType == error.type) {
			NSString		*mark_;
		
			mark_ = scan2ch_XCommentStringWithHTML(contents);
			error.type = [replyErrorCodeDictionary() 
									integerForKey : mark_
									 defaultValue : k2chUnknownErrorType];
		}
		
		// hana=mogera
		if (k2chContributionCheckErrorType == error.type || k2chSPIDCookieErrorType == error.type) {
			NSDictionary	*tmp_;
			tmp_ = [self scanAdditionalFormsWithHTML: contents];
			if (tmp_ != nil)
				[self setAdditionalFormsData : tmp_];
		}
	} else {
		const char	*host_ = [[[self requestURL] host] UTF8String];
		
		if (is_jbbs_shita(host_) || is_shitaraba(host_)) {
			/*
			2004-02-25 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
			----------------------------------------
			したらば板は何も返さないか、html 以外
			*/
			error.type = k2chNoneErrorType;
		} else if (nil == contents || [contents isEmpty]) {
	
			// Server's response contains no data.
			error.type = k2chEmptyDataErrorType;
			title_ = PluginLocalizedStringFromTable(
						@"k2chEmptyDataErrorType", nil, nil);
			message_ = PluginLocalizedStringFromTable(
						@"k2chEmptyDataErrorType", nil, nil);
		}
	}
	
	if (k2chUnknownErrorType == error.type) {
		title_ = @"ERROR";
		message_ = contents;
		error.type = k2chAnyErrorType;
	}

	if (ptitle != NULL) *ptitle = title_;
	if (pmessage != NULL) *pmessage = message_;

	[self setRecentError : error];
	[self setRecentErrorTitle : title_];
	[self setRecentErrorMessage : message_];
	return error;
}



- (NSURL *) requestURL
{
	return m_requestURL;
}
- (void) setRequestURL : (NSURL *) aRequestURL
{
	[aRequestURL retain];
	[[self requestURL] release];
	m_requestURL = aRequestURL;
}
- (SG2chServerError) recentError
{
	return m_recentError;
}
- (void) setRecentError : (SG2chServerError) aRecentError
{
	m_recentError = aRecentError;
}
- (NSString *) recentErrorTitle
{
	return m_recentErrorTitle;
}
- (void) setRecentErrorTitle : (NSString *) aRecentErrorTitle
{
	[aRecentErrorTitle retain];
	[[self recentErrorTitle] release];
	m_recentErrorTitle = aRecentErrorTitle;
}
- (NSString *) recentErrorMessage
{
	return m_recentErrorMessage;
}
- (void) setRecentErrorMessage : (NSString *) aRecentErrorMessage
{
	[aRecentErrorMessage retain];
	[[self recentErrorMessage] release];
	m_recentErrorMessage = aRecentErrorMessage;
}
- (void) setRecentErrorCode : (int) code
{
	m_recentError.error = code;
}

#pragma mark CometBlaster
- (NSDictionary *) additionalFormsData
{
	return m_additionalFormsData;
}

- (void) setAdditionalFormsData : (NSDictionary *) anAdditionalFormsData
{
	[anAdditionalFormsData retain];
	[m_additionalFormsData release];
	m_additionalFormsData = anAdditionalFormsData;
}
#pragma mark HTML Utilities

#define HTML_TAG(xpp, tagName, theType)	(theType == [xpp eventType] && [[xpp name] isEqualToString : tagName])

- (id<XmlPullParser>) setUpParserWithInputSource: (NSString *) htmlContents
{
	if (htmlContents == nil) return nil;
	id<XmlPullParser>	xpp_ = [[[SGXmlPullParser alloc] initHTMLParser] autorelease];

	[xpp_ setInputSource: htmlContents];
	return xpp_;
}

- (BOOL) parseHTMLContents: (NSString *) htmlContents
				 intoTitle: (NSString **) ptitle
			   intoMessage: (NSString **) pbody
{
	id<XmlPullParser>	xpp_ = [self setUpParserWithInputSource: htmlContents];
	if (xpp_ == nil) return NO;

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
				if (text_) [body_ appendString : text_];
				
				// 改行
				if (HTML_TAG(xpp_, @"br", XMLPULL_START_TAG))
					[body_ appendString : kHTMLBreakLine];
				
				// 区切り線
				if (HTML_TAG(xpp_, @"hr", XMLPULL_START_TAG))
					[body_ appendString : kHTMLHorizotalLine];
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

	if (nil == title_ && nil == body_)
		return NO;
	
	[body_ replaceCharacters:@"\n" toString:@""];
	[body_ replaceCharacters:kHTMLBreakLine toString:@"\n"];

	if (ptitle != NULL) *ptitle = title_;
	if (pbody != NULL) *pbody = body_;
	
	return YES;
}

- (NSDictionary *) scanAdditionalFormsWithHTML: (NSString *) htmlContents
{
	id<XmlPullParser>	xpp_ = [self setUpParserWithInputSource: htmlContents];

	int					type_;
	NSMutableDictionary *additionalFormData_ = [[[NSMutableDictionary alloc] init] autorelease];
	NSSet *defaultKeys_ = [NSSet setWithObjects: @"bbs", @"key", @"time", @"FROM", @"mail", @"MESSAGE", @"subject", nil];
	
NS_DURING
	while ((type_ = [xpp_ next]) != XMLPULL_END_DOCUMENT) {
		if (HTML_TAG(xpp_, @"form", XMLPULL_START_TAG)) {
			while ((type_ = [xpp_ next]) != XMLPULL_END_DOCUMENT) {
				if (HTML_TAG(xpp_, @"form", XMLPULL_END_TAG))
					break;
				
				if (HTML_TAG(xpp_, @"input", XMLPULL_START_TAG)) {

					if ([[xpp_ attributeForName : @"type"] isEqualToString : @"hidden"]) {
						NSString *value_ = [xpp_ attributeForName : @"name"];
						if (value_ == NULL) break;

						if (![defaultKeys_ containsObject : value_]) {
							NSString *value2_ = [xpp_ attributeForName : @"value"];
							if (value2_ == NULL) break;
							[additionalFormData_ setObject: value2_ forKey: value_];
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

SG2chServerError SGMake2chServerError(int type, 
			     					  w2chConnectMode mode, 
									  int error)
{
	SG2chServerError err_;
	
	err_.type = type;
	err_.mode = mode;
	err_.error = error;
	
	return err_;
}

static NSDictionary *replyErrorCodeDictionary(void)
{
	static NSDictionary *typeTbl;
	
	if (nil == typeTbl) {
		NSString	*filepath_;
		
		filepath_ = [PLUGIN_BUNDLE pathForResourceWithName :
										k2ch_XCommentTypeFile];
		UTILCAssertNotNil(filepath_);
		typeTbl = [[NSDictionary alloc] initWithContentsOfFile : filepath_];
		UTILCAssertNotNil(typeTbl);
	}
	return typeTbl;
}

static NSString *scan2ch_XCommentStringWithHTML(NSString *contents)
{
	NSScanner		*scanner_;
	NSString		*mark_;
	
	if (nil == contents) return nil;
	scanner_ = [NSScanner scannerWithString : contents];
	if (nil == scanner_) return nil;
	
	[scanner_ scanUpToString : @"<!--" intoString : NULL];
	[scanner_ scanString : @"<!--" intoString : NULL];
	[scanner_ scanString : @"2ch_X" intoString : NULL];
	[scanner_ scanString : @":" intoString : NULL];
	
	if (NO == [scanner_ scanCharactersFromSet : [NSCharacterSet alphanumericCharacterSet] intoString : &mark_])
		return nil;
	
	return mark_;
}
