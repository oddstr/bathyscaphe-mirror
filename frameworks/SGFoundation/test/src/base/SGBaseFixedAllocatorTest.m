//:SGBaseFixedAllocatorTest.m
/**
  *
  * @see SGBaseChunk.h
  * @see SGBaseFixedAllocator.h
  * @see SGBaseObject.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/19  8:59:31 AM)
  *
  */
#import "SGBaseFixedAllocatorTest.h"
#import "UTILKit.h"


@implementation SGBaseFixedAllocatorTest
- (void) setUp
{
}
- (void) tearDown
{
}

- (void) test_init
{
	SGBaseFixedAllocator	*allocator_;
	
	allocator_ = [SGBaseFixedAllocator allocatorWithBlockSize : 32];
	[self assertNotNil : allocator_];
	
}
- (void) test_accessor
{
	size_t	bsize_[] = {1, 32, 100};
	int		i, cnt;
	
	cnt = UTILNumberOfCArray(bsize_);
	for(i = 0; i < cnt; i++){
		SGBaseFixedAllocator	*allocator_;
		
		allocator_ = [SGBaseFixedAllocator allocatorWithBlockSize : bsize_[i]];
		[self assertNotNil : allocator_];
		[self assertInt : [allocator_ blockSize]
				 equals : bsize_[i]];
		[self assertInt : [allocator_ chunkSize]/[allocator_ numberOfBlocks]
				 equals : [allocator_ blockSize]];
	}
}


- (void) test_allocate
{
	size_t	bsize_[] = {1, 32, 100};
	int		i, cnt;
	
	cnt = UTILNumberOfCArray(bsize_);
	for(i = 0; i < cnt; i++){
		SGBaseFixedAllocator	*allocator_;
		void					*bytes1_;
		void					*bytes2_;
		
		allocator_ = [SGBaseFixedAllocator allocatorWithBlockSize : bsize_[i]];
		
		bytes1_ = [allocator_ allocate];
		[self assertNotNil : bytes1_];
		bytes2_ = [allocator_ allocate];
		[self assertNotNil : bytes2_];
		
		[self assertInt : bytes2_ - bytes1_
				 equals : bsize_[i]];
		
		[allocator_ deallocate : bytes1_];
		[allocator_ deallocate : bytes2_];
	}
}




- (void) test_allocate2
{
	size_t	bsize_[] = {1, 32, 100};
	int		i, cnt;
	
	cnt = UTILNumberOfCArray(bsize_);
	for(i = 0; i < cnt; i++){
		SGBaseFixedAllocator	*allocator_;
		void					*bytes_;
		size_t					chunkSize_;
		int						j;
		
		allocator_ = [SGBaseFixedAllocator allocatorWithBlockSize : bsize_[i]];
		chunkSize_ = [allocator_ chunkSize];
		
		for(j = 0; j <= [allocator_ numberOfBlocks]; j++){
			bytes_ = [allocator_ allocate];
		}
		[self assertInt : [allocator_ numberOfChunks]
				 equals : 2];
	}
}


#define		LOOP_TIME		10000
- (void) test_allocate3
{
	size_t	bsize_[] = {8, 32, 100};
	int		i, cnt;
	
	cnt = UTILNumberOfCArray(bsize_);
	for(i = 0; i < cnt; i++){
		SGBaseFixedAllocator	*allocator_;
		void					*bytes_[LOOP_TIME];
		int						j;
		
		allocator_ = [SGBaseFixedAllocator allocatorWithBlockSize : bsize_[i]];
		
		for(j = 0; j < LOOP_TIME; j++){
			bytes_[j] = [allocator_ allocate];
		}
		for(j = 0; j < LOOP_TIME; j++){
			[allocator_ deallocate : bytes_[j]];
		}
	}
}

@end
