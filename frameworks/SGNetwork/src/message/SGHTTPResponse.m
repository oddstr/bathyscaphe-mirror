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
  * "chunked" 転送コーディングをデコードする。
  * 
  * @param    chunked    chunked転送コーディングされたデータ
  * @param    headers    追加エンティティヘッダ
  * @return              ボディ
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
//////////////////// [ インスタンスメソッド ] ////////////////////////
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
  * 送信内容にデータを追加。
  * 
  * @param    newBytes  追加するデータ
  * @return             解析失敗時にはNO
  */
- (BOOL) appendBytes : (NSData *) newBytes
{
	NSString *enc_;
	
	if ([super appendBytes : newBytes]) {
		NSData *decoded_;
		
		enc_ = [self headerFieldValueForKey : HTTP_TRANSFER_ENCODING_KEY];
		if (nil == enc_ ||
		   NO == [enc_ isEqualToString : HTTP_TRANSFER_CHUNKED_ENCODING])
			// Transfer-Encoding指定なし。
			// 通常の解析を終えているので、そのまま返す。
			return YES;
		
		decoded_ = [self body];
		decoded_ = decode_chunked(decoded_, NULL);
		[self writeBody : decoded_];
		
		{
			NSString *slen_;		//Content-Length
			
			//chunked data を設定しなおしたので、ヘッダを書き換える。
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
	unsigned long dlength_;		//データ長
	
	if (nil == chunked || 0 == [chunked length])
		return chunked;
	
	bytes_ = [chunked bytes];
	dlength_ = strtoul(bytes_, &endp_, 16);
	
	if (bytes_ == endp_) {
		//データ長を読み込めなかった。
		//chunked転送コーディングではなかったと見なし、
		//元のデータをそのまま返す。
		return chunked;
	}
	//CRLFがくるはず。
	if (*endp_ != '\r' || *(++endp_) != '\n') {
		//chunked転送コーディングではなかったと見なし、
		//元のデータをそのまま返す。
		return chunked;
	}
	endp_++;
	if (ULONG_MAX == dlength_) {
		//オーバーフロー
		return chunked;
	}
	
	{
		char *cendp_;
		
		//chunked dataの終わり。
		//CRLFがつづき、0のchunke
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

