/**
  * $Id: UtkDescription.h,v 1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * UtkDescription.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     UTILDescription
 * @discussion The debug write macros.
 *             to eliminates UTILWirteBody_ macro, 
 *             
 *               #define UTIL_BLOCK_DEBUG_WRITE
 *             
 *             or setup "Other C Flags"
 *             
 *               -DUTIL_BLOCK_DEBUG_WRITE
 */

#ifndef UTKDESCRIPTION_H_INCLUDED
#define UTKDESCRIPTION_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif



/*
Implementation of print 

Since compiler (such as GNU C Compiler) warn about excess arguments to a printf,
maybe you need specify compiler flags (i.e. -Wno-format-extra-args)
*/
#ifndef UtkWriteBody_
  #ifndef UTK_BLOCK_DEBUG_WRITE
    #define UtkWriteBody_(desc, arg1, arg2, arg3, arg4, arg5)	fprintf(stderr, (desc), (arg1), (arg2), (arg3), (arg4), (arg5))
  #else
    #define UtkWriteBody_(desc, arg1, arg2, arg3, arg4, arg5)	
  #endif  /* !UTK_BLOCK_DEBUG_WRITE */
#endif  /* !UtkWriteBody_ */



/*
 * Debug write in C function
 */
#define UtkDebugWrite5(desc, arg1, arg2, arg3, arg4, arg5)	\
  UtkWriteBody_((desc), (arg1), (arg2), (arg3), (arg4), (arg5))
#define UtkDebugWrite4(desc, arg1, arg2, arg3, arg4)	\
  UtkWriteBody_((desc), (arg1), (arg2), (arg3), (arg4), 0)
#define UtkDebugWrite3(desc, arg1, arg2, arg3)	\
  UtkWriteBody_((desc), (arg1), (arg2), (arg3), 0, 0)
#define UtkDebugWrite2(desc, arg1, arg2)	\
  UtkWriteBody_((desc), (arg1), (arg2), 0, 0, 0)
#define UtkDebugWrite1(desc, arg1)	\
  UtkWriteBody_((desc), (arg1), 0, 0, 0, 0)
#define UtkDebugWrite(desc)	\
  UtkWriteBody_((desc), 0, 0, 0, 0, 0)



/* Pretty Function for GNU C */
#ifndef __GNUC__
  #define UtkPrettyFunction  UtkDebugWrite3("in %s(), %s:%d\n", "<function>", __FILE__, __LINE__)
#else
  #define UtkPrettyFunction  UtkDebugWrite3("in %s(), %s:%d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__)
#endif  /* !__GNUC__ */



/* Boolean -> C string */
#define UtkBOOLStr(x)	x?"TRUE":"FALSE"

#define UtkDescNil(x)		UtkDebugWrite2("(NULL?) %s = %s\n", #x, UtkBOOLStr(NULL==(x)))
#define UtkDescInt(x)		UtkDebugWrite2("(Integer) %s = %d\n", #x, (int)(x))
#define UtkDescUInt(x)		UtkDebugWrite2("(Unsigned) %s = %u\n", #x, (unsigned)(x))
#define UtkDescStr(x)		UtkDebugWrite2("(Unsigned) %s = %s\n", #x, (char*)(x))
#define UtkDescFloat(x)		UtkDebugWrite2("(Float) %s = %.2f\n", #x, (x))
#define UtkDescPointer(x)	UtkDebugWrite2("(void *) %s = %p\n", #x, (void*)(x))



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif

#endif /* UTKDESCRIPTION_H_INCLUDED */
