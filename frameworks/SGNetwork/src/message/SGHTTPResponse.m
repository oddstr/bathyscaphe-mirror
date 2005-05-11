/**
  * $Id: SGHTTPResponse.m,v 1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * SGHTTPResponse.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "FrameworkDefines.h"
#import <SGNetwork/SGHTTPResponse.h>



/**
  * "chunked" �]���R�[�f�B���O���f�R�[�h����B
  * 
  * @param    chunked    chunked�]���R�[�f�B���O���ꂽ�f�[�^
  * @param    headers    �ǉ��G���e�B�e�B�w�b�_
  * @return              �{�f�B
  */
static NSData *decode_chunked(NSData *chunked, NSDictionary **headers);



@implementation SGHTTPResponse
+ (id) emptyResponse
{
	return [[[[self class] alloc] init] autorelease];
}
+ (id) responseWithStatusCode : (int        ) code
                   statusLine : (NSString  *) line
                  HTTPVersion : (CFStringRef) httpVersion
{
	return [[[[self class] alloc] initWithStatusCode : code
                                          statusLine : line
                                         HTTPVersion : httpVersion] autorelease];
}
- (id) initWithStatusCode : (int        ) code
               statusLine : (NSString  *) line
              HTTPVersion : (CFStringRef) httpVersion
{
	CFHTTPMessageRef response_;
	CFStringRef      line_;
	
	if (NULL == httpVersion) httpVersion = kCFHTTPVersion1_1;
	line_ = (CFStringRef)line;
	if (nil == line) line_ = CFSTR("OK");
	
	response_ = CFHTTPMessageCreateResponse(kCFAllocatorDefault,
										    code,
									        (CFStringRef) line,
										    httpVersion);
	
	if (self = [super initWithHTTPMessageRef : response_]) {
		;
	}
	return self;
}
// create from loaded HTTPStream
+ (id) responseFromLoadedStream : (CFReadStreamRef) stream
{
	SGHTTPResponse *response_ = nil;
	CFTypeRef       property_ = NULL;
	
	property_ = CFReadStreamCopyProperty(
					stream,
					kCFStreamPropertyHTTPResponseHeader);
	UTILRequireCondition(property_ != NULL, RET_RESPONSE);
	
	// check the property's type ID
	NSAssert1(CFHTTPMessageGetTypeID() == CFGetTypeID(property_),
		@"CFReadStreamCopyProperty(kCFStreamPropertyHTTPResponseHeader):\n"
		@"  expected CFHTTPMessage object returns, \n"
		@"  but %@ returned.",
		[(NSString*)CFCopyDescription(property_) autorelease]);
	
	response_ = [[SGHTTPResponse alloc] initWithHTTPMessageRef : 
									(CFHTTPMessageRef) property_];
	CFRelease(property_);
	property_ = NULL;

RET_RESPONSE:
	return [response_ autorelease];
}

- (id) init
{
	CFHTTPMessageRef response_;
	
	response_ = CFHTTPMessageCreateEmpty(kCFAllocatorDefault,
										 FALSE);
	if (self = [super initWithHTTPMessageRef : response_]) {
		;
	}
	return self;
}
//////////////////////////////////////////////////////////////////////
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
- (UInt32) statusCode
{
	return CFHTTPMessageGetResponseStatusCode([self HTTPMessageRef]);
}
- (NSString *) statusLine
{
	CFStringRef line_;
	
	line_ = CFHTTPMessageCopyResponseStatusLine([self HTTPMessageRef]);
	if (NULL == line_) return nil;
	
	return [(NSString *)line_ autorelease];
}

/**
  * ���M���e�Ƀf�[�^��ǉ��B
  * 
  * @param    newBytes  �ǉ�����f�[�^
  * @return             ��͎��s���ɂ�NO
  */
- (BOOL) appendBytes : (NSData *) newBytes
{
	NSString *enc_;
	
	if ([super appendBytes : newBytes]) {
		NSData *decoded_;
		
		enc_ = [self headerFieldValueForKey : HTTP_TRANSFER_ENCODING_KEY];
		if (nil == enc_ ||
		   NO == [enc_ isEqualToString : HTTP_TRANSFER_CHUNKED_ENCODING])
			// Transfer-Encoding�w��Ȃ��B
			// �ʏ�̉�͂��I���Ă���̂ŁA���̂܂ܕԂ��B
			return YES;
		
		decoded_ = [self body];
		decoded_ = decode_chunked(decoded_, NULL);
		[self writeBody : decoded_];
		
		{
			NSString *slen_;		//Content-Length
			
			//chunked data ��ݒ肵�Ȃ������̂ŁA�w�b�_������������B
			slen_ = [[NSNumber numberWithUnsignedInt : [decoded_ length]] stringValue];
			
			[self setHeaderFieldValue : slen_
	                           forKey : HTTP_CONTENT_LENGTH_KEY];
			[self setHeaderFieldValue : nil
	                           forKey : HTTP_TRANSFER_ENCODING_KEY];
		}
		return YES;
	}
	return NO;
}

- (NSString *) description
{
	return [NSString stringWithFormat : 
					@"<%@ %p>\n"
					@"  Status Code: %d\n"
					@"  Status Line: %@\n"
					@"  Response   : \n%@",
					[self className], self,
					[self statusCode],
					[self statusLine],
					[[self allHeaderFields] description]];
}
@end



static NSData *decode_chunked(NSData *chunked, NSDictionary **headers)
{
	const char *bytes_;
	char       *endp_;
	unsigned long dlength_;		//�f�[�^��
	
	if (nil == chunked || 0 == [chunked length])
		return chunked;
	
	bytes_ = [chunked bytes];
	dlength_ = strtoul(bytes_, &endp_, 16);
	
	if (bytes_ == endp_) {
		//�f�[�^����ǂݍ��߂Ȃ������B
		//chunked�]���R�[�f�B���O�ł͂Ȃ������ƌ��Ȃ��A
		//���̃f�[�^�����̂܂ܕԂ��B
		return chunked;
	}
	//CRLF������͂��B
	if (*endp_ != '\r' || *(++endp_) != '\n') {
		//chunked�]���R�[�f�B���O�ł͂Ȃ������ƌ��Ȃ��A
		//���̃f�[�^�����̂܂ܕԂ��B
		return chunked;
	}
	endp_++;
	if (ULONG_MAX == dlength_) {
		//�I�[�o�[�t���[
		return chunked;
	}
	
	{
		char *cendp_;
		
		//chunked data�̏I���B
		//CRLF���Â��A0��chunke
		cendp_ = (endp_ + dlength_);
		if (*cendp_ != '\r' ||
		   *(++cendp_) != '\n' ||
		   *(++cendp_) != '0' ||
		   *(++cendp_) != '\r' ||
		   *(++cendp_) != '\n') {
			
			return chunked;
		}
	}
	
	return [NSData dataWithBytes : endp_ length : dlength_];
}

