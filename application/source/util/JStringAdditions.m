//: JStringAdditions.m
/**
  * $Id: JStringAdditions.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * JStringAdditions.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "JStringAdditions.h"
#import "CocoMonar_Prefix.h"



//半角・全角文字列
static NSString *_Hankaku = nil;
static NSString *_Hankaku_Kana = nil;
static NSString *_Hankaku_Kana_Daku = nil;
static NSString *_Zenkaku = nil;
static NSString *_Zenkaku_Hira = nil;
static NSString *_Zenkaku_Hira_Daku = nil;
static NSString *_Zenkaku_Kana = nil;
static NSString *_Zenkaku_Kana_Daku = nil;

@implementation NSString(JStringAdditions)

static NSString *loadStringResource(NSString *target, 
									NSString *resource, 
									NSString *type)
{
	if(nil == target){
		NSString	*filepath;
		NSString	*contents;
		
		filepath = [[NSBundle mainBundle] pathForResource : resource
												   ofType : type];
		if(nil == filepath) return nil;
		
		contents = [[NSString alloc] initWithContentsOfFile : filepath];
		if(nil == contents){
			NSLog(@"Can't read from file: %@", filepath);
			return nil;
		}
		return contents;
	}
	return target;
}

static BOOL JStringAdditionInit(void)
{
	static BOOL isFirst = YES;
	
	if(NO == isFirst) return YES;
	
	isFirst = NO;
	_Hankaku = loadStringResource(_Hankaku,
									   @"Hankaku",
									   @"txt");
	if(nil == _Hankaku) return NO;
	
	_Hankaku_Kana = loadStringResource(_Hankaku_Kana,
											@"Hankaku-Kana",
											@"txt");
	if(nil == _Hankaku_Kana) return NO;
	
	_Hankaku_Kana_Daku = loadStringResource(_Hankaku_Kana_Daku, 
												 @"Hankaku-Kana-Daku",
												 @"txt");
	if(nil == _Hankaku_Kana_Daku) return NO;
	
	_Zenkaku = loadStringResource(_Zenkaku,
									   @"Zenkaku",
									   @"txt");
	if(nil == _Zenkaku) return NO;
	
	_Zenkaku_Hira = loadStringResource(_Zenkaku_Hira,
											@"Zenkaku-Hira",
											@"txt");
	if(nil == _Zenkaku_Hira) return NO;
	
	_Zenkaku_Hira_Daku = loadStringResource(_Zenkaku_Hira_Daku, 
												 @"Zenkaku-Hira-Daku",
												 @"txt");
	if(nil == _Zenkaku_Hira_Daku) return NO;
	
	_Zenkaku_Kana = loadStringResource(_Zenkaku_Kana, 
											@"Zenkaku-Kana",
											@"txt");
	if(nil == _Zenkaku_Kana) return NO;
	
	_Zenkaku_Kana_Daku = loadStringResource(_Zenkaku_Kana_Daku,
												 @"Zenkaku-Kana-Daku",
												 @"txt");
	if(nil == _Zenkaku_Kana_Daku) return NO;

	return YES;
}

/**
  * [関数：_refIndexOfHdakuAtIndex]
  * 
  * 指定されたインデックスの
  * 文字が半角濁音または半角半濁音か
  *
  * @param    str    文字列
  * @param    index  インデックス
  * @return          見つかった場合は探索した文字列中のインデックスを返す。
  *                  見つからなければ-1を返す。
  */

#define H_DAKUON_CHAR			0xff9e		// 半角濁点
#define H_HANDAKUON_CHAR		0xff9f		// 半角半濁点

static int _refIndexOfHdakuAtIndex(NSString *str, unsigned int index)
{
	static NSRange rng_ = {0, 1};

	NSString *char_;
	NSRange   includeKana_;
	
	if(NO == JStringAdditionInit()) return -1;
	
	if(nil == str) return -1;
	if(index >= [str length] -1) return -1;
	
	rng_.location = index;
	char_ = [str substringWithRange : rng_];
	rng_.location = 0;
	
	//次の文字が濁点なら濁音
	//記号などの場合は違う
	includeKana_ = [_Hankaku_Kana_Daku rangeOfString : char_];
	if(includeKana_.length != 0){
		unichar next_ = [str characterAtIndex : index +1];
		if(H_DAKUON_CHAR == next_ || H_HANDAKUON_CHAR == next_){
			return includeKana_.location;
		}
	}
	return -1;
}

/**
  * 半角文字を全角文字に変換して返す。
  * flagにYESを渡すとカナに変換。
  * NOなら「かな」で変換する。
  * 
  * @param    flag     NOなら「かな」で変換する
  * @return            全角文字列
  */
- (NSString *) stringByConvertingHankaku : (BOOL) toZenKana
{
	static NSRange _charRng  = {0, 1};	// 1文字
	
	NSString        *ztable_;			// 全角文字列
	NSMutableString *buffer_;			// 変換後
	unsigned int i, cnt;
	
	buffer_ = [NSMutableString string];
	if(NO == JStringAdditionInit() || 0 == (cnt = [self length]))
		return buffer_;
	
	for(i = 0; i < cnt; i++){
		NSString *char_;
		NSRange   result_;
		
		// 1文字ずつ検索
		_charRng.location = i;
		char_   = [self substringWithRange : _charRng];
		result_ = [_Hankaku rangeOfString : char_];
		ztable_ = _Zenkaku;

		if(0 == result_.length){
			result_ = [_Hankaku_Kana rangeOfString : char_];
			ztable_ = toZenKana ? _Zenkaku_Kana : _Zenkaku_Hira;
		}
		
		if(result_.length > 0){
			int loc_;
			//半濁音、濁音
			if((loc_ = _refIndexOfHdakuAtIndex(self, _charRng.location)) != -1){
				result_.location = loc_ / 2;
				result_.length = 1;
				i++;
				ztable_ = toZenKana ? _Zenkaku_Kana_Daku : _Zenkaku_Hira_Daku;
			}
			char_ = [ztable_ substringWithRange : result_];
		}
		[buffer_ appendString : char_];
	}
	_charRng.location = 0;
	
	return buffer_;
}

/**
  * 半角文字を全角文字に変換して返す。
  * 半角カナは全角かなに変換される。
  * 
  * @return    全角文字列
  */
- (NSString *) ZHiraString
{
	return [self stringByConvertingHankaku : NO];
}

/**
  * 半角文字を全角文字に変換して返す。
  * 半角カナは全角かなに変換される。
  * 
  * @return    全角文字列
  */
- (NSString *) ZKanaString
{
	return [self stringByConvertingHankaku : YES];
}


/**
  * できるだけ半角文字に変換して返す。
  *
  * @return     半角文字
  */
- (NSString *) HString
{
	static NSRange _charRng = {0, 1};
	
	NSMutableString *buffer_;	//変換後
	NSString        *hString_;	//半角文字列
	unsigned int i, cnt;
	
	buffer_ = [NSMutableString string];
	if(NO == JStringAdditionInit()) return buffer_;
	if(0 == (cnt = [self length])) return buffer_;
	
	for(i = 0; i < cnt; i++){
		NSString *char_;
		NSRange   result_;
		
		_charRng.location = i;
		char_ = [self substringWithRange : _charRng];
		
		//マッチした全角のテーブルに対して、
		//テーブルを変更していく。
		result_ = [_Zenkaku rangeOfString : char_];
		hString_ = _Hankaku;
		if(0 == result_.length){
			result_ = [_Zenkaku_Kana rangeOfString : char_];
			hString_ = _Hankaku_Kana;
		}
		if(0 == result_.length){
			result_ = [_Zenkaku_Hira rangeOfString : char_];
			hString_ = _Hankaku_Kana;
		}
		if(0 == result_.length){
			//濁音で検索
			hString_ = _Hankaku_Kana_Daku;
			result_ = [_Zenkaku_Hira_Daku rangeOfString : char_];
			if(0 == result_.length) 
				result_ = [_Zenkaku_Kana_Daku rangeOfString : char_];
			if(result_.length > 0){
				result_.location = result_.location * 2;
				result_.length++;
				char_ = [hString_ substringWithRange : result_];
			}
		}else{
			char_ = [hString_ substringWithRange : result_];
		}
		
		[buffer_ appendString : char_];
	}
	_charRng.location = 0;
	//SGWriteObject(([NSString stringWithFormat : @"%@ = %@", self, buffer_]), @"Zen2Han.txt");
	return buffer_;
}

static NSRange min_rng(NSRange rng1, NSRange rng2, NSRange rng3)
{
	NSRange result_;
	
	result_ = (rng1.location < rng2.location) 
			  ? rng1 
			  : rng2;
	result_ = (rng3.location < result_.location)
			  ? rng3 
			  : result_;
	
	return result_;
}

static NSRange max_rng(NSRange rng1, NSRange rng2, NSRange rng3)
{
	NSRange result_;
	NSRange ar[3];
	int i, cnt;
	
	ar[0] = rng1;
	ar[1] = rng2;
	ar[2] = rng3;
	
	cnt = (sizeof(ar) / sizeof(NSRange));
	result_ = NSMakeRange(0, 0);
	
	for(i = 0; i < cnt; i++){
		if((result_.location <= ar[i].location) && ar[i].location != NSNotFound){
			result_.location = ar[i].location;
			result_.length = ar[i].length;
		}
	}
	
	if(NSNotFound == result_.location) result_.length = 0;
	return result_;
}

/**
  * 全角・半角を無視して、文字列の検索を行う。
  * 
  * @param    aString  検索文字列
  * @param    option   オプション
  * @param    aRange   検索範囲
  * @return            結果
  */
- (NSRange) rangeOfStringZHInsensitive : (NSString   *) aString
                               options : (unsigned int) option
                                 range : (NSRange     ) aRange
{
	static NSRange rngL1 = {0, 1};
	static NSRange rngL2 = {0, 2};
	
	unsigned int self_index_;	// 対象文字列中のインデックス
	unsigned int fchar_index_;	// 検索文字列中のインデックス
	unsigned int i;
	
	NSString *char_;	// 1文字毎に検査
	NSString *zhchar_;	// 全角かな
	NSString *zkchar_;	// 全角カナ
	NSString *hchar_;	// 半角
	
	NSRange result_;	// 検索結果
	NSRange zhrng_;		// 全角かなでの検索結果
	NSRange zkrng_;		// 全角カナでの検索結果
	NSRange hrng_;		// 半角での検索結果
	
	unsigned	srcLength  = [self length];
	unsigned	findLength = [aString length];
	
	UTILRequireCondition(
		aString != nil && aRange.length > 0,
		ErrSearchRange);
		
	if(NSMaxRange(aRange) > srcLength){
		[NSException raise:NSRangeException
					format:@"Attempt string(length=%u) rage:%@",
					srcLength,
					NSStringFromRange(aRange)];
	}
	if(0 == findLength || 0 == srcLength)
		return NSMakeRange(0, 0);
	
	if(_refIndexOfHdakuAtIndex(aString, 0) != -1){
		// 濁音・半濁音を含む半角文字
		char_ = [aString substringToIndex : 2];
		hchar_ = char_;
		fchar_index_ = 2;
	}else{
		char_ = [aString substringToIndex : 1];
		hchar_  = [char_ HString];
		fchar_index_ = 1;
	}
	
	// 全角文字は一文字
	zhchar_ = [char_ ZHiraString];
	zkchar_ = [char_ ZKanaString];
	
	
	zhrng_ = [self rangeOfString : zhchar_
						  options : option
						    range : aRange];
	zkrng_ = [self rangeOfString : zkchar_
						 options : option
						   range : aRange];
	hrng_ = [self rangeOfString : hchar_
						options : option
						  range : aRange];

	if(NSNotFound == zhrng_.location &&
	   NSNotFound == zkrng_.location &&
	   NSNotFound == hrng_.location)
		return kNFRange;
	
	result_ = (option & NSBackwardsSearch)
			  ? max_rng(zhrng_, zkrng_, hrng_)
			  : min_rng(zhrng_, zkrng_, hrng_);
	
	self_index_ = NSMaxRange(result_);
	if(2 == fchar_index_ && result_.location == hrng_.location){
		//半角濁音を読んでいれば、
		self_index_++;
	}
	
	//残りの文字を検証する。
	for(i = fchar_index_; i < findLength; i++){
		rngL1.location = i;
		rngL2.location = i;
		if(_refIndexOfHdakuAtIndex(aString, i) != -1){
			//濁音・半濁音を含む半角文字
			char_ = [aString substringWithRange : rngL2];
			hchar_ = char_;
			i++;
			if(self_index_ >= NSMaxRange(aRange)){
				return kNFRange;
			}
		}else{
			char_ = [aString substringWithRange : rngL1];
			hchar_  = [char_ HString];
			if(self_index_ +1 >= NSMaxRange(aRange)){
				return kNFRange;
			}
		}
		//全角文字は一文字
		zhchar_ = [char_ ZHiraString];
		zkchar_ = [char_ ZKanaString];

/*		rngL2.location = self_index_;

		
*/		
		rngL1.location = 0;
		rngL2.location = 0;
		if([self characterAtIndex : self_index_] == 
				[zhchar_ characterAtIndex : 0]){
			result_.length++;
			self_index_++;
			continue;
		}else if([self characterAtIndex : self_index_] == 
				[zkchar_ characterAtIndex : 0]){
			result_.length++;
			self_index_++;
			continue;
		}else{
			int  j, hfindLength;	//半角
			BOOL ok_;
			ok_ = YES;
			hfindLength = [hchar_ length];
			for(j = 0; j < hfindLength; j++){
				NSString *s;
				
				rngL1.location = j;
				s = [hchar_ substringWithRange : rngL1];
				rngL1.location = self_index_ + j;
				if(([self rangeOfString : s 
								options : option 
								  range : rngL1]).location == NSNotFound){
					//半角で合致しなかった
					ok_ = NO;
					break;
				}
/*				if([self characterAtIndex : self_index_ + j] != 
					[hchar_ characterAtIndex : j]){
					//半角で合致しなかった
					ok_ = NO;
				}
*/
				result_.length += hfindLength;
				self_index_+= hfindLength;
			}
			if(ok_) continue;
		}
		//合致せず、次を検索
		{
			int next_;
			
			if(NO == (NSBackwardsSearch & option)){
				next_ = (result_.location +1) - aRange.location;
				if(next_ <= 0) return kNFRange;
				aRange.location = result_.location +1;
				if(aRange.length < next_) return kNFRange;
				aRange.length -= next_;
			}else{
				next_ = (result_.location -1) - aRange.location;
				if(next_ <= 0) return kNFRange;
				aRange.length = next_;
			}
		}
		return [self rangeOfStringZHInsensitive : aString
								        options : option
								          range : aRange];
	}
	
	if(NSMaxRange(aRange) < NSMaxRange(result_))
		return kNFRange;
	return result_;
	
ErrSearchRange:
	return kNFRange;
}
- (NSRange) rangeOfString : (NSString *) subString
				  options : (unsigned  ) mask
				    range : (NSRange   ) aRange
	HanZenKakuInsensitive : (BOOL      ) flag
{
	NSRange		result;
	
	if(flag){
		result = [self rangeOfStringZHInsensitive : subString 
							options : mask
							range : aRange];
	}else{
		result = [self rangeOfString : subString 
							options : mask
							range : aRange];
	}
	return result;
}
@end
