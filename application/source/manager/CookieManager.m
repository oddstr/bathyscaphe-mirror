//
//  CookieManager.m
//  CocoMonar
//
//  Created by Takanori Ishikawa on Mon Mar 25 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "CookieManager.h"
#import "Cookie.h"
#import "AppDefaults.h"
#import <AppKit/NSApplication.h>



@implementation CookieManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

+ (NSString *) defaultFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRCookiesFile
						resolvingFileRef : NULL];
}

- (id) init
{
	NSString		*filepath_;
	NSDictionary	*dict_;
	
	filepath_ = [[self class] defaultFilepath];
	UTILAssertNotNil(filepath_);
		
	dict_ = [NSDictionary dictionaryWithContentsOfFile : filepath_];
	return (self = [self initWithPropertyListRepresentation : dict_]);
}
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	return [[[self alloc] initWithPropertyListRepresentation : rep] autorelease];
}
- (id) propertyListRepresentation
{
	return [self dictionaryRepresentation];
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	if (self = [super init]) {
		if (NO == [self initializeFromPropertyListRepresentation : rep]) {
			[self autorelease];
			return nil;
		}
		
		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(applicationWillTerminate:)
					    name : NSApplicationWillTerminateNotification
					  object : NSApp];
	}
	return self;
}
- (BOOL) initializeFromPropertyListRepresentation : (id) rep;
{
	NSDictionary		*tmp_;
	
	if (nil == rep) return YES;
	if (NO == [rep isKindOfClass : [NSDictionary class]]) return NO;
	
	tmp_ = [self dictionaryByDeletingExpiredCookies : rep];
	[self setCookies : tmp_];
	return YES;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[_cookies release];
	[super dealloc];
}



- (NSDictionary *) cookies
{
	if (nil == _cookies)
		_cookies = [[NSDictionary empty] copy];
	
	return _cookies;
}
- (void) setCookies : (NSDictionary *) aCookies
{
	id		tmp;
	
	tmp = _cookies;
	_cookies = [aCookies retain];
	[tmp release];
}
- (void) setCookiesArray : (NSArray  *) aCookiesArray
				 forHost : (NSString *) aHost
{
	NSMutableDictionary		*tmp;
	NSDictionary			*newDict_;
	
	if (nil == aCookiesArray || nil == aHost) 
		return;
	
	tmp = [[self cookies] mutableCopy];
	[tmp setObject:aCookiesArray forKey:aHost];
	
	newDict_ = [tmp copy];
	[self setCookies : newDict_];
	
	[newDict_ release];
	[tmp release];
}
- (void) removeAllCookies
{
	[self setCookies : nil];
}

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
- (NSArray *) scanSetCookieHeader : (NSString *) header
{
	static NSString *const st_sep_ = @",";
	static NSString *const st_expsep_ = @"day,";
	static NSString *const st_expsep2_ = @"day.";
	NSMutableArray  *marray_;
	NSMutableString *mstr_;
	
	if (nil == header || 0 == [header length])
		return nil;
	marray_ = [NSMutableArray array];
	// カンマで区切られているが、有効期限のフォーマットにもカンマ
	// が含まれているため、単純に切り分けることはできない。
	// ex. expires=Wednesday, 24-Apr-2002 00:00:00 GMT 
	mstr_ = [NSMutableString stringWithString : header];
	//expiresの曜日の後のカンマをひとまず、他の文字に(*)
	[mstr_ replaceCharacters : st_expsep_
	                toString : st_expsep2_];
	//解析部
	{
		NSArray      *comps_;		//区切り文字で切り分け
		NSEnumerator *iter_;		//順次探索
		NSString     *item_;		//各単位
		
		comps_ = [mstr_ componentsSeparatedByString : st_sep_];
		iter_ = [comps_ objectEnumerator];
		while (item_ = [iter_ nextObject]) {
			Cookie *cookie_;
			
			item_ = [item_ stringByStriped];
			//(*)の置換を戻しておく。
			item_ = [item_ stringByReplaceCharacters : st_expsep2_
				                            toString : st_expsep_];
			cookie_ = [Cookie cookieWithString : item_];
			NSAssert1(
				(cookie_ != nil),
				@"Can't create Cookie! from %@",
				item_);
			[marray_ addObject : cookie_];
		}
	}
	if (0 == [marray_ count])
		return nil;
	return marray_;
}

/**
  * @"Set-Cookie"で要求されたクッキーを保持。
  * 
  * @param    header    @"Set-Cookie"ヘッダ
  * @param    hostName  要求元のホスト名
  */
- (void) addCookies : (NSString *) header
         fromServer : (NSString *) hostName
{
	NSMutableArray *oldCookies_;		//前回までのクッキー
	NSArray        *newCookies_;		//新しく追加するクッキー
	
	if (nil == header || nil == hostName) return;
	
	oldCookies_ = [[self cookies] objectForKey : hostName];
	// 新規作成
	if (nil == oldCookies_)
		oldCookies_ = [NSMutableArray array];
	
	UTILAssertKindOfClass(oldCookies_, NSMutableArray);

	newCookies_ = [self scanSetCookieHeader : header];
	if (newCookies_ != nil) {
		NSEnumerator *iter_;		//順次探索
		Cookie       *cookie_;		//各クッキー
		
		iter_ = [newCookies_ reverseObjectEnumerator];
		while (cookie_ = [iter_ nextObject]) {
			//重複するクッキーは取り除く。
			[oldCookies_ removeObject : cookie_];
			[oldCookies_ addObject : cookie_];
		}
	}
	[self setCookiesArray:oldCookies_ forHost:hostName];
}
/**
  * 送信先に送るべきURLがある場合はクッキー文字列を返す。
  * 
  * @param    anURL  送信先URL
  * @return          クッキー
  */
- (NSString *) cookiesForRequestURL : (NSURL *) anURL
{
	NSArray        *cookies_;		//ホストに対応するクッキー
	NSEnumerator   *iter_;			//順次探索
	Cookie         *item_;			//各クッキー
	NSMutableArray *avails_;		//送るべきクッキー

	const char *hs = [[anURL host] UTF8String];
	if (NULL == hs) return nil;
	
	if (nil == anURL) return nil;
	cookies_ = [[self cookies] objectForKey : [anURL host]];
	if (nil == cookies_ || 0 == [cookies_ count]) return nil;
	avails_ = [NSMutableArray array];
	
	iter_ = [cookies_ objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		if (NO == [item_ isAvalilableURL : anURL]) continue;
		if (NO == [item_ isEnabled]) continue;
		if ([item_ isExpired : NULL]) continue;
		[avails_ addObject : item_];
	}
	//名前が同じで、パスの違うクッキーがある場合は
	//より深くマッチするものを送る。
/*	iter_ = [avails_ objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		//いまのところ未実装
	}
*/
	// ここに be ログインのためのクッキー追加コード
	if (is_2channel(hs)) {
		if ([CMRPref shouldLoginBe2chAnyTime] || [[anURL host] isEqualToString : @"be.2ch.net"] || [[anURL host] isEqualToString : @"qa.2ch.net"]) {
			Cookie	*beItem_, *beItem2_;
			NSString *dmdmStr_, *mdmdStr_;
			
			dmdmStr_ = [CMRPref be2chAccountMailAddress];
			if (dmdmStr_ == nil || [dmdmStr_ length] == 0) goto default_cookie;

			mdmdStr_ = [CMRPref be2chAccountCode];
			if (mdmdStr_ == nil || [mdmdStr_ length] == 0) goto default_cookie;
			
			beItem_ = [Cookie cookieWithDictionary : [NSDictionary dictionaryWithObject : dmdmStr_ forKey : @"DMDM"]];
			[avails_ addObject : beItem_];
			beItem2_ = [Cookie cookieWithDictionary : [NSDictionary dictionaryWithObject : mdmdStr_ forKey : @"MDMD"]];
			[avails_ addObject : beItem2_];
		}
	}
	
default_cookie:
	return [avails_ componentsJoinedByString : @"; "];
}

/**
  * 期限切れのクッキーを削除する。
  */
- (void) deleteExpiredCookies
{
	[self setCookies : [self dictionaryByDeletingExpiredCookies : [self cookies]]];
}

/**
  * 期限切れのクッキーを削除し、可変辞書で返す。
  * 
  * @param    dict  辞書
  * @return         期限切れのクッキーを削除した辞書
  */
- (NSMutableDictionary *) dictionaryByDeletingExpiredCookies : (NSDictionary *) dict
{
	NSMutableDictionary *tmp_;		//作業用
	NSEnumerator        *kiter_;	//すべてのキー
	NSString            *host_;		//各キー
	
	tmp_ = [NSMutableDictionary dictionary];
	if (nil == dict || 0 == [dict count]) return tmp_;
	
	kiter_ = [dict keyEnumerator];
	while (host_ = [kiter_ nextObject]) {
		NSMutableArray      *tmparray_;	//作業用
		NSArray             *cookies_;		//すべてのクッキー
		NSEnumerator        *citer_;		//順次探索
		id                   cookie_;		//各クッキー
		
		cookies_ = [dict objectForKey : host_];
		if (nil == cookies_ || 0 == [cookies_ count]) continue;
		
		tmparray_ = [NSMutableArray array];
		citer_ = [cookies_ reverseObjectEnumerator];
		while (cookie_ = [citer_ nextObject]) {
			// 辞書の場合はCookieに変換
			if ([cookie_ isKindOfClass : [NSDictionary class]])
				cookie_ = [Cookie cookieWithDictionary : cookie_];
			if ([cookie_ isExpired : NULL])
				continue;
			// 期限切れでない場合は移す
			[tmparray_ addObject : cookie_];
		}
		[tmp_ setObject : tmparray_
				 forKey : host_];
	}
	return [[tmp_ copy] autorelease];
}

/**
  * ファイルとして保存。
  * 
  * @param    path  保存場所のパス
  * @param    flag  NOなら直接、書き込む。
  * @return         成功時にYES
  */
- (BOOL) writeToFile : (NSString *) path
          atomically : (BOOL      ) flag
{
	return [[self dictionaryRepresentation] writeToFile : path
									         atomically : flag];
}

/**
  * レシーバを保存可能な辞書で返す。
  * 
  * @return     辞書
  */
- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary		*tmp_;
	NSEnumerator			*kiter_;
	NSString				*host_;
	
	tmp_ = [NSMutableDictionary dictionary];
	kiter_ = [[self cookies] keyEnumerator];
	while (host_ = [kiter_ nextObject]) {
		NSMutableArray      *tmparray_;		//作業用
		NSArray             *cookies_;		//すべてのクッキー
		NSEnumerator        *citer_;		//順次探索
		Cookie              *cookie_;		//各クッキー
		
		cookies_ = [[self cookies] objectForKey : host_];
		if (nil == cookies_ || 0 == [cookies_ count]) continue;
		
		tmparray_ = [NSMutableArray array];
		citer_ = [cookies_ reverseObjectEnumerator];
		while (cookie_ = [citer_ nextObject]) {
			BOOL whenTerminate_;
			
			whenTerminate_ = NO;
			if ([cookie_ isExpired : &whenTerminate_] || whenTerminate_)
				continue;
			//期限切れでない場合は
			//辞書形式で追加
			[tmparray_ addObject : [cookie_ dictionaryRepresentation]];
		}
		[tmp_ setObject : tmparray_
				 forKey : host_];
	}
	return tmp_;
}

- (void) applicationWillTerminate : (NSNotification *) theNotification
{
	UTILAssertNotificationName(
		theNotification,
		NSApplicationWillTerminateNotification);
	
	[self writeToFile : [[self class] defaultFilepath]
		   atomically : YES];
}
@end
