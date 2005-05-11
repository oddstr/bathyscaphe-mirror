//: UTILDescription.h
/**
  * $Id: UTILDescription.h,v 1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     UTILDescription
 * @discussion The debug write macros.
 *             to eliminates UTILWriteBody_ macro, 
 *             
 *               #define UTIL_BLOCK_DEBUG_WRITE
 *             
 *             or setup "Other C Flags"
 *             
 *               -DUTIL_BLOCK_DEBUG_WRITE
 */

#ifndef UTILDESCRIPTION_H_INCLUDED
#define UTILDESCRIPTION_H_INCLUDED



#ifdef __cplusplus
extern "C" {
#endif



/* Implementation of print */
#ifndef UTILWriteBody_
  #ifndef UTIL_BLOCK_DEBUG_WRITE
    #define UTILWriteBody_(desc, arg1, arg2, arg3, arg4, arg5)	NSLog((desc), (arg1), (arg2), (arg3), (arg4), (arg5))
  #else
    #define UTILWriteBody_(desc, arg1, arg2, arg3, arg4, arg5)	
  #endif  /* !UTIL_BLOCK_DEBUG_WRITE */
#endif  /* !UTILWriteBody_ */



/*
 * Debug write for Objective-C
 */
#define UTILDebugWrite5(desc, arg1, arg2, arg3, arg4, arg5)	\
  UTILWriteBody_((desc), (arg1), (arg2), (arg3), (arg4), (arg5))
#define UTILDebugWrite4(desc, arg1, arg2, arg3, arg4)	\
  UTILWriteBody_((desc), (arg1), (arg2), (arg3), (arg4), 0)
#define UTILDebugWrite3(desc, arg1, arg2, arg3)	\
  UTILWriteBody_((desc), (arg1), (arg2), (arg3), 0, 0)
#define UTILDebugWrite2(desc, arg1, arg2)	\
  UTILWriteBody_((desc), (arg1), (arg2), 0, 0, 0)
#define UTILDebugWrite1(desc, arg1)	\
  UTILWriteBody_((desc), (arg1), 0, 0, 0, 0)
#define UTILDebugWrite(desc)	\
  UTILWriteBody_((desc), 0, 0, 0, 0, 0)



/*
 * Some useful macros
 */
#define UTILBOOLString(x)					x?@"YES":@"NO"
#define UTILStringFromProtocol(protocol)	[NSString stringWithUTF8String:(const char*)[(id)(protocol) name]]
#define UTILComparisonResultString(x)		(NSOrderedAscending == x) ? @"NSOrderedAscending" : ((NSOrderedDescending == x) ? @"NSOrderedDescending" : ((NSOrderedSame == x) ? @"NSOrderedSame" : @"None"))

#define UTILDescSizeof(obj)                  UTILDebugWrite2(@"%s:%u.", #obj, sizeof(obj))
#define UTILDescription(x)                   UTILDebugWrite3(@"(%@)%s = %@", NSStringFromClass([x class]), #x, [x description])
#define UTILDescRect(x)                      UTILDebugWrite2(@"(NSRect)%s = %@", #x, NSStringFromRect(x))
#define UTILDescRange(x)                     UTILDebugWrite2(@"(NSRange)%s = %@", #x, NSStringFromRange(x))
#define UTILDescPoint(x)                     UTILDebugWrite2(@"(NSPoint)%s = %@", #x, NSStringFromPoint(x))
#define UTILDescSize(x)                      UTILDebugWrite2(@"(NSSize)%s = %@", #x, NSStringFromSize(x))
#define UTILDescBoolean(x)                   UTILDebugWrite2(@"(BOOL)%s = %@", #x, UTILBOOLString(x))
#define UTILDescRetainCount(x)               UTILDebugWrite2(@"(RetainCount)%s = %u", #x, [x retainCount])
#define UTILDescIsNil(x)                     UTILDebugWrite2(@"(Nil?)%s = %@", #x, UTILBOOLString(x==nil))
#define UTILDescClass(x)                     UTILDebugWrite2(@"(class)%s = %@", #x, NSStringFromClass(x))
#define UTILDescSelector(x)                  UTILDebugWrite2(@"(SEL)%s = %@", #x, NSStringFromSelector(x))
#define UTILDescString(x)                    UTILDebugWrite2(@"(NSString)%s = %@", #x, x)
#define UTILDescInt(x)                       UTILDebugWrite2(@"(Integer)%s = %d", #x, x)
#define UTILDescUnsignedInt(x)  UTILDebugWrite2(@"(Integer)%s = %u", #x, x)
#define UTILDescFloat(x)  UTILDebugWrite2(@"(float)%s = %.2f", #x, x)
#define UTILDescComparisonResult(x) UTILDebugWrite1(@"(ComparisonResult)%s = %@", #x, UTILComparisonResultString(x))



#define UTILMethodPtrLog  UTILDebugWrite3(@"%@::%@(%p)",\
                            NSStringFromClass([self class]),\
                            NSStringFromSelector(_cmd),\
                            self)
#define UTILMethodLog     UTILDebugWrite4(@"%@::%@ in %@:%d",\
                            NSStringFromClass([self class]),\
                            NSStringFromSelector(_cmd),\
                            [NSString stringWithCString:__FILE__],\
                            __LINE__)
#define UTILCFunctionLog  UTILDebugWrite3(@"%@ in %@:%d",\
                            [NSString stringWithCString : __PRETTY_FUNCTION__],\
                            [NSString stringWithCString:__FILE__],\
                            __LINE__)

#define UTILWriteObject(x, file)  [x writeToFile : [NSHomeDirectory() stringByAppendingPathComponent : file] atomically : NO]



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif

#endif /* UTILDESCRIPTION_H_INCLUDED */
