/**
  * $Id: SGBaseCArray.c,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGBaseCArray.c
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#include "SGBaseCArray.h"
#include "Utk.h"


/*!
 * @defined     kSGBaseCArrayBacketsInitSize
 * @discussion  îzóÒÇÃèâä˙óvëfêî
 */
#define kSGBaseCArrayBacketsInitSize	16
/*!
 * @defined     kSGBaseCArrayBacketsGrow
 * @discussion  îzóÒÇÃóvëfêîÇÃêLèkó¶
 */
#define kSGBaseCArrayBacketsGrow		2



/* èâä˙âª */
SGBaseCArray *SGBaseCArrayInit(SGBaseCArray *self)
{
	UtkAssertNotNULL(self);
	
	SG_BASE_CARRAY_CAPACITY(self) = 0;
	SG_BASE_CARRAY_COUNT(self) = 0;
	SG_BASE_CARRAY_ELEMENTS(self) = NULL;
	
	return self;
}
/* å„énññ */
SGBaseCArray *SGBaseCArrayFinalize(SGBaseCArray *self)
{
	UtkAssertNotNULL(self);
	
	free(SG_BASE_CARRAY_ELEMENTS(self));
	return SGBaseCArrayInit(self);
}

static unsigned SGBaseCArrayNewCapacityFor_(SGBaseCArray *self, unsigned numElements)
{
	size_t		newCount;
	
	UtkAssertNotNULL(self);
	
	newCount = SG_BASE_CARRAY_CAPACITY(self);
	if (0 == newCount)
		newCount = kSGBaseCArrayBacketsInitSize;
	
	while (newCount < numElements) 
		newCount *= kSGBaseCArrayBacketsGrow;
	
	return newCount;
}
void **SGBaseCArrayReserve(SGBaseCArray *self, unsigned numElements)
{
	unsigned	capacity;
	size_t		size;
	void		**newp;
	
	UtkAssertNotNULL(self);
	
	if (SG_BASE_CARRAY_CAPACITY(self) >= numElements)
		return SG_BASE_CARRAY_ELEMENTS(self);
	
	capacity = SGBaseCArrayNewCapacityFor_(self, numElements);
	UtkAssert2(capacity >= numElements,
		"new capacity:%u must be greater than requested number:%u",
		capacity, numElements);
	
	size = capacity * sizeof(void*);
	if (NULL == SG_BASE_CARRAY_ELEMENTS(self)) {
		UtkAssert1(0 == SG_BASE_CARRAY_COUNT(self),
			"Elements was NULL, but count was %u.",
			SG_BASE_CARRAY_COUNT(self));
		
		newp = (void**)malloc(size);
		newp[0] = NULL;
	} else {
		newp = (void**)realloc(SG_BASE_CARRAY_ELEMENTS(self), size);
	}
	
	/* Error */
	if (NULL == newp) {
		UtkError1("can not reserve requested memory:%lu", size);
		return NULL;
	}
	
	SG_BASE_CARRAY_CAPACITY(self) = capacity;
	SG_BASE_CARRAY_ELEMENTS(self) = newp;
	
	return SG_BASE_CARRAY_ELEMENTS(self);
}


void SGBaseCArrayApply(SGBaseCArray *self, SGBaseCArrayApplier applier, void *userData)
{
	unsigned	i, cnt;
	void		*p;
	
	UtkAssertNotNULL(self);
	UtkAssertNotNULL(applier);
	
	cnt = SG_BASE_CARRAY_COUNT(self);
	for (i = 0; i < cnt; i++) {
		p = SG_BASE_CARRAY_ELEMENTS(self)[i];
		applier(p, i, userData);
	}
}
void SGBaseCArrayAppendValue(SGBaseCArray *self, void *aValue)
{
	void		**p;
	unsigned	idx;
	
	UtkAssertNotNULL(self);
	
	idx = SG_BASE_CARRAY_COUNT(self);
	p = SGBaseCArrayReserve(self, idx +2);
	p[idx++] = aValue; p[idx] = NULL;
	
	SG_BASE_CARRAY_COUNT(self) = idx;
}
void SGBaseCArrayInsertValueAtIndex(SGBaseCArray *self, void *aValue, unsigned anIndex)
{
	void		**p;
	unsigned	count;
	
	UtkAssertNotNULL(self);
	count = SG_BASE_CARRAY_COUNT(self);
	if (count == anIndex) {
		SGBaseCArrayAppendValue(self, aValue);
		return;
	}
	UtkAssert2(anIndex < count,
		"index (%u) beyond bounds (%u)", anIndex, count);
	
	p = SGBaseCArrayReserve(self, count +2);
	memmove(p + anIndex + 1, p + anIndex, (count - anIndex) * sizeof(p));
	
	p[anIndex] = aValue;
	p[++count] = NULL;
	SG_BASE_CARRAY_COUNT(self) = count;
}

void SGBaseCArrayRemoveValueAtIndex(SGBaseCArray *self, unsigned anIndex)
{
	void		**p;
	unsigned	move_;
	
	UtkAssertNotNULL(self);
	UtkAssert2(
		anIndex < SG_BASE_CARRAY_COUNT(self),
		"index (%u) beyond bounds (%u)",
		anIndex, SG_BASE_CARRAY_COUNT(self));
	
	p = SG_BASE_CARRAY_ELEMENTS(self);
	move_ = (SG_BASE_CARRAY_COUNT(self) - (anIndex +1));
	
	if (move_ > 0)
		memmove(p+anIndex, p+anIndex+1, move_ * sizeof(p));
	
	p[--SG_BASE_CARRAY_COUNT(self)] = NULL;
}
void SGBaseCArrayRemoveLastValue(SGBaseCArray *self)
{
	UtkAssertNotNULL(self);
	if (0 == SG_BASE_CARRAY_COUNT(self))
		return;
	
	SG_BASE_CARRAY_ELEMENTS(self)[--SG_BASE_CARRAY_COUNT(self)] = NULL;
}
