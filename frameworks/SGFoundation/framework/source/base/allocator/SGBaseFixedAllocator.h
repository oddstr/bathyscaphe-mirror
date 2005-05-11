//: SGBaseFixedAllocator.h
/**
  * $Id: SGBaseFixedAllocator.h,v 1.1 2005/05/11 17:51:43 tsawada2 Exp $
  * 
  * Copyright (c) 2001 by Andrei Alexandrescu
  * Copyright (c) 2001-2004, Takanori Ishikawa.
  *
  * Original code and ideas from The Loki Library, by Andrei Alexandrescu.
  * This is a Objective-C implementation of it.
  * See Copyright notice of The Loki Library at the end of this file.
  *
  * See the file LICENSE for copying permission.
  */
#ifndef SGBASEFIXEDALLOCATOR_H_INCLUDED
#define SGBASEFIXEDALLOCATOR_H_INCLUDED

#import <Foundation/Foundation.h>
#import <SGFoundation/SGBase.h>
#import <SGFoundation/SGBaseChunk.h>
#import <SGFoundation/SGBaseCArray.h>

SG_DECL_BEGIN



@interface SGBaseFixedAllocator : NSObject
{
	@public
	size_t			m_blockSize;	/* the block size */
	
	@private
	SGByte			m_numBlocks;	/* number of blocks in per chunk */
	SGBaseCArray	m_chunks;			/* chunks backet */
	
	
	/* cache */
	SGBaseChunk		*allocChunk;
	unsigned int	deallocIdx;
}
+ (id) allocatorWithBlockSize : (size_t) blockSize;
- (id) initWithBlockSize : (size_t) blockSize;
- (id) initWithBlockSize : (size_t) blockSize
			   chunkSize : (size_t) chunkSize;

- (unsigned) numberOfChunks;
- (void) clearAll;
- (size_t) blockSize;
- (SGByte) numberOfBlocks;
- (size_t) chunkSize;

- (void *) allocate;
- (void) deallocate : (void *) pAllocated;
@end



SG_STATIC_INLINE
size_t SGBaseFixedAllocatorBlockSize(SGBaseFixedAllocator *me)
{
	return me->m_blockSize;
}


////////////////////////////////////////////////////////////////////////////////
// The Loki Library
// Copyright (c) 2001 by Andrei Alexandrescu
// This code accompanies the book:
// Alexandrescu, Andrei. "Modern C++ Design: Generic Programming and Design 
//     Patterns Applied". Copyright (c) 2001. Addison-Wesley.
// Permission to use, copy, modify, distribute and sell this software for any 
//     purpose is hereby granted without fee, provided that the above copyright 
//     notice appear in all copies and that both that copyright notice and this 
//     permission notice appear in supporting documentation.
// The author or Addison-Wesley Longman make no representations about the 
//     suitability of this software for any purpose. It is provided "as is" 
//     without express or implied warranty.
////////////////////////////////////////////////////////////////////////////////

SG_DECL_END

#endif /* SGBASEFIXEDALLOCATOR_H_INCLUDED */
