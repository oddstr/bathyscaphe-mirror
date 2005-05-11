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
  * ���N�G�X�g���URL���w�肵�ď������B
  * 
  * @param    anURL    ���N�G�X�g���URL
  * @param    method   ���\�b�h
  * @param    version  HTTP�o�[�W����
  * @return            �������ς݂̃C���X�^���X
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
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * ���N�G�X�g���URL���Q��
  * 
  * @return     ���N�G�X�g���URL
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
  * ���N�G�X�g���\�b�h�̎Q�ƁB
  * 
  * @return     ���\�b�h
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
  * �g�p���Ă���HTTP�o�[�W�����̎Q�ƁB
  * 
  * @return     HTTP�o�[�W����
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
