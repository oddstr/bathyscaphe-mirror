/**
  * $Id: SG2chErrorHandler.h,v 1.1.1.1 2005/05/11 17:51:12 tsawada2 Exp $
  * 
  * SG2chErrorHandler.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import "w2chConnect.h"



@interface SG2chErrorHandler : NSObject<w2chErrorHandling>
{
	NSURL				*m_requestURL;
	w2chConnectMode		m_requestMode;
	SG2chServerError	m_recentError;
	NSString			*m_recentErrorTitle;
	NSString			*m_recentErrorMessage;
}
//////////////////////////////////////////////////////////////////////
/////////////////////// [ 初期化・後始末 ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 一時オブジェクトの生成。
  * 取得先のURLを指定して初期化。
  * 
  * @param    anURL       取得先のURL
  * @return               一時オブジェクト
  */
+ (id) handlerWithURL : (NSURL *) anURL;

/**
  * 取得先のURLを指定して初期化。
  * 
  * @param    anURL       取得先のURL
  * @return               初期化済みのインスタンス
  */
- (id) initWithURL : (NSURL         *) anURL;


//////////////////////////////////////////////////////////////////////
/////////////////////// [ クラスメソッド ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 指定されたURLからデータを取得できる場合はYES
  * 
  * @param    anURL  URL
  * @return          URLからデータを取得できる場合はYES
  */
+ (BOOL) canInitWithURL : (NSURL *) anURL;

//////////////////////////////////////////////////////////////////////
////////////////////// [ アクセサメソッド ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_requestURL */
- (void) setRequestURL : (NSURL *) aRequestURL;
/* Accessor for m_recentError */
- (void) setRecentError : (SG2chServerError) aRecentError;
/* Accessor for m_recentErrorTitle */
- (void) setRecentErrorTitle : (NSString *) aRecentErrorTitle;
/* Accessor for m_recentErrorMessage */
- (void) setRecentErrorMessage : (NSString *) aRecentErrorMessage;
@end

extern SG2chServerError SGMake2chServerError(int type, 
			     						     w2chConnectMode mode, 
										     int error);

