//: SGHTTPResponse.h
/**
  * $Id: SGHTTPResponse.h,v 1.1.1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <SGNetwork/SGHTTPMessage.h>
#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

@interface SGHTTPResponse : SGHTTPMessage
{

}
+ (id) emptyResponse;

/**
  * �V�������X�|���X���쐬����B
  * 
  * @param    code         �X�e�[�^�X�R�[�h
  * @param    line         �X�e�[�^�X�s
  * @param    httpVersion  HTTP�̃o�[�W����
  * @return                �ꎞ�I�u�W�F�N�g
  */
+ (id) responseWithStatusCode : (int        ) code
                   statusLine : (NSString  *) line
                  HTTPVersion : (CFStringRef) httpVersion;
/**
  * �V�������X�|���X���쐬����B
  * 
  * @param    code         �X�e�[�^�X�R�[�h
  * @param    line         �X�e�[�^�X�s
  * @param    httpVersion  HTTP�̃o�[�W����
  * @return                �������ς݂̃C���X�^���X
  */
- (id) initWithStatusCode : (int        ) code
               statusLine : (NSString  *) line
              HTTPVersion : (CFStringRef) httpVersion;

// create from loaded HTTPStream
+ (id) responseFromLoadedStream : (CFReadStreamRef) stream;

- (UInt32) statusCode;
- (NSString *) statusLine;
@end



