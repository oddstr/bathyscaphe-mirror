//: SGBaseRangeArray.h
/**
  * $Id: SGBaseRangeArray.h,v 1.1.1.1.4.1 2006/02/27 17:31:50 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>

//#import <SGFoundation/SGBaseObject.h>
#import <SGFoundation/SGRangeArrayImp.h>


@class SGBaseRangeEnumerator;



@interface SGBaseRangeArray : NSObject//SGBaseObject
{
	@public
	SGRangeArrayRef		_imp;
}
+ (id) array;
+ (id) arrayWithRangeArray : (SGBaseRangeArray *) theArray;
- (id) initWithRangeArray : (SGBaseRangeArray *) theArray;

- (SGBaseRangeEnumerator *) enumerator;
- (SGBaseRangeEnumerator *) reverseEnumerator;

- (NSRange) rangeAtIndex : (unsigned) anIndex;

- (unsigned) count;
- (BOOL) isEmpty;
- (NSRange) last;
- (NSRange) head;

- (void) append : (NSRange) aRange;
- (void) setRange : (NSRange ) aRange
		  atIndex : (unsigned) anIndex;

- (void) removeLast;
- (void) removeAll;
@end



@interface SGBaseRangeEnumerator : NSObject//SGBaseObject
{
	@private
	unsigned			_position;
	SGBaseRangeArray	*_array;
	BOOL				_reverse;
}
- (id) initWithRangeArray : (SGBaseRangeArray *) theArray
				  reverse : (BOOL          ) reverse;
- (BOOL) hasNext;
- (NSRange) next;
@end
