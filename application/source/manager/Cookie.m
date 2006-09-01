//:Cookie.m
#import "Cookie.h"



//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* クッキーのオプション名 */
#define kCookieOptionPath			@"path"
#define kCookieOptionDomain			@"domain"
#define kCookieOptionExpires		@"expires"
#define kCookieOptionSecure			@"secure"
/* 内部用 */
#define kCookieOptionEnabled		@"x-application/CocoMonar enabled"
#define kCookieOptionBSEnabled		@"x-application/BathyScaphe enabled" // available in BathyScaphe 1.2.2/1.5 and later.



@implementation Cookie
//////////////////////////////////////////////////////////////////////
/////////////////////// [ 初期化・後始末 ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * 一時オブジェクトの生成。
  * 
  * @return                 一時オブジェクト
  */
+ (id) cookie
{
	return [[[[self class] alloc] init] autorelease];
}

/**
  * 一時オブジェクトの生成。
  * 文字列表現からインスタンスを生成、初期化。
  * 
  * @param      anyCookies  文字列表現
  * @return     一時オブジェクト
  */
+ (id) cookieWithString : (NSString *) anyCookies
{
	return [[[[self class] alloc] initWithString : anyCookies] autorelease];
}

/**
  * 一時オブジェクトの生成。
  * 辞書オブジェクトからインスタンスを生成、初期化。
  * 
  * @param      anyCookies  辞書オブジェクト
  * @return                 一時オブジェクト
  */
+ (id) cookieWithDictionary : (NSDictionary *) anyCookies
{
	return [[[[self class] alloc] initWithDictionary : anyCookies] autorelease];
}

- (id) init
{
	if(self = [super init]){
		[self setIsEnabled : YES];
	}
	return self;
}

/**
  * 指定イニシャライザ。
  * 文字列表現からインスタンスを生成、初期化。
  * 
  * @param    anyCookies  文字列表現
  * @return               初期化済みのインスタンス
  */
- (id) initWithString : (NSString *) anyCookies
{
	if(self = [self init]){
		[self setCookieWithString : anyCookies];
	}
	return self;
}

/**
  * 指定イニシャライザ。
  * 辞書オブジェクトからインスタンスを生成、初期化。
  * 
  * @param    anyCookies  辞書オブジェクト
  * @return               初期化済みのインスタンス
  */
- (id) initWithDictionary : (NSDictionary *) dict
{
	
	if(self = [self init]){
		if(nil == dict)
			return self;
		
		[self setCookieWithDictionary : dict];
	}
	return self;
}

- (void) dealloc
{
	[m_name release];		//名前
	[m_value release];		//値
	[m_path release];		//クッキーが有効であるURL範囲
	[m_domain release];		//クッキーが有効であるドメイン範囲
	[m_expires release];	//有効期限
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////
////////////////////// [ アクセサメソッド ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_name */
- (NSString *) name
{
	return m_name;
}
- (void) setName : (NSString *) aName
{
	[aName retain];
	[[self name] release];
	m_name = aName;
}
/* Accessor for m_value */
- (NSString *) value
{
	return m_value;
}
- (void) setValue : (NSString *) aValue
{
	[aValue retain];
	[[self value] release];
	m_value = aValue;
}
/* Accessor for m_path */
- (NSString *) path
{
	return m_path;
}

- (void) setPath : (NSString *) aPath
{
	[aPath retain];
	[[self path] release];
	m_path = aPath;
}
/* Accessor for m_domain */
- (NSString *) domain
{
	return m_domain;
}
- (void) setDomain : (NSString *) aDomain
{
	[aDomain retain];
	[[self domain] release];
	m_domain = aDomain;
}
/* Accessor for m_expires */
- (NSString *) expires
{
	return m_expires;
}
- (void) setExpires : (NSString *) anExpires
{
	[anExpires retain];
	[[self expires] release];
	m_expires = anExpires;
}
/* Accessor for m_secure */
- (BOOL) secure
{
	return m_secure;
}
- (void) setSecure : (BOOL) aSecure
{
	m_secure = aSecure;
}
/* Accessor for m_isEnabled */
- (BOOL) isEnabled
{
	return m_isEnabled;
}
- (void) setIsEnabled : (BOOL) anIsEnabled
{
	m_isEnabled = anIsEnabled;
}
//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * レシーバのクッキーが有効なURLならYESを返す。
  * 
  * @param    anURL  対象URL
  * @return          クッキーが有効なURLならYES
  */
- (BOOL) isAvalilableURL : (NSURL *) anURL
{
	if(nil == anURL) return NO;
	
	//pathが指定されていれば、マッチするか検査
	if(nil == [self path]) return YES;
	return [[anURL path] hasPrefix : [self path]];
}

/**
  * 期限切れの場合はYESを返す。
  * 終了時に破棄される場合にはwhenTerminate = YES
  *
  * @param   whenTerminate   終了時に破棄される場合はYES
  * @return                  期限切れの場合はYES
  */
- (BOOL) isExpired : (BOOL *) whenTerminate
{
	NSDate *exp_;
	
	exp_ = [self expiresDate];
	if(nil == exp_){
		//終了時に破棄
		if(whenTerminate != NULL) *whenTerminate = YES;
		return NO;
	}
	return [exp_ isBeforeDate : [NSDate date]];
}


/**
  * レシーバのを辞書形式で返す。
  * 
  * @return     辞書オブジェクト
  */
- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict_;
	
	dict_ = [NSMutableDictionary dictionary];
	//オプションを保存
	if([self path] != nil){
		[dict_ setObject : [self path]
				  forKey : kCookieOptionPath];
	}
	if([self domain] != nil){
		[dict_ setObject : [self domain]
				  forKey : kCookieOptionDomain];
	}
	if([self expires] != nil){
		[dict_ setObject : [self expires]
				  forKey : kCookieOptionExpires];
	}
	[dict_ setBool : [self secure]
		    forKey : kCookieOptionSecure];
	[dict_ setBool : [self isEnabled]
		    forKey : kCookieOptionBSEnabled];
	//クッキーを保存
	if([self name] != nil && [self value] != nil){
		[dict_ setObject : [self value]
			      forKey : [self name]];
	}
	return dict_;
}


//:アクセサ
/**
  * 有効期限を返す。
  * 
  * @return     有効期限
  */
- (NSDate *) expiresDate
{
	if(nil == [self expires]) return nil;
	return [NSCalendarDate dateWithHTTPTimeRepresentation : [self expires]];
}

//クッキーの設定
/**
  * クッキーを設定。
  * 
  * @param    aValue  値
  * @param    aName   名前
  */
- (void) setCookie : (id        ) aValue
           forName : (NSString *) aName
{
	if(nil == aValue || nil == aName) return;
	//オプション指定の場合はインスタンス変数に保持
	if([aName isEqualToString : kCookieOptionSecure]){
		if(NO == [aValue respondsToSelector : @selector(boolValue)])
			[self setSecure : NO];
		[self setSecure : [aValue boolValue]];
	}else if([aName isEqualToString : kCookieOptionEnabled] || [aName isEqualToString : kCookieOptionBSEnabled]){
		if(NO == [aValue respondsToSelector : @selector(boolValue)])
			[self setIsEnabled : YES];
		[self setIsEnabled : [aValue boolValue]];
	}else if([aName isEqualToString : kCookieOptionPath]){
		[self setPath : aValue];
	}else if([aName isEqualToString : kCookieOptionDomain]){
		[self setDomain : aValue];
	}else if([aName isEqualToString : kCookieOptionExpires]){
		[self setExpires : aValue];
	}else{
		[self setName : aName];
		[self setValue : aValue];
	}
}

/**
  * 文字列から変換。
  * オプションを指定した場合は、それらも反映される。
  * 
  * ex : @"SPID=XWDtLhNY; expires=1016920836 GMT; path=/"
  * 
  * @param    anyCookies  文字列表現
  */
- (void) setCookieWithString : (NSString *) anyCookies
{
	NSArray      *comps_;		//組毎を配列オブジェクトに
	NSEnumerator *iter_;		//順次検査
	NSString     *item_;		//各組
	
	if(nil == anyCookies) return;
	//UTILDebugLog(@"anyCookies = %@", anyCookies);
	comps_ = [anyCookies componentsSeparatedByString : @";"];
	if(nil == comps_ || 0 == [comps_ count]) return;
	//UTILDebugLog(@"comps_ = (%d)", [comps_ count]);

	iter_ = [comps_ objectEnumerator];
	while(item_ = [iter_ nextObject]){
		NSArray         *pair_;				//名前、値
		NSMutableString *name_, *value_;
		
		//UTILDebugLog(@"item_ = %@", item_);
		pair_ = [item_ componentsSeparatedByString : @"="];
		if(nil == pair_) continue;
		
		//Secure
		if(1 == [pair_ count]){
			NSMutableString *cstr_;
			
			cstr_ = [NSMutableString stringWithString : [pair_ objectAtIndex : 0]];
			[cstr_ strip];
			
			if([cstr_ isEqualToString : kCookieOptionSecure])
				[self setSecure : YES];
			continue;
		}
		if([pair_ count] != 2) continue;
		
		name_ = [NSMutableString stringWithString : [pair_ objectAtIndex : 0]];
		value_ = [NSMutableString stringWithString : [pair_ objectAtIndex : 1]];
		//先頭、末尾の空白を削除
		[name_ strip];
		[value_ strip];
		//UTILDebugLog(@"name = %@", name_);
		[self setCookie : value_
		        forName : name_];
	}
}

/**
  * 辞書オブジェクトから変換。
  * オプションを指定した場合は、それらも反映される。
  * 
  * 
  * @param    anyCookies  辞書オブジェクト
  */
- (void) setCookieWithDictionary : (NSDictionary *) anyCookies
{
	NSEnumerator    *iter_;		//キーを順次検査
	NSString        *key_;		//キー
	
	if(nil == anyCookies) return;
	
	iter_ = [anyCookies keyEnumerator];
	while(key_ = [iter_ nextObject]){
		id value_;
		
		value_ = [anyCookies objectForKey : key_];
		if(nil == value_) continue;
		
		[self setCookie : value_
			    forName : key_];
	}
}

/**
  * クッキーを文字列で表現したものを返す。
  * 
  * @return     文字列表現
  */
- (NSString *) stringValue
{
	if(nil == [self name] || nil == [self value])
		return nil;
	return [NSString stringWithFormat : @"%@=%@",
										[self name],
										[self value]];
}

/////////////////////////////////////////////////////////////////////
/////////////////////////// NSObject ////////////////////////////////
/////////////////////////////////////////////////////////////////////
- (NSString *) description
{
	return [self stringValue];
}

- (BOOL) isEqual : (id) obj
{
	if([super isEqual : obj])
		return YES;
	if(NO == [obj isKindOfClass : [self class]])
		return NO;
	if(NO == [[obj name] isEqualToString : [self name]])
		return NO;
	if(NO == [[obj path] isEqualToString : [self path]])
		return NO;
	return YES;
}
/////////////////////////////////////////////////////////////////////
////////////////////////// NSCopying ////////////////////////////////
/////////////////////////////////////////////////////////////////////
- (id) copyWithZone : (NSZone *) zone
{
	Cookie		*tmpcopy;
	
	tmpcopy = [[[self class] allocWithZone : zone] init];
	[tmpcopy setName : [self name]];
	[tmpcopy setValue : [self value]];
	[tmpcopy setPath : [self path]];
	[tmpcopy setDomain : [self domain]];
	[tmpcopy setExpires : [self expires]];
	[tmpcopy setSecure : [self secure]];
	[tmpcopy setIsEnabled : [self isEnabled]];
	
	return tmpcopy;
}
@end
