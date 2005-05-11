//: SGBaseAllocator.m
/**
  * $Id: SGBaseAllocator.m,v 1.1 2005/05/11 17:51:43 tsawada2 Exp $
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

#import "SGBaseAllocator.h"

#import "PrivateDefines.h"
#import "SGFoundationBase.h"

#import <objc/objc-class.h>



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



static NSLock *kAllocatorLock = nil;
static id kSGBaseSharedAllocator = nil;


static inline NSZone *SGBaseResolveZone_(NSZone *aZone)
{
	return (NULL == aZone) ? NSDefaultMallocZone() : aZone;
}

static inline BOOL isOrderedAllocator_(
						SGBaseFixedAllocator	*anAllloc,
						NSZone					*aZone,
						size_t					aNumBytes)
{
	return (anAllloc != nil && 
					aNumBytes == SGBaseFixedAllocatorBlockSize(anAllloc) &&
					aZone == NSZoneFromPointer(anAllloc));
}

#if UTIL_DEBUGGING
/* ブロックのレイアウトを文字列表現で返す */
static NSString *blocksLayoutDescWithFixAllocators_(NSArray *theFixAllocators)
{
	NSEnumerator			*iter_;
	SGBaseFixedAllocator	*fixAlloc_;
	unsigned				index_ = 0;
	NSMutableString			*desc_;
	
	desc_ = [NSMutableString string];
	iter_ = [theFixAllocators objectEnumerator];
	while (fixAlloc_ = [iter_ nextObject]) {
		
		[desc_ appendFormat : 
			@"<%u>{size:%u zone:%p blocks:%u}",
			index_,
			[fixAlloc_ blockSize],
			[fixAlloc_ zone],
			[fixAlloc_ numberOfBlocks]];
		
		index_++;
		if (index_ != [theFixAllocators count])
			[desc_ appendString : @", "];
	}
	return desc_;
}
#endif




@implementation SGBaseAllocator
+ (void) initialize
{
	if (nil == kAllocatorLock)
		kAllocatorLock = [[NSLock alloc] init];
}

+ (SGBaseAllocator *) sharedAllocator
{
	if (nil == kSGBaseSharedAllocator) {
		[kAllocatorLock lock];
		if (nil == kSGBaseSharedAllocator) {
			kSGBaseSharedAllocator = 
				[[self alloc] initWithChunkSize : DEFAULT_CHUNK_SIZE
								  maxObjectSize : DEFAULT_MAX_OBJ_SIZE];
		}
		[kAllocatorLock unlock];
	}
	return kSGBaseSharedAllocator;
}
- (id) initWithChunkSize : (size_t) chunkSize
		   maxObjectSize : (size_t) maxObjectSize
{
	NSAssert2(
		chunkSize >= maxObjectSize,
		@"chunkSize must be greater than maxObjectSize.\n"
		@"\tbut chunkSize=%u, maxObjectSize=%u,",
		chunkSize, maxObjectSize);
	
	if (kSGBaseSharedAllocator) {
		[self release];
	}else if (self = [super init]) {
		m_chunkSize = chunkSize;
		m_maxObjectSize = maxObjectSize;
		kSGBaseSharedAllocator = self;
	}
	
	return kSGBaseSharedAllocator;
}

- (void) dealloc
{
	[_allocatorArray release];
	[super dealloc];
}



- (void *) allocateWithZone : (NSZone *) aZone
					 length : (size_t  ) numBytes
{
	NSZone		*zone_;
	void		*memory_;
	BOOL		isMultiThreaded_;
	
	if (numBytes > m_maxObjectSize)
		return NSZoneMalloc(aZone, numBytes);
	
	//
	// should be serialized. if multi-threaded.
	//
	isMultiThreaded_ = [NSThread isMultiThreaded];
	if (isMultiThreaded_)
		[kAllocatorLock lock];
	
	zone_ = SGBaseResolveZone_(aZone);
	if (NO == isOrderedAllocator_(_pLastAllocator, zone_, numBytes)) {
		SGBaseFixedAllocator	*fixAlloc_;
		unsigned				index_, numAllocs;
		
		/* この時点で初期化されるはず */
		[self fixAllocatorArray];
		UTILAssertNotNil(_allocatorArray);
		
		_pLastAllocator = nil;
		numAllocs = SGBaseCArrayWrapperCount(_allocatorArray);
		for (index_ = 0; index_ < numAllocs; index_++) {
			fixAlloc_ = SGBaseCArrayWrapperObjectAtIndex(
										_allocatorArray,
										index_);
			if (isOrderedAllocator_(fixAlloc_, zone_, numBytes)) {
				_pLastAllocator = fixAlloc_;
				break;
			}
			if (SGBaseFixedAllocatorBlockSize(fixAlloc_) > numBytes) {
				_pLastAllocator = nil;
				break;
			}
		}
		NSAssert2(
			index_ <= numAllocs,
			@"invalid index (%u) count (%u)",
			index_,
			[_allocatorArray count]);
		
		// 新規 Fixed Allocator
		if (nil == _pLastAllocator) {
			_pLastAllocator = 
				[[SGBaseFixedAllocator allocWithZone : zone_]
						initWithBlockSize : numBytes
								chunkSize : m_chunkSize ];
			NSAssert2(
				numBytes == SGBaseFixedAllocatorBlockSize(_pLastAllocator),
				@"blockSize expected %u but was %u.",
				numBytes,
				SGBaseFixedAllocatorBlockSize(_pLastAllocator));
			
			// 新しい Fixed Allocator を追加
			if (numAllocs == index_)
				[_allocatorArray addObject:_pLastAllocator];
			else
				[_allocatorArray insertObject:_pLastAllocator atIndex:index_];
			
			numAllocs++;
			[_pLastAllocator release];
			
			NSAssert(
				[_allocatorArray count] >= 1, 
				@"Array must have more then 1 element.");
			
			_pLastDeallocator = SGBaseCArrayWrapperObjectAtIndex(_allocatorArray, 0);
		}
	}
	memory_ = [_pLastAllocator allocate];
	
	if (isMultiThreaded_)
		[kAllocatorLock unlock];
	
	return memory_;
}

- (void) deallocateWithZone : (NSZone *) aZone
					  bytes : (void   *) pAllocated
					 length : (size_t  ) numBytes
{
	NSZone		*zone_;
	BOOL		isMultiThreaded_;
	
	if (numBytes > m_maxObjectSize) {
		NSZoneFree(aZone, pAllocated);
		return;
	}
	
	//
	// should be serialized. if multi-threaded.
	//
	isMultiThreaded_ = [NSThread isMultiThreaded];
	if (isMultiThreaded_)
		[kAllocatorLock lock];
	
	zone_ = SGBaseResolveZone_(aZone);
	
	if (NO == isOrderedAllocator_(_pLastDeallocator, zone_, numBytes)) {
		SGBaseFixedAllocator	*fixAlloc_;
		unsigned				i, numAllocs;
		
		UTILAssertNotNil(_allocatorArray);
		numAllocs = SGBaseCArrayWrapperCount(_allocatorArray);
		NSAssert(numAllocs > 0, @"Empty Pool");
		
		_pLastDeallocator = nil;
		for (i = 0; i < numAllocs; i++) {
			fixAlloc_ = SGBaseCArrayWrapperObjectAtIndex(_allocatorArray, i);
			
			if (isOrderedAllocator_(fixAlloc_, zone_, numBytes)) {
				_pLastDeallocator = fixAlloc_;
				break;
			}
		}

#if UTIL_DEBUGGING
	if (nil == _pLastDeallocator) {
		NSAssert4(
			_pLastDeallocator,
			@"\n\t"
			@"No Associated Deallocator (for zone:%@ size:%u) "
			@"in %u allocators.\n\n"
			@"%@\n",
			zone_,
			numBytes,
			[_allocatorArray count],
			blocksLayoutDescWithFixAllocators_(_allocatorArray));
	}
#endif
		NSAssert3(
			numBytes == SGBaseFixedAllocatorBlockSize(_pLastDeallocator),
			@"\n\t"
			@"Invalid Deallocator(Block Size:expected %u but was %u) "
			@"in %u allocators.",
			numBytes,
			SGBaseFixedAllocatorBlockSize(_pLastDeallocator),
			[_allocatorArray count]);
		NSAssert3(
			zone_ == [_pLastDeallocator zone],
			@"\n\t"
			@"Invalid Deallocator(Zone:expected %p but was %p)."
			@"in %u allocators.",
			zone_,
			[_pLastDeallocator zone],
			[_allocatorArray count]);
	}
	[_pLastDeallocator deallocate : pAllocated];
	
	if (isMultiThreaded_)
		[kAllocatorLock unlock];
}


- (size_t) chunkSize
{
	return m_chunkSize;
}
- (size_t) maxObjectSize
{
	return m_maxObjectSize;
}
- (NSArray *) fixAllocatorArray
{
	if (nil == _allocatorArray)
		_allocatorArray = [[SGBaseCArrayWrapper allocWithZone:NULL] init];
	
	return _allocatorArray;
}
@end



// Allocate/Deallocate an Object
id<NSObject> SGBaseObjAlloc(Class aClass, size_t extraBytes, NSZone *aZone)
{
	id<NSObject>				instance_;
	size_t						size_;
	
	NSCAssert(aClass != Nil, @"Class must be not Nil");
	if (Nil == aClass)
		return nil;
	
	NSCAssert(0 == extraBytes, @"Not Support extraBytes");
	
	size_ = aClass->instance_size + extraBytes;
	instance_ = SGBaseZoneMalloc(aZone, size_);
	
	memset(instance_, 0, size_);
	instance_->isa = aClass;
	
	return instance_;
}
void SGBaseObjDealloc(id<NSObject> anObject)
{
	size_t				size_;
	
	if (nil == anObject) return;
	
	size_ = anObject->isa->instance_size;
	SGBaseZoneFree([anObject zone], anObject, size_);
}
void *SGBaseZoneMalloc(NSZone *aZone, size_t bytesLen)
{
	SGBaseAllocator	*allocator_;
	NSZone			*zone_;
	
	zone_ = SGBaseResolveZone_(aZone);
	
	allocator_ = kSGBaseSharedAllocator;
	if (nil == allocator_)
		allocator_ = [SGBaseAllocator sharedAllocator];
	
	UTILCAssertNotNil(allocator_);
	
	return [allocator_ allocateWithZone:zone_ length:bytesLen];
}

void SGBaseZoneFree(NSZone *aZone, void *pointer, size_t bytesLen)
{
	SGBaseAllocator		*allocator_;
	NSZone				*zone_;
	
	if (nil == pointer)
		return;
	
	zone_ = SGBaseResolveZone_(aZone);
	allocator_ = kSGBaseSharedAllocator;
	if (nil == kSGBaseSharedAllocator)
		allocator_ = [SGBaseAllocator sharedAllocator];
	
	UTILCAssertNotNil(allocator_);
	[allocator_ deallocateWithZone : zone_
							 bytes : pointer
							length : bytesLen];
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
