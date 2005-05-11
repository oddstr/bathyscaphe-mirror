//: SGRangeArrayImp.m
/**
  * $Id: SGRangeArrayImp.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/SGRangeArrayImp.h>
#import "PrivateDefines.h"

enum {
	kSGRangeArrayInt	= 8,
	kSGRangeArrayGrow	= 2
};


struct SGRangeArrayImp_t{
	NSRange			*_item;
	unsigned		_count;
	unsigned		_maxLength;
};

inline static void SGRangeArraySetCount(
				SGRangeArrayRef		theArray,
				unsigned			aCount)
{
	theArray->_count = aCount;
}


SGRangeArrayRef SGRangeArrayCreate(void)
{
	SGRangeArrayRef		instance_;
	size_t				msize_;
	
	msize_ = sizeof(struct SGRangeArrayImp_t);
	instance_ = (SGRangeArrayRef) malloc(msize_);
	
	if (NULL == instance_) {
		return NULL;
	}
	memset(instance_, 0, msize_);
	instance_->_item = NULL;
	
	return instance_;
}
SGRangeArrayRef SGRangeArrayCreateCopy(SGRangeArrayRef srcArray)
{
	SGRangeArrayRef		dest_;
	size_t				memsize_;
	
	if (NULL == srcArray) return NULL;
	
	memsize_ = sizeof(struct SGRangeArrayImp_t);
	dest_ = (SGRangeArrayRef) malloc(memsize_);
	if (NULL == dest_) 
		return NULL;
	
	memmove(dest_, srcArray, memsize_);
	dest_->_item = NULL;

	memsize_ = (sizeof(NSRange) * srcArray->_maxLength);
	dest_->_item = malloc(memsize_);
	if (NULL == dest_->_item) {
		free(dest_);
		return NULL;
	}
	memmove(dest_->_item, srcArray->_item, memsize_);
	
	
	return dest_;
}
void SGRangeArrayDeallocate(SGRangeArrayRef theArray)
{
	free(theArray->_item);
	free(theArray);
}

unsigned SGRangeArrayGetCount(SGRangeArrayRef theArray)
{
	return theArray->_count;
}
NSRange SGRangeArrayGetValueAtIndex(
						SGRangeArrayRef	theArray,
						unsigned 		anIndex)
{
	NSCAssert3(
		anIndex < SGRangeArrayGetCount(theArray),
		@"%@: index (%u) beyond bounds (%u).",
		UTIL_HANDLE_FAILURE_IN_FUNCTION,
		anIndex,
		SGRangeArrayGetCount(theArray));
	
	
	return theArray->_item[anIndex];
}

void SGRangeArrayAppendValue(
				SGRangeArrayRef		theArray,
				NSRange				aRange)
{
	unsigned	count_;
	size_t		size_;
	
	count_ = SGRangeArrayGetCount(theArray);
	size_ = sizeof(NSRange);
	
	if (NULL == theArray->_item) {
		// Å‰‚ÌŠ„‚è“–‚Ä
		
		theArray->_item = (NSRange *) malloc(kSGRangeArrayInt * size_);
		NSCAssert(
			theArray->_item != NULL,
			@"***ERROR*** malloc() returns NULL");
		
		theArray->_maxLength = kSGRangeArrayInt;
		SGRangeArraySetCount(theArray, 0);
		
	}else if (count_ >= theArray->_maxLength) {
		unsigned	growed_;
		NSRange		*renew_;
		
		growed_ = kSGRangeArrayGrow * theArray->_maxLength;
		renew_ = (NSRange *) realloc(theArray->_item, size_ * growed_);
		NSCAssert(
			renew_ != NULL,
			@"***ERROR*** realloc() returns NULL");
		
		theArray->_maxLength = growed_;
		theArray->_item = renew_;
	}
	
	theArray->_item[count_] = aRange;
	SGRangeArraySetCount(theArray, ++count_);
}


void SGRangeArraySetValueAtIndex(
				SGRangeArrayRef		theArray,
				NSRange				aRange,
				unsigned			anIndex)
{
	NSCAssert3(
		anIndex < SGRangeArrayGetCount(theArray),
		@"%@: index (%u) beyond bounds (%u).",
		UTIL_HANDLE_FAILURE_IN_FUNCTION,
		anIndex,
		SGRangeArrayGetCount(theArray));
	
	theArray->_item[anIndex] = aRange;
}

void SGRangeArrayRemoveLastValue(SGRangeArrayRef theArray)
{
	unsigned		count_;
	
	count_ = SGRangeArrayGetCount(theArray);
	if (0 == count_ || 0 == theArray->_maxLength)
		return;
	
	SGRangeArraySetCount(theArray, count_ -1);
}
void SGRangeArrayRemoveAllValues(SGRangeArrayRef theArray)
{
	unsigned		count_;
	
	count_ = SGRangeArrayGetCount(theArray);
	if (0 == count_ || 0 == theArray->_maxLength)
		return;
	
	memset(theArray->_item, 0, sizeof(NSRange) * theArray->_maxLength);
	SGRangeArraySetCount(theArray, 0);
}
