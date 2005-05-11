/**
  * $Id: NSDictionary-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * NSDictionary-SGExtensions.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/NSDictionary-SGExtensions.h>
#import <SGFoundation/PrivateDefines.h>




@implementation NSDictionary(SGExtensions)
+ (id) empty
{
	static id kSharedInstance;
	if (nil == kSharedInstance)
		kSharedInstance = [[NSDictionary alloc] init];
	
	return kSharedInstance;
}



- (id) deepMutableCopy
{
	return [self deepMutableCopyWithZone : nil];
}

- (id) deepMutableCopyWithZone : (NSZone *) zone
{
	NSMutableDictionary *mdict_;		// 可変辞書
	NSEnumerator        *iter_;			// 順次探索
	id                   item_;			// 各アイテム
	id                   key;			// 各検索キー

	mdict_ = [self mutableCopyWithZone : zone];
	iter_ = [mdict_ keyEnumerator];
	
	while(key = [iter_ nextObject]){
		item_ = [mdict_ objectForKey : key];
		if([item_ respondsToSelector : @selector(deepMutableCopyWithZone:)]){
			item_ = [item_ deepMutableCopyWithZone : zone];
		}else if([item_ respondsToSelector : @selector(mutableCopyWithZone:)]){
			item_ = [item_ mutableCopyWithZone : zone];
		}else{
			// 可変オブジェクトのコピーがサポートされていない場合は
			// そのまま加える。
		}
		[mdict_ setObject : item_ 
				   forKey : key];
		[item_ release];
	}
	return mdict_;
}

#define PRIV_OBJECT_CONVERTION(keyArg, classNameArg)	\
	id		object_;\
	\
	object_ = [self objectForKey : key];\
	if((nil == object_) ||\
	   (NO == [object_ isKindOfClass : [classNameArg class]])){\
		return nil;\
	}\
	return object_

- (NSNumber *) numberForKey : (id) key
{
	PRIV_OBJECT_CONVERTION(key, NSNumber);
}
- (NSDictionary *) dictionaryForKey : (id) key;
{
	PRIV_OBJECT_CONVERTION(key, NSDictionary);
}
- (NSString *) stringForKey : (id) key
{
	PRIV_OBJECT_CONVERTION(key, NSString);
}
- (NSArray *) arrayForKey : (id) key
{
	PRIV_OBJECT_CONVERTION(key, NSArray);
}

#undef PRIV_OBJECT_CONVERTION



- (float) floatForKey : (id) key
         defaultValue : (float     ) defaultValue
{
	NSNumber		*num_;
	
	num_ = [self numberForKey : key];
	return (num_ != nil) ? [num_ floatValue] : defaultValue;
}

- (float) floatForKey : (id) key
{
	return [self floatForKey : key
				defaultValue : 0.0f];
}

- (double) doubleForKey : (id) key
           defaultValue : (double    ) defaultValue
{
	NSNumber *num_;
	num_ = [self numberForKey : key];
	return (num_ != nil) ? [num_ doubleValue] : defaultValue;
}

- (double) doubleForKey : (id) key
{
	return [self doubleForKey : key
	             defaultValue : 0.0];
}

- (BOOL) boolForKey : (id) key
       defaultValue : (BOOL      ) defaultValue
{
	id value_;
	
	value_ = [self objectForKey : key];
	if(value_ != nil){ 
		if([value_ isKindOfClass : [NSString class]] ||
		   [value_ isKindOfClass : [NSNumber class]]){
			return [value_ boolValue];
		}
	}
	return defaultValue;
}

- (BOOL) boolForKey : (id) key
{
	return [self boolForKey : key
	           defaultValue : NO];
}

- (int) integerForKey : (id) key
		 defaultValue : (int       ) defaultValue
{
	NSNumber *num_;
	num_ = [self numberForKey : key];
	return (num_ != nil) ? [num_ intValue] : defaultValue;
}

- (int) integerForKey : (id) key
{
	return [self integerForKey : key
				  defaultValue : 0];
}


- (unsigned) unsignedIntForKey : (id) key
				 defaultValue : (unsigned int) defaultValue
{
	NSNumber *num_;
	num_ = [self numberForKey : key];
	return (num_ != nil) ? [num_ unsignedIntValue] : defaultValue;
}
- (unsigned) unsignedIntForKey : (id) key
{
	return [self unsignedIntForKey : key
				      defaultValue : 0];
}



- (id) objectForKey : (id) key
      defaultObject : (id) defaultObject
{
	id obj;
	
	obj = [self objectForKey : key];
	return (nil == obj) ? defaultObject : obj;
}


- (NSPoint) pointForKey : (id) key
{
	id		obj;
	
	UTILRequireCondition(key, ErrConvert);
	obj = [self objectForKey : key];
	
	UTILRequireCondition(obj, ErrConvert);
	if([obj isKindOfClass : [NSString class]])
		return NSPointFromString(obj);
	if([obj respondsToSelector : @selector(pointValue)])
		return [obj pointValue];

ErrConvert:
	return NSZeroPoint;
}
- (NSRect) rectForKey : (id) key
{
	id		obj;
	
	UTILRequireCondition(key, ErrConvert);
	obj = [self objectForKey : key];
	
	UTILRequireCondition(obj, ErrConvert);
	if([obj isKindOfClass : [NSString class]])
		return NSRectFromString(obj);
	if([obj respondsToSelector : @selector(rectValue)])
		return [obj rectValue];

ErrConvert:
	return NSZeroRect;
}
- (NSSize) sizeForKey : (id) key
{
	id		obj;
	
	UTILRequireCondition(key, ErrConvert);
	obj = [self objectForKey : key];
	
	UTILRequireCondition(obj, ErrConvert);
	if([obj isKindOfClass : [NSString class]])
		return NSSizeFromString(obj);
	if([obj respondsToSelector : @selector(sizeValue)])
		return [obj sizeValue];

ErrConvert:
	return NSZeroSize;
}
@end



@implementation NSUserDefaults(SGExtensions030717)
- (int) integerForKey : (NSString *) key
		 defaultValue : (int       ) defaultValue
{
	id obj;
	
	obj = [self objectForKey : key];
	return (nil == obj || NO == [obj respondsToSelector : @selector(intValue)])
				? defaultValue : [obj intValue];
}
- (float) floatForKey : (NSString *) key
         defaultValue : (float     ) defaultValue
{
	id obj;
	
	obj = [self objectForKey : key];
	return (nil == obj || NO == [obj respondsToSelector : @selector(floatValue)])
				? defaultValue : [obj floatValue];
}
- (BOOL) boolForKey : (NSString *) key
       defaultValue : (BOOL      ) defaultValue
{
	id obj;
	
	obj = [self objectForKey : key];
	return (nil == obj || NO == [obj respondsToSelector : @selector(boolValue)])
				? defaultValue : [obj boolValue];
}
@end
