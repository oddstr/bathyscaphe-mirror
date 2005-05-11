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
/////////////////////// [ �������E��n�� ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * ���ۃN���X�F�w��C�j�V�����C�U
  * �Ϗ�����CFHTTPMessageRef���w�肵�ď������B
  * 
  * @param    messageRef  CFHTTPMessageRef
  * @return               �������ς݂̃C���X�^���X
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
////////////////////// [ �A�N�Z�T���\�b�h ] //////////////////////////
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
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �w�b�_��ǉ��B����̃w�b�_���폜����Ƃ��ɂ�
  * value��nil��n���B
  * 
  * @param    value  �w�b�_�l
  * @param    key    �w�b�_���ʎq
  */
- (void) setHeaderFieldValue : (NSString *) value
                      forKey : (NSString *) key
{
	if(NULL == [self HTTPMessageRef]) return;
	if(nil == key) return;
	
	//�w�b�_��ǉ�
	CFHTTPMessageSetHeaderFieldValue([self HTTPMessageRef],
									 (CFStringRef) key,
									 (CFStringRef) value);
}

/**
  * �w�b�_���Q��
  * 
  * @param    key  �w�b�_���ʎq
  * return         �w�b�_
  */
- (NSString *) headerFieldValueForKey : (NSString *) key
{
	CFStringRef fvalue_;		//�t�B�[���h�̒l
	
	if(NULL == [self HTTPMessageRef]) return nil;
	if(nil == key) return nil;
	
	fvalue_ = CFHTTPMessageCopyHeaderFieldValue([self HTTPMessageRef],
												(CFStringRef) key);
	if(NULL == fvalue_) return nil;
	return [(NSString *) fvalue_ autorelease];
}

/**
  * ���ׂẴ��N�G�X�g�w�b�_�������Ɏ��߂ĕԂ��B
  * 
  * @return     ���ׂẴ��N�G�X�g�w�b�_
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
  * �w�b�_�����S�ɖ������ꍇ��YES��Ԃ��B
  * 
  * @return     �w�b�_�����S�ɖ������Ă���Ȃ�YES
  */
- (BOOL) isHeaderComplete
{
	if(NULL == [self HTTPMessageRef]) return nil;
	
	return (TRUE == CFHTTPMessageIsHeaderComplete([self HTTPMessageRef]));
}

/**
  * ���N�G�X�g�̓��e��ݒ�B
  * 
  * @param    body  �{�f�B�̃f�[�^
  */
- (void) writeBody : (NSData *) body
{
	if(nil == body || NULL == [self HTTPMessageRef]) return;
	
	CFHTTPMessageSetBody([self HTTPMessageRef],
						 (CFDataRef)body);
}

/**
  * ���N�G�X�g�̓��e���Q�ƁB
  * 
  * @return     �{�f�B�̃f�[�^
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
  * �V���A���C�Y�����f�[�^��Ԃ��B
  * 
  * @return     �V���A���C�Y�����f�[�^
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
  * ���M���e�Ƀf�[�^��ǉ��B
  * 
  * @param    newBytes  �ǉ�����f�[�^
  * @return             ��͎��s���ɂ�NO
  */
- (BOOL) appendBytes : (NSData *) newBytes
{
	if(nil == newBytes || 0 == [newBytes length])
		return YES;
		
	return [self appendBytes : [newBytes bytes]
					  length : [newBytes length]];
}

/**
  * ���M���e�Ƀf�[�^��ǉ��B
  * 
  * @param    newBytes     �ǉ�����f�[�^
  * @param    bytesLength  �ǉ�����f�[�^��
  * @return                ��͎��s���ɂ�NO
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
