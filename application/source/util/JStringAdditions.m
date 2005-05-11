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



//���p�E�S�p������
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
  * [�֐��F_refIndexOfHdakuAtIndex]
  * 
  * �w�肳�ꂽ�C���f�b�N�X��
  * ���������p�����܂��͔��p��������
  *
  * @param    str    ������
  * @param    index  �C���f�b�N�X
  * @return          ���������ꍇ�͒T�����������񒆂̃C���f�b�N�X��Ԃ��B
  *                  ������Ȃ����-1��Ԃ��B
  */

#define H_DAKUON_CHAR			0xff9e		// ���p���_
#define H_HANDAKUON_CHAR		0xff9f		// ���p�����_

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
	
	//���̕��������_�Ȃ����
	//�L���Ȃǂ̏ꍇ�͈Ⴄ
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
  * ���p������S�p�����ɕϊ����ĕԂ��B
  * flag��YES��n���ƃJ�i�ɕϊ��B
  * NO�Ȃ�u���ȁv�ŕϊ�����B
  * 
  * @param    flag     NO�Ȃ�u���ȁv�ŕϊ�����
  * @return            �S�p������
  */
- (NSString *) stringByConvertingHankaku : (BOOL) toZenKana
{
	static NSRange _charRng  = {0, 1};	// 1����
	
	NSString        *ztable_;			// �S�p������
	NSMutableString *buffer_;			// �ϊ���
	unsigned int i, cnt;
	
	buffer_ = [NSMutableString string];
	if(NO == JStringAdditionInit() || 0 == (cnt = [self length]))
		return buffer_;
	
	for(i = 0; i < cnt; i++){
		NSString *char_;
		NSRange   result_;
		
		// 1����������
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
			//�������A����
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
  * ���p������S�p�����ɕϊ����ĕԂ��B
  * ���p�J�i�͑S�p���Ȃɕϊ������B
  * 
  * @return    �S�p������
  */
- (NSString *) ZHiraString
{
	return [self stringByConvertingHankaku : NO];
}

/**
  * ���p������S�p�����ɕϊ����ĕԂ��B
  * ���p�J�i�͑S�p���Ȃɕϊ������B
  * 
  * @return    �S�p������
  */
- (NSString *) ZKanaString
{
	return [self stringByConvertingHankaku : YES];
}


/**
  * �ł��邾�����p�����ɕϊ����ĕԂ��B
  *
  * @return     ���p����
  */
- (NSString *) HString
{
	static NSRange _charRng = {0, 1};
	
	NSMutableString *buffer_;	//�ϊ���
	NSString        *hString_;	//���p������
	unsigned int i, cnt;
	
	buffer_ = [NSMutableString string];
	if(NO == JStringAdditionInit()) return buffer_;
	if(0 == (cnt = [self length])) return buffer_;
	
	for(i = 0; i < cnt; i++){
		NSString *char_;
		NSRange   result_;
		
		_charRng.location = i;
		char_ = [self substringWithRange : _charRng];
		
		//�}�b�`�����S�p�̃e�[�u���ɑ΂��āA
		//�e�[�u����ύX���Ă����B
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
			//�����Ō���
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
  * �S�p�E���p�𖳎����āA������̌������s���B
  * 
  * @param    aString  ����������
  * @param    option   �I�v�V����
  * @param    aRange   �����͈�
  * @return            ����
  */
- (NSRange) rangeOfStringZHInsensitive : (NSString   *) aString
                               options : (unsigned int) option
                                 range : (NSRange     ) aRange
{
	static NSRange rngL1 = {0, 1};
	static NSRange rngL2 = {0, 2};
	
	unsigned int self_index_;	// �Ώە����񒆂̃C���f�b�N�X
	unsigned int fchar_index_;	// ���������񒆂̃C���f�b�N�X
	unsigned int i;
	
	NSString *char_;	// 1�������Ɍ���
	NSString *zhchar_;	// �S�p����
	NSString *zkchar_;	// �S�p�J�i
	NSString *hchar_;	// ���p
	
	NSRange result_;	// ��������
	NSRange zhrng_;		// �S�p���Ȃł̌�������
	NSRange zkrng_;		// �S�p�J�i�ł̌�������
	NSRange hrng_;		// ���p�ł̌�������
	
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
		// �����E���������܂ޔ��p����
		char_ = [aString substringToIndex : 2];
		hchar_ = char_;
		fchar_index_ = 2;
	}else{
		char_ = [aString substringToIndex : 1];
		hchar_  = [char_ HString];
		fchar_index_ = 1;
	}
	
	// �S�p�����͈ꕶ��
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
		//���p������ǂ�ł���΁A
		self_index_++;
	}
	
	//�c��̕��������؂���B
	for(i = fchar_index_; i < findLength; i++){
		rngL1.location = i;
		rngL2.location = i;
		if(_refIndexOfHdakuAtIndex(aString, i) != -1){
			//�����E���������܂ޔ��p����
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
		//�S�p�����͈ꕶ��
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
			int  j, hfindLength;	//���p
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
					//���p�ō��v���Ȃ�����
					ok_ = NO;
					break;
				}
/*				if([self characterAtIndex : self_index_ + j] != 
					[hchar_ characterAtIndex : j]){
					//���p�ō��v���Ȃ�����
					ok_ = NO;
				}
*/
				result_.length += hfindLength;
				self_index_+= hfindLength;
			}
			if(ok_) continue;
		}
		//���v�����A��������
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
