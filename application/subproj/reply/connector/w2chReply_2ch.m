/**
  * $Id: w2chReply_2ch.m,v 1.1.1.1 2005/05/11 17:51:12 tsawada2 Exp $
  * 
  * w2chReply_2ch.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "w2chReply_2ch.h"
#import "SG2chConnector_p.h"

#import <AppKit/NSApplication.h>




@implementation w2chReply_2ch
+ (BOOL) canInitWithURL : (NSURL *) anURL
{
	const char	*host_;
	NSString	*cgiName_;
	
	host_ = [[anURL host] UTF8String];
	cgiName_ = [[anURL absoluteString] lastPathComponent];
	if (NULL == host_) return NO;	
	if (can_readcgi(host_))
		return [cgiName_ isEqualToString : @"bbs.cgi"];
	if (is_machi(host_))
		return [cgiName_ isEqualToString : @"write.cgi"];

	return NO;
}
// zero-terminated list
+ (const CFStringEncoding *) availableURLEncodings
{
	static const CFStringEncoding encodings_[] = {
					kCFStringEncodingMacJapanese,
					kCFStringEncodingDOSJapanese,
					kCFStringEncodingShiftJIS,
					0
				};
	
	return encodings_;
}

// îFèÿÇ™ïKóvÇ»èÍçáÇ‡Ç†ÇÈ
#define w2chAuthMgr		[w2chAuthenticater defaultAuthenticater]
- (BOOL) writeForm : (NSDictionary *) forms
{
	id			params_ = forms;
	NSString	*sessionID_;
	
	sessionID_ = [w2chAuthMgr sessionID];
	if (sessionID_ != nil) {
		params_ = [[params_ mutableCopy] autorelease];
		[params_ setObject : sessionID_
				    forKey : k2chAuthSessionIDKey];
	}else if ([w2chAuthMgr recentErrorType] != w2chNoError) {
		return NO;
	}
	
	return [super writeForm : params_];
}
#undef w2chAuthMgr
@end



@implementation w2chReply_2ch(RequestHeaders)
- (NSDictionary *) requestHeaders
{
	UTILAssertNotNil([self requestURL]);
	return [NSDictionary dictionaryWithObjectsAndKeys : 
					[[self requestURL] host],		HTTP_HOST_KEY,
					@"close",						HTTP_CONNECTION_KEY,
					@"text/html, text/plain, */*",	HTTP_ACCEPT_KEY,
					@"shift_jis",					HTTP_ACCEPT_CHARSET_KEY,
					[[self class] userAgent],		HTTP_USER_AGENT_KEY,
					@"NAME=; Path=/",				HTTP_COOKIE_HEADER_KEY,
					nil];
}
- (BOOL) isRequestHeadersComplete : (NSDictionary *) headers
{
	UTILAssertNotNil([headers objectForKey : HTTP_REFERER_KEY]);
	UTILAssertNotNil([headers objectForKey : HTTP_COOKIE_HEADER_KEY]);
	
	return YES;
}
@end
