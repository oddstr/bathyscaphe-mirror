/**
  * $Id: CMRMessageFilter.m,v 1.12 2007/09/04 07:45:43 tsawada2 Exp $
  * 
  * CMRMessageFilter.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRMessageFilter.h"
//#import "CocoMonar_Prefix.h"
#import "CMRThreadMessage.h"
#import "CMRThreadSignature.h"
#import "CMXTextParser.h"

#import "BSNGExpression.h"
#import <OgreKit/OgreKit.h>
// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"

static int detectMessageAny_(
				CMRMessageSample *s,
				CMRThreadMessage *m,
				CMRThreadSignature *t,
				NSArray *noNamesArray);
static int doDetectMessageAny_(
				CMRThreadMessage	*m1,	// sample
				CMRThreadSignature	*t1,	// sample
				CMRThreadMessage	*m2,	// target
				CMRThreadSignature	*t2,	// target
				NSArray *noNamesArray);

// �ݒ肳��Ă��Ȃ�ID �� �悭���閼�O���͔�r�Ώۂɂ��Ȃ�
static BOOL checkMailIsNonSignificant_(NSString *mail);
static BOOL checkNameIsNonSignificant_(NSString *name);
static BOOL checkIDIsNonSignificant_(NSString *idStr_);
static BOOL checkNameHasResLink_(NSString *name);


@implementation CMRMessageDetecter
/* primitive */
- (BOOL)detectMessage:(CMRThreadMessage *)aMessage
{
	return NO;
}
@end

@implementation CMRSamplingDetecter
- (SGBaseCArrayWrapper *)samples
{
	if (!_samples) {
		_samples = [[SGBaseCArrayWrapper alloc] init];
	}
	return _samples;
}

- (NSArray *)sampleArray
{
	return [self samples];
}

- (unsigned)numberOfSamples
{
	return [[self sampleArray] count];
}

- (void)dealloc
{
	[_samples release];
	[_corpus release];
	[_table release];
	[m_noNameArray release];
	[super dealloc];
}

#pragma mark  CMRPropertyListCoding

#define kSamplesKey			@"Samples"

- (BOOL)initializeWithPropertyListRepresentation:(id)rep
{
	NSEnumerator		*iter_;
	id					item_;
	
	if (![rep isKindOfClass:[NSDictionary class]]) return NO;
	item_ = [rep arrayForKey:kSamplesKey];
	if (!item_) return NO;

	iter_ = [item_ objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		CMRMessageSample	*sample_;
		
		sample_ = [CMRMessageSample objectWithPropertyListRepresentation:item_];
		if (!sample_) return NO;

		[self addNewMessageSample:sample_];
	}
	
	return YES;
}

- (id)initWithPropertyListRepresentation:(id)rep
{
	if (self = [self init]) {
		if (![self initializeWithPropertyListRepresentation:rep]) {
			[self release];
			return nil;
		}
	}
	return self;
}

+ (id)objectWithPropertyListRepresentation:(id)rep
{
	return [[[self alloc] initWithPropertyListRepresentation:rep] autorelease];
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

- (NSArray *)sampleArrayByCompacting
{
	NSEnumerator			*iter_;
	CMRMessageSample		*item_;
	NSMutableArray			*compacted_;
	
	compacted_ = [NSMutableArray array];
	iter_ = [[self sampleArray] objectEnumerator];

	while (item_ = [iter_ nextObject]) {
		if ([compacted_ containsObject:item_]) {
			// �d������v�f
			continue;
		}
		[compacted_ addObject:item_];
	}
	
	[compacted_ sortUsingFunction:compareAsMatchedCount_ context:NULL];

	return compacted_;
}

- (id)propertyListRepresentation
{
	NSEnumerator			*iter_;
	CMRMessageSample		*item_;
	NSMutableArray			*samplesRep_;
	
	samplesRep_ = [NSMutableArray array];
	iter_ = [[self sampleArrayByCompacting] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		[samplesRep_ addObject:[item_ propertyListRepresentation]];
	}
	
	return [NSDictionary dictionaryWithObject:samplesRep_ forKey:kSamplesKey];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)aDictionary
{
	return [self initWithPropertyListRepresentation:aDictionary];
}

- (NSDictionary *)dictionaryRepresentation
{
	return [self propertyListRepresentation];
}

#pragma mark Detecting
- (NSMutableDictionary *)samplesTable
{
	if (!_table) {
		_table = [[NSMutableDictionary alloc] init];
	}
	return _table;
}

- (void)clear
{
	[[self samples] removeAllObjects];
	[[self samplesTable] removeAllObjects];
}

- (NSArray *)corpus
{
	return _corpus;
}

- (void)setCorpus:(NSArray *)aCorpus
{
	id		tmp;
	
	tmp = _corpus;
	_corpus = [aCorpus retain];
	[tmp release];
}

- (NSArray *)noNameArrayAtWorkingBoard
{
	return m_noNameArray;
}

- (void)setNoNameArrayAtWorkingBoard:(NSArray *)anArray
{
	[anArray retain];
	[m_noNameArray release];
	m_noNameArray = anArray;
}

- (BOOL)nanashiAllowedAtWorkingBoard
{
	return _nanashiAllowed;
}

- (void)setNanashiAllowedAtWorkingBoard:(BOOL)allowed
{
	_nanashiAllowed = allowed;
}

- (void)addNewMessageSample:(CMRMessageSample *)aSample
{
	[self setupAppendingSampleForSample:aSample table:[self samplesTable]];
	[[self samples] addObject:aSample];
}

- (void)addSamplesFromDetecter:(CMRSamplingDetecter *)aDetecter
{
	NSEnumerator		*iter_;
	CMRMessageSample	*sample_;

	if (!aDetecter || 0 == [aDetecter numberOfSamples])
		return;
	
	iter_ = [[aDetecter sampleArray] objectEnumerator];
	while (sample_ = [iter_ nextObject]) {
		[self addNewMessageSample:sample_];
	}
}

- (void)addSample:(CMRThreadMessage *)aMessage with:(CMRThreadSignature *)aThread
{
	CMRMessageSample	*sample_;
	CMRThreadMessage	*message_;

	UTILAssertNotNilArgument(aMessage, @"Sample Message");
	
	message_ = [[aMessage copyWithZone:[self zone]] autorelease];
	[message_ clearTemporaryAttributes];
	
	[message_ setSpam:YES];
	[message_ setProperty:kSampleAsAny];

	sample_ = [CMRMessageSample sampleWithMessage:message_ withThread:aThread];
	[self addNewMessageSample:sample_];
}

- (void)removeSampleCache:(CMRMessageSample *)aSample with:(CMRThreadSignature *)aThread
{
	NSMutableDictionary	*sampleTbl = [self samplesTable];
	CMRMessageSample	*mSample;
	CMRThreadMessage	*sampleMsg;
	id					key;

	sampleMsg = [aSample message];
	
	key = [sampleMsg IDString];
	mSample = [sampleTbl objectForKey:key];
	if (mSample == aSample) {
		UTIL_DEBUG_WRITE(@"ID Cache Removed");
		[sampleTbl removeObjectForKey:key];
	}
	key = [sampleMsg name];
	mSample = [sampleTbl objectForKey:key];
	if (mSample == aSample) {
		UTIL_DEBUG_WRITE(@"Name Cache Removed");
		[sampleTbl removeObjectForKey:key];
	}
	key = [sampleMsg host];
	mSample = [sampleTbl objectForKey:key];
	if (mSample == aSample) {
		UTIL_DEBUG_WRITE(@"Host Cache Removed");
		[sampleTbl removeObjectForKey:key];
	}
	key = aThread;
	mSample = [sampleTbl objectForKey:key];
	if (mSample == aSample) {
		UTIL_DEBUG_WRITE(@"ThreadLocal Cache Removed");
		[sampleTbl removeObjectForKey:key];
	}
}

- (void)removeSample:(CMRThreadMessage *)aMessage with:(CMRThreadSignature *)aThread
{
	SGBaseCArrayWrapper	*mArray = [self samples];
	CMRMessageSample	*mSample;
	NSArray				*mSet = [self noNameArrayAtWorkingBoard];
	int					i;
	// ��v������̂����ׂĎ�菜��
	for (i = [mArray count] -1; i >= 0; i--) {
		mSample = SGBaseCArrayWrapperObjectAtIndex(mArray, i);
		if (detectMessageAny_(mSample, aMessage, aThread, mSet)) {
			UTIL_DEBUG_WRITE2(@"Sample:%u %@ was removed.", i, mSample);
			[self removeSampleCache:mSample with:aThread];
			[mArray removeObjectAtIndex:i];
		}
	}
}

- (BOOL)detectMessage:(CMRThreadMessage *)aMessage
{
	return [self detectMessage:aMessage with:nil];
}

- (NSArray *)NGExpressionsForTargetMask:(unsigned int)mask
{
	NSMutableArray *array = [NSMutableArray array];
	NSEnumerator *iter = [[self corpus] objectEnumerator];
	BSNGExpression	*expression;

	while (expression = [iter nextObject]) {
		if ([expression targetMask] & mask) {
			[array addObject:expression];
		}
	}

	return (NSArray *)array;
}

- (BOOL)detectStringUsingCorpus:(NSString *)source targetMask:(unsigned int)mask
{
	NSArray *NGExpressions = [self NGExpressionsForTargetMask:mask];
	NSEnumerator *iter = [NGExpressions objectEnumerator];
	BSNGExpression	*NGExp;

//	OgreSyntax syntax;
	OGRegularExpression *regExp;

	while (NGExp = [iter nextObject]) {
/*		if ([NGExp isRegularExpression] && [NGExp validAsRegularExpression]) {
			syntax = OgreRubySyntax;
		} else {
			syntax = OgreSimpleMatchingSyntax;
		}

		regexp = [[OGRegularExpression alloc] initWithString:[NGExp expression]
													 options:OgreNoneOption
													  syntax:syntax
											 escapeCharacter:OgreBackslashCharacter];

		if ([regexp matchInString:source]) {
			[regexp release];
			return YES;
		}
		[regexp release];*/
		if (regExp = [NGExp OGRegExpInstance]) {
			if ([regExp matchInString:source]) return YES;
		} else {
			if ([source rangeOfString:[NGExp expression] options:NSLiteralSearch].length != 0) return YES;
		}
	}
	return NO;
}

- (BOOL)detectMessageUsingCorpus:(CMRThreadMessage *)aMessage
{
	if (![self corpus]) return NO;

	NSMutableString *name_, *mail_, *message_;
	NSString	*field;

	// ���O
	field = [aMessage name];
	if (!checkNameIsNonSignificant_(field)) {
		if (![self nanashiAllowedAtWorkingBoard] || ![[self noNameArrayAtWorkingBoard] containsObject:field]) {
			name_ = [[field mutableCopy] autorelease];
			[CMXTextParser convertMessageSourceToCachedMessage:name_];
			if ([self detectStringUsingCorpus:name_ targetMask:BSNGExpressionAtName]) {
				return YES;
			}
		}
	}

	// ���[��
	field = [aMessage mail];
	if (!checkMailIsNonSignificant_(field)) {
		mail_ = [[field mutableCopy] autorelease];
		[CMXTextParser replaceEntityReferenceWithString:mail_];
		if ([self detectStringUsingCorpus:mail_ targetMask:BSNGExpressionAtMail]) {
			return YES;
		}
	}
	
	// �{��
	field = [aMessage messageSource];
	message_ = [[field mutableCopy] autorelease];
	[CMXTextParser convertMessageSourceToCachedMessage:message_];
	if ([self detectStringUsingCorpus:message_ targetMask:BSNGExpressionAtMessage]) {
		return YES;
	}

	return NO;
}

- (BOOL) detectMessage : (CMRThreadMessage   *) aMessage
			      with : (CMRThreadSignature *) aThread
{
	SGBaseCArrayWrapper	*sampleArray = [self samples];

	NSDictionary		*cacheDict = [self samplesTable];
	NSArray	*array_ = [self noNameArrayAtWorkingBoard];
	CMRMessageSample	*sample;
	int					i, cnt;
	id cache[4];
	
	// ----------------------------------------
	// �ȉ��̍��ڂŃL���b�V������D��I�ɔ�r
	// { ID, Host, Name, Thread ID }
	// ----------------------------------------
	/* key ��ݒ� */
	cache[0] = [aMessage IDString];
	cache[1] = [aMessage host];
	cache[2] = [aMessage name];
	cache[3] = aThread;
	
	for (i = 0, cnt = UTILNumberOfCArray(cache); i < cnt; i++) {
		sample = [cacheDict objectForKey : cache[i]];
		if (sample != nil) {
			if (detectMessageAny_(sample, aMessage, aThread, array_)) {//set_)) {
				return YES;
			}
		}
		cache[i] = sample;
	}

	for (i = 0, cnt = [sampleArray count]; i < cnt; i++) {
		sample = SGBaseCArrayWrapperObjectAtIndex(sampleArray, i);
		if (detectMessageAny_(sample, aMessage, aThread, array_))
			return YES;
	}

	// ���W���Ɣ�r
	if ([self detectMessageUsingCorpus:aMessage])
		return YES;
	
	return NO;
}

/*
�������X�g�F
���[�����F"sage", "age", "0"
���O�F���X�����N�A�̖�����


�iID�j�� ID ����v
�i���O�j�T���v���ɓ������O����������AID ���قȂ�ꍇ�͖��O���g�p����
�i���[�����j���O��ID����������ꍇ�͍l������
�i�{���j���e����v

@param sample �ǉ��\��̃T���v��
@param table  ����܂Œǉ����ꂽ�T���v���̎����B
			�@�L�[�͖��O��ID�i�G���e�B�e�B�������͂��Ȃ��j
*/
- (void) setupAppendingSampleForSample: (CMRMessageSample *) sample table: (NSMutableDictionary *) table
{
	CMRThreadMessage	*m = [sample message];
	CMRThreadSignature	*threadIdentifier = [sample threadIdentifier];
	unsigned			sign;		// �l�����鍀�ڂ̃t���O
	NSString			*s;
	id					tmp;
	CMRThreadMessage	*tmp_m;
	NSString			*tmpString;
	
	UTILCAssertNotNil(sample);
	UTILCAssertNotNil(table);
	
	// ��{�I�Ƀ��[�����ƃz�X�g�A���O���i�X���b�h����j�͖�������
	sign = kSampleAsAny;
	sign &= ~kSampleAsMailMask;
	sign &= ~kSampleAsHostMask;
	sign &= ~kSampleAsThreadLocalMask;
	
	
	/* ID */
	tmpString = [m IDString];

	if (!tmpString || checkIDIsNonSignificant_([tmpString stringByStriped])) {
	   // ID ���Ȃ����A�d�v�łȂ��BID �𖳎��B
		sign &= ~kSampleAsIDMask; 
	} else {
		// ID �œo�^
		[table setObject:sample forKey:tmpString];
	}

	/* Host */
	tmpString = [m host];
	s = [tmpString stringByStriped];
	if ([s length] > 0) {
		// Host �œo�^
		sign |= kSampleAsHostMask; 
		[table setObject:sample forKey:tmpString];
	}
	
	/* Name */
	// �G���e�B�e�B�Q�Ƃ��������A���O�𐳋K��
	tmpString = [m name];
//	s = [tmpString stringByReplaceEntityReference];

//    if (!s) sign &= ~kSampleAsNameMask;

//	if (![self nanashiAllowedAtWorkingBoard] || [[self noNameArrayAtWorkingBoard] containsObject:s]) {
    	// �̖������Ɠ������O�B�܂��͔̖������Ɠ������O�ł͂Ȃ����A���̔ł͖��O���K�{�B�����B
//	    sign &= ~kSampleAsNameMask;
//	} else {
	if (![self nanashiAllowedAtWorkingBoard] || [[self noNameArrayAtWorkingBoard] containsObject:tmpString]) {
		sign &= ~kSampleAsNameMask;
	} else {
		// ���O�̕�����Ō���
		s = [tmpString stringByReplaceEntityReference];
		s = [s stringByStriped];
		if (checkNameIsNonSignificant_(s)) {
            // �d�v�łȂ����O
			sign &= ~kSampleAsNameMask;
		} else if (checkNameHasResLink_(s)) {
			// ���X�ւ̃����N
			// ����X���b�h��łЂƂO�ɓo�^����Ă����
			// �X���b�h���[�J���ōl������
			sign &= ~kSampleAsNameMask;
			
			tmp = [table objectForKey : threadIdentifier];
			tmp_m = [(CMRMessageSample*)tmp message];
			if (tmp && tmp_m && [[tmp_m name] isEqualToString : tmpString]) {
				if (0 == ([tmp_m property] & kSampleAsThreadLocalMask)) {
					sign |= kSampleAsThreadLocalMask;
				}
			} else if (threadIdentifier) {
				// �X���b�h �œo�^
				[table setObject:sample forKey:threadIdentifier];
			}
		}
	}

    // �����܂ł̃t�B���^�����O�Ŗ��O���l������O������Ă��Ȃ�
	if ((sign & kSampleAsNameMask) != 0) {
		if ((sign & kSampleAsIDMask) || (sign & kSampleAsHostMask)) {
			// ���łɈ�x���O�œo�^����Ă���A����
			// ID/Host ���قȂ�i�܂��� ID/Host ���Ȃ��j�ꍇ�ɁA
			// ���O�œo�^
			
			sign &= ~kSampleAsNameMask;
			tmp = [table objectForKey : tmpString];
			tmp_m = [(CMRMessageSample*)tmp message];
			if (tmp && tmp_m && (0 == ([tmp_m property] & kSampleAsNameMask))) {
				BOOL	q = YES;
				
				if ((sign & kSampleAsIDMask))
					q = q && (NO == [[tmp_m IDString] isEqualToString : [m IDString]]);
				if ((sign & kSampleAsHostMask))
					q = q && (NO == [[tmp_m host] isEqualToString : [m host]]);
				
				if (q) {
					sign |= kSampleAsNameMask;
					[table setObject:sample forKey:tmpString];
				}
			} else {
				// ���O�œo�^
				[table setObject:sample forKey:tmpString];
			}
		} else {
			// ID �� Host ���Ȃ��̂ŁA���O�œo�^
			sign |= kSampleAsNameMask;
			[table setObject:sample forKey:tmpString];
		}
	} else {
		if (0 == (sign & kSampleAsIDMask)) {
			/* Name */
			// ���O��ID���g���Ȃ��ꍇ�̂�
			// ���[�����̕�����Ō���
			s = [[[m mail] stringByReplaceEntityReference] stringByStriped];
			if (!checkMailIsNonSignificant_(s)) {
				sign |= kSampleAsMailMask;
//			} else {
				// ID�A���O�A���[�����A������ł���ʂł��Ȃ�
			}
		}
	}
	
	[m setProperty : sign];
}
@end

#pragma mark Static Funcs

static int detectMessageAny_(CMRMessageSample *s, CMRThreadMessage *m, CMRThreadSignature *t, NSArray *noNamesArray)
{
	int		match;
	
	match = doDetectMessageAny_([s message], [s threadIdentifier], m, t, noNamesArray);
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
				CMRThreadSignature	*t2,	// target
				NSArray *noNamesArray)
{
	BOOL				Eq_b, Eq_t;
	unsigned			mask = [m1 property];
	
	NSString			*b1 = [t1 BBSName];
	NSString			*b2 = [t2 BBSName];
	NSString			*s1, *s2;
	
	Eq_t = [t1 isEqual : t2];
	Eq_b = (NO == Eq_t) ? [b1 isEqualToString : b2] : YES;

	if (Eq_b) { // ����AID �܂��� Host �̈�v���`�F�b�N�i����łȂ��Ȃ� ID�AHost �͌���\�����Ȃ��j�i�X�����薼�O���j
		if (kSampleAsIDMask & mask) {
			s1 = [m1 IDString];
			s2 = [m2 IDString];
			
			if ([s1 isEqualToString : s2]) {
				// ����ł��AID ����v
				return kSampleAsIDMask;
			}
		}
		
		if (kSampleAsHostMask & mask) {
			s1 = [m1 host];

			if ([s1 length] > 1 && [s1 isEqualToString : [m2 host]]) {
				// ����ł��AHost ����v
				// 2005-02-13 �C���F����ł��AHost ���񕶎��ȏ�A���AHost ����v
				// �g�сEPC ��ʂ�0,o�΍�
				return kSampleAsHostMask;
			}
		}
	
		// ���O�i�X���b�h����j// ���R�A�����
		if (kSampleAsThreadLocalMask & mask) { 
			if (Eq_t) {
				s1 = [m1 name];
				s2 = [m2 name];
				
				if ([s1 isEqualToString : s2]) {
					// ����X���b�h�ł����O����v
					return kSampleAsThreadLocalMask;
				}
			}
		}
	}
	// ���O
	if (kSampleAsNameMask & mask) { 
		s2 = [m2 name];
//		if (NO == [noNamesSet containsObject: s2]) {
		if (![noNamesArray containsObject:s2]) {
			if ([[m1 name] isEqualToString : s2]) {
				return kSampleAsNameMask;
			}
		}
	}
	
	// ���[����
	if (kSampleAsMailMask & mask) { 
		s1 = [m1 mail];
		s2 = [m2 mail];
		if ([s1 isEqualToString : s2]) {
			return kSampleAsMailMask;
		}
	}
	
	// �{��
	if (kSampleAsMessageMask & mask) { 
		s1 = [m1 messageSource];
		s2 = [m2 messageSource];
		if ([s1 isEqualToString : s2]) {
			return kSampleAsMessageMask;
		}
	}
	return 0;
}

// �ݒ肳��Ă��Ȃ�ID �� �悭���閼�O���͔�r�Ώۂɂ��Ȃ�
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
	
	// �����̂�
	cset = [NSCharacterSet decimalDigitCharacterSet];
	if (NSEqualRanges([mail rangeOfCharacterFromSet:cset], [mail range])) {
		UTIL_DEBUG_WRITE1(
			@"mail:%@ was decimalDigits, so nonsignificant.", mail);
		return YES;
	}
		
	return NO;
}


// ���O���̃`�F�b�N
static BOOL checkNameIsNonSignificant_(NSString *name)
{
	if (nil == name || 0 == [name length]) {
		UTIL_DEBUG_WRITE1(
			@"name:%@ was empty, so was nonsignificant.", name);
		return YES;
	}
	return NO;
}

// ID ���̃`�F�b�N
static BOOL checkIDIsNonSignificant_(NSString *idStr_)
{
	// ID �� 0 or 1�����A�܂��́u???�v�Ŏn�܂�Ƃ�
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
	NSCharacterSet	*whiteCset = [NSCharacterSet whitespaceCharacterSet];
	
	// >> xx: ���X�ւ̃����N����������
	scanner = [NSScanner scannerWithString : name];
	cset = [NSCharacterSet innerLinkPrefixCharacterSet];
	[scanner scanCharactersFromSet:cset intoString:NULL];

	[scanner scanCharactersFromSet: whiteCset intoString: NULL];
	
	while (1) {
		cset = [NSCharacterSet numberCharacterSet_JP];
		if (NO == [scanner scanCharactersFromSet:cset intoString:NULL])
			break;

		[scanner scanCharactersFromSet: whiteCset intoString: NULL];
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

		[scanner scanCharactersFromSet: whiteCset intoString: NULL];
	}
	
	return NO;
}
