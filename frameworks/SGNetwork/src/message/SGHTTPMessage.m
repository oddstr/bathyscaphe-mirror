//: SGHTTPMessage.m
/**
  * $Id: SGHTTPMessage.m,v 1.1.1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGHTTPMessage.h"
#import "FrameworkDefines.h"

@implementation SGHTTPMessage
//////////////////////////////////////////////////////////////////////
/////////////////////// [ 初期化・後始末 ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 抽象クラス：指定イニシャライザ
  * 委譲するCFHTTPMessageRefを指定して初期化。
  * 
  * @param    messageRef  CFHTTPMessageRef
  * @return               初期化済みのインスタンス
  */
- (id) initWithHTTPMessageRef : (CFHTTPMessageRef) messageRef
{
	if(self = [super init]){
		[self setHTTPMessageRef : messageRef];
	}
	return self;
}

- (void) dealloc
{
	if(m_message != NULL) CFRelease(m_message);
	[super dealloc];
}

- (NSString *) description
{
	return [NSString stringWithFormat :
				@"<%@ %p>\n"
				@"%@",
				[self className],
				self,
				[self allHeaderFields]];
}
//////////////////////////////////////////////////////////////////////
////////////////////// [ アクセサメソッド ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_message */
- (CFHTTPMessageRef) HTTPMessageRef;
{
	return m_message;
}

- (void) setHTTPMessageRef : (CFHTTPMessageRef) aMessage;
{
	if(aMessage != NULL) CFRetain(aMessage);
	if(m_message != NULL) CFRelease(m_message);
	m_message = aMessage;
}

//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * ヘッダを追加。特定のヘッダを削除するときには
  * valueにnilを渡す。
  * 
  * @param    value  ヘッダ値
  * @param    key    ヘッダ識別子
  */
- (void) setHeaderFieldValue : (NSString *) value
                      forKey : (NSString *) key
{
	if(NULL == [self HTTPMessageRef]) return;
	if(nil == key) return;
	
	//ヘッダを追加
	CFHTTPMessageSetHeaderFieldValue([self HTTPMessageRef],
									 (CFStringRef) key,
									 (CFStringRef) value);
}

/**
  * ヘッダを参照
  * 
  * @param    key  ヘッダ識別子
  * return         ヘッダ
  */
- (NSString *) headerFieldValueForKey : (NSString *) key
{
	CFStringRef fvalue_;		//フィールドの値
	
	if(NULL == [self HTTPMessageRef]) return nil;
	if(nil == key) return nil;
	
	fvalue_ = CFHTTPMessageCopyHeaderFieldValue([self HTTPMessageRef],
												(CFStringRef) key);
	if(NULL == fvalue_) return nil;
	return [(NSString *) fvalue_ autorelease];
}

/**
  * すべてのリクエストヘッダを辞書に収めて返す。
  * 
  * @return     すべてのリクエストヘッダ
  */
- (NSDictionary *) allHeaderFields
{
	CFDictionaryRef dict_;
	
	if(NULL == [self HTTPMessageRef]) return nil;
	
	dict_ = CFHTTPMessageCopyAllHeaderFields([self HTTPMessageRef]);
	
	if(NULL == dict_) return nil;
	return [(NSDictionary *) dict_ autorelease];
}

/**
  * ヘッダを完全に満たす場合にYESを返す。
  * 
  * @return     ヘッダを完全に満たしているならYES
  */
- (BOOL) isHeaderComplete
{
	if(NULL == [self HTTPMessageRef]) return nil;
	
	return (TRUE == CFHTTPMessageIsHeaderComplete([self HTTPMessageRef]));
}

/**
  * リクエストの内容を設定。
  * 
  * @param    body  ボディのデータ
  */
- (void) writeBody : (NSData *) body
{
	if(nil == body || NULL == [self HTTPMessageRef]) return;
	
	CFHTTPMessageSetBody([self HTTPMessageRef],
						 (CFDataRef)body);
}

/**
  * リクエストの内容を参照。
  * 
  * @return     ボディのデータ
  */
- (NSData *) body
{
	CFDataRef data_;
	
	if(NULL == [self HTTPMessageRef]) return nil;
	
	data_ = CFHTTPMessageCopyBody([self HTTPMessageRef]);
	
	if(NULL == data_) return nil;
	return [(NSData *)data_ autorelease];
}

/**
  * シリアライズしたデータを返す。
  * 
  * @return     シリアライズしたデータ
  */
- (NSData *) serializedMessage
{
	CFDataRef data_;
	
	if(NULL == [self HTTPMessageRef]) return nil;
	
	data_ = CFHTTPMessageCopySerializedMessage([self HTTPMessageRef]);
	
	if(NULL == data_) return nil;
	return [(NSData *)data_ autorelease];
}

/**
  * 送信内容にデータを追加。
  * 
  * @param    newBytes  追加するデータ
  * @return             解析失敗時にはNO
  */
- (BOOL) appendBytes : (NSData *) newBytes
{
	if(nil == newBytes || 0 == [newBytes length])
		return YES;
		
	return [self appendBytes : [newBytes bytes]
					  length : [newBytes length]];
}

/**
  * 送信内容にデータを追加。
  * 
  * @param    newBytes     追加するデータ
  * @param    bytesLength  追加するデータ長
  * @return                解析失敗時にはNO
  */
- (BOOL) appendBytes : (const unsigned *) newBytes
              length : (unsigned        ) bytesLength
{
	return (BOOL)CFHTTPMessageAppendBytes([self HTTPMessageRef],
							              (const UInt8 *)newBytes,
							              (CFIndex)bytesLength);
}
- (NSURL *) requestURL
{
	CFURLRef url_;

	url_ = CFHTTPMessageCopyRequestURL([self HTTPMessageRef]);
	if(NULL == url_)
		return nil;
	return [(NSURL *)url_ autorelease];
}
- (NSString *) requestMethod;
{
	CFStringRef method_;

	method_ = CFHTTPMessageCopyRequestMethod([self HTTPMessageRef]);
	if(NULL == method_)
		return nil;
	return [(NSString *)method_ autorelease];
}
@end



@implementation SGHTTPMessage(HeaderReadOrWrite)
- (unsigned) readContentLength
{
	NSString		*header_;
	unsigned		contentLength_;
	
	header_ = [self headerFieldValueForKey : HTTP_CONTENT_LENGTH_KEY];
	
	if(nil == header_ || 0 == [header_ length]) return NSNotFound;
	
	if(0 == sscanf([header_ UTF8String], "%u", &contentLength_))
		return NSNotFound;
	
	return contentLength_;
}

- (void) writeContentLength : (int) aLength
{
	NSAssert1(
		aLength >= 0, 
		@"Length must not be Negative Value. but was (%d).",
		aLength);
	[self setHeaderFieldValue : [[NSNumber numberWithInt : aLength] stringValue]
					   forKey : HTTP_CONTENT_LENGTH_KEY];
}
@end
