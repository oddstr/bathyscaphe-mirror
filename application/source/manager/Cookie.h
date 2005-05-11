//:Cookie.h
/**
  *
  * Cookie。
  * 
  * Cookieの仕様は、Netscape Communications Corporation により、
  * ﾊhttp://home.netscape.com/newsref/std/cookie_spec.html
  * にて公開されている。
  * なお、HTTPの仕様に含まれるものではない。
  *
  * @version 1.0.0d1 (02/03/25  8:27:57 PM)
  *
  */

#import <SGFoundation/SGFoundation.h>



@interface Cookie : SGBaseObject<NSCopying>
{
	// 名前=値のペア
	NSString *m_name;				//名前
	NSString *m_value;				//値
	// オプション
	NSString            *m_path;	//クッキーが有効であるURL範囲
	NSString            *m_domain;	//クッキーが有効であるドメイン範囲
	NSString            *m_expires;	//有効期限
	BOOL                 m_secure;	//セキュリティの確保されていない
									//場合は使用しない。
	BOOL                 m_isEnabled;	//有効・無効
}
//////////////////////////////////////////////////////////////////////
/////////////////////// [ 初期化・後始末 ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 一時オブジェクトの生成。
  * 
  * @return                 一時オブジェクト
  */
+ (id) cookie;

/**
  * 一時オブジェクトの生成。
  * 文字列表現からインスタンスを生成、初期化。
  * 
  * @param      anyCookies  文字列表現
  * @return     一時オブジェクト
  */
+ (id) cookieWithString : (NSString *) anyCookies;

/**
  * 一時オブジェクトの生成。
  * 辞書オブジェクトからインスタンスを生成、初期化。
  * 
  * @param      anyCookies  辞書オブジェクト
  * @return                 一時オブジェクト
  */
+ (id) cookieWithDictionary : (NSDictionary *) anyCookies;


/**
  * 指定イニシャライザ。
  * 文字列表現からインスタンスを生成、初期化。
  * 
  * @param    anyCookies  文字列表現
  * @return               初期化済みのインスタンス
  */
- (id) initWithString : (NSString *) anyCookies;

/**
  * 指定イニシャライザ。
  * 辞書オブジェクトからインスタンスを生成、初期化。
  * 
  * @param    anyCookies  辞書オブジェクト
  * @return               初期化済みのインスタンス
  */
- (id) initWithDictionary : (NSDictionary *) anyCookies;

//////////////////////////////////////////////////////////////////////
////////////////////// [ アクセサメソッド ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_name */
- (NSString *) name;
- (void) setName : (NSString *) aName;
/* Accessor for m_value */
- (NSString *) value;
- (void) setValue : (NSString *) aValue;
/* Accessor for m_path */
- (NSString *) path;
- (void) setPath : (NSString *) aPath;
/* Accessor for m_domain */
- (NSString *) domain;
- (void) setDomain : (NSString *) aDomain;
/* Accessor for m_expires */
- (NSString *) expires;
- (void) setExpires : (NSString *) anExpires;
/* Accessor for m_secure */
- (BOOL) secure;
- (void) setSecure : (BOOL) aSecure;
/* Accessor for m_enabled */
/* Accessor for m_isEnabled */
- (BOOL) isEnabled;
- (void) setIsEnabled : (BOOL) anIsEnabled;
//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * レシーバのクッキーが有効なURLならYESを返す。
  * 
  * @param    anURL  対象URL
  * @return          クッキーが有効なURLならYES
  */
- (BOOL) isAvalilableURL : (NSURL *) anURL;

/**
  * 期限切れの場合はYESを返す。
  * 終了時に破棄される場合にはwhenTerminate = YES
  *
  * @param   whenTerminate   終了時に破棄される場合はYES
  * @return                  期限切れの場合はYES
  */
- (BOOL) isExpired : (BOOL *) whenTerminate;

/**
  * レシーバのを辞書形式で返す。
  * 
  * @return     辞書オブジェクト
  */
- (NSDictionary *) dictionaryRepresentation;

//:アクセサ
/**
  * 有効期限を返す。指定されていない場合は
  * アプリケーション終了時に破棄すること。
  * 
  * @return     有効期限
  */
- (NSDate *) expiresDate;

/**
  * クッキーを設定。
  * 
  * @param    aValue  値
  * @param    aName   名前
  */
- (void) setCookie : (id        ) aValue
           forName : (NSString *) aName;

/**
  * 文字列から変換。
  * オプションを指定した場合は、それらも反映される。
  * 
  * ex : @"SPID=XWDtLhNY; expires=1016920836 GMT; path=/"
  * 
  * @param    anyCookies  文字列表現
  */
- (void) setCookieWithString : (NSString *) anyCookies;

/**
  * 辞書オブジェクトから変換。
  * オプションを指定した場合は、それらも反映される。
  * 
  * 
  * @param    anyCookies  辞書オブジェクト
  */
- (void) setCookieWithDictionary : (NSDictionary *) anyCookies;

/**
  * クッキーを文字列で表現したものを返す。
  * 
  * @return     文字列表現
  */
- (NSString *) stringValue;


@end
