//: SGUtilLogHandler.h
/**
  * $Id: SGUtilLogHandler.h,v 1.2 2007/01/22 02:23:29 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGFoundation Logging API -- SGUtilLogHandler class
 * @discussion SGUtilLogRecord
 */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundationBase.h>
#import <SGFoundation/SGUtilLogger.h>

@class SGUtilLogRecord;
@class SGUtilLogFormatter;

/*!
 * @class      SGUtilLogHandler
 * @abstract   ログを実際に出力するクラス
 * @discussion SGUtilLogHandlerはLoggerから渡されたログ情報をもとに
 *             実際のログ出力を行うクラスです。
 */
@interface SGUtilLogHandler : NSObject
{
	SGLoggingLevel		_level;
	NSStringEncoding	_encoding;
	SGUtilLogFormatter	*_formatter;
}
+ (id) logHandler;

/* abstract method */
- (void) close;
/* abstract method */
- (void) flush;
- (void) publish : (SGUtilLogRecord *) aRecord;
/* abstract method */
- (void) publishMessage : (NSString *) aMessage;

/*!
 * @method         loggable:
 * @abstract       ログ出力の判定
 * @discussion     指定されたログレコードが出力されるかどうかの
 *                 判定に使います。たとえばログレベルがハンドラ
 *                 に設定されているレベルより低かったり、出力文字列
 *                 がnilの場合などはNOを返します。
 *
 * @param aRecord  判定する対象レコード
 * @result         出力される場合はYES
 */
- (BOOL) loggable : (SGUtilLogRecord *) aRecord;

/*!
 * @method      encoding
 * @abstract    出力時のエンコーディング
 * @discussion  出力時のエンコーディング。デフォルトはShiftJIS
 * @result      出力時のエンコーディング
 */
- (NSStringEncoding) encoding;
- (void) setEncoding : (NSStringEncoding) anEncoding;
- (SGLoggingLevel) level;
- (void) setLevel : (SGLoggingLevel) aLevel;
- (SGUtilLogFormatter *) logFormatter;
- (void) setLogFormatter : (SGUtilLogFormatter *) aFormatter;
@end
