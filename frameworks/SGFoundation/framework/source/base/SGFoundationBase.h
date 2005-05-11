//: SGFoundationBase.h
/**
  * $Id: SGFoundationBase.h,v 1.1.1.1 2005/05/11 17:51:43 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */
#ifndef SGFOUNDATIONBASE_H_INCLUDED
#define SGFOUNDATIONBASE_H_INCLUDED

#import <SGFoundation/SGBase.h>

#import <SGFoundation/SGBaseChunk.h>
#import <SGFoundation/SGBaseFixedAllocator.h>
#import <SGFoundation/SGBaseAllocator.h>
#import <SGFoundation/SGBaseObject.h>

#import <SGFoundation/SGBaseUnicode.h>

#import <SGFoundation/SGBaseCArray.h>
#import <SGFoundation/SGBaseCArrayWrapper.h>
#import <SGFoundation/SGBaseBitArray.h>
#import <SGFoundation/SGRangeArrayImp.h>
#import <SGFoundation/SGBaseRangeArray.h>
#import <SGFoundation/SGBaseQueue.h>

SG_DECL_BEGIN



// Allocation Preferences
#define DEFAULT_CHUNK_SIZE			4096
#define DEFAULT_MAX_OBJ_SIZE		64



/* NSRange { NSNotFound, 0 } */
SG_EXPORT
const NSRange kNFRange;



SG_DECL_END

#endif /* SGFOUNDATIONBASE_H_INCLUDED */


