//:SGBaseChunkTest.m
/**
  *
  * @see SGBaseChunk.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/19  5:55:25 AM)
  *
  */
#import "SGBaseChunkTest.h"


@implementation SGBaseChunkTest
- (void) setUp
{
}
- (void) tearDown
{
}

- (void) test_init
{
	SGBaseChunk		*chunk_;
	
	chunk_ = SGBaseChunkCreate(1,1);
	[self assertTrue : chunk_ != NULL];
	SGBaseChunkDealloc(chunk_);
}
- (void) test_firstAvailableBlock
{
	SGBaseChunk		*chunk_;
	void			*alloc_;
	
	chunk_ = SGBaseChunkCreate(1,1);
	[self assertInt : SG_BASE_CHUNK_FIRST_AVAIL(chunk_)
			 equals : 0];
	
	alloc_ = SGBaseChunkAllocateBlock(chunk_, 1);
	[self assertNotNil : alloc_];
	[self assertInt : SG_BASE_CHUNK_FIRST_AVAIL(chunk_)
			 equals : 1];
	SGBaseChunkDealloc(chunk_);
}
- (void) test_blocksAvailable
{
	SGBaseChunk		*chunk_;
	void			*alloc_;
	
	chunk_ = SGBaseChunkCreate(1,1);
	[self assertInt : SGBaseChunkBlocksAvailable(chunk_)
			 equals : 1];
	
	alloc_ = SGBaseChunkAllocateBlock(chunk_, 1);
	[self assertNotNil : alloc_];
	[self assertInt : SGBaseChunkBlocksAvailable(chunk_)
			 equals : 0];
	SGBaseChunkDealloc(chunk_);
}
@end
