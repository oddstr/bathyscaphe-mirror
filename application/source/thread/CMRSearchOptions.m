/**
  * $Id: CMRSearchOptions.m,v 1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * CMRSearchOptions.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRSearchOptions.h"
#import "CocoMonar_Prefix.h"



@implementation CMRSearchOptions
+ (id) operationWithFindObject : (id      ) fobj
                       replace : (id      ) replacement
                      userInfo : (id      ) info
					    option : (unsigned) opt
{
	return [[[self alloc] initWithFindObject : fobj
									 replace : replacement
									userInfo : info
									  option : opt] autorelease];
}
- (id) initWithFindObject : (id      ) aFindObject
                  replace : (id      ) aReplacement
                 userInfo : (id      ) aUserInfo
			       option : (unsigned) anOption
{
	if(self = [super init]){
		_findObject = [aFindObject retain];
		_replaceObject = [aReplacement retain];
		_userInfo = [aUserInfo retain];
		_findOption = anOption;
	}
	return self;
}

- (void) dealloc
{
	[_findObject release];
	[_replaceObject release];
	[_userInfo release];
	[super dealloc];
}

// NSObject
- (NSString *) description
{
	return [NSString stringWithFormat : 
				@"<%@ %p> find=%@ replace=%@ userInfo=%@ option=%u",
				[self className],
				self,
				[self findObject],
				[self replaceObject],
				[self userInfo],
				[self findOption]];
}
- (BOOL) isEqual : (id) other
{
	CMRSearchOptions	*other_ = other;
	id					obj1, obj2;
	BOOL				result = NO;
	
	if(nil == other) return NO;
	if(nil == self) return YES;
	
	if(NO == [self isHistoryEqual : other])
		return NO;
	
	obj1 = [self userInfo];
	obj2 = [other_ userInfo];
	result = (obj1 == obj2) ? YES : [obj1 isEqual : obj2];
	if(NO == result)
		return NO;
	
	return ([self findOption] == [other_ findOption]);
}

// CMRHistoryObject

/*
履歴の重複チェック
検索・置換文字列のみで比較
*/
- (BOOL) isHistoryEqual : (id) anObject
{
	if(nil == anObject) return NO;
	if(nil == self) return YES;
	
	if([anObject isKindOfClass : [self class]]){
		CMRSearchOptions	*other_ = anObject;
		id					obj1, obj2;
		BOOL				result = NO;
		
		obj1 = [self findObject];
		obj2 = [other_ findObject];
		result = (obj1 == obj2) ? YES : [obj1 isEqual : obj2];
		if(NO == result) return NO;
		
		obj1 = [self replaceObject];
		obj2 = [other_ replaceObject];
		result = (obj1 == obj2) ? YES : [obj1 isEqual : obj2];
		if(NO == result) return NO;
		
		return YES;
	}
	
	return NO;
}

// NSCopying
- (id) copyWithZone : (NSZone *) zone
{
	return [self retain];
}

// CMRPropertyListCoding
#define kRepresentationFindObjectKey		@"Find"
#define kRepresentationReplaceObjectKey		@"Replace"
#define kRepresentationUserInfoObjectKey	@"UserInfo"
#define kRepresentationOptionKey			@"Option"
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	id			findObject_;
	id			replaceObject_;
	id			userInfo_;
	unsigned	findOption_;
	
	if(nil == rep || NO == [rep isKindOfClass : [NSDictionary class]])
		return nil;
	
	findObject_ = [rep objectForKey : kRepresentationFindObjectKey];
	replaceObject_ = [rep objectForKey : kRepresentationReplaceObjectKey];
	userInfo_ = [rep objectForKey : kRepresentationUserInfoObjectKey];
	findOption_ = [rep unsignedIntForKey : kRepresentationOptionKey];
	
	return [self operationWithFindObject : findObject_
								 replace : replaceObject_
								userInfo : userInfo_
								  option : findOption_];
}

- (id) propertyListRepresentation
{
	NSMutableDictionary		*dict;
	
	dict = [NSMutableDictionary dictionary];
	
	[dict setNoneNil:[self findObject] forKey:kRepresentationFindObjectKey];
	[dict setNoneNil:[self replaceObject] forKey:kRepresentationReplaceObjectKey];
	[dict setNoneNil:[self userInfo] forKey:kRepresentationUserInfoObjectKey];
	[dict setUnsignedInt:[self findOption] forKey:kRepresentationOptionKey];

	return dict;
}

// NSCoding
- (id) initWithCoder : (NSCoder *) coder
{
	id		tmp;
	
	UTILMethodLog;
/*
	self = [super initWithCoder:coder];
*/
	if([coder supportsKeyedCoding]){
		
		tmp = [coder decodeObjectForKey:kRepresentationFindObjectKey];
		_findObject = [tmp retain];
		tmp = [coder decodeObjectForKey:kRepresentationReplaceObjectKey];
		_replaceObject = [tmp retain];
		tmp = [coder decodeObjectForKey:kRepresentationUserInfoObjectKey];
		_userInfo = [tmp retain];
		
		_findOption = [coder decodeInt32ForKey:kRepresentationOptionKey];
		
	}else{
		tmp = [coder decodeObject];
		_findObject = ([[NSNull null] isEqual : tmp]) ? nil : [tmp retain];
		tmp = [coder decodeObject];
		_replaceObject = ([[NSNull null] isEqual : tmp]) ? nil : [tmp retain];
		tmp = [coder decodeObject];
		_userInfo = ([[NSNull null] isEqual : tmp]) ? nil : [tmp retain];
		[coder decodeValueOfObjCType:@encode(unsigned int) at:&_findOption];
	}
	return self;
}

- (void) encodeWithCoder : (NSCoder *) encoder
{
	id		tmp;
	
	UTILMethodLog;
	
/*
	[super encodeWithCoder:encoder];
*/
	if([encoder supportsKeyedCoding]){
		tmp = [self findObject];
		if(tmp != nil)
			[encoder encodeObject:tmp forKey:kRepresentationFindObjectKey];
		
		tmp = [self replaceObject];
		if(tmp != nil)
			[encoder encodeObject:tmp forKey:kRepresentationReplaceObjectKey];
		
		tmp = [self userInfo];
		if(tmp != nil)
			[encoder encodeObject:tmp forKey:kRepresentationUserInfoObjectKey];
		
		[encoder encodeInt32:[self findOption] forKey:kRepresentationOptionKey];
	}else{
		tmp = [self findObject];
		if(nil == tmp) tmp = [NSNull null];
		[encoder encodeObject:tmp];

		tmp = [self replaceObject];
		if(nil == tmp) tmp = [NSNull null];
		[encoder encodeObject:tmp];

		tmp = [self userInfo];
		if(nil == tmp) tmp = [NSNull null];
		[encoder encodeObject:tmp];

		[encoder encodeValueOfObjCType:@encode(unsigned int) at:&_findOption];
	}
}


//////////////////////////////////////////////////////////////////////
////////////////////// [ アクセサメソッド ] //////////////////////////
//////////////////////////////////////////////////////////////////////

- (id) findObject
{
	return _findObject;
}
- (id) replaceObject
{
	return _replaceObject;
}
- (id) userInfo
{
	return _userInfo;
}
- (unsigned int) findOption
{
	return _findOption;
}


- (void) setOptionState : (BOOL        ) flag
                 option : (unsigned int) opt
{
	_findOption = flag ? (_findOption | opt) : (_findOption & (~opt));
}
@end
