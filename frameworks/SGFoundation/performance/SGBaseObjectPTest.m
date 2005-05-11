/**
  * $Id: SGBaseObjectPTest.m,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * SGBaseObjectPTest.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBaseObjectPTest.h"
#import "UTILKit.h"



#define LOOP					300
#define MAX_SMALL_OBJ_SIZE		DEFAULT_MAX_OBJ_SIZE
#define NUM_OBJECT				100

#define ALLOC_TEST_NOBJECT	1024
#define ALLOC_TEST_NOBJECT2	(1000)


@implementation SGBaseObjectPTest
- (void) setUp
{
}
- (void) tearDown
{
}


static id obj_backets[ALLOC_TEST_NOBJECT];



- (void) AllocTest_default : (Class) aClass
{
	CLOCK_TIMER_BEGIN(LOOP)
	
	int		i;
	
	for (i = 0; i < ALLOC_TEST_NOBJECT; i++) {
		obj_backets[i] = [[aClass alloc] init];
	}
	for (i = 0; i < ALLOC_TEST_NOBJECT; i++) {
		[obj_backets[i] release];
	}
	
	CLOCK_TIMER_END_CLASS(aClass, LOOP)
}
- (void) AllocTest_reverse : (Class) aClass
{
	CLOCK_TIMER_BEGIN(LOOP)
	
	int		i;
	
	for (i = 0; i < ALLOC_TEST_NOBJECT; i++) {
		obj_backets[i] = [[aClass alloc] init];
	}
	for (i = ALLOC_TEST_NOBJECT -1; i >= 0; i--) {
		[obj_backets[i] release];
	}
	
	CLOCK_TIMER_END_CLASS(aClass, LOOP)
}

#if 1
- (void) test_allocSoManyObjects
{
	
	int		i;
	id		*backets_;
	size_t	size;
	SGBaseAllocator	*allocator_;
	
	size = (MAX_SMALL_OBJ_SIZE/2);
	NSLog(@"Allocate %d objects (size=%u).",
		ALLOC_TEST_NOBJECT2, size);
	
	CLOCK_TIMER_BEGIN(LOOP)
	
	allocator_ = [SGBaseAllocator sharedAllocator];
	backets_ = malloc(sizeof(id) * ALLOC_TEST_NOBJECT2);
	UTILAssertNotNil(backets_);
	
	for (i = 0; i < ALLOC_TEST_NOBJECT2; i++) {
		backets_[i] = [allocator_ allocateWithZone:NULL length:size];
	}
	for (i = 0; i < ALLOC_TEST_NOBJECT2; i++) {
		[allocator_ deallocateWithZone : NULL
							 bytes : backets_[i]
							length : size];
	}
	free(backets_);
	
	CLOCK_TIMER_END(LOOP)
	
}
#endif
- (void) test_allocation
{
#if 1
	[self AllocTest_default : [NSObject class]];
	[self AllocTest_reverse : [NSObject class]];
#endif

	[self AllocTest_default : [SGBaseObject class]];
	[self AllocTest_reverse : [SGBaseObject class]];
}

- (void) test_multiple_sizes_alloc
{
	CLOCK_TIMER_BEGIN(LOOP)
	void		*pointers_[MAX_SMALL_OBJ_SIZE * NUM_OBJECT];
	int			i;
	SGBaseAllocator	*allocator_;
	
	allocator_ = [SGBaseAllocator sharedAllocator];
	for (i = 0; i < MAX_SMALL_OBJ_SIZE; i++) {
		int j;
		for (j = 0; j < NUM_OBJECT; j++)
			pointers_[i*NUM_OBJECT+j] = 
				[allocator_ allocateWithZone : NULL length:i+1];
	}
	for (i = 0; i < MAX_SMALL_OBJ_SIZE; i++) {
		int j;
		for (j = 0; j < NUM_OBJECT; j++)
			[allocator_ deallocateWithZone : NULL
								 bytes : pointers_[i*NUM_OBJECT+j]
								length : i+1];
	}
	CLOCK_TIMER_END(LOOP)
}
- (void) test_multiple_sizes_alloc_rev
{
	CLOCK_TIMER_BEGIN(LOOP)
	void		*pointers_[MAX_SMALL_OBJ_SIZE * NUM_OBJECT];
	int			i;
	SGBaseAllocator	*allocator_;
	
	allocator_ = [SGBaseAllocator sharedAllocator];
	for (i = MAX_SMALL_OBJ_SIZE -1; i >= 0; i--) {
		int j;
		for (j = NUM_OBJECT-1; j >= 0; j--)
			pointers_[i*NUM_OBJECT+j] = 
				[allocator_ allocateWithZone : NULL length:i+1];
	}
	for (i = MAX_SMALL_OBJ_SIZE -1; i >= 0; i--) {
		int j;
		for (j = NUM_OBJECT-1; j >= 0; j--)
			[allocator_ deallocateWithZone : NULL
								 bytes : pointers_[i*NUM_OBJECT+j]
								length : i+1];
	}
	CLOCK_TIMER_END(LOOP)
}

- (void) test_multiple_sizes_alloc_Uturn
{
	CLOCK_TIMER_BEGIN(LOOP)
	void		*pointers_[MAX_SMALL_OBJ_SIZE * NUM_OBJECT];
	int			i;
	SGBaseAllocator	*allocator_;
	
	allocator_ = [SGBaseAllocator sharedAllocator];
	for (i = 0; i < MAX_SMALL_OBJ_SIZE; i++) {
		int j;
		for (j = 0; j < NUM_OBJECT; j++)
			pointers_[i*NUM_OBJECT+j] = [allocator_ allocateWithZone : NULL length:i+1];
	}
	for (i = MAX_SMALL_OBJ_SIZE -1; i >= 0; i--) {
		int j;
		for (j = NUM_OBJECT-1; j >= 0; j--)
			[allocator_ deallocateWithZone : NULL
								 bytes : pointers_[i*NUM_OBJECT+j]
								length : i+1];
	}
	CLOCK_TIMER_END(LOOP)
}
@end
