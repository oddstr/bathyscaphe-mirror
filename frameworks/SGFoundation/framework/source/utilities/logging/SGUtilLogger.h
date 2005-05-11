//: SGUtilLogger.h
/**
  * $Id: SGUtilLogger.h,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGFoundation Logging API -- SGUtilLogger class
 * @discussion SGUtilLogger
 */
#ifndef SGUTILLOGGER_H_INCLUDED
#define SGUTILLOGGER_H_INCLUDED

#import <Foundation/Foundation.h>
#import <SGFoundation/SGBase.h>

SG_DECL_BEGIN



@class SGUtilLogHandler;

/*!
 * @typedef      SGLoggingLevel
 * @abstract     ログ出力のレベルを定義した定数
 * @discussion   SGLoggingLevelはログ出力の標準的なレベル設定に
 *               使える各種マスク定数です。
 *               Logging APIではあるレベルより低いレベルは無視されます。
 *
 * @constant kSGLoggingLevelAll      すべてのレベル.
 * @constant kSGLoggingLevelFine     成功
 * @constant kSGLoggingLevelInfo     情報
 * @constant kSGLoggingLevelWarnning 警告
 * @constant kSGLoggingLevelSevere   致命的
 * @constant kSGLoggingLevelOff      ログ出力を抑止
 */
typedef enum {
	kSGLoggingLevelAll      = INT_MIN,
	kSGLoggingLevelFine     = 500,
	kSGLoggingLevelInfo     = 800,
	kSGLoggingLevelWarning = 900,
	kSGLoggingLevelSevere   = 1000,
	kSGLoggingLevelOff      = INT_MAX,
	
} SGLoggingLevel;


/*!
 * @class      SGUtilLogger
 * @abstract   ログ出力のためのオブジェクト
 *
 * @discussion SGUtilLoggerオブジェクト(Logger)は特定のアプリケーションや
 *             システムがログを出力するために使うことのできるオブジェクトです。
 */
@interface SGUtilLogger : NSObject
{
	SGLoggingLevel	_level;
	NSString		*_name;
	NSMutableArray	*_handlers;
}
/*!
 * @method      sharedInstance
 * @abstract    グローバルなLoggerオブジェクトへのアクセサ
 *
 * @discussion  プログラマが簡単にLoggerオブジェクトを利用できるよう
 *              用意されたグローバルなLoggerオブジェクトへのアクセサです。
 *              通常はSGLogger関数でアクセスします。
 * @result      グローバルなLoggerオブジェクト
 */
+ (SGUtilLogger *) sharedInstance;

/*!
 * @method       loggerNamed:
 * @abstract     指定された名前のLoggerオブジェクトを返す。
 * @discussion   指定された名前のLoggerを生成、または既に存在している
 *               場合はそれを返します。
 *
 * @param aName  Loggerの名前
 * @result       適切なLogger
 */
+ (SGUtilLogger *) loggerNamed : (NSString *) aName;

/*!
 * @method      anonymousLogger
 * @abstract    匿名のLoggerを返す。
 * @discussion  このメソッドで生成されたLoggerはLogManagerには登録されません。
 * @result      匿名のLogger
 */
+ (SGUtilLogger *) anonymousLogger;

/*!
 * @method         addHandler:
 * @abstract       ハンドラの追加
 * @discussion     実際にログの出力を行うハンドラオブジェクトを追加します
 *
 * @param handler  ハンドラ
 */
- (void) addHandler : (SGUtilLogHandler *) handler;
/*!
 * @method         removeHandler:
 * @abstract       ハンドラの削除
 * @discussion     実際にログの出力を行うハンドラオブジェクトを取り除きます。
 *
 * @param handler  取り除くハンドラ
 */
- (void) removeHandler : (SGUtilLogHandler *) handler;

/*!
 * @method      name
 * @abstract    Loggerの名前
 * @discussion  Loggerの名前を返します。匿名のLoggerではnilを返します。
 * @result      Loggerの名前
 */
- (NSString *) name;
/*!
 * @method      level
 * @abstract    ログ出力のレベル
 * @discussion  設定されているレベルを参照
 * @result      レベル
 */
- (SGLoggingLevel) level;
/*!
 * @method        setLevel:
 * @abstract      ログ出力のレベルを設定
 * @discussion    ログ出力のレベルを設定
 * @param aLevel  レベル
 */
- (void) setLevel : (SGLoggingLevel) aLevel;

/*!
 * @method        logv:format:arguments:
 * @abstract      ログを出力
 * @discussion    引数リストを受け付けるログ出力メソッド
 *
 * @param aLevel  このログのレベルを設定します
 * @param format  書式指定文字列
 * @param args    引数リスト
 */
- (void) logv : (SGLoggingLevel) aLevel
	   format : (NSString     *) format
	arguments : (va_list       ) args;
@end


/*!
 * @category   SGUtilLogger(SGLoggingExtentions)
 * @abstract   レベルごとのログ出力
 * @discussion プログラマがいちいちレベルを指定せずに済むように
 *             用意されたカテゴリです。
 *             それぞれのレベルに対応したメソッドが定義されています。
 */
@interface SGUtilLogger(SGLoggingExtentions)
- (void) fine : (NSString *) format,...;
- (void) info : (NSString *) format,...;
- (void) warning : (NSString *) format,...;
- (void) severe : (NSString *) format,...;

/*!
 * @method        log:format:
 * @abstract      ログを出力
 * @discussion    printfフォーマットでログを出力します
 *
 * @param aLevel  このログのレベルを設定します
 * @param format  書式指定文字列と引数
 */
- (void) log : (SGLoggingLevel) aLevel
      format : (NSString     *) format,...;
@end



/*!
 * @function    SGLogger
 * @abstract    グローバルなLoggerオブジェクトへのアクセサ
 * @discussion  プログラマが簡単にLoggerオブジェクトを利用できるよう
 *              用意されたグローバルなLoggerオブジェクトへのアクセサです。
 *
 * @result      グローバルなLoggerオブジェクト
 */
SG_EXPORT
SGUtilLogger *SGLogger(void);



SG_DECL_END


#endif /* SGUTILLOGGER_H_INCLUDED */
