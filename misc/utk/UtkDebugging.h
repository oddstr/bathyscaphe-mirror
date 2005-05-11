/**
  * $Id: UtkDebugging.h,v 1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * UtkDebugging.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#ifndef UTKDEBUGGING_H_INCLUDED
#define UTKDEBUGGING_H_INCLUDED

#include <UtkDescription.h>

#ifdef __cplusplus
extern "C" {
#endif


/*
 must be included in implementation file


// for debugging only
#define UTK_DEBUGGING		1
#include "UtkDebugging.h"

*/

#if UTK_DEBUGGING
#define UTK_DEBUG_WRITE(fmt)								UtkDebugWrite((fmt))
#define UTK_DEBUG_WRITE1(fmt, arg1)							UtkDebugWrite1((fmt), (arg1))
#define UTK_DEBUG_WRITE2(fmt, arg1, arg2)					UtkDebugWrite2((fmt), (arg1), (arg2))
#define UTK_DEBUG_WRITE3(fmt, arg1, arg2, arg3)				UtkDebugWrite3((fmt), (arg1), (arg2), (arg3))
#define UTK_DEBUG_WRITE4(fmt, arg1, arg2, arg3, arg4)		UtkDebugWrite4((fmt), (arg1), (arg2), (arg3), (arg4))
#define UTK_DEBUG_WRITE5(fmt, arg1, arg2, arg3, arg4, arg5)	UtkDebugWrite5((fmt), (arg1), (arg2), (arg3), (arg4), (arg5))
/* print function name */
#define UTK_DEBUG_FUNCTION	UtkPrettyFunction
/* execute debugging code */
#define UTK_DEBUG_DO(code)	do { code } while(0)

#else
#define UTK_DEBUG_WRITE(fmt)								
#define UTK_DEBUG_WRITE1(fmt, arg1)							
#define UTK_DEBUG_WRITE2(fmt, arg1, arg2)					
#define UTK_DEBUG_WRITE3(fmt, arg1, arg2, arg3)				
#define UTK_DEBUG_WRITE4(fmt, arg1, arg2, arg3, arg4)		
#define UTK_DEBUG_WRITE5(fmt, arg1, arg2, arg3, arg4, arg5)	

#define UTK_DEBUG_FUNCTION									
#define UTK_DEBUG_DO(code)									
#endif



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif

#endif /* UTKDEBUGGING_H_INCLUDED */
