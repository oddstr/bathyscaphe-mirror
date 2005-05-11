/**
  * $Id: UTILError.h,v 1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * UTILError.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#ifndef UTILERROR_H_INCLUDED
#define UTILERROR_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif



#define UTILDebugRequireBody_(condition, label, desc, arg1, arg2, arg3, arg4, arg5)	do { if (!(condition)) { UTILDebugWrite1(@"*** WARNING *** at %@", UTIL_HANDLE_FAILURE_IN_FUNCTION); UTILDebugWrite5((desc), (arg1), (arg2), (arg3), (arg4), (arg5)); goto label; } } while (0)



/* error handling: goto label if condition was FALSE. */
#define UTILRequireCondition(condition, label)			do { if(!(condition)) goto label; } while (0)
#define UTILRequireNoErr(err, label)	UTILRequireCondition((noErr == (err)), label)



/*
   error handling:
   debug write description, and goto label if condition was FALSE. 
*/
#define UTILDebugRequire(condition, label, desc)	UTILDebugRequireBody_(condition, label, desc, 0, 0, 0, 0, 0)
#define UTILDebugRequire1(condition, label, desc, arg1)	UTILDebugRequireBody_(condition, label, desc, arg1, 0, 0, 0, 0)
#define UTILDebugRequire2(condition, label, desc, arg1, arg2)	UTILDebugRequireBody_(condition, label, desc, arg1, arg2, 0, 0, 0)
#define UTILDebugRequire3(condition, label, desc, arg1, arg2, arg3)	UTILDebugRequireBody_(condition, label, desc, arg1, arg2, arg3, 0, 0)
#define UTILDebugRequire4(condition, label, desc, arg1, arg2, arg3, arg4)	UTILDebugRequireBody_(condition, label, desc, arg1, arg2, arg3, arg4, 0)
#define UTILDebugRequire5(condition, label, desc, arg1, arg2, arg3, arg4, arg5)	UTILDebugRequireBody_(condition, label, desc, arg1, arg2, arg3, arg4, arg5)



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif

#endif /* UTILERROR_H_INCLUDED */
