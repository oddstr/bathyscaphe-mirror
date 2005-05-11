/**
  * $Id: SGBaseCArrayWrapper.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGBaseCArrayWrapper.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBaseCArrayWrapper.h"
#import "PrivateDefines.h"



#define OBJECT_AT_INDEX_(self, idx)	(id)(self->m_objects.elements[(idx)])

#define METHOD_BOUNDS_CHECK(anIndex)						\
	UTILExceptionRaise2(									\
		(anIndex < SG_BASE_CARRAY_COUNT(&m_objects)),		\
		NSInvalidArgumentException,							\
		@"index %d out of bounds %d",						\
		anIndex,											\
		SG_BASE_CARRAY_COUNT(&m_objects))
#define METHOD_NULL_CHECK(anObject)		\
	UTILExceptionRaise(					\
		(anObject != nil),				\
		NSInvalidArgumentException,		\
		@"Element can not be nil.")



@interface SGBaseEnumerator : NSEnumerator
{
	@private
	id			*m_pointer;
	unsigned	m_count;
	unsigned	m_index;
	BOOL		m_isReverse;
}
- (id) initWithPointer : (id     *) ptr
				 count : (unsigned) count
			   reverse : (BOOL    ) isReverse;
@end



@implementation SGBaseCArrayWrapper
/**
  * Creating an array
  */
- (id) initWithObjects : (id     *) objects
                 count : (unsigned) count
{
	if (self = [self initWithCapacity : count]) {
		unsigned i;
		
		if (0 == count) return self;
		
		memmove(m_objects.elements, objects, count * sizeof(id *));
		m_objects.count = count;
		
		for (i = 0; i < count; i++)
			[OBJECT_AT_INDEX_(self, i) retain];
		
	}
	return self;
}
- (id) initWithCapacity : (unsigned int) capacity
{
	self = [self init];
	NSAssert(self, @"Fail: [self init]");
	UTILRequireCondition(self, ErrInitCapacity);
	
	SGBaseCArrayReserve(&m_objects, capacity);
	
	return self;

ErrInitCapacity:
	[self release];
	return nil;
}
- (id) init
{
	if (self = [super init]) {
		SGBaseCArrayInit(&m_objects);
	}
	return self;
}
- (void) dealloc
{
	[self removeAllObjects];
	SGBaseCArrayFinalize(&m_objects);
	[super dealloc];
}

/**
  * Querying the array
  */
- (BOOL) containsObject : (id) anObject
{
	return ([self indexOfObject : anObject] != NSNotFound);
}
- (unsigned) count
{
	return SG_BASE_CARRAY_COUNT(&m_objects);
}
- (id) lastObject
{
	return SG_BASE_CARRAY_LAST_VALUE(&m_objects);
}
- (id) objectAtIndex : (unsigned) anIndex
{
	METHOD_BOUNDS_CHECK(anIndex);
	return SG_BASE_CARRAY_ELEMENTS(&m_objects)[anIndex];
}
- (void) getObjects : (id *) aBuffer
{
	[self getObjects:aBuffer range:NSMakeRange(0, [self count])];
}
- (void) getObjects : (id    *) aBuffer
              range : (NSRange) aRange
{
	if (NSMaxRange(aRange) > [self count]) {
		[NSException raise : NSRangeException
					format : @"Attempt to Range(%@) bounds(%u)",
							 NSStringFromRange(aRange),
							 [self count]];
	}
	
	if (NULL == aBuffer || 0 == aRange.length)
		return;
	
	memmove(
		aBuffer,
		(SG_BASE_CARRAY_ELEMENTS(&m_objects) + aRange.location),
		aRange.length * sizeof(id *));
}

- (unsigned) indexOfObjectIdenticalTo : (id) anObject
{
	unsigned	i;
	
	if (nil == anObject)
		return NSNotFound;
	
	for (i = 0; i < m_objects.count; i++) {
		if (anObject == SG_BASE_CARRAY_ELEMENTS(&m_objects)[i])
			return i;
	}
	
	return NSNotFound;
}
- (unsigned) indexOfObject : (id) anObject
{
	unsigned	i;
	
	if (nil == anObject)
		return NSNotFound;
	
	for (i = 0; i < m_objects.count; i++) {
		if ([anObject isEqual : SG_BASE_CARRAY_ELEMENTS(&m_objects)[i]])
			return i;
	}
	
	return NSNotFound;
}

- (NSEnumerator *) objectEnumerator
{
	return [[[SGBaseEnumerator allocWithZone : [self zone]]
				initWithPointer : (id*)SG_BASE_CARRAY_ELEMENTS(&m_objects)
						  count : SG_BASE_CARRAY_COUNT(&m_objects)
						reverse : NO] autorelease];
}
- (NSEnumerator *) reverseObjectEnumerator
{
	return [[[SGBaseEnumerator allocWithZone : [self zone]]
				initWithPointer : (id*)SG_BASE_CARRAY_ELEMENTS(&m_objects)
						  count : SG_BASE_CARRAY_COUNT(&m_objects)
						reverse : YES] autorelease];
}

- (void) addObject : (id) anObject
{
	METHOD_NULL_CHECK(anObject);
	SGBaseCArrayAppendValue(&m_objects, [anObject retain]);
}
- (void) insertObject : (id		 ) anObject
			  atIndex : (unsigned) anIndex
{
	METHOD_NULL_CHECK(anObject);
	METHOD_BOUNDS_CHECK(anIndex);
	SGBaseCArrayInsertValueAtIndex(&m_objects, [anObject retain], anIndex);
}

- (void) replaceObjectAtIndex : (unsigned) anIndex
				   withObject : (id		 ) anObject
{
	METHOD_BOUNDS_CHECK(anIndex);
	METHOD_NULL_CHECK(anObject);
	
	
	[OBJECT_AT_INDEX_(self, anIndex) release];
	OBJECT_AT_INDEX_(self, anIndex) = [anObject retain];
}
/**
  * Removing objects
  */
- (void) removeObjectAtIndex : (unsigned) anIndex
{
	METHOD_BOUNDS_CHECK(anIndex);
	[OBJECT_AT_INDEX_(self, anIndex) release];
	SGBaseCArrayRemoveValueAtIndex(&m_objects, anIndex);
}

- (void) removeLastObject
{
	if (m_objects.count != 0) {
		[OBJECT_AT_INDEX_(self, m_objects.count -1) release];
		SGBaseCArrayRemoveLastValue(&m_objects);
	}
}


static void releaseAllObjects_(id anObject, unsigned anIndex, void *userData)
{
	[anObject release];
}
- (void) removeAllObjects
{
	SGBaseCArrayApply(
		&m_objects,
		(SGBaseCArrayApplier)releaseAllObjects_,
		NULL);
	
	SG_BASE_CARRAY_COUNT(&m_objects) = 0;
}

/**
  * Rearranging objects
  */
- (void) exchangeObjectAtIndex : (unsigned) idx1
			 withObjectAtIndex : (unsigned) idx2
{
	id		tmp;
	
	METHOD_BOUNDS_CHECK(idx1);
	METHOD_BOUNDS_CHECK(idx2);
	
	tmp = m_objects.elements[idx1];
	OBJECT_AT_INDEX_(self, idx1) = OBJECT_AT_INDEX_(self, idx2);
	OBJECT_AT_INDEX_(self, idx2) = tmp;
}
@end



@implementation SGBaseEnumerator : NSEnumerator
- (id) initWithPointer : (id     *) ptr
				 count : (unsigned) count
			   reverse : (BOOL    ) isReverse
{
	if (self = [super init]) {
		m_pointer = ptr;
		m_count = count;
		m_isReverse = isReverse;
		m_index = m_isReverse ? m_count-1 : 0;
	}
	return self;
}
- (id) nextObject
{
	if (m_isReverse) {
		m_index = (0 == m_index) ? NSNotFound : m_index-1;
		return (NSNotFound == m_index) ? nil : m_pointer[m_index];
	} else {
		return (m_count == m_index) ? nil : m_pointer[m_index++];
	}
}
@end
