//: SGBaseFixedAllocator.m
/**
  * $Id: SGBaseFixedAllocator.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001 by Andrei Alexandrescu
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  *
  * Original code and ideas from The Loki Library, by Andrei Alexandrescu.
  * This is a Objective-C implementation of it.
  * See Copyright notice of The Loki Library at the end of this file.
  *
  * See the file LICENSE for copying permission.
  */

#import "SGBaseFixedAllocator.h"

#import "PrivateDefines.h"
#import "SGFoundationBase.h"



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


/*!
 * @defined     CHUNK_BACKET_INIT
 * @discussion  chunk �z��̏����v�f��
 */
#define CHUNK_BACKET_INIT	8
/*!
 * @defined     CHUNK_BACKET_GROW
 * @discussion  chunk �z��̗v�f���̐L�k��
 */
#define CHUNK_BACKET_GROW	2



#if UTIL_DEBUGGING
/* �f�o�b�O�p�F�������̃��C�A�E�g���o�� */
static NSString *SGBaseFixedAllocatorBlocksLayoutDesc_(SGBaseChunk **chunks, unsigned numChunks, size_t chunkSize);
#else
#define SGBaseFixedAllocatorBlocksLayoutDesc_(chunks, numChunks, chunkSize)		@"<no debugging>"
#endif



/* �C�����C���֐� */
SG_STATIC_INLINE BOOL checkPointerInChunk_(void *pData, void *p, size_t size) {
	return (p >= pData && p < pData + size);
}
#define chunksBuckets_(self)		((SGBaseChunk**)SG_BASE_CARRAY_ELEMENTS(&(self)->m_chunks))
#define chunkIsEmpty_(self, chunk)	(SGBaseChunkBlocksAvailable(chunk) == (self)->m_numBlocks)



@implementation SGBaseFixedAllocator
+ (id) allocatorWithBlockSize : (size_t) blockSize
{
	return [[[self alloc] initWithBlockSize : blockSize] autorelease];
}

- (id) init
{
	if (self = [super init]) {
		self->allocChunk = NULL;
		self->deallocIdx = NSNotFound;
		SGBaseCArrayInit(&m_chunks);
	}
	return self;
}
- (id) initWithBlockSize : (size_t) sizePerBlock
			   chunkSize : (size_t) chunkSize
{
	size_t	numBlocks_;
	
	self = [self init];
	if (nil == self) return nil;
	
	NSAssert(sizePerBlock, @"sizePerBlock must not be 0");
	m_blockSize = sizePerBlock;
	
	numBlocks_ = (chunkSize / sizePerBlock);
	NSAssert2(
		numBlocks_ != 0,
		@"Maybe sizePerBlock(%u) param was too large! (chunkSize=%u)",
		sizePerBlock, chunkSize);
	if (numBlocks_ > UCHAR_MAX)
		numBlocks_ = UCHAR_MAX;
	
	m_numBlocks = (SGByte)numBlocks_;
	
	return self;
}
- (id) initWithBlockSize : (size_t) blockSize
{
	return [self initWithBlockSize:blockSize chunkSize:DEFAULT_CHUNK_SIZE];
}

- (void) dealloc
{
	[self clearAll];
	[super dealloc];
}


static void releaseChunksApplier(SGBaseChunk *element, unsigned anIndex, unsigned *numBlocks)
{
	SGBaseChunkDealloc(element);
}
- (void) clearAll
{
	SGBaseCArrayApply(
		&m_chunks,
		(SGBaseCArrayApplier)releaseChunksApplier,
		&m_numBlocks);
	SGBaseCArrayFinalize(&m_chunks);
	SGBaseCArrayInit(&m_chunks);
	
	self->allocChunk = NULL;
	self->deallocIdx = NSNotFound;
}

- (unsigned) numberOfChunks
{
	return SG_BASE_CARRAY_COUNT(&m_chunks);
}
- (NSString *) description
{
	return [NSString stringWithFormat : 
				@"%@<p:%p zone:%p>\n"
				@"blockSize=%u blocks=%u chunks=%u",
				[self className],
				self,
				[self zone],
				m_blockSize,
				m_numBlocks,
				[self numberOfChunks]];
}



/* --- �������̊m�ہA�j�� --- */

/*

�`�����N�̒T�������������邽�߂̃L���b�V��
----------------------------------------
  allocChunk : �������m�ۃ`�����N�i�|�C���^�j
  deallocIdx : �������j���`�����N�i�C���f�b�N�X�j

�������m�ہE�j���Ɍ�����X���F
  (1) ��x�ɑ�ʂ̃I�u�W�F�N�g���m��
  (2) ���������ŉ��
  (3) �t�̏����ŉ��
  (4) �����_���Ɋm�ہE���

�������m�ێ��F
���O�Ƀ��������m�ۂ����`�����N�� allocChunk �Ŏw���Ă����A
�V���ȃ������m�ێ��ɂ͂܂��A���̃`�����N�ɋ󂫂����邩�ǂ���
���m�F�B�Ȃ���΋󂢂��`�����N����`�T���B
�ЂƂ��Ȃ���΁A�V���Ƀ`�����N�𐶐����A�x�N�^�̖����ɒǉ��B
�iNOTE: ���̐헪�͂قƂ�ǂ̃P�[�X�ł��܂������j

������������F
���O�Ƀ���������������`�����N�̃C���f�b�N�X�� deallocIdx �Ŏw���Ă����A
������������ɂ͂�������o�����Ƀ`�����N�������B��������j������B
�`�����N����ɂȂ����ꍇ�́F
�E���ꂪ�����̗v�f�Ȃ�A�������Ȃ�
�E�����̗v�f�ł͂Ȃ��A�����̗v�f����Ȃ�j�����A�v�f����ύX
�E��ɂȂ����`�����N�𖖔��̗v�f�Ɠ���ւ���B
���̂��߁A��̃`�����N�͏�ɖ����ɂЂƂ݂̂ɂȂ�B

*/



- (void *) allocate
{
	SGBaseChunk		*chunkAlloc_ = self->allocChunk;
	
	
	UTIL_DEBUG_METHOD;
	
	/* �������m�ۃ`�����N�̃L���b�V�����m�F */
	if (NULL == chunkAlloc_) {
		
		UTIL_DEBUG_WRITE(@"Create chunk backets");
		NSAssert(NULL == chunksBuckets_(self), 
			@"Allocated cache was NULL. but chunks array was exists.");
		
		SGBaseCArrayReserve(&m_chunks, CHUNK_BACKET_INIT);
		
	} else {
		
		UTIL_DEBUG_WRITE1(@"theAllocChunk = %p", chunkAlloc_);
		NSAssert(chunksBuckets_(self) != NULL, 
			@"Allocated cache was exists. but chunks array was NULL.");
		
		if (SGBaseChunkBlocksAvailable(chunkAlloc_) > 0) {	/* �󂫂����� */
			UTIL_DEBUG_WRITE1(
				@"theAllocChunk has space. avalable blocks=%u",
				SGBaseChunkBlocksAvailable(chunkAlloc_));
			
			goto CHUNK_FOUND;
			
		} else {
			SGBaseChunk		**p     = NULL;
			
			/* �L���b�V���Ƀq�b�g���Ȃ������̂ŁA
				�󂫂̂���`�����N����`�T�� */
			UTIL_DEBUG_WRITE(@"theAllocChunk has no room. do search:");
			for (p = chunksBuckets_(self) ; *p != NULL; p++) {
				UTIL_DEBUG_DO( fprintf(stderr, "."); );
				
				
				if (SGBaseChunkBlocksAvailable(*p) > 0) {
					chunkAlloc_ = *p;
					UTIL_DEBUG_WRITE1(
						@"Available chunk was found. avalable blocks=%u",
						SGBaseChunkBlocksAvailable(chunkAlloc_));
					
					goto CHUNK_FOUND;
				}
			}
			UTIL_DEBUG_DO( fprintf(stderr, "\n"); );
		}
	}
	
	/* �V�K�`�����N */
	NSAssert(
		(NULL == chunkAlloc_ || 0 == SGBaseChunkBlocksAvailable(chunkAlloc_)),
		@"Attempt to create garbage chunk.");
	
	chunkAlloc_ = SGBaseChunkAlloc(m_blockSize, m_numBlocks);
	chunkAlloc_ = SGBaseChunkInit(chunkAlloc_, m_blockSize, m_numBlocks);
	
	UTIL_DEBUG_WRITE(@"*** New chunk was created ***");
	UTIL_DEBUG_DO( SGBaseChunkPrint(chunkAlloc_); );
	
	SGBaseCArrayAppendValue(&m_chunks, chunkAlloc_);
	self->deallocIdx = 0;
	
CHUNK_FOUND:
	/* �`�����N���������ꏊ�A���邢�͒ǉ������ꏊ���w���悤�ɂ��� */
	UTILAssertNotNil(chunkAlloc_);
	NSAssert(SGBaseChunkBlocksAvailable(chunkAlloc_), @"0 == blocksAvailable");
	
	self->allocChunk = chunkAlloc_;
	
	return SGBaseChunkAllocateBlock(self->allocChunk, m_blockSize);
}



- (void) deallocate : (void *) aBytes;
{
	unsigned		numChunks   = SG_BASE_CARRAY_COUNT(&m_chunks);
	SGBaseChunk		**cp        = chunksBuckets_(self);
	SGBaseChunk		**last_cp   = cp + numChunks;
	SGBaseChunk		*chunk_     = NULL;
	unsigned		chunkIndex_ = NSNotFound;
	
	UTIL_DEBUG_METHOD;
	NSCAssert(numChunks >= 1, @"Chunks Empty");
	UTILAssertNotNil(cp);
	UTILAssertNotNil(last_cp[-1]);
	
	/* ---�`�����N�̒T�� ---*/
	/* �}�[�N���Ă������C���f�b�N�X����o�����ɐ��`�T�� */
	{
		size_t			chunkSize_ = (m_blockSize * m_numBlocks);
		unsigned		lowerIdx   = self->deallocIdx;
		unsigned		upperIdx   = lowerIdx + 1;
		
		NSAssert(chunkSize_ != 0, @"chunkSize was 0.");
		NSAssert(lowerIdx != NSNotFound, @"self->deallocIdx was NSNotFound.");
		UTIL_DEBUG_WRITE4(@"Search dealloc chunk for <%p>\n"
		@"  nChunks=%u chunkSize:%lu theDeallocIdx:%u", 
		aBytes, numChunks, chunkSize_, self->deallocIdx);
		
		
		while (lowerIdx != NSNotFound || upperIdx < numChunks) {
			UTIL_DEBUG_DO( fprintf(stderr, "."); );
			
			if (lowerIdx != NSNotFound) {
				if (checkPointerInChunk_(SG_BASE_CHUNK_BYTES(cp[lowerIdx]), aBytes, chunkSize_)) {
					UTIL_DEBUG_WRITE1(
						@"Dealloc chunk was found in axis to lower, at %u", lowerIdx);
					
					chunkIndex_ = lowerIdx;
					break;
				}
				lowerIdx = (0 == lowerIdx) ? NSNotFound : lowerIdx-1;
			}
			if (upperIdx < numChunks) {
				if (checkPointerInChunk_(SG_BASE_CHUNK_BYTES(cp[upperIdx]), aBytes, chunkSize_)) {
					UTIL_DEBUG_WRITE1(
						@"Dealloc chunk was found in axis to upper, at %u", upperIdx);
					
					chunkIndex_ = upperIdx;
					break;
				}
				upperIdx++;
			}
		}
		UTIL_DEBUG_DO( fprintf(stderr, "\n"); );
	}
	NSAssert3(
		chunkIndex_ != NSNotFound && cp[chunkIndex_] != NULL,
		@"Can't find chunk for (%cp).\n%@\n\n%@",
		aBytes,
		[self description],
		SGBaseFixedAllocatorBlocksLayoutDesc_(
			cp, SG_BASE_CARRAY_COUNT(&m_chunks),
			[self chunkSize]));
	
	
	/* ---�������̔j�� ---*/
	/* ���������Ǘ����Ă���`�����N����� */
	chunk_ = cp[chunkIndex_];
	NSAssert(
		checkPointerInChunk_(SG_BASE_CHUNK_BYTES(chunk_), aBytes, [self chunkSize]),
		@"Inalid Deallocator Chunk");
	
	SGBaseChunkDeallocateBlock(chunk_, aBytes, m_blockSize);
	/* ���O�Ƀ���������������`�����N�Ƃ��ă}�[�N */
	self->deallocIdx = chunkIndex_;
	
	
	/* ---�`�����N�̔j�� ---*/
	/*
	��̃`�����N�͖����ɂ܂Ƃ߂Ă����A����炪��ɂȂ������_��
	�����̋�`�����N��j������B
	*/
	if (!chunkIsEmpty_(self, chunk_))
		return;
	
	
	self->deallocIdx = 0;	/* ���ɋ�Ȃ̂ŁA���� 0 �����蒼�� */
	if (last_cp[-1] == chunk_) 
		return;
	
	NSAssert1(numChunks >= 2, @"numChunks >= 2, but was %u.", numChunks);
	if (chunkIsEmpty_(self, last_cp[-1])) {
		/* ����������������`�����N�Ɩ����̃`�����N�̂ӂ����� */
		UTIL_DEBUG_WRITE(@"  Two Empty Chunks, remove last one.");
		
		/* �����̋�`�����N��j�� */
		SGBaseChunkDealloc(last_cp[-1]);
		last_cp[-1] = NULL; last_cp--;
		numChunks = --m_chunks.count;
	}
	
	/* ����������������`�����N�𖖔��́i��ł͂Ȃ��j�v�f�Ɠ���ւ���B*/
	if (last_cp[-1] != chunk_) {
		UTIL_DEBUG_WRITE(@"  Exchange empty chunk and last chunk.");
		cp[chunkIndex_] = last_cp[-1];
		last_cp[-1] = chunk_;
		NSAssert(!chunkIsEmpty_(self, cp[chunkIndex_]),
			@"Exchange empty chunk and last EMPTY chunk. it's bug.");
	}
	/*
	�������m�ۂɎg���\��̃`�����N�����łɖ��t�Ȃ�A
	�������̃`�����N�ɕύX����
	*/
	if (chunkIsEmpty_(self, self->allocChunk)) {
		UTIL_DEBUG_WRITE(@"  theAllocChunk was full, so make it points to Empty chunk.");
		self->allocChunk = chunk_;
	}
	
	/* ��̃`�����N��ɖ����̗v�f�ЂƂ��� */
	UTIL_DEBUG_DO(
		int		i;
		
		UTIL_DEBUG_WRITE1(@"*** Check empty chunks in vetor(%u) ****\n", numChunks);
		for (i = 0; i < numChunks -1; i++) {
			NSAssert1(!chunkIsEmpty_(self, cp[i]),
				@"Empty chunk at (%u), it's bug!", i);
		}
		NSAssert(chunkIsEmpty_(self, last_cp[-1]),
			@"Last chunk is not Empty!");
	);
}




- (size_t) blockSize
{
	return m_blockSize;
}
- (SGByte) numberOfBlocks
{
	return m_numBlocks;
}
- (size_t) chunkSize
{
	return (m_blockSize * m_numBlocks);
}
@end



#if UTIL_DEBUGGING
static NSString *SGBaseFixedAllocatorBlocksLayoutDesc_(SGBaseChunk **chunks, unsigned numChunks, size_t chunkSize)
{
	SGBaseChunk				*chunk_;
	unsigned				index_ = 0;
	NSMutableString			*desc_;
	
	if (NULL == chunks || 0 == numChunks)
		return @"";
	
	desc_ = [NSMutableString string];
	for (index_ = 0; index_ < numChunks; index_++) {
		
		chunk_ = chunks[index_];
		[desc_ appendFormat : 
			@"<%u>{%p...%p first:%u avail:%u}",
			index_,
			[chunk_ pData],
			[chunk_ pData] + chunkSize,
			[chunk_ firstAvailableBlock],
			[chunk_ blocksAvailable]];
		
		if (index_ != numChunks -1)
			[desc_ appendString : @", "];
	}
	return desc_;
}
#endif
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
