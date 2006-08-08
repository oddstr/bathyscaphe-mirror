#import <Foundation/Foundation.h>

// Extension For BSImagePreviewInspector 2.0.x

@interface NSDictionary(BSIPIExtensionFromSG)
- (float) floatForKey: (id) key defaultValue: (float) defaultValue;
- (BOOL) boolForKey: (id) key defaultValue: (BOOL) defaultValue;
- (int) integerForKey: (id) key defaultValue: (int) defaultValue;
- (id) objectForKey: (id) key defaultObject: (id) defaultObject;
@end

@interface NSMutableDictionary(BSIPIExtensionFromSG)
- (void) setFloat: (float) aValue forKey: (id) aKey;
- (void) setBool: (BOOL) aValue forKey: (id) aKey;
- (void) setInteger: (int) aValue forKey: (id) aKey;
@end

extern NSLock *CMRSingletonObjectFactoryLock;

#define APP_RETURN_SINGLETON_CREATED_WITH_LOCK(lockObj)	\
	static id st_instance = nil;\
	\
	if(nil == st_instance){\
		[lockObj lock];\
		if(nil == st_instance){\
			st_instance = [[self alloc] init];\
		}\
		[lockObj unlock];\
	}\
	return st_instance


#define APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(methodName)	\
+ (void) initialize\
{\
	if(nil == CMRSingletonObjectFactoryLock)\
		CMRSingletonObjectFactoryLock = [[NSLock alloc] init];\
}\
\
+ (id) methodName\
{\
	APP_RETURN_SINGLETON_CREATED_WITH_LOCK(CMRSingletonObjectFactoryLock);\
}

