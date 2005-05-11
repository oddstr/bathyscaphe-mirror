//: SGRangeArrayImp.h
/**
  * $Id: SGRangeArrayImp.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#if !defined(FRWK_SGFOUNDATION_SGRANGEARRAYREF)
#define FRWK_SGFOUNDATION_SGRANGEARRAYREF	1

#include <Foundation/Foundation.h>
#import <SGFoundation/SGBase.h>

SG_DECL_BEGIN



typedef struct SGRangeArrayImp_t	*SGRangeArrayRef;


// initialize
SG_EXPORT
SGRangeArrayRef SGRangeArrayCreate(void);
SG_EXPORT
SGRangeArrayRef SGRangeArrayCreateCopy(SGRangeArrayRef srcArray);
SG_EXPORT
void SGRangeArrayDeallocate(SGRangeArrayRef theArray);


// accessor
SG_EXPORT
unsigned SGRangeArrayGetCount(SGRangeArrayRef theArray);

SG_EXPORT
NSRange SGRangeArrayGetValueAtIndex(
						SGRangeArrayRef	theArray,
						unsigned 		anIndex);

SG_EXPORT
void SGRangeArrayAppendValue(
				SGRangeArrayRef		theArray,
				NSRange				aRange);

SG_EXPORT
void SGRangeArraySetValueAtIndex(
				SGRangeArrayRef		theArray,
				NSRange				aRange,
				unsigned			anIndex);

SG_EXPORT
void SGRangeArrayRemoveLastValue(SGRangeArrayRef array);
SG_EXPORT
void SGRangeArrayRemoveAllValues(SGRangeArrayRef array);



SG_DECL_END


#endif		/* FRWK_SGFOUNDATION_SGRangeArrayREF */