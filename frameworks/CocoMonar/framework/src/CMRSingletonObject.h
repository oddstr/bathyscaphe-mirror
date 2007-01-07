//: CMRSingletonObject.h
/**
  * $Id: CMRSingletonObject.h,v 1.2 2007/01/07 17:04:24 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

//#import <Foundation/Foundation.h>


//extern NSLock *CMRSingletonObjectFactoryLock;

/*
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
*/
#define APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(methodName) \
static id st_instance = nil;\
\
+ (id) methodName\
{\
    @synchronized(self) {\
        if (st_instance == nil) {\
            [[self alloc] init];\
        }\
    }\
    return st_instance;\
}\
+ (id) allocWithZone: (NSZone *) zone\
{\
    @synchronized(self) {\
        if (st_instance == nil) {\
            st_instance = [super allocWithZone: zone];\
            return st_instance;\
        }\
    }\
    return nil;\
}\
- (id) copyWithZone: (NSZone *) zone {return self;}\
- (id) retain {return self;}\
- (unsigned) retainCount {return UINT_MAX;}\
- (void) release{}\
- (id) autorelease{return self;}
