/**
  * $Id: CMRMessageFilter.m,v 1.3.2.1 2005/12/14 16:05:06 masakih Exp $
  * 
  * CMRMessageFilter.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRMessageFilter.h"
#import "CocoMonar_Prefix.h"
#import "CMRThreadMessage.h"
//#import "CMRBBSSignature.h"
#import "CMRThreadSignature.h"
#import "BoardManager.h"
#import "CMXTextParser.h"
#import "NSCharacterSet+CMXAdditions.h"



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



@implementation CMRMessageDetecter
/* primitive */
- (BOOL) detectMessage : (CMRThreadMessage *) aMessage
{ return NO; }
@end

#pragma mark -

@implementation CMRMessageSample
+ (id) sampleWithMessage : (CMRThreadMessage   *) aMessage
			  withThread : (CMRThreadSignature *) aThreadIdentifier
{
	return [[[self alloc] initWithMessage:aMessage withThread:aThreadIdentifier] autorelease];
}
- (id) initWithMessage : (CMRThreadMessage   *) aMessage
			withThread : (CMRThreadSignature *) aThreadIdentifier
{
	if (self = [super init]) {
		[self setMessage : aMessage];
		[self setThreadIdentifier : aThreadIdentifier];
	}
	return self;
}

- (void) dealloc
{
	[_message release];
	[_threadIdentifier release];
	[super dealloc];
}

- (BOOL) isEqual : (id) anObject
{
	CMRThreadMessage	*m1, *m2;
	
	if (nil == anObject) return NO;
	if (self == anObject) return YES;
	
	if (NO == [anObject isKindOfClass : [self class]])
		return NO;
	if (NO == [[self threadIdentifier] isEqual : [anObject threadIdentifier]])
		return NO;
	
	m1 = [self message];
	m2 = [(CMRMessageSample*)anObject message];
	
	if (m1 == m2) return YES;
	if (NO == [[m1 name] isEqualToString : [m2 name]]) return NO;
	if (NO == [[m1 IDString] isEqualToString : [m2 IDString]]) return NO;
	if (NO == [[m1 messageSource] isEqualToString : [m2 messageSource]]) return NO;
	
	
	return YES;
}

- (UInt32) flags
{
	return _flags;
}
- (void) setFlags : (UInt32) aFlags
{
	_flags = aFlags;
}
- (UInt32) matchedCount
{
	return _matchedCount;
}
- (void) setMatchedCount : (UInt32) aMatchedCount
{
	_matchedCount = aMatchedCount;
}
- (void) incrementMatchedCount
{
	_matchedCount++;
}

- (CMRThreadMessage *) message
{
	return _message;
}
- (CMRThreadSignature *) threadIdentifier
{
	return _threadIdentifier;
}
- (void) setMessage : (CMRThreadMessage *) aMessage
{
	id		tmp;
	
	tmp = _message;
	_message = [aMessage retain];
	[tmp release];
}
- (void) setThreadIdentifier : (CMRThreadSignature *) aThreadIdentifier
{
	id		tmp;
	
	tmp = _threadIdentifier;
	_threadIdentifier = [aThreadIdentifier retain];
	[tmp release];
}

#pragma mark  CMRPropertyListCoding

#define kMessageKey			@"Message"
#define kThreadIDKey		@"Thread"
#define kFlagsKey			@"Flags"
#define kMatchedCount		@"MatchedCount"

- (BOOL) initializeWithPropertyListRepresentation : (id) rep
{
	id		v;
	
	if (NO == [rep isKindOfClass : [NSDictionary class]]) {
		return NO;
	}
	[self setMessage :
		[CMRThreadMessage objectWithPropertyListRepresentation :
			[rep objectForKey : kMessageKey]]];
	[self setThreadIdentifier :
		[CMRThreadSignature objectWithPropertyListRepresentation :
			[rep objectForKey : kThreadIDKey]]];
	
	v = [rep numberForKey : kFlagsKey];
	if (v != nil) [self setFlags : [v unsignedIntValue]];
	v = [rep numberForKey : kMatchedCount];
	if (v != nil) [self setMatchedCount : [v unsignedIntValue]];
	
	return YES;
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	if (self = [self init]) {
		if (NO == [self initializeWithPropertyListRepresentation:rep]) {
			[self release];
			return nil;
		}
	}
	return self;
}
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	return [[[self alloc] initWithPropertyListRepresentation : rep] autorelease];
}
- (id) propertyListRepresentation
{
	NSMutableDictionary		*rep;
	
	rep = [NSMutableDictionary dictionary];
	[rep setNoneNil : [[self message] propertyListRepresentation]
			 forKey : kMessageKey];
	[rep setNoneNil : [[self threadIdentifier] propertyListRepresentation]
			 forKey : kThreadIDKey];
	[rep setUnsignedInt : [self flags]
			 	 forKey : kFlagsKey];
	[rep setUnsignedInt : [self matchedCount]
			 	 forKey : kMatchedCount];
	
	return rep;
}
@end

#pragma mark -
#pragma mark stuff

static void setupAppendingSample_(CMRMessageSample *sample, NSMutableDictionary *table);
static int detectMessageAny_(
				CMRMessageSample *s,
				CMRThreadMessage *m,
				CMRThreadSignature *t);
static int doDetectMessageAny_(
				CMRThreadMessage	*m1,	// sample
				CMRThreadSignature	*t1,	// sample
				CMRThreadMessage	*m2,	// target
				CMRThreadSignature	*t2);	// target
// 設定されていないID や よくある名前等は比較対象にしない
static BOOL checkMailIsNonSignificant_(NSString *mail);
static BOOL checkNameIsNonSignificant_(NSString *name);
static BOOL checkIDIsNonSignificant_(NSString *idStr_);

#pragma mark -

@implementation CMRSamplingDetecter
- (SGBaseCArrayWrapper *) samples
{
	if (nil == _samples)
		_samples = [[SGBaseCArrayWrapper alloc] init];
	
	return _samples;
}
- (NSArray *) sampleArray
{
	return [self samples];
}
- (unsigned) numberOfSamples
{
	return [[self sampleArray] count];
}

- (void) dealloc
{
	[_samples release];
	[_table release];
	[super dealloc];
}

#pragma mark  CMRPropertyListCoding

#define kSamplesKey			@"Samples"

- (BOOL) initializeWithPropertyListRepresentation : (id) rep
{
	NSEnumerator		*iter_;
	id					item_;
	
	if (NO == [rep isKindOfClass : [NSDictionary class]]) return NO;
	item_ = [rep arrayForKey : kSamplesKey];
	if (nil == item_) return NO;
	
	iter_ = [item_ objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		CMRMessageSample	*sample_;
		
		sample_ = [CMRMessageSample objectWithPropertyListRepresentation : item_];
		if (nil == sample_)
			return NO;
		
		[self addNewMessageSample : sample_];
	}
	
	return YES;
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	if (self = [self init]) {
		if (NO == [self initializeWithPropertyListRepresentation:rep]) {
			[self release];
			return nil;
		}
	}
	return self;
}
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	return [[[self alloc] initWithPropertyListRepresentation : rep] autorelease];
}

static int compareAsMatchedCount_(id arg1, id arg2, void *info)
{
	UInt32		mc1 = [arg1 matchedCount];
	UInt32		mc2 = [arg2 matchedCount];
	
	if (mc1 == mc2) 
		return NSOrderedSame;
	else if (mc1 > mc2)
		return NSOrderedAscending;
	else
		return NSOrderedDescending;
}
- (NSArray *) sampleArrayByCompacting
{
	NSEnumerator			*iter_;
	CMRMessageSample		*item_;
	NSMutableArray			*compacted_;
	
	compacted_ = [NSMutableArray array];
	iter_ = [[self sampleArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		if ([compacted_ containsObject : item_]) {
			// 重複する要素
			continue;
		}
		[compacted_ addObject : item_];
	}
	
	[compacted_ sortUsingFunction:compareAsMatchedCount_ context:NULL];
	
	return compacted_;
}

- (id) propertyListRepresentation
{
	NSEnumerator			*iter_;
	CMRMessageSample		*item_;
	NSMutableArray			*samplesRep_;
	
	samplesRep_ = [NSMutableArray array];
	iter_ = [[self sampleArrayByCompacting] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		[samplesRep_ addObject : [item_ propertyListRepresentation]];
	}
	
	return [NSDictionary dictionaryWithObject : samplesRep_
									   forKey : kSamplesKey];
}

#pragma mark -

- (id) initWithDictionaryRepresentation : (NSDictionary *) aDictionary
{
	return [self initWithPropertyListRepresentation : aDictionary];
}
- (NSDictionary *) dictionaryRepresentation
{
	return [self propertyListRepresentation];
}

- (NSMutableDictionary *) samplesTable
{
	if (nil == _table) {
		_table = [[NSMutableDictionary alloc] init];
	}
	return _table;
}
- (void) clear
{
	[[self samples] removeAllObjects];
	[[self samplesTable] removeAllObjects];
}

- (NSArray *) corpus
{
	return _corpus;
}
- (void) setCorpus : (NSArray *) aCorpus
{
	id		tmp;
	
	tmp = _corpus;
	_corpus = [aCorpus retain];
	[tmp release];
}
- (void) addNewMessageSample : (CMRMessageSample *) aSample
{
	setupAppendingSample_(aSample, [self samplesTable]);
	[[self samples] addObject : aSample];
}
- (void) addSamplesFromDetecter : (CMRSamplingDetecter *) aDetecter
{
	NSEnumerator		*iter_;
	CMRMessageSample	*sample_;
	
	if (nil == aDetecter || 0 == [aDetecter numberOfSamples])
		return;
	
	iter_ = [[aDetecter sampleArray] objectEnumerator];
	while (sample_ = [iter_ nextObject]) {
		[self addNewMessageSample : sample_];
	}
}
- (void) addSample : (CMRThreadMessage      *) aMessage
			  with : (CMRThreadSignature    *) aThread
{
	CMRMessageSample	*sample_;
	CMRThreadMessage	*message_;
	
	UTILAssertNotNilArgument(aMessage, @"Sample Message");
	
	message_ = [[aMessage copyWithZone : [self zone]] autorelease];
	[message_ clearTemporaryAttributes];
	
	[message_ setSpam : YES];
	[message_ setProperty : kSampleAsAny];
	
	sample_ = [CMRMessageSample sampleWithMessage:message_ withThread:aThread];
	[self addNewMessageSample : sample_];
}

- (void) removeSampleCache : (CMRMessageSample   *) aSample
			          with : (CMRThreadSignature *) aThread
{
	NSMutableDictionary	*sampleTbl = [self samplesTable];
	CMRMessageSample	*mSample;
	id					key;
	
	key = [[aSample message] IDString];
	mSample = [sampleTbl objectForKey : key];
	if (mSample == aSample) {
		UTIL_DEBUG_WRITE(@"ID Cache Removed");
		[sampleTbl removeObjectForKey : key];
	}
	key = [[aSample message] name];
	mSample = [sampleTbl objectForKey : key];
	if (mSample == aSample) {
		UTIL_DEBUG_WRITE(@"Name Cache Removed");
		[sampleTbl removeObjectForKey : key];
	}
	key = [[aSample message] host];
	mSample = [sampleTbl objectForKey : key];
	if (mSample == aSample) {
		UTIL_DEBUG_WRITE(@"Host Cache Removed");
		[sampleTbl removeObjectForKey : key];
	}
	key = aThread;
	mSample = [sampleTbl objectForKey : key];
	if (mSample == aSample) {
		UTIL_DEBUG_WRITE(@"ThreadLocal Cache Removed");
		[sampleTbl removeObjectForKey : key];
	}
}
- (void) removeSample : (CMRThreadMessage   *) aMessage
			     with : (CMRThreadSignature *) aThread
{

	SGBaseCArrayWrapper	*mArray = [self samples];
	CMRMessageSample	*mSample;
	int					i;
	
	// 一致するものをすべて取り除く
	for (i = [mArray count] -1; i >= 0; i--) {
		mSample = SGBaseCArrayWrapperObjectAtIndex(mArray, i);
		if (detectMessageAny_(mSample, aMessage, aThread)) {
			UTIL_DEBUG_WRITE2(@"Sample:%u %@ was removed.", i, mSample);
			[self removeSampleCache:mSample with:aThread];
			[mArray removeObjectAtIndex : i];
		}
	}
}

- (BOOL) detectMessage : (CMRThreadMessage *) aMessage
{
	return [self detectMessage:aMessage with:nil];
}


- (BOOL) detectMessageUsingCorpus : (CMRThreadMessage   *) aMessage
						     with : (CMRThreadSignature *) aThread
{
	NSEnumerator	*iter_;
	NSString		*contents_;
	NSString		*word_;
	
	iter_ = [[self corpus] objectEnumerator];
	if (nil == iter_)
		return NO;
	
	// ----------------------------------------
	// 名前欄、メール欄、本文を対象にする。
	// すべてを結合し、プレインテキストに変換したあと、
	// 検索する。
	// ----------------------------------------
	{
		NSMutableString		*tmp;
		NSString			*field;
		
		tmp = [NSMutableString string];
		
		// 名前
		field = [aMessage name];
		if (NO == checkNameIsNonSignificant_(field)) {
			NSString *b = [aThread BBSName];
			NSString *nn = [[BoardManager defaultManager] defaultNoNameForBoard : b];
			
			if (NO == [field isEqualToString : nn])
				[tmp appendString : field];
		}
		
		// メール
		field = [aMessage mail];
		if (NO == checkMailIsNonSignificant_(field))
			[tmp appendString : field];
		
		// 本文
		field = [aMessage messageSource];
		[tmp appendString : field];
		
		field = [aMessage name];
		[CMXTextParser convertMessageSourceToCachedMessage : tmp];
		
		contents_ = tmp;
	}
	while (word_ = [iter_ nextObject]) {
		
		if ([contents_ rangeOfString:word_ options:NSLiteralSearch].length != 0) {
			UTIL_DEBUG_WRITE2(@"UsingCorpus:%u matched:%@", 
								[aMessage index], word_);
			return YES;
		}
	}
	return NO;
}

- (BOOL) detectMessage : (CMRThreadMessage   *) aMessage
			      with : (CMRThreadSignature *) aThread
{
	SGBaseCArrayWrapper	*sampleArray = [self samples];
	NSDictionary		*cacheDict = [self samplesTable];
	CMRMessageSample	*sample;
	int					i, cnt;
	id cache[4];
	
	// ----------------------------------------
	// 以下の項目でキャッシュから優先的に比較
	// { ID, Host, Name, Thread ID }
	// ----------------------------------------
	/* key を設定 */
	cache[0] = [aMessage IDString];
	cache[1] = [aMessage host];
	cache[2] = [aMessage name];
	cache[3] = aThread;
	
	for (i = 0, cnt = UTILNumberOfCArray(cache); i < cnt; i++) {
		sample = [cacheDict objectForKey : cache[i]];
		if (sample != nil) {
			if (detectMessageAny_(sample, aMessage, aThread)) {
				return YES;
			}
		}
		cache[i] = sample;
	}

	for (i = 0, cnt = [sampleArray count]; i < cnt; i++) {
		sample = SGBaseCArrayWrapperObjectAtIndex(sampleArray, i);
		if (detectMessageAny_(sample, aMessage, aThread))
			return YES;
	}
	
	// 語句集合と比較
	if ([self detectMessageUsingCorpus:aMessage with:aThread])
		return YES;
	
	return NO;
}
@end

#pragma mark -
#pragma mark Static Funcs

static int detectMessageAny_(
				CMRMessageSample *s,
				CMRThreadMessage *m,
				CMRThreadSignature *t)
{
	int		match;
	
	match = doDetectMessageAny_([s message], [s threadIdentifier], m, t);
	if (match != 0) { 
		UTIL_DEBUG_WRITE2(@"detectMessage:%u match=%d", [m index], match);
		[s incrementMatchedCount];
	}
	return match;
}
static int doDetectMessageAny_(
				CMRThreadMessage	*m1,	// sample
				CMRThreadSignature	*t1,	// sample
				CMRThreadMessage	*m2,	// target
				CMRThreadSignature	*t2)	// target
{
	BOOL				Eq_b, Eq_t;
	unsigned			mask = [m1 property];
	
	BoardManager		*nnMgr = [BoardManager defaultManager];
	//CMRBBSSignature		*b1 = [t1 BBSSignature];
	//CMRBBSSignature		*b2 = [t2 BBSSignature];
	NSString	*b1 = [t1 BBSName];
	NSString	*b2 = [t2 BBSName];
	NSString			*s1, *s2;
	
	Eq_t = [t1 isEqual : t2];
	//Eq_b = (NO == Eq_t) ? [b1 isEqual : b2] : YES;
	Eq_b = (NO == Eq_t) ? [b1 isEqualToString : b2] : YES;

	if (kSampleAsIDMask & mask) { 
		if (b1 == b2 || Eq_b) {
			s1 = [m1 IDString];
			s2 = [m2 IDString];
			
			if ([s1 isEqualToString : s2]) {
				// 同一板でかつ、ID が一致
				return kSampleAsIDMask;
			}
		}
	}
	if (kSampleAsHostMask & mask) { 
		if (b1 == b2 || Eq_b) {
			s1 = [m1 host];
			s2 = [m2 host];

			if ([s1 length] > 1 && [s1 isEqualToString : s2]) {
				// 同一板でかつ、Host が一致
				// 2005-02-13 修正：同一板でかつ、Host が二文字以上、かつ、Host が一致
				// 携帯・PC 区別の0,o対策
				return kSampleAsHostMask;
			}
		}
	}
	// 名前（スレッド限定）
	if (kSampleAsThreadLocalMask & mask) { 
		if (t1 == t2 || Eq_t) {
			s1 = [m1 name];
			s2 = [m2 name];
			
			if ([s1 isEqualToString : s2]) {
				// 同一スレッドでかつ名前が一致
				return kSampleAsThreadLocalMask;
			}
		}
	}
	// 名前
	if (kSampleAsNameMask & mask) { 
		s1 = [m1 name];
		s2 = [m2 name];
		if (NO == [s2 isEqualToString : [nnMgr defaultNoNameForBoard : b2]]) {
			if ([s1 isEqualToString : s2]) {
				return kSampleAsNameMask;
			}
		}
	}
	
	// メール欄
	if (kSampleAsMailMask & mask) { 
		s1 = [m1 mail];
		s2 = [m2 mail];
		if ([s1 isEqualToString : s2]) {
			return kSampleAsMailMask;
		}
	}
	
	// 本文
	if (kSampleAsMessageMask & mask) { 
		s1 = [m1 messageSource];
		s2 = [m2 messageSource];
		if ([s1 isEqualToString : s2]) {
			return kSampleAsMessageMask;
		}
	}
	return 0;
}

// 設定されていないID や よくある名前等は比較対象にしない
static BOOL checkMailIsNonSignificant_(NSString *mail)
{
	NSCharacterSet	*cset;
	
	if (nil == mail || 0 == [mail length] || 
		[mail isEqualToString : CMRThreadMessage_AGE_String] ||
		[mail isEqualToString : CMRThreadMessage_SAGE_String] ||
		[mail isEqualToString : @"0"]) 
	{
		UTIL_DEBUG_WRITE1(@"mail:%@ was nonsignificant.", mail);
		return YES;
	}
	
	// 数字のみ
	cset = [NSCharacterSet decimalDigitCharacterSet];
	if (NSEqualRanges([mail rangeOfCharacterFromSet:cset], [mail range])) {
		UTIL_DEBUG_WRITE1(
			@"mail:%@ was decimalDigits, so nonsignificant.", mail);
		return YES;
	}
		
	return NO;
}


// 名前欄のチェック
static BOOL checkNameIsNonSignificant_(NSString *name)
{
	if (nil == name || 0 == [name length]) {
		UTIL_DEBUG_WRITE1(
			@"name:%@ was empty, so was nonsignificant.", name);
		return YES;
	}
	return NO;
}

// ID 欄のチェック
static BOOL checkIDIsNonSignificant_(NSString *idStr_)
{
	// ID が 0 or 1文字、または「???」で始まるとき
	if (nil == idStr_ || 2 > [idStr_ length] || [idStr_ hasPrefix : @"???"]) 
	{
		UTIL_DEBUG_WRITE1(@"ID:%@ was nonsignificant.", idStr_);
		return YES;
	}

	return NO;
}

static BOOL checkNameHasResLink_(NSString *name)
{
	NSScanner		*scanner;
	NSCharacterSet	*cset;
	
	// >> xx: レスへのリンクも無視する
	scanner = [NSScanner scannerWithString : name];
	cset = [NSCharacterSet innerLinkPrefixCharacterSet];
	[scanner scanCharactersFromSet:cset intoString:NULL];
	cset = [NSCharacterSet whitespaceCharacterSet];
	[scanner scanCharactersFromSet:cset intoString:NULL];
	
	while (1) {
		cset = [NSCharacterSet numberCharacterSet_JP];
		if (NO == [scanner scanCharactersFromSet:cset intoString:NULL])
			break;
		cset = [NSCharacterSet whitespaceCharacterSet];
		[scanner scanCharactersFromSet:cset intoString:NULL];
		if ([scanner isAtEnd]) {
			
			UTIL_DEBUG_WRITE1(
				@"name:%@ was ResLink, so was nonsignificant.",
				name);
			
			return YES;
			break;
		}
		cset = [NSCharacterSet innerLinkRangeCharacterSet];
		[scanner scanCharactersFromSet:cset intoString:NULL];
		cset = [NSCharacterSet innerLinkSeparaterCharacterSet];
		[scanner scanCharactersFromSet:cset intoString:NULL];
		cset = [NSCharacterSet whitespaceCharacterSet];
		[scanner scanCharactersFromSet:cset intoString:NULL];
	}
	
	return NO;
}
/*
無視リスト：
メール欄："sage", "age", "0"
名前：レスリンク、板の名無し


（ID）板と ID が一致
（名前）サンプルに同じ名前が複数あり、ID が異なる場合は名前を使用する
（メール欄）名前もIDも無視する場合は考慮する
（本文）内容が一致

@param sample 追加予定のサンプル
@param table  これまで追加されたサンプルの辞書。
			　キーは名前かID（エンティティ解決等はしない）
*/

static void setupAppendingSample_(CMRMessageSample *sample, NSMutableDictionary *table)
{
	CMRThreadMessage	*m = [sample message];
	CMRThreadSignature	*t = [sample threadIdentifier];
	NSString			*b = [t BBSName];
	unsigned			sign;		// 考慮する項目のフラグ
	NSString			*s;
	id					tmp;
	CMRThreadMessage	*tmp_m;
	
	UTILCAssertNotNil(sample);
	UTILCAssertNotNil(table);
	
	// 基本的にメール欄とホスト、名前欄（スレッド限定）は無視する
	sign = kSampleAsAny;
	sign &= ~kSampleAsMailMask;
	sign &= ~kSampleAsHostMask;
	sign &= ~kSampleAsThreadLocalMask;
	
	
	/* ID */
	s = [[m IDString] stringByStriped];
	//if (nil == s || [s length] < 4)
	if (checkIDIsNonSignificant_(s))
	{
		UTIL_DEBUG_WRITE1(@"ID:%@ was nonsignificant.", s);
		sign &= ~kSampleAsIDMask; 
	} else {
		// ID で登録
		[table setObject:sample forKey:[m IDString]];
	}
	/* Host */
	s = [[m host] stringByStriped];
	if ([s length] != 0) {
		// Host で登録
		sign |= kSampleAsHostMask; 
		[table setObject:sample forKey:[m IDString]];
	}
	
	
	/* Name */
	// エンティティ参照を解決し、名前を正規化
	// 板の名無しと同じ名前なら無視
	s = [[m name] stringByReplaceEntityReference];
	tmp = [[BoardManager defaultManager] defaultNoNameForBoard : b];
	if (s != nil && [s isEqualToString : tmp]) {
		UTIL_DEBUG_WRITE1(
			@"name:%@ was default NO_NAME, was nonsignificant.", s);
		sign &= ~kSampleAsNameMask;
	} else {
		// 名前の文字列で検証
		s = [s stringByStriped];
		if (checkNameIsNonSignificant_(s)) {
			sign &= ~kSampleAsNameMask;
		} else if (checkNameHasResLink_(s)) {
			// レスへのリンク
			// 同一スレッド上でひとつ前に登録されていれば
			// スレッドローカルで考慮する
			sign &= ~kSampleAsNameMask;
			
			tmp = [table objectForKey : t];
			tmp_m = [(CMRMessageSample*)tmp message];
			if (tmp && tmp_m && [[tmp_m name] isEqualToString : [m name]]) {
				if (0 == ([tmp_m property] & kSampleAsThreadLocalMask)) {
					UTIL_DEBUG_WRITE2(
						@"name:%@ was duplicate ResLink in thread(%@)"
						@", so it will be added as thread-local", 
						s, t);
					sign |= kSampleAsThreadLocalMask;
				}
			} else if (t != nil){
				UTIL_DEBUG_WRITE2(
					@"name:%@ was ResLink in thread(%@)"
					@", but it can be added as thread-local", 
					s, t);
				// スレッド で登録
				[table setObject:sample forKey:t];
			}
		}
	}
	
	if ((sign & kSampleAsNameMask) != 0) {
		if ((sign & kSampleAsIDMask) || (sign & kSampleAsHostMask)) {
			// すでに一度名前で登録されており、かつ
			// ID/Host が異なり（または ID/Host がない）、
			// すでに有効になっていない場合のみ
			// 名前も考慮に含める
			
			sign &= ~kSampleAsNameMask;
			tmp = [table objectForKey : [m name]];
			tmp_m = [(CMRMessageSample*)tmp message];
			if (tmp && tmp_m && (0 == ([tmp_m property] & kSampleAsNameMask))) {
				BOOL	q = YES;
				
				if ((sign & kSampleAsIDMask))
					q = q && (NO == [[tmp_m IDString] isEqualToString : [m IDString]]);
				if ((sign & kSampleAsHostMask))
					q = q && (NO == [[tmp_m host] isEqualToString : [m host]]);
				
				if (q) {
					sign |= kSampleAsNameMask;
					UTIL_DEBUG_WRITE1(
						@"name:%@ was duplicate and has identical ID"
						@", so it will be added.", s);
					[table setObject:sample forKey:[m name]];
				}
			} else {
				// 名前 で登録
				[table setObject:sample forKey:[m name]];
			}
		} else {
			// ID/Host がなければ名前
			sign |= kSampleAsNameMask;
			UTIL_DEBUG_WRITE1(
				@"name:%@ will be added.", s);
			[table setObject:sample forKey:[m name]];
		}
	} else {
		if (0 == (sign & kSampleAsIDMask)) {
			/* Name */
			// 名前もIDも使えない場合のみ
			// メール欄の文字列で検証
			s = [[[m mail] stringByReplaceEntityReference] stringByStriped];
			if (NO == checkMailIsNonSignificant_(s)) {
				UTIL_DEBUG_WRITE1(
					@"mail:%@ will be added.", s);
				sign |= kSampleAsMailMask;
			} else {
				// ID、名前、メール欄、いずれでも区別できない
			}
		}
	}
	
	[m setProperty : sign];
}

