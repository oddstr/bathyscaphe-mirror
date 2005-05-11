//:w2chConnect.h
/**
  *
  * 2chに接続できるクラスのプロトコル
  *
  * @version 1.0.1 (02/02/04  5:44:38 PM)
  *
  */
#import <Foundation/Foundation.h>

@class SGHTTPConnector;

typedef enum {
	kw2chConnectGettingSubject_txtMode,		//subject.txtの取得
	kw2chConnectGettingDATMode,				//.datファイルの取得
	kw2chConnectPOSTMessageMode,			//"POST"メソッドの実行
	

} w2chConnectMode;

//Error Handling

// 対応表はReplyErrorCode.plistを参照
enum {
	k2chNoneErrorType 				= 0,		// 正常
	k2chEmptyDataErrorType			= 1,		// データなし
	k2chAnyErrorType				= 2,		// ＥＲＲＯＲ！
	k2chContributionCheckErrorType	= 3,		// 投稿確認

	k2chRequireNameErrorType		= 4,		// 名前いれてちょ
	k2chRequireContentsErrorType	= 5,		// 本文がありません。
	k2chSPIDCookieErrorType			= 6,		// クッキー確認！
	k2chDoubleWritingErrorType		= 7,		// 二重書き込み
	k2chWarningType					= 8,		// 注意事項
	
	
	k2chUnknownErrorType
};

typedef struct {
	int type;
	w2chConnectMode mode;
	int error;
} SG2chServerError;

@protocol w2chConnect<NSObject>
- (SGHTTPConnector*) HTTPConnector;
- (id) delegate;

- (void) setDelegate : (id) newDelegate;

/**
  * 各コネクタの処理対象を表す定数を返す。
  * 
  * @return     SG2chConnectorMode
  */
- (w2chConnectMode) mode;

/**
  * その時点で受信完了したデータを返す。
  * 圧縮されている場合は展開する。
  * 
  * @return     受信完了したデータ
  */
- (NSData *) availableResourceData;

/**
  * レシーバの保持するデータを返す。
  * 必要な場合は接続し、データを受信
  * 
  * @return     保持するデータ
  */
- (NSData *) resourceData;

/**
  * 受信を開始。終了するまでブロックする。
  * 
  * @return     受信したデータ
  */
- (NSData *) loadInForeground;

/**
  * バックグラウンドで受信を開始する。
  */
- (void) loadInBackground;

/**
  * バックグラウンドでの受信を中止する。
  */
- (void) cancelLoadInBackground;

/**
  * サーバに送信するデータを設定。
  * このとき、"Content-Length"ヘッダは
  * 自動的に設定される。
  * 
  * @param    data  送信するデータ
  * @return         成功時にはYES
  */
- (BOOL) writeData : (NSData *) data;

/**
  * サーバに送信するフォームのデータを設定する。
  * このとき、"Content-Length"ヘッダ及び、"Content-Type"
  * ヘッダは自動的に設定される。
  * 
  * @param    forms  フォームの変数と値を納めた辞書オブジェクト
  * @return          成功時にはYES
  */
- (BOOL) writeForm : (NSDictionary *) forms;


//response
/**
  * サーバからのレスポンスを返す。
  * 
  * @return     ヘッダ
  */
- (NSDictionary *) responseHeaders;

/**
  * レスポンスヘッダを参照。
  * 
  * @param    field  フィールド名
  * @return          値
  */
- (NSString *) headerFieldValueForKey : (NSString *) field;

/**
  * サーバのレスポンスコードを返す。
  * 
  * @return     レスポンスコード
  */
- (unsigned) statusCode;

/**
  * ステータス行を返す。
  * 
  * @return     ステータス行
  */
- (NSString *) statusLine;

- (NSURL *) requestURL;

- (NSString *) requestMethod;
@end

//Error Handling
@protocol w2chErrorHandling<NSObject>
//////////////////////////////////////////////////////////////////////
////////////////////// [ アクセサメソッド ] //////////////////////////
//////////////////////////////////////////////////////////////////////
- (NSURL *) requestURL;
- (w2chConnectMode) requestMode;
- (SG2chServerError) recentError;
- (NSString *) recentErrorTitle;
- (NSString *) recentErrorMessage;
- (void) setRecentErrorCode : (int) code;
//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * サーバーから返ってきたデータを受けとり、エラーかどうか
  * 判断。SG2chServerError構造体のtypeがk2chNoneErrorType
  * 以外はエラー。
  * 
  * @param    contents  サーバーから返ってきたデータ
  * @param    title     エラーの内容を簡潔に表した文字列
  * @param    message   エラーの内容
  * @return             SG2chServerError構造体
  */
- (SG2chServerError) handleErrorWithContents : (NSString  *) contents
                                       title : (NSString **) title
                                     message : (NSString **) message; 

@end


//Delegate
@interface NSObject(w2chConnectDelegate)
/////////////////////////////////////////////////////////////////////
////////////////// [ 受信の開始、終了、キャンセルなど ] /////////////
/////////////////////////////////////////////////////////////////////

- (void) connectorResourceDidBeginLoading : (id<w2chConnect>) sender;

- (void) connectorResourceDidCancelLoading : (id<w2chConnect>) sender;

- (void) connectorResourceDidFinishLoading : (id<w2chConnect>) sender;
  
/////////////////////////////////////////////////////////////////////
///////////////////// [ データの受信関係 ] //////////////////////////
/////////////////////////////////////////////////////////////////////

- (void) connector               : (id<w2chConnect>) sender
  resourceDataDidBecomeAvailable : (NSData      *) newBytes;

- (void) connector                 : (id<w2chConnect>) sender
  resourceDidFailLoadingWithReason : (NSString    *) reason;

/**
  * 受信・送信は完了したが、何らかの理由で受け入れられなかった。
  * 
  * @param    sender   コネクター
  * @param    handler  エラー処理オブジェクト
  */
- (void) connector                 : (id<w2chConnect>) sender
   resourceDidFailLoadingWithError : (id<w2chErrorHandling>) handler;
@end


