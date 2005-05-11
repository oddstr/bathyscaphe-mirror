/**
  * $Id: UTILAssertion.h,v 1.1.1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * UTILAssertion.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#ifndef UTILASSERTION_H_INCLUDED
#define UTILASSERTION_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif



// Description
#define		UTIL_HANDLE_FAILURE_IN_METHOD		[NSString stringWithFormat : @"%@<%@> in %@:%d", NSStringFromSelector(_cmd), NSStringFromClass([self class]), [NSString stringWithCString:__FILE__], __LINE__]
#define		UTIL_HANDLE_FAILURE_IN_FUNCTION		[NSString stringWithFormat : @"%@ in %@:%d", [NSString stringWithCString : __PRETTY_FUNCTION__], [NSString stringWithCString:__FILE__], __LINE__]


// 
// Assertion
// 
#ifndef UTIL_BLOCK_ASSERTIONS
  #define UTILAssertNotNil(v) NSAssert1((v) != nil, @"FAIL:%s must be not nil.", #v)
  #define UTILAssertKindOfClass(v, klass)	\
    NSAssert3((v) != nil && [(v) isKindOfClass : [klass class]],\
      @"%s was expected instanceof <%@>, but was instanceof <%@>.",\
      #v, NSStringFromClass([klass class]),\
      ((v) != nil) ? NSStringFromClass([(v) class]) : @"nil")
  #define UTILAssertRespondsTo(object, selector)	\
    NSAssert2((object) != nil && [(object) respondsToSelector : (selector)],\
      @"<%@> must respondsTo %@",\
      (object != Nil) ? NSStringFromClass([object class]) : @"Nil",\
      NSStringFromSelector((selector)))
  #define UTILAssertConformsTo(object, protocol) \
    NSAssert2(object != nil && [object conformsToProtocol : protocol],\
      @"FAIL: <%@> expected conformsToProtocol <%@>",\
      (object != Nil) ? NSStringFromClass([object class]) : @"Nil",\
      UTILStringFromProtocol(protocol))

  #define UTILCAssertNotNil(v) NSCAssert1((v) != nil, @"FAIL:%s must be not nil.", #v)
  #define UTILCAssertKindOfClass(v, klass)	\
    NSCAssert3((v) != nil && [(v) isKindOfClass : [klass class]],\
      @"%s was expected instanceof <%@>, but was instanceof <%@>.",\
      #v, NSStringFromClass([klass class]),\
      ((v) != nil) ? NSStringFromClass([(v) class]) : @"nil")
  #define UTILCAssertRespondsTo(object, selector)	\
    NSCAssert2((object) != nil && [(object) respondsToSelector : (selector)],\
      @"<%@> must respondsTo %@",\
      (object != Nil) ? NSStringFromClass([object class]) : @"Nil",\
      NSStringFromSelector((selector)))
  #define UTILCAssertConformsTo(object, protocol) \
    NSCAssert2(object != nil && [object conformsToProtocol : protocol],\
      @"FAIL: <%@> expected conformsToProtocol <%@>",\
      (object != Nil) ? NSStringFromClass([object class]) : @"Nil",\
      UTILStringFromProtocol(protocol))
#else
  #define UTILAssertNotNil(v)                        
  #define UTILAssertKindOfClass(v, klass)            
  #define UTILAssertRespondsTo(object, selector)     
  #define UTILAssertConformsTo(object, protocol)     
 
  #define UTILCAssertNotNil(v)                       
  #define UTILCAssertKindOfClass(v, klass)           
  #define UTILCAssertRespondsTo(object, selector)    
  #define UTILCAssertConformsTo(object, protocol)    
#endif



// Exception
#define		UTILAssertNotNilArgument(souldNotNilValue, souldNotNilStatus)	\
	do{						\
		if(nil == souldNotNilValue){\
			[NSException raise : NSInvalidArgumentException\
						format : @"F:%@ must be not nil.\n\t%@",\
								 souldNotNilStatus,\
								 UTIL_HANDLE_FAILURE_IN_METHOD];\
		}\
	}while(0)

// Notification
#define		UTILAssertNotificationName(aNotification, expectedName)		\
NSAssert2([aNotification name] != nil && [[aNotification name] isEqualToString : expectedName],\
			@"Expected Notification <%@> but was <%@>",\
			expectedName,\
			[aNotification name])
#define		UTILAssertNotificationObject(aNotification, expectedObject)		\
NSAssert2([aNotification object] != nil && [[aNotification object] isEqual : expectedObject],\
			@"Expected Notification <%@> but was <%@>",\
			expectedObject,\
			[aNotification object])


/* Implementation of asserts (ignore) */
#if !defined(UTILExceptionRaiseBody)
#define UTILExceptionRaiseBody(condition, exceptionName, desc, arg1, arg2, arg3, arg4, arg5)	\
	do{						\
		if(!(condition)){										\
			[NSException raise : (exceptionName)				\
						format : [NSString stringWithFormat : @"%@ -%@",(desc), 					\
																UTIL_HANDLE_FAILURE_IN_METHOD],	\
								(arg1), (arg2), (arg3), (arg4), (arg5)];		\
		}						\
	}while(0)
#endif
#if !defined(UTILCExceptionRaiseBody)
#define UTILCExceptionRaiseBody(condition, exceptionName, desc, arg1, arg2, arg3, arg4, arg5)	\
	do{						\
		if(!(condition)){										\
			[NSException raise : (exceptionName)				\
						format : [NSString stringWithFormat : @"%@ -%@",(desc), 						\
																UTIL_HANDLE_FAILURE_IN_FUNCTION],	\
									(arg1), (arg2), (arg3), (arg4), (arg5)];		\
		}						\
	}while(0)
#endif



/*
 * Asserts to use in Objective-C method bodies
 */
 
#define UTILExceptionRaise5(condition, exceptionName, desc, arg1, arg2, arg3, arg4, arg5)	\
    UTILExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), (arg2), (arg3), (arg4), (arg5))

#define UTILExceptionRaise4(condition, exceptionName, desc, arg1, arg2, arg3, arg4)	\
    UTILExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), (arg2), (arg3), (arg4), 0)

#define UTILExceptionRaise3(condition, exceptionName, desc, arg1, arg2, arg3)	\
    UTILExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), (arg2), (arg3), 0, 0)

#define UTILExceptionRaise2(condition, exceptionName, desc, arg1, arg2)		\
    UTILExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), (arg2), 0, 0, 0)

#define UTILExceptionRaise1(condition, exceptionName, desc, arg1)		\
    UTILExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), 0, 0, 0, 0)

#define UTILExceptionRaise(condition, exceptionName, desc)			\
    UTILExceptionRaiseBody((condition), (exceptionName), (desc), 0, 0, 0, 0, 0)


#define UTILCExceptionRaise5(condition, exceptionName, desc, arg1, arg2, arg3, arg4, arg5)	\
    UTILCExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), (arg2), (arg3), (arg4), (arg5))

#define UTILCExceptionRaise4(condition, exceptionName, desc, arg1, arg2, arg3, arg4)	\
    UTILCExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), (arg2), (arg3), (arg4), 0)

#define UTILCExceptionRaise3(condition, exceptionName, desc, arg1, arg2, arg3)	\
    UTILCExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), (arg2), (arg3), 0, 0)

#define UTILCExceptionRaise2(condition, exceptionName, desc, arg1, arg2)	\
    UTILCExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), (arg2), 0, 0, 0)

#define UTILCExceptionRaise1(condition, exceptionName, desc, arg1)		\
    UTILCExceptionRaiseBody((condition), (exceptionName), (desc), (arg1), 0, 0, 0, 0)

#define UTILCExceptionRaise(condition, exceptionName, desc)			\
    UTILCExceptionRaiseBody((condition), (exceptionName), (desc), 0, 0, 0, 0, 0)



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif

#endif /* UTILASSERTION_H_INCLUDED */
