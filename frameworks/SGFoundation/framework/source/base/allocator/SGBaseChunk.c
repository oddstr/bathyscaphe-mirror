/**
  * $Id: SGBaseChunk.c,v 1.1.1.1 2005/05/11 17:51:43 tsawada2 Exp $
  * 
  * SGBaseChunk.c
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#include "SGBaseChunk.h"
#include "Utk.h"



SGBaseChunk *SGBaseChunkCreate(size_t blockSize, SGByte numBlocks)
{
	SGBaseChunk		*self;
	
	self = SGBaseChunkAlloc(blockSize, numBlocks);
	return SGBaseChunkInit(self, blockSize, numBlocks);
}


SGBaseChunk *SGBaseChunkAlloc(size_t blockSize, SGByte numBlocks)
{
	SGBaseChunk		*self;
	size_t			memorySize;
	
	UtkAssert(
		(blockSize != 0) && (numBlocks != 0),
		"blockSize blocks must be not 0.");
	UtkAssert(
		((blockSize * numBlocks) / blockSize) == numBlocks,
		"Overflow Error");
	
	memorySize = sizeof(SGBaseChunk);
	memorySize += sizeof(SGByte) * (blockSize * numBlocks);
	memorySize -= 1;	/* bytes[1] */
	
	UtkAssert1(memorySize > 0, "memorySize = %lu", memorySize);
	self = malloc(memorySize);
	
	if (NULL == self) {
		UtkError("Can't allocate instance of SGBaseChunk");
		return NULL;
	}
	return self;
}
SGBaseChunk *SGBaseChunkInit(SGBaseChunk *self, size_t blockSize, SGByte numBlocks)
{

	SGByte	i;
	SGByte	*p;
	
	UtkAssertNotNULL(self);
	UtkAssert(
		(blockSize != 0) && (numBlocks != 0),
		"blockSize blocks must be not 0.");
	UtkAssert(
		((blockSize * numBlocks) / blockSize) == numBlocks,
		"Overflow Error");
	
	
	SG_BASE_CHUNK_FIRST_AVAIL(self) = 0;
	SG_BASE_CHUNK_BLOCKS_AVAIL(self) = numBlocks;
	
	p = SG_BASE_CHUNK_BYTES(self);
	for (i = 0; i < numBlocks; p += blockSize) {
		/*
		各ブロックの先頭に次に利用可能な
		ブロックのインデックスを格納
		*/
		*p = ++i;
	}
	
	return self;
}
void SGBaseChunkDealloc(SGBaseChunk *self)
{
	UtkAssertNotNULL(self);
	free(self);
}


void *SGBaseChunkAllocateBlock(SGBaseChunk *self, size_t blockSize)
{
	SGByte		*pResult_;
	
	UtkAssertNotNULL(self);
	if (0 == SG_BASE_CHUNK_BLOCKS_AVAIL(self))
		return NULL;
	
	pResult_ = SG_BASE_CHUNK_BYTES(self) + (SG_BASE_CHUNK_FIRST_AVAIL(self) * blockSize);
	
	/*
	*pResult_には次に利用可能なブロックの
	インデックスが格納されている。
	*/
	SG_BASE_CHUNK_FIRST_AVAIL(self) = *pResult_;
	SG_BASE_CHUNK_BLOCKS_AVAIL(self)--;
	
	return pResult_;
}


void SGBaseChunkPrint(SGBaseChunk *self)
{
	UtkAssertNotNULL(self);
	fprintf(stderr, "%s<%p>\nfirstAvailableBlock=%u blocksAvailable=%u",
		"SGBaseChunk", self, SG_BASE_CHUNK_FIRST_AVAIL(self), SG_BASE_CHUNK_BLOCKS_AVAIL(self));
}

void SGBaseChunkDeallocateBlock(SGBaseChunk *self, void *p, size_t blockSize)
{
	SGByte		*toRelease_;
	
	UtkAssertNotNULL(self);
	UtkAssert2(
		(void *)SG_BASE_CHUNK_BYTES(self) <= p,
		"Allocated Memory must be (%p <=) but was (%p).",
		SG_BASE_CHUNK_BYTES(self), p);
	
	toRelease_ = (SGByte *)p;
	/* 整列のチェック */
	UtkAssert1(
		0 == ((toRelease_ - SG_BASE_CHUNK_BYTES(self)) % blockSize),
		"Alignment Error: object location must be (%lu) * u.",
		blockSize);
	
	/*
	未使用ブロックに戻す。
	スタックを積むのと同じ要領
	*/
	*toRelease_ = SG_BASE_CHUNK_FIRST_AVAIL(self);
	SG_BASE_CHUNK_FIRST_AVAIL(self) = 
		(SGByte)((toRelease_ - SG_BASE_CHUNK_BYTES(self)) / blockSize);
	
	SG_BASE_CHUNK_BLOCKS_AVAIL(self)++;
}
