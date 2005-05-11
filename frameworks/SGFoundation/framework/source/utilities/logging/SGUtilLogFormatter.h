//: SGUtilLogFormatter.h
/**
  * $Id: SGUtilLogFormatter.h,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGFoundation Logging API -- SGUtilLogFormatter class
 * @discussion SGUtilLogFormatter
 */

#import <Foundation/Foundation.h>

@class SGUtilLogRecord;
@class SGUtilLogHandler;

/*!
 * @class      SGUtilLogFormatter
 * @abstract   ログレコードの整形をサポート
 * @discussion Formatterはログレコード(SGUtilLogRecord)の内容を整形する
 *             役割を担います。
 *
 *             通常、それぞれのハンドラ(SGUtilLogHandler)はログを整形して
 *             出力するためのFormatterを持っています。Formatterはハンドラ
 *             からログレコードを受け取り、それを文字列に変換、整形したもの
 *             をハンドラに返します。
 *
 *             Formatterによっては整形後の文字列を何らかの文字列で囲む必要が
 *             あります。たとえばXML形式をサポートするFormatterはいくつかの
 *             タグを追加する必要があるでしょう。- header, - tailメソッドは
 *             それらの文字列を得るために使えます。
 */
@interface SGUtilLogFormatter : NSObject
/* default: return [record message];*/
- (NSString *) format : (SGUtilLogRecord *) record;
/* default: return nil */
- (NSString *) header : (SGUtilLogHandler *) handler;
/* default: return nil */
- (NSString *) tail : (SGUtilLogHandler *) handler;
@end



/*!
 * @class      SGUtilNSLogLikeFormatter
 * @abstract   NSLog(...)風の出力
 * @discussion NSLog(...)風の形式に整形する
 */
@interface SGUtilNSLogLikeFormatter : SGUtilLogFormatter
@end
