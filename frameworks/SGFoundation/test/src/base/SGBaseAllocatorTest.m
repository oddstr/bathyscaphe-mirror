//:SGBaseAllocatorTest.m
/**
  *
  * @see SGBaseAllocator.h
  * @see SGBaseObject.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/19  11:26:59 AM)
  *
  */
#import "SGBaseAllocatorTest.h"


@implementation SGBaseAllocatorTest
- (void) setUp
{
}
- (void) tearDown
{
}


- (void) test_allocate
{
	SGBaseObject		*obj_;
	
	obj_ = [[SGBaseObject alloc] init];
	[self assertNotNil : obj_];
	[self assertString : [obj_ className]
				equals : NSStringFromClass([SGBaseObject class])];
	[self assertInt : [obj_ retainCount]
			 equals : 1];
	[self assertTrue : [obj_ isKindOfClass : [NSObject class]]];
	[self assertTrue : [obj_ respondsToSelector : @selector(description)]];
	
	[obj_ release];
}

#define LOOP	10

- (void) test_SGBaseObject_allocate
{
	NSMutableArray	*objects_;
	int				index_;
	
	objects_ = [[NSMutableArray alloc] init];
	
	for(index_ = 0; index_ < LOOP; index_++){
		NSObject		*obj_;
	
		obj_ = [[SGBaseObject alloc] init];
		[objects_ addObject : obj_];
		[obj_ release];
	}
	
	[objects_ release];
}


#define MAX_MULTIPLE_SIZES_ALLOC		DEFAULT_MAX_OBJ_SIZE
- (void) test_multiple_sizes_alloc
{
	void		*pointers_[MAX_MULTIPLE_SIZES_ALLOC];
	int			i;
	SGBaseAllocator	*allocator_;
	
	allocator_ = [SGBaseAllocator sharedAllocator];
	for(i = 1; i < MAX_MULTIPLE_SIZES_ALLOC; i++){
		pointers_[i] = [allocator_ allocateWithZone : NULL
											 length : i];
	}
	for(i = 1; i < MAX_MULTIPLE_SIZES_ALLOC; i++){
		[allocator_ deallocateWithZone : NULL
								 bytes : pointers_[i]
								length : i];
	}
}
- (void) test_multiple_sizes_alloc_rev
{
	void		*pointers_[MAX_MULTIPLE_SIZES_ALLOC];
	int			i;
	SGBaseAllocator	*allocator_;
	
	allocator_ = [SGBaseAllocator sharedAllocator];
	for(i = MAX_MULTIPLE_SIZES_ALLOC-1; i >= 1; i--){
		pointers_[i] = [allocator_ allocateWithZone : NULL
											 length : i];
	}
	for(i = MAX_MULTIPLE_SIZES_ALLOC-1; i >= 1; i--){
		[allocator_ deallocateWithZone : NULL
								 bytes : pointers_[i]
								length : i];
	}
}

- (void) test_multiple_sizes_alloc_Uturn
{
	void		*pointers_[MAX_MULTIPLE_SIZES_ALLOC];
	int			i;
	SGBaseAllocator	*allocator_;
	
	allocator_ = [SGBaseAllocator sharedAllocator];
	for(i = 1; i < MAX_MULTIPLE_SIZES_ALLOC; i++){
		pointers_[i] = [allocator_ allocateWithZone : NULL
											 length : i];
	}
	for(i = MAX_MULTIPLE_SIZES_ALLOC-1; i >= 1; i--){
		[allocator_ deallocateWithZone : NULL
								 bytes : pointers_[i]
								length : i];
	}
}
@end
