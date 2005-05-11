//: SGBaseAllocator.h
/**
  * $Id: SGBaseAllocator.h,v 1.1 2005/05/11 17:51:43 tsawada2 Exp $
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

#ifndef SGBASEALLOCATOR_H_INCLUDED
#define SGBASEALLOCATOR_H_INCLUDED

#import <Foundation/Foundation.h>
#import <SGFoundation/SGBase.h>

SG_DECL_BEGIN


@class SGBaseFixedAllocator;
@class SGBaseCArrayWrapper;

@interface SGBaseAllocator : NSObject
{
	@private
	size_t			m_chunkSize;
	size_t			m_maxObjectSize;
	
	SGBaseCArrayWrapper		*_allocatorArray;
	SGBaseFixedAllocator	*_pLastAllocator;
	SGBaseFixedAllocator	*_pLastDeallocator;
}
+ (SGBaseAllocator *) sharedAllocator;
- (id) initWithChunkSize : (size_t) chunkSize
		   maxObjectSize : (size_t) maxObjectSize;

- (size_t) chunkSize;
- (size_t) maxObjectSize;
- (NSArray *) fixAllocatorArray;

- (void *) allocateWithZone : (NSZone *) aZone
					 length : (size_t  ) numBytes;
- (void) deallocateWithZone : (NSZone *) aZone
					  bytes : (void   *) pAllocated
					 length : (size_t  ) numBytes;
@end



// Allocate/Deallocate an Object
SG_EXPORT
void *SGBaseZoneMalloc(NSZone *zone, size_t size);
SG_EXPORT
void SGBaseZoneFree(NSZone *zone, void *pointer, size_t bytesLen);

SG_EXPORT
id<NSObject> SGBaseObjAlloc(Class aClass, size_t extraBytes, NSZone *zone);
SG_EXPORT
void SGBaseObjDealloc(id<NSObject> anObject);



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

#endif /* SGBASEALLOCATOR_H_INCLUDED */
