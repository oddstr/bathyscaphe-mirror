//: SGBaseRangeArray.m
/**
  * $Id: SGBaseRangeArray.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/SGBaseRangeArray.h>



@implementation SGBaseRangeEnumerator
- (id) initWithRangeArray : (SGBaseRangeArray *) theArray
				  reverse : (BOOL          ) reverse
{
	if(self = [super init]){
		_array = [theArray retain];
		/*
		_array = theArray;
		*/
		_reverse = reverse;
		
		_position = _reverse 
						? SGRangeArrayGetCount(_array->_imp)
						: 0;
	}
	return self;
}
- (void) dealloc
{
	[_array release];
	[super dealloc];
}

- (BOOL) hasNext
{
	return (_reverse 
				? _position != 0 
				: _position < SGRangeArrayGetCount(_array->_imp));
}
- (NSRange) next
{
	NSRange		next_;
	
	next_ = SGRangeArrayGetValueAtIndex(
				_array->_imp,
				_reverse ? _position -1 : _position);
	
	_position += (_reverse ? -1 : 1);
	
	return next_;
}
@end



@implementation SGBaseRangeArray
+ (id) array
{
	return [[[self alloc] init] autorelease];
}
+ (id) arrayWithRangeArray : (SGBaseRangeArray *) theArray
{
	return [[[self alloc] initWithRangeArray : theArray] autorelease];
}
- (id) init
{
	if(self = [super init]){
		_imp = SGRangeArrayCreate();
		if(NULL == _imp){
			[self release];
			return nil;
		}
	}
	return self;
}

- (id) initWithRangeArray : (SGBaseRangeArray *) theArray
{
	if(self = [super init]){
		_imp = SGRangeArrayCreateCopy(theArray->_imp);
		if(NULL == _imp){
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) dealloc
{
	SGRangeArrayDeallocate(_imp);
	[super dealloc];
}
// NSObject
- (NSString *) description
{
	NSMutableString			*description_ = [NSMutableString string];
	SGBaseRangeEnumerator	*enumerator_;
	unsigned				index_ = 0;
	
	[description_ appendFormat : 
			@"<%@ %p> count=%u\n",
			[self className],
			self,
			[self count]];
	enumerator_ = [self enumerator];
	while([enumerator_ hasNext]){
		NSRange	next_ = [enumerator_ next];
		
		[description_ appendFormat : @"  %u: %@\n",
						index_,
						NSStringFromRange(next_)];
		index_++;
	}
	return description_;
}
// enumerator
- (SGBaseRangeEnumerator *) enumerator
{
	return [[[SGBaseRangeEnumerator alloc]
				initWithRangeArray : self
						   reverse : NO] autorelease];
}
- (SGBaseRangeEnumerator *) reverseEnumerator
{
	return [[[SGBaseRangeEnumerator alloc]
				initWithRangeArray : self
						   reverse : YES] autorelease];
}


- (NSRange) rangeAtIndex : (unsigned) anIndex
{
	return SGRangeArrayGetValueAtIndex(_imp, anIndex);
}


- (BOOL) isEmpty
{
	return (0 == [self count]);
}
- (NSRange) last
{
	unsigned	count_ = [self count];
	
	if(0 == count_)
		return NSMakeRange(NSNotFound, 0);
	
	return [self rangeAtIndex : (count_ -1)];
}
- (NSRange) head
{
	return ([self isEmpty]) ? NSMakeRange(NSNotFound, 0) : [self rangeAtIndex : 0];
}
- (unsigned) count
{
	return SGRangeArrayGetCount(_imp);
}
- (void) append : (NSRange) aRange
{
	SGRangeArrayAppendValue(_imp, aRange);
}
- (void) setRange : (NSRange ) aRange
		  atIndex : (unsigned) anIndex
{
	SGRangeArraySetValueAtIndex(_imp, aRange, anIndex);
}
- (void) removeLast { SGRangeArrayRemoveLastValue(_imp); }
- (void) removeAll { SGRangeArrayRemoveAllValues(_imp); }
@end
