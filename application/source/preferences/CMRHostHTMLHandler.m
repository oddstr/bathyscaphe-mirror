/**
  * $Id: CMRHostHTMLHandler.m,v 1.2.4.1 2006/05/24 19:50:29 tsawada2 Exp $
  * 
  * CMRHostHTMLHandler.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRHostHandler_p.h"
#import "CMXTextParser.h"



// for debugging only
#define UTIL_DEBUGGING    0
#import "UTILDebugging.h"



/*
�܂�BBS - HTML���X�E�T���v��
--------------------------------
<dt>98 ���O�F<font color="#008800"><b> �Ȃ܂疼���� </b></font> ���e���F 2003/08/04(��) 18:41:07 ID:EyIz7zyM <font size=1>[ gemini.komazawa-u.ac.jp
 ]</font><br><dd> ��[�A�N����ȁB<br>�ǂ�Ȋ����łł邩�i�����߂��Ƃ��L�q�����Ƃ��j���炢�Ȃ�<br>�[�~���ɂ��������Ă�搶�Ȃ炽�����񂢂邾�낤�B  <br><br>
*/
#define HTML_TAG(xpp, tagName, theType)	(theType == [xpp eventType] && [[xpp name] isEqualToString : tagName])



// properties
#define GET_PROPERTY(key)	[[self properties] objectForKey : key]

#define kMailtoKey		@"HTML - mailto:"
#define kNamePrefixKey	@"HTML - NamePrefix"
#define kDatePrefixKey	@"HTML - DatePrefix"
#define kAllowedTag		@"HTML - AllowedTag"



@implementation CMRHostHTMLHandler : CMRHostHandler
// return title
- (NSString *) scanHead : (id<XmlPullParser>) xpp
		           with : (id               ) thread
{
	int			type_;
	NSString	*title_ = nil;
	
	while ((type_ = [xpp next]) != XMLPULL_END_DOCUMENT) {
		if (HTML_TAG(xpp, @"head", XMLPULL_END_TAG)) {
			return title_;
		
		}else if (HTML_TAG(xpp, @"title", XMLPULL_START_TAG)) {
			[xpp nextText];
			title_ = [[[xpp text] copy] autorelease];
		}
	}
	return nil;
}

- (NSString *) readMail : (id<XmlPullParser>) xpp
{
	NSString	*v;
	NSString	*prefix_;
	
	v = [xpp attributeForName : @"href"];
	if (nil == v) return nil;
	
	prefix_ = GET_PROPERTY(kMailtoKey);
	if ([v length] > [prefix_ length] && [v hasPrefix : prefix_])
		return [v substringFromIndex:[prefix_ length]];
	
	return nil;
}

- (unsigned) indexWithFieldsString : (NSString *) aString
{
	const char	*s;
	char		*endp_;
	unsigned	index_;
	
	s = [aString UTF8String];
	if (NULL == s) return NSNotFound;
	
	index_ = strtoul(s, &endp_, 10);
	if (s == endp_) return NSNotFound;
	
	return index_;
}

/*
str = @"���q  <><> 2003/09/01(��) 20:00:12 ID:Bc0TyiNc [ ntt2-ppp758.tokyo.sannet.ne.jp ]"
*/
static void formatHostField(NSMutableString *str)
{
	char		c;
	NSRange		hostPrefixRange_;
	
	if (nil == str || [str isEmpty]) return;
	
	c = ([str characterAtIndex : ([str length] -1)] & 0x7f);
	if (c != ']') return;
	
	[str deleteCharactersInRange : NSMakeRange([str length] -1, 1)];
	hostPrefixRange_ = [str rangeOfString:@"[" options:(NSBackwardsSearch | NSLiteralSearch)];
	if (NSNotFound == hostPrefixRange_.location)
		return;
	
	[str replaceCharactersInRange:hostPrefixRange_ withString:@"HOST:"];
	
	[str stripAtEnd];
}
- (void) scanFields : (id<XmlPullParser>) xpp
		       with : (id               ) thread
			  index : (unsigned int    *) indexp
{
	int			type_;
	NSString	*mail_ = @"";
	id			tmp;
	
	tmp = SGTemporaryString();
	while ((type_ = [xpp next]) != XMLPULL_END_DOCUMENT) {
		NSString	*v;
		
		if (HTML_TAG(xpp, @"a", XMLPULL_START_TAG))
			mail_ = [self readMail:xpp];

		if (HTML_TAG(xpp, @"dd", XMLPULL_START_TAG)) {
			// dat�`���ɕϊ�
			unsigned	index_;
			NSRange		found;
			
			index_ = [self indexWithFieldsString : tmp];
			// ���X�ԍ����A�����Ă��邩�`�F�b�N����
			if (indexp != NULL && index_ != NSNotFound) {
				if (*indexp != NSNotFound && *indexp +1 != index_) {
					unsigned	i;
					
					// �K���ɍs���l�߂�
					NSLog(@"Invisible Abone Occurred(%u)", index_);
					for (i = *indexp +1; i < index_; i++)
						[thread appendString : @"<><><><>\n"];
				}
			}
			if (indexp != NULL) *indexp = index_;
			
			v = GET_PROPERTY(kNamePrefixKey);
			found = [tmp rangeOfString : v];
			if (0 == found.length) break;
			
			found.length += found.location;
			found.location = 0;
			
			[tmp deleteCharactersInRange : found];
			
			v = GET_PROPERTY(kDatePrefixKey);
			found = [tmp rangeOfString : v];
			if (0 == found.length) break;
			
			[tmp deleteCharactersInRange : found];
			[tmp insertString:@"<>" atIndex:found.location];
			// 2005-01-15 ������΂łȂ��� mail_ == nil �ɂȂ��Ă��܂��ꍇ������悤���B�Ȃ��H
			// �Ƃ肠���������ŋl�܂��Đ�֐i�߂Ȃ��ƍ���̂ŏꓖ����I�Ώ��B
			if (mail_ != nil) [tmp insertString:mail_ atIndex:found.location];
			[tmp insertString:@"<>" atIndex:found.location];
			
			[tmp replaceCharacters:@"\n" toString:@""];
			[tmp strip];

/*
���̎��_�ŁF
tmp = @"���q  <><> 2003/09/01(��) 20:00:12 ID:Bc0TyiNc [ ntt2-ppp758.tokyo.sannet.ne.jp ]"
*/
			// �z�X�g�𐮌`
			formatHostField(tmp);
			[tmp appendString : @"<>"];
			
			[thread appendString : tmp];
			
			break;
		}
		
		v = [xpp text];
		if (v != nil && XMLPULL_TEXT == [xpp eventType])
			[tmp appendString : v];
		
	}
	
}
- (BOOL) isMessageStopTag : (id<XmlPullParser>) xpp
{
	if (XMLPULL_START_TAG == [xpp eventType]) {
		static const char *allowedTags_ = NULL;
		static size_t     allowedTagsLen_;
		
		auto   const char *nm = [[xpp name] UTF8String];
		auto   const char *p  = NULL;
		
		if (NULL == nm) return NO;
		
		if (NULL == allowedTags_) {
			allowedTags_ = [GET_PROPERTY(kAllowedTag) UTF8String];
			UTILAssertNotNil(allowedTags_);
			allowedTags_ = nsr_strdup(allowedTags_);
			allowedTagsLen_ = strlen(allowedTags_);
		}
		
		p = (const char*)nsr_strncasestr(allowedTags_, nm, allowedTagsLen_);
		if (NULL == p) {
			UTIL_DEBUG_WRITE2(@"Allowed:(%s) name:(%s)", allowedTags_, nm);
			return YES;
		}
		
		return (*(p + strlen(nm)) != '<');
	}
	return NO;
}
- (void) scanMessage : (id<XmlPullParser>) xpp
		        with : (id               ) thread
{
	int			type_;
	id			tmp;
	
	UTIL_DEBUG_METHOD;
	tmp = SGTemporaryString();
	while ((type_ = [xpp next]) != XMLPULL_END_DOCUMENT) {
		NSString	*v;
		
		if (HTML_TAG(xpp, @"br", XMLPULL_START_TAG))
			[tmp appendString : @"<br>"];
		
		if ([self isMessageStopTag : xpp]) {
			NSRange		found;
			
			[tmp replaceCharacters:@"\n" toString:@""];
			
			found = [tmp rangeOfString:@"<br><br>" options:NSBackwardsSearch];
			if (found.length != 0)
				[tmp deleteCharactersInRange : found];
			
			[tmp appendString : @"<>"];
			[tmp appendString : @"\n"];
			
			UTIL_DEBUG_WRITE1(@"message:\n%@", tmp);
			[thread appendString : tmp];
			
			break;
		}
		
		v = [xpp text];
		if (v != nil && XMLPULL_TEXT == [xpp eventType]) {
			UTIL_DEBUG_WRITE1(@"text=%@", v);
			[tmp appendString : v];
		}
	}
}

- (void) scanBody : (id<XmlPullParser>) xpp
		     with : (id               ) thread
		    count : (unsigned         ) loadedCount
{
	int			type_;
	unsigned	index_ = loadedCount;
	type_ = [xpp next];
	while (1) {
		if (XMLPULL_END_DOCUMENT == type_) break;
		//if (HTML_TAG(xpp, @"body", XMLPULL_END_TAG))
		//	break;
		if (HTML_TAG(xpp, @"dt", XMLPULL_START_TAG)) {
			[self scanFields:xpp with:thread index:&index_];
			continue;
		}
		if (HTML_TAG(xpp, @"dd", XMLPULL_START_TAG)) {
			[self scanMessage:xpp with:thread];
			continue;
		}
		
		type_ = [xpp next];
	}
}

- (id) parseHTML : (NSString *) inputSource
			with : (id        ) thread
		   count : (unsigned  ) loadedCount
{
	id<XmlPullParser>		xpp_;
	
	xpp_ = [[[SGXmlPullParser alloc] initHTMLParser] autorelease];
	
	[xpp_ setInputSource : inputSource];
	// ����dat�ɕϊ�����̂�
	// �G���e�B�e�B�͉������Ȃ�
	[xpp_ setFeature:YES forKey:SGXmlPullParserDisableEntityResolving];
NS_DURING
	int			type_;
	NSString	*title_ = nil;
	
	type_ = [xpp_ nextName : @"html" 
					  type : XMLPULL_START_TAG
				   options : NSCaseInsensitiveSearch];
	while ((type_ = [xpp_ next]) != XMLPULL_END_DOCUMENT) {
		if (HTML_TAG(xpp_, @"head", XMLPULL_START_TAG))
			title_ = [self scanHead:xpp_ with:thread];
		if (HTML_TAG(xpp_, @"body", XMLPULL_START_TAG))
			[self scanBody:xpp_ with:thread count:loadedCount];
	}
	
	if (title_ != nil) {
		// �^�C�g����}��
		NSRange		found;
		
		found = [thread rangeOfString : @"\n"];
		if (found.length != 0) {
			[thread insertString:title_ atIndex:found.location];
		}
	}
	
NS_HANDLER
	UTILCatchException(XmlPullParserException) {
		NSLog(@"***XMLPULL_EXCEPTION***%@", localException);
		
	} else {
		[localException raise];
	}
NS_ENDHANDLER
	
	return thread;
}
@end
