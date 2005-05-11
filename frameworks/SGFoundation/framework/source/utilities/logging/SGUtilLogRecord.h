//: SGUtilLogRecord.h
/**
  * $Id: SGUtilLogRecord.h,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGFoundation Logging API -- SGUtilLogRecord class
 * @discussion SGUtilLogRecord
 */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundationBase.h>
#import <SGFoundation/SGUtilLogger.h>

/*!
 * @class      SGUtilLogRecord
 * @abstract   ログ出力の情報をまとめたレコード
 * @discussion SGUtilLogRecordはログ出力時の各種情報を保持する
 *             レコードです。主にSGUtilLogHandlerハンドラオブジェクト
 *             に渡すために使われます。一度、生成されLogging APIに
 *             渡されたあとは各種属性を変更しないでください。
 */
@interface SGUtilLogRecord : SGBaseObject<NSCopying>
{
	NSString			*_message;
	SGLoggingLevel		_level;
	NSString			*loggerName;
	NSCalendarDate		*_date;
	unsigned long		_threadID;
}

/*!
 * @method        logRecordWithLevel:message:
 * @abstract      一時オブジェクトの生成
 * @discussion    autoreleaseされたオブジェクトを返します
 *
 * @param aLevel  ログのレベル
 * @param msg     メッセージ
 * @result        一時オブジェクト
 */
+ (id) logRecordWithLevel : (SGLoggingLevel) aLevel
			      message : (NSString     *) msg;

/*!
 * @method        initWithLevel:message:
 * @abstract      指定イニシャライザ
 * @discussion    新しいインスタンスを生成します。date属性は
 *                生成した日時に、threadIDはイニシャライザを
 *                呼び出したスレッドに設定されます。
 *
 * @param aLevel  ログのレベル
 * @param msg     メッセージ
 * @result        インスタンス
 */
- (id) initWithLevel : (SGLoggingLevel) aLevel
			 message : (NSString     *) msg;
			 
- (NSString *) message;
- (SGLoggingLevel) level;
- (NSString *) loggerName;
- (NSCalendarDate *) date;
- (unsigned long) threadID;
- (void) setMessage : (NSString *) aMessage;
- (void) setLevel : (SGLoggingLevel) aLevel;
- (void) setLoggerName : (NSString *) aLoggerName;
- (void) setDate : (NSCalendarDate *) aDate;
- (void) setThreadID : (unsigned long) aThreadID;
@end
