/**
  * $Id: Utk.h,v 1.1.1.1 2005/05/11 17:51:55 tsawada2 Exp $
  * 
  * Utk.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#ifndef UTK_H_INCLUDED
#define UTK_H_INCLUDED

#include <UtkAssertion.h>
#include <UtkDescription.h>
#include <UtkError.h>

#ifdef __cplusplus
extern "C" {
#endif



/*!
	@defined UtkCArrayCount
	@discussion 配列の要素数を計算
	
	@param ary 配列（ポインタではなく）
*/
#define UtkCArrayCount(ary)		sizeof(ary)/sizeof(ary[0])



#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif

#endif /* UTK_H_INCLUDED */
