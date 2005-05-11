/**
  * $Id: UTILDebugging.h,v 1.1.1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * UTILDebugging.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#ifndef UTILDEBUGGING_H_INCLUDED
#define UTILDEBUGGING_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

/*
 must be included in implementation file


// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"

*/

#if UTIL_DEBUGGING
#define UTIL_DEBUG_WRITE(fmt)									UTILDebugWrite((fmt))
#define UTIL_DEBUG_WRITE1(fmt, arg1)							UTILDebugWrite1((fmt), (arg1))
#define UTIL_DEBUG_WRITE2(fmt, arg1, arg2)						UTILDebugWrite2((fmt), (arg1), (arg2))
#define UTIL_DEBUG_WRITE3(fmt, arg1, arg2, arg3)				UTILDebugWrite3((fmt), (arg1), (arg2), (arg3))
#define UTIL_DEBUG_WRITE4(fmt, arg1, arg2, arg3, arg4)			UTILDebugWrite4((fmt), (arg1), (arg2), (arg3), (arg4))
#define UTIL_DEBUG_WRITE5(fmt, arg1, arg2, arg3, arg4, arg5)	UTILDebugWrite5((fmt), (arg1), (arg2), (arg3), (arg4), (arg5))

/* print function name */
#define UTIL_DEBUG_FUNCTION	UTILCFunctionLog
#define UTIL_DEBUG_METHOD	UTILMethodLog
/* execute debugging code */
#define UTIL_DEBUG_DO(code)	do { code } while(0)

#else
#define UTIL_DEBUG_WRITE(fmt)									
#define UTIL_DEBUG_WRITE1(fmt, arg1)							
#define UTIL_DEBUG_WRITE2(fmt, arg1, arg2)						
#define UTIL_DEBUG_WRITE3(fmt, arg1, arg2, arg3)				
#define UTIL_DEBUG_WRITE4(fmt, arg1, arg2, arg3, arg4)			
#define UTIL_DEBUG_WRITE5(fmt, arg1, arg2, arg3, arg4, arg5)	

#define UTIL_DEBUG_FUNCTION										
#define UTIL_DEBUG_METHOD										
#define UTIL_DEBUG_DO(code)										
#endif



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif
#endif /* UTILDEBUGGING_H_INCLUDED */
