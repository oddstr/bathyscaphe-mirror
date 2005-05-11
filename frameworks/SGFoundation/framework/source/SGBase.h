/**
  * $Id: SGBase.h,v 1.1.1.1 2005/05/11 17:51:43 tsawada2 Exp $
  * 
  * SGBase.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#ifndef SGBASE_H_INCLUDED
#define SGBASE_H_INCLUDED



#ifndef SG_DECL_BEGIN
#ifdef __cplusplus
#define SG_DECL_BEGIN  extern "C" {
#define SG_DECL_END    }
#else  /*! __cplusplus */
#define SG_DECL_BEGIN
#define SG_DECL_END
#endif /* #ifdef __cplusplus */
#endif /* #ifndef SG_DECL_BEGIN */

SG_DECL_BEGIN



/* NULL / TRUE / FALSE */
#ifndef NULL
#define NULL	0
#endif
#ifndef FALSE
#define FALSE	0
#endif
#ifndef TRUE
#define TRUE	1
#endif

/* external/inline decleration */
#ifndef SG_EXPORT
#define SG_EXPORT			extern
#endif
#ifndef SG_STATIC_INLINE
#define SG_STATIC_INLINE	static __inline__
#endif



/*-------------------------------------------------------------
 * BASIC TYPES
 */

/* Basic types */
/*
SGWord:
----------------------------------------
maybe 32 or 64-bit unsigned native integer,
and has the same number of bits as a pointer.
*/
typedef unsigned long SGWord;

/*
SGByte:
----------------------------------------
8-bit unsigned integer, a Octet.
*/
typedef unsigned char SGByte;



SG_DECL_END

#endif /* SGBASE_H_INCLUDED */
