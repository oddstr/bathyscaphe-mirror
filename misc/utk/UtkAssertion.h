/**
  * $Id: UtkAssertion.h,v 1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * UtkAssertion.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
/*!
 * @header     UtkAssertion
 * @discussion The debug assertion macros.
 *             to eliminates UtkAssertBody_ macro, 
 *             
 *               #define UTK_BLOCK_ASSERTIONS
 *             
 *             or setup "Other C Flags"
 *             
 *               -DUTK_BLOCK_ASSERTIONS
 */
#ifndef UTKASSERTION_H_INCLUDED
#define UTKASSERTION_H_INCLUDED

#include <assert.h>
#include <errno.h>

#ifdef __cplusplus
extern "C" {
#endif



/*
Implementation of asserts

Since compiler (such as GNU C Compiler) warn about excess arguments to a printf,
maybe you need specify compiler flags (i.e. -Wno-format-extra-args)
*/
#ifndef UtkFailureInFunction
#define UtkFailureInFunction(function, fileName, line, desc, arg1, arg2, arg3, arg4, arg5)      \
do { fprintf(stderr, "*** Assertion failure in %s(), %s:%d\n", (function), (fileName), (line)); \
     fprintf(stderr, "*** Uncaught exception: <InternalInconsistencyException>\n  ");           \
     fprintf(stderr, (desc), (arg1), (arg2), (arg3), (arg4), (arg5));                           \
     fprintf(stderr, "\n"); exit(2); } while (0)
#endif /* !UtkFailureInFunction */

#ifndef UtkFailureBody_
#ifndef __GNUC__
  #define UtkFailureBody_(desc, arg1, arg2, arg3, arg4, arg5)           \
        UtkFailureInFunction("<function>", __FILE__, __LINE__,          \
          (desc), (arg1), (arg2), (arg3), (arg4), (arg5))
#else
  #define UtkFailureBody_(desc, arg1, arg2, arg3, arg4, arg5)           \
        UtkFailureInFunction(__PRETTY_FUNCTION__, __FILE__, __LINE__,   \
          (desc), (arg1), (arg2), (arg3), (arg4), (arg5))
#endif  /* !__GNUC__ */
#endif  /* !UtkFailureBody_ */



#ifndef UTK_BLOCK_ASSERTIONS
  #ifndef UtkAssertBody_
    #define UtkAssertBody_(condition, desc, arg1, arg2, arg3, arg4, arg5)  do { if (!(condition)) UtkFailureBody_((desc), (arg1), (arg2), (arg3), (arg4), (arg5)); } while(0)
  #endif  /* !UtkAssertBody_ */
#else
  #ifndef UtkAssertBody_
    #define UtkAssertBody_(condition, desc, arg1, arg2, arg3, arg4, arg5)  
  #endif  /* !UtkAssertBody_ */
#endif  /* !UTK_BLOCK_ASSERTIONS */



/*
 * Asserts to use in C function bodies
 */
#define UtkAssert5(condition, desc, arg1, arg2, arg3, arg4, arg5)	\
  UtkAssertBody_((condition), (desc), (arg1), (arg2), (arg3), (arg4), (arg5))
#define UtkAssert4(condition, desc, arg1, arg2, arg3, arg4)	\
  UtkAssertBody_((condition), (desc), (arg1), (arg2), (arg3), (arg4), 0)
#define UtkAssert3(condition, desc, arg1, arg2, arg3)	\
  UtkAssertBody_((condition), (desc), (arg1), (arg2), (arg3), 0, 0)
#define UtkAssert2(condition, desc, arg1, arg2)	\
  UtkAssertBody_((condition), (desc), (arg1), (arg2), 0, 0, 0)
#define UtkAssert1(condition, desc, arg1)	\
  UtkAssertBody_((condition), (desc), (arg1), 0, 0, 0, 0)
#define UtkAssert(condition, desc)	\
  UtkAssertBody_((condition), (desc), 0, 0, 0, 0, 0)

/*
 * Some useful assertion macros
 */
#define UtkAssertNotNULL(x)	UtkAssert1((x), "\"%s\" must be not NULL.", #x)

/*
 * Reports an internal inconsistency in C function
 */
#define UtkError5(desc, arg1, arg2, arg3, arg4, arg5)	\
  UtkFailureBody_((desc), (arg1), (arg2), (arg3), (arg4), (arg5))
#define UtkError4(desc, arg1, arg2, arg3, arg4)	\
  UtkFailureBody_((desc), (arg1), (arg2), (arg3), (arg4), 0)
#define UtkError3(desc, arg1, arg2, arg3)	\
  UtkFailureBody_((desc), (arg1), (arg2), (arg3), 0, 0)
#define UtkError2(desc, arg1, arg2)	\
  UtkFailureBody_((desc), (arg1), (arg2), 0, 0, 0)
#define UtkError1(desc, arg1)	\
  UtkFailureBody_((desc), (arg1), 0, 0, 0, 0)
#define UtkError(desc)	\
  UtkFailureBody_((desc), 0, 0, 0, 0, 0)


#define UtkStdError(desc)	UtkError3("%s: %s (errno=%d)", desc, strerror(errno), errno)

#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif

#endif /* UTKASSERTION_H_INCLUDED */
