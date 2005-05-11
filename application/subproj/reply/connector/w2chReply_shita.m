/**
  * $Id: w2chReply_shita.m,v 1.1 2005/05/11 17:51:12 tsawada2 Exp $
  * 
  * w2chReply_shita.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "w2chReply_shita.h"
#import "SG2chConnector_p.h"



@implementation w2chReply_shita(RequestHeaders)
- (NSDictionary *) requestHeaders
{
	UTILAssertNotNil([self requestURL]);
	return [NSDictionary dictionaryWithObjectsAndKeys : 
					[[self requestURL] host],		HTTP_HOST_KEY,
					@"close",						HTTP_CONNECTION_KEY,
					@"text/html, text/plain, */*",	HTTP_ACCEPT_KEY,
					@"shift_jis, x-euc-jp",			HTTP_ACCEPT_CHARSET_KEY,
					[[self class] userAgent],		HTTP_USER_AGENT_KEY,
					@"NAME=; EMAIL=; Path=/",		HTTP_COOKIE_HEADER_KEY,
					nil];
}
- (BOOL) isRequestHeadersComplete : (NSDictionary *) headers
{
	UTILAssertNotNil([headers objectForKey : HTTP_REFERER_KEY]);
	
	return YES;
}
@end



@implementation w2chReply_shita
+ (BOOL) canInitWithURL : (NSURL *) anURL
{
	NSString	*filename_;
	const char	*host_;
	
	if(nil == anURL) return NO;	
	filename_ = [[anURL absoluteString] lastPathComponent];
	host_ = [[anURL host] UTF8String];
	if(nil == filename_ || NULL == host_) return NO;
	
	if(is_shitaraba(host_))
		return [filename_ isEqualToString : @"bbs.cgi"];
	if(is_jbbs_shita(host_))
		return [filename_ isEqualToString : @"write.cgi"];
	
	
	return NO;
}

// zero-terminated list
+ (const CFStringEncoding *) availableURLEncodings
{
	static const CFStringEncoding encodings_[] = {
					kCFStringEncodingEUC_JP,
					0
				};
	
	return encodings_;
}
@end

