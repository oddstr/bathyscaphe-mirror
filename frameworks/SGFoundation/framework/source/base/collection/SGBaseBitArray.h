//: SGBaseBitArray.h
/**
  * $Id: SGBaseBitArray.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#ifndef SGBASE_BITARRAY_INCLUDED
#define SGBASE_BITARRAY_INCLUDED

#include <stddef.h>
#include <SGFoundation/SGBase.h>

SG_DECL_BEGIN

typedef struct SGBaseBitArray SGBaseBitArray;
typedef SGBaseBitArray *SGBaseBitArrayRef;



// allocate
SG_EXPORT
SGBaseBitArrayRef SGBaseBitArrayAlloc(void);
SG_EXPORT
SGBaseBitArrayRef SGBaseBitArrayAllocLength(unsigned aLength);

// deallocte
SG_EXPORT
void SGBaseBitArrayDealloc(SGBaseBitArrayRef me);

// length
SG_EXPORT
unsigned SGBaseBitArrayGetLength(SGBaseBitArrayRef me);
SG_EXPORT
void SGBaseBitArraySetLength(SGBaseBitArrayRef me, unsigned aLength);
SG_EXPORT
void SGBaseBitArrayReserve(SGBaseBitArrayRef me, unsigned reserveLength);

// bit operation
SG_EXPORT
int SGBaseBitArrayGetAtIndex(SGBaseBitArrayRef me, unsigned anIndex);
SG_EXPORT
void SGBaseBitArraySetAtIndex(SGBaseBitArrayRef me, unsigned anIndex);
SG_EXPORT
void SGBaseBitArrayClearAtIndex(SGBaseBitArrayRef me, unsigned anIndex);
SG_EXPORT
void SGBaseBitArrayClearAll(SGBaseBitArrayRef me);



SG_DECL_END

#endif /* SGBASE_BITARRAY_INCLUDED */
