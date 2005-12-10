//:
/**
  * $Id: CMRThreadsList-Search.m,v 1.3 2005/12/10 12:39:44 tsawada2 Exp $
  * BathyScaphe 1.1.2 "TestaRossa"
  *
  * Copyright 2005 BathyScaphe Project. All rights reserved.
  *
  */

#import "CMRThreadsList_p.h"

@implementation CMRThreadsList(SearchThreads)
- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath
{
	id	thread_;
	
	// ���Ƀ��O���擾���Ă���΁A�����Ɋi�[���Ă���B
	// ���O�����݂��Ȃ��ꍇ��NSNull���i�[���Ă���B
	thread_ = [[self threadsInfo] objectForKey : filepath];
	if(thread_ != nil && (NO == [thread_ isEqual : [NSNull null]]))
		return thread_;

	// ���O���Ȃ���΁A�ꗗ���猟���B
	thread_ = [self seachThreadByPath : filepath inArray : [self threads]];
	return thread_;
}

- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath
									inArray : (NSArray  *) array
{
	NSArray *matched_;
	
	matched_ = [self _searchThreadsInArray : array context : filepath];
	if([matched_ count] == 0) return nil;
	
	//�p�X������̈�v����X���b�h�͂ЂƂ����Ȃ��B
	NSAssert(([matched_ count] == 1), @"duplicated threadsList.");
	
	return [matched_ objectAtIndex : 0];
}

- (NSArray *) _searchThreadsInArray : (NSArray *) array context : (NSString *) context
{
	NSMutableArray		*result_;
	NSEnumerator		*iter_;
	NSDictionary		*thread_;
	NSAutoreleasePool	*pool_;
	
	result_ = [NSMutableArray array];
	if (nil == array || nil == context)
		return result_;

	pool_ = [[NSAutoreleasePool alloc] init];
	iter_ = [array objectEnumerator];

	while (thread_ = [iter_ nextObject]) {
		NSString *target_;

		target_ = [CMRThreadAttributes pathFromDictionary : thread_];
		if (target_ == nil)
			continue;
		if([context isSameAsString : target_])
			[result_ addObject : thread_];
	}
	[pool_ release];
	return result_;
}
@end
