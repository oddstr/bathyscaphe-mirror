//: SGBaseChunk.h
/**
  * $Id: SGBaseChunk.h,v 1.1.1.1 2005/05/11 17:51:43 tsawada2 Exp $
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

#ifndef SGBASECHUNK_H_INCLUDED
#define SGBASECHUNK_H_INCLUDED

#include <SGFoundation/SGBase.h>
#include <CoreServices/CoreServices.h>

SG_DECL_BEGIN



typedef struct {
	SGByte		firstAvailableBlock;
	SGByte		blocksAvailable;
	SGByte		bytes[1];
} SGBaseChunk;

#define SG_BASE_CHUNK_FIRST_AVAIL(self)		((self)->firstAvailableBlock)
#define SG_BASE_CHUNK_BLOCKS_AVAIL(self)	((self)->blocksAvailable)
#define SG_BASE_CHUNK_BYTES(self)			((self)->bytes)



SG_STATIC_INLINE
SGByte SGBaseChunkBlocksAvailable(SGBaseChunk *self)
{
	return self->blocksAvailable;
}


SG_EXPORT
SGBaseChunk *SGBaseChunkAlloc(size_t blockSize, SGByte numBlocks);
SG_EXPORT
SGBaseChunk *SGBaseChunkInit(SGBaseChunk *self, size_t blockSize, SGByte numBlocks);

SG_EXPORT
SGBaseChunk *SGBaseChunkCreate(size_t blockSize, SGByte numBlocks);

SG_EXPORT
void SGBaseChunkDealloc(SGBaseChunk *self);

SG_EXPORT
void *SGBaseChunkAllocateBlock(SGBaseChunk *self, size_t blockSize);
SG_EXPORT
void SGBaseChunkDeallocateBlock(SGBaseChunk *self, void *p, size_t blockSize);

SG_EXPORT
void SGBaseChunkPrint(SGBaseChunk *self);


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

SG_DECL_BEGIN

#endif /* SGBASECHUNK_H_INCLUDED */
