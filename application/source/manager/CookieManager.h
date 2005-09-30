/**
  * $Id: CookieManager.h,v 1.2 2005/09/30 18:52:03 tsawada2 Exp $
  * 
  * CookieManager.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>



@interface CookieManager : NSObject<CMRPropertyListCoding>
{
	@private
	NSDictionary		*_cookies;
}
+ (id) defaultManager;

- (NSDictionary *) cookies;
- (void) setCookies : (NSDictionary *) aCookies;

- (void) setCookiesArray : (NSArray  *) aCookiesArray
				 forHost : (NSString *) aHost;
- (void) removeAllCookies;

//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 単一、または複数のクッキー設定をまとめた@"Set-Cookie"ヘッダを
  * 解析し、適切な数のCookieを生成し、配列に格納して返す。
  * 
  * @param    header  ヘッダ
  * @return           Cookieの配列(失敗時にはnil)
  */
- (NSArray *) scanSetCookieHeader : (NSString *) header;

/**
  * @"Set-Cookie"で要求されたクッキーを保持。
  * 
  * @param    header    @"Set-Cookie"ヘッダ
  * @param    hostName  要求元のホスト名
  */
- (void) addCookies : (NSString *) header
         fromServer : (NSString *) hostName;

/**
  * 送信先に送るべきURLがある場合はクッキー文字列を返す。
  * 
  * @param    anURL  送信先URL
  * @param    withBe  Be ログイン用のクッキーも付けるかどうか
  * @return          クッキー
  */
- (NSString *) cookiesForRequestURL : (NSURL *) anURL
					   withBeCookie : (BOOL   ) withBe;

/**
  * 期限切れのクッキーを削除する。
  */
- (void) deleteExpiredCookies;

/**
  * 期限切れのクッキーを削除し、可変辞書で返す。
  * 
  * @param    dict  辞書
  * @return         期限切れのクッキーを削除した辞書
  */
- (NSMutableDictionary *) dictionaryByDeletingExpiredCookies : (NSDictionary *) dict;

/**
  * ファイルとして保存。
  * 
  * @param    path  保存場所のパス
  * @param    flag  NOなら直接、書き込む。
  * @return         成功時にYES
  */
- (BOOL) writeToFile : (NSString *) path
          atomically : (BOOL      ) flag;

- (NSDictionary *) dictionaryRepresentation;
@end
