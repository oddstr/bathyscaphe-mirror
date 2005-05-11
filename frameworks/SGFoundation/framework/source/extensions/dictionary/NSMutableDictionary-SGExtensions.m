//: NSMutableDictionary-SGExtensions.m

#import <SGFoundation/NSMutableDictionary-SGExtensions.h>
#import <SGFoundation/PrivateDefines.h>
#import <Foundation/Foundation.h>



@implementation NSMutableDictionary(SGExtensions)
- (void) setNoneNil : (id) obj 
			 forKey : (id) key
{
	if(nil == obj || nil == key) return;
	[self setObject:obj forKey:key];
}
- (void) moveEntryWithKey : (id) key to : (id) other
{
	id	value_ = [self objectForKey : key];
	if(nil == value_) return;
	[value_ retain];
	[self removeObjectForKey : key];
	[self setObject:value_ forKey:other];
	[value_ release];
}


#define PRIV_SET_NUMERIC_VALUE(aValue, aKey, methodName)	\
	NSNumber *v;\
	\
	if(nil == aKey) return;\
	\
	v = [NSNumber methodName : aValue];\
	[self setObject:v forKey:aKey]

- (void) setFloat : (float) aValue
           forKey : (id   ) aKey
{
	PRIV_SET_NUMERIC_VALUE(aValue, aKey, numberWithFloat);
}

- (void) setDouble : (double) aValue
            forKey : (id    ) aKey
{
	PRIV_SET_NUMERIC_VALUE(aValue, aKey, numberWithDouble);
}

- (void) setInteger : (int) aValue
             forKey : (id ) aKey
{
	PRIV_SET_NUMERIC_VALUE(aValue, aKey, numberWithInt);
}

- (void) setUnsignedInt : (unsigned int) aValue
                 forKey : (id) aKey
{
	PRIV_SET_NUMERIC_VALUE(aValue, aKey, numberWithUnsignedInt);
}
- (void) setBool : (BOOL      ) aValue
          forKey : (id) aKey
{
	PRIV_SET_NUMERIC_VALUE(aValue, aKey, numberWithBool);
}
#undef PRIV_SET_NUMERIC_VALUE



#define PRIV_SET_STRCONV_VALUE(aValue, aKey, FunctionName)	\
	NSString		*s;\
	\
	if(nil == aKey) return;\
	s = FunctionName(aValue);\
	if(nil == s) return;\
	\
	[self setObject:s forKey:aKey]

- (void) setRect : (NSRect) aValue
		  forKey : (id    ) aKey
{
	PRIV_SET_STRCONV_VALUE(aValue, aKey, NSStringFromRect);
}
- (void) setSize : (NSSize) aValue
		  forKey : (id    ) aKey
{
	PRIV_SET_STRCONV_VALUE(aValue, aKey, NSStringFromSize);
}
- (void) setPoint : (NSPoint) aValue
		   forKey : (id     ) aKey
{
	PRIV_SET_STRCONV_VALUE(aValue, aKey, NSStringFromPoint);
}
#undef PRIV_SET_STRCONV_VALUE



@end
