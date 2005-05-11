//: SGBaseRangeArray.h
/**
  * $Id: SGBaseRangeArray.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>

#import <SGFoundation/SGBaseObject.h>
#import <SGFoundation/SGRangeArrayImp.h>


@class SGBaseRangeEnumerator;



@interface SGBaseRangeArray : SGBaseObject
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



@interface SGBaseRangeEnumerator : SGBaseObject
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
