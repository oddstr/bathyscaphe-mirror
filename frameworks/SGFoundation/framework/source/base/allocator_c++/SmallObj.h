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

// Last update: June 20, 2001

#ifndef SMALLOBJ_INC_
#define SMALLOBJ_INC_

#include <cstddef>
#include <vector>

#ifndef DEFAULT_CHUNK_SIZE
#define DEFAULT_CHUNK_SIZE 4096
#endif

#ifndef MAX_SMALL_OBJECT_SIZE
#define MAX_SMALL_OBJECT_SIZE 64
#endif

namespace Loki
{
////////////////////////////////////////////////////////////////////////////////
// class FixedAllocator
// Offers services for allocating fixed-sized objects
////////////////////////////////////////////////////////////////////////////////

    class FixedAllocator
    {
    private:
        struct Chunk
        {
            void Init(std::size_t blockSize, unsigned char blocks);
            void* Allocate(std::size_t blockSize);
            void Deallocate(void* p, std::size_t blockSize);
            void Reset(std::size_t blockSize, unsigned char blocks);
            void Release();
            unsigned char* pData_;
            unsigned char
                firstAvailableBlock_,
                blocksAvailable_;
        };
        
        // Internal functions        
        void DoDeallocate(void* p);
        Chunk* VicinityFind(void* p);
        
        // Data 
        std::size_t blockSize_;
        unsigned char numBlocks_;
        typedef std::vector<Chunk> Chunks;
        Chunks chunks_;
        Chunk* allocChunk_;
        Chunk* deallocChunk_;
        // For ensuring proper copy semantics
        mutable const FixedAllocator* prev_;
        mutable const FixedAllocator* next_;
        
    public:
        // Create a FixedAllocator able to manage blocks of 'blockSize' size
        explicit FixedAllocator(std::size_t blockSize = 0);
        FixedAllocator(const FixedAllocator&);
        FixedAllocator& operator=(const FixedAllocator&);
        ~FixedAllocator();
        
        void Swap(FixedAllocator& rhs);
        
        // Allocate a memory block
        void* Allocate();
        // Deallocate a memory block previously allocated with Allocate()
        // (if that's not the case, the behavior is undefined)
        void Deallocate(void* p);
        // Returns the block size with which the FixedAllocator was initialized
        std::size_t BlockSize() const
        { return blockSize_; }
        // Comparison operator for sorting 
        bool operator<(std::size_t rhs) const
        { return BlockSize() < rhs; }
    };
    
////////////////////////////////////////////////////////////////////////////////
// class SmallObjAllocator
// Offers services for allocating small-sized objects
////////////////////////////////////////////////////////////////////////////////

    class SmallObjAllocator
    {
    public:
        SmallObjAllocator(
            std::size_t chunkSize, 
            std::size_t maxObjectSize);
    
        void* Allocate(std::size_t numBytes);
        void Deallocate(void* p, std::size_t size);
    
    private:
        SmallObjAllocator(const SmallObjAllocator&);
        SmallObjAllocator& operator=(const SmallObjAllocator&);
        
        typedef std::vector<FixedAllocator> Pool;
        Pool pool_;
        FixedAllocator* pLastAlloc_;
        FixedAllocator* pLastDealloc_;
        std::size_t chunkSize_;
        std::size_t maxObjectSize_;
    };

} // namespace Loki

////////////////////////////////////////////////////////////////////////////////
// Change log:
// June 20, 2001: ported by Nick Thurn to gcc 2.95.3. Kudos, Nick!!!
////////////////////////////////////////////////////////////////////////////////

#endif // SMALLOBJ_INC_
