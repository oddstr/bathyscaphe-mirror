//: SGHTTPMessage.h
/**
  * $Id: SGHTTPMessage.h,v 1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

@interface SGHTTPMessage : NSObject
{
	@private
	CFHTTPMessageRef  m_message;		//HTTPメッセージ
}
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
- (id) initWithHTTPMessageRef : (CFHTTPMessageRef) messageRef;

//////////////////////////////////////////////////////////////////////
////////////////////// [ アクセサメソッド ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_message */
- (CFHTTPMessageRef) HTTPMessageRef;
- (void) setHTTPMessageRef : (CFHTTPMessageRef) aMessage;

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
                      forKey : (NSString *) key;
/**
  * ヘッダを参照
  * 
  * @param    key  ヘッダ識別子
  * return         ヘッダ
  */
- (NSString *) headerFieldValueForKey : (NSString *) key;

/**
  * すべてのリクエストヘッダを辞書に収めて返す。
  * 
  * @return     すべてのリクエストヘッダ
  */
- (NSDictionary *) allHeaderFields;

/**
  * ヘッダを完全に満たす場合にYESを返す。
  * 
  * @return     ヘッダを完全に満たしているならYES
  */
- (BOOL) isHeaderComplete;

/**
  * リクエストの内容を設定。
  * 
  * @param    body  ボディのデータ
  */
- (void) writeBody : (NSData *) body;

/**
  * リクエストの内容を参照。
  * 
  * @return     ボディのデータ
  */
- (NSData *) body;

/**
  * シリアライズしたデータを返す。
  * 
  * @return     シリアライズしたデータ
  */
- (NSData *) serializedMessage;

/**
  * 送信内容にデータを追加。
  * 
  * @param    newBytes  追加するデータ
  * @return             解析失敗時にはNO
  */
- (BOOL) appendBytes : (NSData *) newBytes;

/**
  * 送信内容にデータを追加。
  * 
  * @param    newBytes     追加するデータ
  * @param    bytesLength  追加するデータ長
  * @return                解析失敗時にはNO
  */
- (BOOL) appendBytes : (const unsigned *) newBytes
              length : (unsigned        ) bytesLength;

- (NSURL *) requestURL;

- (NSString *) requestMethod;
@end



@interface SGHTTPMessage(HeaderReadOrWrite)
// Error : NSNotFound
- (unsigned) readContentLength;
- (void) writeContentLength : (int) aLength;
@end
