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
//////////////////// [ �C���X�^���X���\�b�h ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * �P��A�܂��͕����̃N�b�L�[�ݒ���܂Ƃ߂�@"Set-Cookie"�w�b�_��
  * ��͂��A�K�؂Ȑ���Cookie�𐶐����A�z��Ɋi�[���ĕԂ��B
  * 
  * @param    header  �w�b�_
  * @return           Cookie�̔z��(���s���ɂ�nil)
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
	// �J���}�ŋ�؂��Ă��邪�A�L�������̃t�H�[�}�b�g�ɂ��J���}
	// ���܂܂�Ă��邽�߁A�P���ɐ؂蕪���邱�Ƃ͂ł��Ȃ��B
	// ex. expires=Wednesday, 24-Apr-2002 00:00:00 GMT 
	mstr_ = [NSMutableString stringWithString : header];
	//expires�̗j���̌�̃J���}���ЂƂ܂��A���̕�����(*)
	[mstr_ replaceCharacters : st_expsep_
	                toString : st_expsep2_];
	//��͕�
	{
		NSArray      *comps_;		//��؂蕶���Ő؂蕪��
		NSEnumerator *iter_;		//�����T��
		NSString     *item_;		//�e�P��
		
		comps_ = [mstr_ componentsSeparatedByString : st_sep_];
		iter_ = [comps_ objectEnumerator];
		while (item_ = [iter_ nextObject]) {
			Cookie *cookie_;
			
			item_ = [item_ stringByStriped];
			//(*)�̒u����߂��Ă����B
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
  * @"Set-Cookie"�ŗv�����ꂽ�N�b�L�[��ێ��B
  * 
  * @param    header    @"Set-Cookie"�w�b�_
  * @param    hostName  �v�����̃z�X�g��
  */
- (void) addCookies : (NSString *) header
         fromServer : (NSString *) hostName
{
	NSMutableArray *oldCookies_;		//�O��܂ł̃N�b�L�[
	NSArray        *newCookies_;		//�V�����ǉ�����N�b�L�[
	
	if (nil == header || nil == hostName) return;
	
	oldCookies_ = [[self cookies] objectForKey : hostName];
	// �V�K�쐬
	if (nil == oldCookies_)
		oldCookies_ = [NSMutableArray array];
	
	UTILAssertKindOfClass(oldCookies_, NSMutableArray);

	newCookies_ = [self scanSetCookieHeader : header];
	if (newCookies_ != nil) {
		NSEnumerator *iter_;		//�����T��
		Cookie       *cookie_;		//�e�N�b�L�[
		
		iter_ = [newCookies_ reverseObjectEnumerator];
		while (cookie_ = [iter_ nextObject]) {
			//�d������N�b�L�[�͎�菜���B
			[oldCookies_ removeObject : cookie_];
			[oldCookies_ addObject : cookie_];
		}
	}
	[self setCookiesArray:oldCookies_ forHost:hostName];
}
/**
  * ���M��ɑ���ׂ�URL������ꍇ�̓N�b�L�[�������Ԃ��B
  * 
  * @param    anURL  ���M��URL
  * @return          �N�b�L�[
  */
- (NSString *) cookiesForRequestURL : (NSURL *) anURL
{
	NSArray        *cookies_;		//�z�X�g�ɑΉ�����N�b�L�[
	NSEnumerator   *iter_;			//�����T��
	Cookie         *item_;			//�e�N�b�L�[
	NSMutableArray *avails_;		//����ׂ��N�b�L�[

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
	//���O�������ŁA�p�X�̈Ⴄ�N�b�L�[������ꍇ��
	//���[���}�b�`������̂𑗂�B
/*	iter_ = [avails_ objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		//���܂̂Ƃ��떢����
	}
*/
	// ������ be ���O�C���̂��߂̃N�b�L�[�ǉ��R�[�h
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
  * �����؂�̃N�b�L�[���폜����B
  */
- (void) deleteExpiredCookies
{
	[self setCookies : [self dictionaryByDeletingExpiredCookies : [self cookies]]];
}

/**
  * �����؂�̃N�b�L�[���폜���A�ώ����ŕԂ��B
  * 
  * @param    dict  ����
  * @return         �����؂�̃N�b�L�[���폜��������
  */
- (NSMutableDictionary *) dictionaryByDeletingExpiredCookies : (NSDictionary *) dict
{
	NSMutableDictionary *tmp_;		//��Ɨp
	NSEnumerator        *kiter_;	//���ׂẴL�[
	NSString            *host_;		//�e�L�[
	
	tmp_ = [NSMutableDictionary dictionary];
	if (nil == dict || 0 == [dict count]) return tmp_;
	
	kiter_ = [dict keyEnumerator];
	while (host_ = [kiter_ nextObject]) {
		NSMutableArray      *tmparray_;	//��Ɨp
		NSArray             *cookies_;		//���ׂẴN�b�L�[
		NSEnumerator        *citer_;		//�����T��
		id                   cookie_;		//�e�N�b�L�[
		
		cookies_ = [dict objectForKey : host_];
		if (nil == cookies_ || 0 == [cookies_ count]) continue;
		
		tmparray_ = [NSMutableArray array];
		citer_ = [cookies_ reverseObjectEnumerator];
		while (cookie_ = [citer_ nextObject]) {
			// �����̏ꍇ��Cookie�ɕϊ�
			if ([cookie_ isKindOfClass : [NSDictionary class]])
				cookie_ = [Cookie cookieWithDictionary : cookie_];
			if ([cookie_ isExpired : NULL])
				continue;
			// �����؂�łȂ��ꍇ�͈ڂ�
			[tmparray_ addObject : cookie_];
		}
		[tmp_ setObject : tmparray_
				 forKey : host_];
	}
	return [[tmp_ copy] autorelease];
}

/**
  * �t�@�C���Ƃ��ĕۑ��B
  * 
  * @param    path  �ۑ��ꏊ�̃p�X
  * @param    flag  NO�Ȃ璼�ځA�������ށB
  * @return         ��������YES
  */
- (BOOL) writeToFile : (NSString *) path
          atomically : (BOOL      ) flag
{
	return [[self dictionaryRepresentation] writeToFile : path
									         atomically : flag];
}

/**
  * ���V�[�o��ۑ��\�Ȏ����ŕԂ��B
  * 
  * @return     ����
  */
- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary		*tmp_;
	NSEnumerator			*kiter_;
	NSString				*host_;
	
	tmp_ = [NSMutableDictionary dictionary];
	kiter_ = [[self cookies] keyEnumerator];
	while (host_ = [kiter_ nextObject]) {
		NSMutableArray      *tmparray_;		//��Ɨp
		NSArray             *cookies_;		//���ׂẴN�b�L�[
		NSEnumerator        *citer_;		//�����T��
		Cookie              *cookie_;		//�e�N�b�L�[
		
		cookies_ = [[self cookies] objectForKey : host_];
		if (nil == cookies_ || 0 == [cookies_ count]) continue;
		
		tmparray_ = [NSMutableArray array];
		citer_ = [cookies_ reverseObjectEnumerator];
		while (cookie_ = [citer_ nextObject]) {
			BOOL whenTerminate_;
			
			whenTerminate_ = NO;
			if ([cookie_ isExpired : &whenTerminate_] || whenTerminate_)
				continue;
			//�����؂�łȂ��ꍇ��
			//�����`���Œǉ�
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
