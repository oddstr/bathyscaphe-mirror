#import "BSIPIfoundationExtensions.h"

NSLock *CMRSingletonObjectFactoryLock = nil;

@implementation NSDictionary(BSIPIExtensionFromSG)

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

#undef PRIV_OBJECT_CONVERTION



- (float) floatForKey: (id) key defaultValue: (float) defaultValue
{
	NSNumber		*num_;
	
	num_ = [self numberForKey : key];
	return (num_ != nil) ? [num_ floatValue] : defaultValue;
}

- (BOOL) boolForKey: (id) key defaultValue: (BOOL) defaultValue
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


- (id) objectForKey: (id) key defaultObject: (id) defaultObject
{
	id obj;
	
	obj = [self objectForKey : key];
	return (nil == obj) ? defaultObject : obj;
}
@end

@implementation NSMutableDictionary(BSIPIExtensionFromSG)
#define PRIV_SET_NUMERIC_VALUE(aValue, aKey, methodName)	\
	NSNumber *v;\
	\
	if(nil == aKey) return;\
	\
	v = [NSNumber methodName : aValue];\
	[self setObject:v forKey:aKey]

- (void) setFloat: (float) aValue forKey: (id) aKey
{
	PRIV_SET_NUMERIC_VALUE(aValue, aKey, numberWithFloat);
}
- (void) setBool: (BOOL) aValue forKey: (id) aKey
{
	PRIV_SET_NUMERIC_VALUE(aValue, aKey, numberWithBool);
}
#undef PRIV_SET_NUMERIC_VALUE
@end
