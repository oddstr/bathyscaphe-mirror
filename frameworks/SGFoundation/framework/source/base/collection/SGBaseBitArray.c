//: SGBaseBitArray.c
/**
  * $Id: SGBaseBitArray.c,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#include "SGBaseBitArray.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include <CoreServices/CoreServices.h>



#define BITS_PER_WORD		32
#define PREFERED_LENGTH		(16 * 8)
#define NBITS_SHIFT			5
#define INDEX_MASK			0x1f



struct SGBaseBitArray {
	UInt32			*mpStore;
	unsigned		mCapacity;
};

// private
static size_t SGBaseBitArrayGetSizeOfStore(SGBaseBitArrayRef me);


// allocate
SGBaseBitArrayRef SGBaseBitArrayAlloc(void)
{
	return SGBaseBitArrayAllocLength(PREFERED_LENGTH);
}


SGBaseBitArrayRef SGBaseBitArrayAllocLength(unsigned aLength)
{
	SGBaseBitArrayRef	instance_;
	unsigned			capacity_;
	
	instance_ = malloc(sizeof(struct SGBaseBitArray));
	assert(instance_ != NULL);
	
	capacity_ = (aLength/BITS_PER_WORD) +1;
	
	instance_->mpStore = malloc(sizeof(UInt32) * capacity_);
	assert(instance_->mpStore != NULL);
	instance_->mCapacity = capacity_;
	
	SGBaseBitArrayClearAll(instance_);
	
	return instance_;
}

void SGBaseBitArrayDealloc(SGBaseBitArrayRef me)
{
	if(NULL == me)
		return;
	
	free(me->mpStore);
	free(me);
}

// length
unsigned SGBaseBitArrayGetLength(SGBaseBitArrayRef me)
{
	assert(me != NULL);
	return (me->mCapacity * BITS_PER_WORD);
}
void SGBaseBitArrayReserve(SGBaseBitArrayRef me, unsigned reserveLength)
{
	if(reserveLength > SGBaseBitArrayGetLength(me))
		SGBaseBitArraySetLength(me, reserveLength);
}
void SGBaseBitArraySetLength(SGBaseBitArrayRef me, unsigned aLength)
{
	unsigned	oldcap_;
	unsigned	newcap_;
	UInt32		*newp_;
	
	assert(me != NULL);
	
	oldcap_ = me->mCapacity;
	newcap_ = (aLength/BITS_PER_WORD) +1;
	if(oldcap_ == newcap_)
		return;
	
	newp_ = realloc(me->mpStore, sizeof(me->mpStore[0]) * newcap_);
	assert(newp_ != NULL);
	
	me->mpStore = newp_;
	me->mCapacity = newcap_;
	
	if(oldcap_ >= newcap_)
		return;
	
	newp_ += oldcap_;
	memset(newp_, 0, sizeof(me->mpStore[0]) * (newcap_ - oldcap_));
}

// bit operation
int SGBaseBitArrayGetAtIndex(SGBaseBitArrayRef me, unsigned anIndex)
{
	unsigned	index_;
	
	index_ = (anIndex>>NBITS_SHIFT);
	assert(0 <= index_ && index_ < me->mCapacity);
	
	return (me->mpStore[index_] & (1 << (anIndex & INDEX_MASK))) != 0;
}
void SGBaseBitArraySetAtIndex(SGBaseBitArrayRef me, unsigned anIndex)
{
	unsigned	index_;
	
	index_ = (anIndex>>NBITS_SHIFT);
	assert(0 <= index_ && index_ < me->mCapacity);
	
	(me->mpStore[index_] |= (1 << (anIndex & INDEX_MASK)));
}
void SGBaseBitArrayClearAtIndex(SGBaseBitArrayRef me, unsigned anIndex)
{
	unsigned	index_;
	
	index_ = (anIndex>>NBITS_SHIFT);
	assert(0 <= index_ && index_ < me->mCapacity);
	
	
	(me->mpStore[index_] &= ~(1 << (anIndex & INDEX_MASK)));
}

void SGBaseBitArrayClearAll(SGBaseBitArrayRef me)
{
	assert(me != NULL);
	memset(me->mpStore, 0, SGBaseBitArrayGetSizeOfStore(me));
}



static size_t SGBaseBitArrayGetSizeOfStore(SGBaseBitArrayRef me)
{
	assert(me != NULL);
	
	return (sizeof(me->mpStore[0]) * me->mCapacity);
}
