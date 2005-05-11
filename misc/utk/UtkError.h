/**
  * $Id: UtkError.h,v 1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * UtkError.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#ifndef UTKERROR_H_INCLUDED
#define UTKERROR_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif



#define UtkDebugRequireBody_(condition, label, desc, arg1, arg2, arg3, arg4, arg5)	do { if (!(condition)) { UtkDebugWrite5((desc), (arg1), (arg2), (arg3), (arg4), (arg5)); goto label; } } while (0)



/* error handling: goto label if condition was FALSE. */
#define UtkRequireCondition(condition, label)			do { if(!(condition)) goto label; } while (0)



/*
   error handling:
   debug write description, and goto label if condition was FALSE. 
*/
#define UtkDebugRequire(condition, label, desc)	UtkDebugRequireBody_(condition, label, desc, 0, 0, 0, 0, 0)
#define UtkDebugRequire1(condition, label, desc)	UtkDebugRequireBody_(condition, label, desc, arg1, 0, 0, 0, 0)
#define UtkDebugRequire2(condition, label, desc)	UtkDebugRequireBody_(condition, label, desc, arg1, arg2, 0, 0, 0)
#define UtkDebugRequire3(condition, label, desc)	UtkDebugRequireBody_(condition, label, desc, arg1, arg2, arg3, 0, 0)
#define UtkDebugRequire4(condition, label, desc)	UtkDebugRequireBody_(condition, label, desc, arg1, arg2, arg3, arg4, 0)
#define UtkDebugRequire5(condition, label, desc)	UtkDebugRequireBody_(condition, label, desc, arg1, arg2, arg3, arg4, arg5)



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif

#endif /* UTKERROR_H_INCLUDED */
