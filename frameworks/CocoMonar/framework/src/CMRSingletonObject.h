//: CMRSingletonObject.h
/**
  * $Id: CMRSingletonObject.h,v 1.1.1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


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


