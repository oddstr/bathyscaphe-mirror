//:Cookie.m
#import "Cookie.h"



//////////////////////////////////////////////////////////////////////
////////////////////// [ �萔��}�N���u�� ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* �N�b�L�[�̃I�v�V������ */
#define kCookieOptionPath			@"path"
#define kCookieOptionDomain			@"domain"
#define kCookieOptionExpires		@"expires"
#define kCookieOptionSecure			@"secure"
/* �����p */
#define kCookieOptionEnabled		@"x-application/CocoMonar enabled"
#define kCookieOptionBSEnabled		@"x-application/BathyScaphe enabled" // available in BathyScaphe 1.2.2/1.5 and later.



@implementation Cookie
//////////////////////////////////////////////////////////////////////
/////////////////////// [ �������E��n�� ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �ꎞ�I�u�W�F�N�g�̐����B
  * 
  * @return                 �ꎞ�I�u�W�F�N�g
  */
+ (id) cookie
{
	return [[[[self class] alloc] init] autorelease];
}

/**
  * �ꎞ�I�u�W�F�N�g�̐����B
  * ������\������C���X�^���X�𐶐��A�������B
  * 
  * @param      anyCookies  ������\��
  * @return     �ꎞ�I�u�W�F�N�g
  */
+ (id) cookieWithString : (NSString *) anyCookies
{
	return [[[[self class] alloc] initWithString : anyCookies] autorelease];
}

/**
  * �ꎞ�I�u�W�F�N�g�̐����B
  * �����I�u�W�F�N�g����C���X�^���X�𐶐��A�������B
  * 
  * @param      anyCookies  �����I�u�W�F�N�g
  * @return                 �ꎞ�I�u�W�F�N�g
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
  * �w��C�j�V�����C�U�B
  * ������\������C���X�^���X�𐶐��A�������B
  * 
  * @param    anyCookies  ������\��
  * @return               �������ς݂̃C���X�^���X
  */
- (id) initWithString : (NSString *) anyCookies
{
	if(self = [self init]){
		[self setCookieWithString : anyCookies];
	}
	return self;
}

/**
  * �w��C�j�V�����C�U�B
  * �����I�u�W�F�N�g����C���X�^���X�𐶐��A�������B
  * 
  * @param    anyCookies  �����I�u�W�F�N�g
  * @return               �������ς݂̃C���X�^���X
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
	[m_name release];		//���O
	[m_value release];		//�l
	[m_path release];		//�N�b�L�[���L���ł���URL�͈�
	[m_domain release];		//�N�b�L�[���L���ł���h���C���͈�
	[m_expires release];	//�L������
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////
////////////////////// [ �A�N�Z�T���\�b�h ] //////////////////////////
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
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * ���V�[�o�̃N�b�L�[���L����URL�Ȃ�YES��Ԃ��B
  * 
  * @param    anURL  �Ώ�URL
  * @return          �N�b�L�[���L����URL�Ȃ�YES
  */
- (BOOL) isAvalilableURL : (NSURL *) anURL
{
	if(nil == anURL) return NO;
	
	//path���w�肳��Ă���΁A�}�b�`���邩����
	if(nil == [self path]) return YES;
	return [[anURL path] hasPrefix : [self path]];
}

/**
  * �����؂�̏ꍇ��YES��Ԃ��B
  * �I�����ɔj�������ꍇ�ɂ�whenTerminate = YES
  *
  * @param   whenTerminate   �I�����ɔj�������ꍇ��YES
  * @return                  �����؂�̏ꍇ��YES
  */
- (BOOL) isExpired : (BOOL *) whenTerminate
{
	NSDate *exp_;
	
	exp_ = [self expiresDate];
	if(nil == exp_){
		//�I�����ɔj��
		if(whenTerminate != NULL) *whenTerminate = YES;
		return NO;
	}
	return [exp_ isBeforeDate : [NSDate date]];
}


/**
  * ���V�[�o�̂������`���ŕԂ��B
  * 
  * @return     �����I�u�W�F�N�g
  */
- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict_;
	
	dict_ = [NSMutableDictionary dictionary];
	//�I�v�V������ۑ�
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
	//�N�b�L�[��ۑ�
	if([self name] != nil && [self value] != nil){
		[dict_ setObject : [self value]
			      forKey : [self name]];
	}
	return dict_;
}


//:�A�N�Z�T
/**
  * �L��������Ԃ��B
  * 
  * @return     �L������
  */
- (NSDate *) expiresDate
{
	if(nil == [self expires]) return nil;
	return [NSCalendarDate dateWithHTTPTimeRepresentation : [self expires]];
}

//�N�b�L�[�̐ݒ�
/**
  * �N�b�L�[��ݒ�B
  * 
  * @param    aValue  �l
  * @param    aName   ���O
  */
- (void) setCookie : (id        ) aValue
           forName : (NSString *) aName
{
	if(nil == aValue || nil == aName) return;
	//�I�v�V�����w��̏ꍇ�̓C���X�^���X�ϐ��ɕێ�
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
  * �����񂩂�ϊ��B
  * �I�v�V�������w�肵���ꍇ�́A���������f�����B
  * 
  * ex : @"SPID=XWDtLhNY; expires=1016920836 GMT; path=/"
  * 
  * @param    anyCookies  ������\��
  */
- (void) setCookieWithString : (NSString *) anyCookies
{
	NSArray      *comps_;		//�g����z��I�u�W�F�N�g��
	NSEnumerator *iter_;		//��������
	NSString     *item_;		//�e�g
	
	if(nil == anyCookies) return;
	//UTILDebugLog(@"anyCookies = %@", anyCookies);
	comps_ = [anyCookies componentsSeparatedByString : @";"];
	if(nil == comps_ || 0 == [comps_ count]) return;
	//UTILDebugLog(@"comps_ = (%d)", [comps_ count]);

	iter_ = [comps_ objectEnumerator];
	while(item_ = [iter_ nextObject]){
		NSArray         *pair_;				//���O�A�l
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
		//�擪�A�����̋󔒂��폜
		[name_ strip];
		[value_ strip];
		//UTILDebugLog(@"name = %@", name_);
		[self setCookie : value_
		        forName : name_];
	}
}

/**
  * �����I�u�W�F�N�g����ϊ��B
  * �I�v�V�������w�肵���ꍇ�́A���������f�����B
  * 
  * 
  * @param    anyCookies  �����I�u�W�F�N�g
  */
- (void) setCookieWithDictionary : (NSDictionary *) anyCookies
{
	NSEnumerator    *iter_;		//�L�[����������
	NSString        *key_;		//�L�[
	
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
  * �N�b�L�[�𕶎���ŕ\���������̂�Ԃ��B
  * 
  * @return     ������\��
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
