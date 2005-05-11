/**
  * $Id: CMRNSObject.m,v 1.1.1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * CMRNSObject.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRNSObject.h"
#import "CocoMonar_Prefix.h"



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


#ifndef NSFoundationVersionNumber10_2
#define NSFoundationVersionNumber10_2 462.0
#endif



@implementation CMRNSObject
+ (void) poseAsClass : (Class) aClass
{
	UTIL_DEBUG_WRITE2(@"(Before) [%@ poseAsClass : %@]",
		NSStringFromClass(self),
		NSStringFromClass(aClass));
	[super poseAsClass : aClass];
	UTIL_DEBUG_WRITE2(@"(After) [%@ poseAsClass : %@]",
		NSStringFromClass(self),
		NSStringFromClass(aClass));
}

/*
	Since [NSKeyValueCoding takeValue:forKey:] (and so on) was deprecated
	in Mac OS X v10.3, I introduce this method in NSObject for 
	backward compatibility.
*/
- (void) setValue : (id        ) value
           forKey : (NSString *) key
{
	double version = floor(NSFoundationVersionNumber);
	
	UTIL_DEBUG_METHOD;
	UTIL_DEBUG_WRITE1(@"value = %@", value);
	UTIL_DEBUG_WRITE1(@"key = %@", key);

/*
You cannot test whether an object inherits a method 
from its superclass by sending respondsToSelector:
to the object using the super keyword. This method 
will still be testing the object as a whole, not just 
the superclass implementation. Therefore, sending respondsToSelector: 
to super is equivalent to sending it to self. Instead, 
you must invoke the NSObject class method instancesRespondToSelector: 
on the object superclass
*/
	if (version <= NSFoundationVersionNumber10_2) {
		[self takeValue:value forKey:key];
	} else {
		[super setValue:value forKey:key];
	}
}
@end
