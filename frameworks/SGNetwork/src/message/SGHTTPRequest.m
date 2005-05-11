/**
  * $Id: SGHTTPRequest.m,v 1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * SGHTTPRequest.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGHTTPRequest.h"



@implementation SGHTTPRequest
+ (id) HTTPRequestWithRequestURL : (NSURL     *) anURL
                   requestMethod : (NSString  *) method
                     HTTPVersion : (CFStringRef) version
{
	return [[[[self class] alloc] initWithRequestURL : anURL
							           requestMethod : method
							             HTTPVersion : version] autorelease];
}

/**
  * リクエスト先のURLを指定して初期化。
  * 
  * @param    anURL    リクエスト先のURL
  * @param    method   メソッド
  * @param    version  HTTPバージョン
  * @return            初期化済みのインスタンス
  */
- (id) initWithRequestURL : (NSURL     *) anURL
            requestMethod : (NSString  *) method
              HTTPVersion : (CFStringRef) version
{
	CFHTTPMessageRef request_;
	CFStringRef      method_;
	
	method_ = (CFStringRef)method;
	if(NULL == method) method_ = CFSTR("GET");
	if(NULL == version) version = kCFHTTPVersion1_1;
	
	request_ = CFHTTPMessageCreateRequest(kCFAllocatorDefault,
										  method_,
									      (CFURLRef) anURL,
										  version);
	
	if(self = [super initWithHTTPMessageRef : request_]){
		;
	}
	return self;
}

- (id) init
{
	CFHTTPMessageRef request_;
	
	request_ = CFHTTPMessageCreateEmpty(kCFAllocatorDefault,
										FALSE);
	if(self = [super initWithHTTPMessageRef : request_]){
		;
	}
	return self;
}

//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * リクエスト先のURLを参照
  * 
  * @return     リクエスト先のURL
  */
- (NSURL *) requestURL
{
	CFURLRef url_;
	if(NULL == [self HTTPMessageRef]) return nil;
	
	url_ = CFHTTPMessageCopyRequestURL([self HTTPMessageRef]);
	if(NULL == url_) return nil;
	
	return [(NSURL *)url_ autorelease];
}

/**
  * リクエストメソッドの参照。
  * 
  * @return     メソッド
  */
- (NSString *) requstMethod
{
	CFStringRef method_;
	if(NULL == [self HTTPMessageRef]) return nil;
	
	method_ = CFHTTPMessageCopyRequestMethod([self HTTPMessageRef]);
	if(NULL == method_) return nil;
	
	return [(NSString *)method_ autorelease];
}

/**
  * 使用しているHTTPバージョンの参照。
  * 
  * @return     HTTPバージョン
  */
- (NSString *) HTTPVersion
{
	CFStringRef version_;
	if(NULL == [self HTTPMessageRef]) return nil;
	
	version_ = CFHTTPMessageCopyVersion([self HTTPMessageRef]);
	if(NULL == version_) return nil;
	
	return [(NSString *)version_ autorelease];
}

- (NSString *) description
{
	return [NSString stringWithFormat : 
					@"<%@ %p>\n"
					@"  Requst URL    : %@\n"
					@"  HTTP Version  : %@\n"
					@"  Request Method: %@\n"
					@"  Request		  : \n%@",
					[self className], self,
					[[self requestURL] absoluteString],
					[self HTTPVersion],
					[self requstMethod],
					[[self allHeaderFields] description]];
}

@end
