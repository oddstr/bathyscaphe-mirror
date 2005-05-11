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
  * 新しいレスポンスを作成する。
  * 
  * @param    code         ステータスコード
  * @param    line         ステータス行
  * @param    httpVersion  HTTPのバージョン
  * @return                一時オブジェクト
  */
+ (id) responseWithStatusCode : (int        ) code
                   statusLine : (NSString  *) line
                  HTTPVersion : (CFStringRef) httpVersion;
/**
  * 新しいレスポンスを作成する。
  * 
  * @param    code         ステータスコード
  * @param    line         ステータス行
  * @param    httpVersion  HTTPのバージョン
  * @return                初期化済みのインスタンス
  */
- (id) initWithStatusCode : (int        ) code
               statusLine : (NSString  *) line
              HTTPVersion : (CFStringRef) httpVersion;

// create from loaded HTTPStream
+ (id) responseFromLoadedStream : (CFReadStreamRef) stream;

- (UInt32) statusCode;
- (NSString *) statusLine;
@end



