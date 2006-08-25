/**
  * $Id: CMRThreadsList-Filter.m,v 1.7.4.2 2006/08/25 17:48:01 masakih Exp $
  * 
  * CMRThreadsList-Filter.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
#import "BoardManager.h"
#import "CMRSearchOptions.h"

@implementation CMRThreadsList(Filter)
- (void) filterByStatus : (int       ) status
		displayWithPath : (NSString *) filepath
{
	NSDictionary		*matched_;
	unsigned int		index_;
	
	[self filterByStatus : status];
	
	matched_ = [self seachThreadByPath : filepath];
	if(nil == matched_) return;
	
	[self _filteredThreadsLock];
	
	// �w�肳�ꂽ���O�t�@�C�������X���b�h���t�B���^�[���
	// �z��Ɋ܂܂�Ă��Ȃ���Βǉ��B
	index_ = [[self filteredThreads] indexOfObject : matched_];
	if(NSNotFound == index_){
		NSString *sortKey_;
		
		[[self filteredThreads] addObject : matched_];
		//�\�[�g������
		sortKey_ = [[BoardManager defaultManager] sortColumnForBoard : [self boardName]];
		[self _sortArrayByKey:sortKey_ array:[self filteredThreads]];
	}
	
	[self _filteredThreadsUnlock];
}
- (void) filterByDisplayingThreadAtPath : (NSString *) filepath
{
	[self filterByStatus:[self filteringMask] displayWithPath:filepath];
}

/**
  * �X���b�h�ꗗ���i���ׂāE�����E���擾�j�Ȃǂŕ���
  * ���Ȃ����Bstatus�ɂ�ThreadStatus���r�b�gOR�����l��
  * �n���B
  * 
  * @param    status  ���ނ���X�e�[�^�X
  */
- (void) filterByStatus : (int) status
{
	ThreadStatus filters[]  = {ThreadNoCacheStatus,
							   ThreadLogCachedStatus,
							   ThreadUpdatedStatus,
							   ThreadNewCreatedStatus,
							   ThreadHeadModifiedStatus};
	int					i, cnt;
	NSMutableArray		*sorted_;
	NSMutableArray		*filtered_ = [NSMutableArray array];
	NSString			*sortKey_  = [[BoardManager defaultManager] sortColumnForBoard : [self boardName]];
	
	if(ThreadStandardStatus == status){
		[filtered_ addObjectsFromArray : [self threads]];
		[self _sortArrayByKey:sortKey_ array:filtered_];
		[self setFilteredThreads : filtered_];
		return;
	}
	
	sorted_ = [NSMutableArray arrayWithArray : [self threads]];
	[self _sortArrayByKey:CMRThreadStatusKey array:sorted_];
	
	i = 0;
	cnt = (sizeof(filters) / sizeof(ThreadStatus));
	for(i = 0; i < cnt; i++){
		if(status & filters[i]){
			NSArray *subarray_;
			NSRange  found_;
			subarray_ = [self _arrayWithStatus : filters[i]
					           fromSortedArray : sorted_
							     subarrayRange : &found_];
			if(subarray_ != nil){
				[filtered_ addObjectsFromArray : subarray_];
				[sorted_ removeObjectsInRange : found_];
			}
		}
	}
	
	[self _sortArrayByKey:sortKey_ array:filtered_];
	[self setFilteredThreads : filtered_];
	return;
}

/**
  * �X�e�[�^�X�Ń\�[�g�ς݂̔z��I�u�W�F�N�g����
  * �w�肳�ꂽ�X�e�[�^�X�̔z���Ԃ��B
  * 
  * @param    status  �X�e�[�^�X
  * @param    array   �X�e�[�^�X�Ń\�[�g�ς݂̔z��
  * @param    aRange  ���������͈�
  *                   (������Ȃ����location == NSNotFound)
  * @return           �w�肳�ꂽ�X�e�[�^�X�̔z��
  */
- (NSArray *) _arrayWithStatus : (ThreadStatus    ) status
               fromSortedArray : (NSMutableArray *) array
			     subarrayRange : (NSRangePointer  ) aRange
{
	int firstIndex_, lastIndex_;
	int i, cnt;
	NSRange rng_;		//�w�肳�ꂽ�X�e�[�^�X���G���g���Ɏ��͈�
	
	//�z��͊��Ƀ\�[�g����Ă���̂ŁA
	//�O�ォ��w�肳�ꂽ�X�e�[�^�X���G���g���Ɏ���
	//�����̃C���f�b�N�X�����߁A����Ő؂�o���B
	rng_ = NSMakeRange(NSNotFound, 0);
	
	firstIndex_ = NSNotFound;  //�v�f��0�������肷��ꍇ������B
	lastIndex_ = 0;
	i = 0;
	cnt = [array count];
	
	for(i = 0; i < cnt; i++){
		NSDictionary *thread_;
		NSNumber     *thStatus_;
		thread_ = [array objectAtIndex : i];
		thStatus_ = [thread_ objectForKey : CMRThreadStatusKey];
		
		if(thStatus_ != nil){
			ThreadStatus st_;
			st_ = [thStatus_ unsignedIntValue];
			if(st_ == status){
				//�ŏ��̃C���f�b�N�X���L�^
				firstIndex_ = i;
				break;
			}
		}
		//������Ȃ�����
		if(i == (cnt -1)){
			firstIndex_ = NSNotFound;
			break;
		}
	}
	
	if(firstIndex_ == NSNotFound){
		if(aRange != NULL) *aRange = rng_;
		return nil;
	}
	
	
	for(i = cnt -1; i >= firstIndex_; i--){
		NSDictionary *thread_;
		NSNumber     *thStatus_;
		thread_ = [array objectAtIndex : i];
		thStatus_ = [thread_ objectForKey : CMRThreadStatusKey];
		
		if(thStatus_ != nil){
			ThreadStatus st_;
			st_ = [thStatus_ unsignedIntValue];
			if(st_ == status){
				break;
			}
		}
	}
	lastIndex_ = i;
	//���������͈͂�����
	rng_.location = firstIndex_;
	rng_.length = (lastIndex_ - firstIndex_) + 1;
	if(aRange != NULL) *aRange = rng_;
	//rng_ = NSMakeRange(firstIndex_, (lastIndex_ - firstIndex_) + 1);
	return [array subarrayWithRange : rng_];
}

//-------------------------------------------------------------------
#pragma mark Filter(search)
//-------------------------------------------------------------------
- (id) temporaryArrayWithSearchString: (NSString *) searchStr fromArray: (NSArray *) targetArray
{
	NSMutableArray	*foundArray_;
	NSEnumerator	*iter_;
	NSString		*precomposedSearchStr;
	id				thread_;
	
	if(!targetArray || [targetArray count] == 0) return nil;
	
	if(!searchStr || [searchStr isEqualToString: @""]) {
		//NSLog(@"searchStr is Empty");
		return targetArray;
	}
	precomposedSearchStr = [searchStr precomposedStringWithCompatibilityMapping];
	if(!precomposedSearchStr || [precomposedSearchStr isEqualToString: @""]) return targetArray;
	
	foundArray_ = [NSMutableArray array];
	iter_ = [targetArray objectEnumerator];
	
	while(thread_ = [iter_ nextObject]) {
		NSString	*title_;
		NSRange		foundRange;
		NSRange		searchRange;
		
		UTILAssertKindOfClass(thread_, NSDictionary);
		title_ = [thread_ objectForKey : CMRThreadTitleKey];
		UTILAssertNotNil(title_);

		title_ = [title_ precomposedStringWithCompatibilityMapping]; // Unicode KC
		
		searchRange = NSMakeRange(0, [title_ length]);
		foundRange = [title_ rangeOfString: precomposedSearchStr 
								   options: NSCaseInsensitiveSearch
									 range: searchRange];
		
		if(0 == foundRange.length) continue;
		
		[foundArray_ addObject: thread_];
	}
	if ([foundArray_ count] == 0) [foundArray_ addObject : @"SearchNotFound"];

	return foundArray_;
}
/*
- (id) temporaryArrayWithFindOperation : (CMRSearchOptions *) operation
							 fromArray : (NSArray       *) array
{
	NSMutableArray			*foundArray_;
	NSEnumerator			*iter_;
	id						thread_;
	NSString				*searchString_;
	
	//foundArray_ = SGTemporaryArray();
	foundArray_ = [NSMutableArray array];

	searchString_ = [operation findObject];
	UTILRequireCondition(array && operation, ErrSearch);
	UTILRequireCondition(
		searchString_ && 
		[searchString_ isKindOfClass : [NSString class]] &&
		NO == [searchString_ isEmpty],
		ErrSearch);
	
	iter_ = [array objectEnumerator];

	searchString_ = [searchString_ precomposedStringWithCompatibilityMapping];
	UTILRequireCondition(NO == [searchString_ isEmpty], ErrSearch);
	
	while(thread_ = [iter_ nextObject]){
		NSString	*title_;
		NSRange		include_;
		NSRange		searchRng_;
		
		UTILAssertKindOfClass(thread_, NSDictionary);
		title_ = [thread_ objectForKey : CMRThreadTitleKey];
		UTILAssertNotNil(title_);

		title_ = [title_ precomposedStringWithCompatibilityMapping]; // Unicode KC
		
		searchRng_ = NSMakeRange(0, [title_ length]);
		include_ = [title_ rangeOfString : searchString_ 
								 options : NSCaseInsensitiveSearch
								   range : searchRng_];
		
		if(0 == include_.length || NSNotFound == include_.location)
			continue;
		
		[foundArray_ addObject : thread_];
	}
	//�z�񂪋�A�܂茟�����ʂ��u������܂���v�������Ƃ��͓��ʂȔz�������ĕԂ��B
	//�ڍׂ� CMRThreadsList.m �� filteredThreads ���\�b�h�ӂ�̃R�����g���Q�ƁB
	if ([foundArray_ count] == 0)
		[foundArray_ addObject : @"SearchNotFound"];
	ErrSearch:
		return foundArray_;
}
*/
- (BOOL) filterByString : (NSString *) searchString
{
	id				result;
	NSMutableArray	*filtered_;
		
	/*
		2004-12-05 tsawada2 �`���V�̗�
		_filteredThreads��nil�ɂ��邱�ƂŁA-filteredThreads:�Łu�S�X���b�h���X�e�[�^�X�Ńt�B���^�������́v���Ԃ��Ă���B
		(see CMRThreadsList.m)
		����nil�ɂ��Ȃ��ƁA-filteredThreads:�Łu�S�X���b�h�𒼑O�̌������ʂŃt�B���^�������́v���Ԃ��Ă��Ă��܂����߁A
		�������ʂ�\��������Ԃŕʂ̌��Ō�������蒼���Ƃ��ɕs�s���ł���B
	*/
	[self setFilteredThreads : nil];

	result = [self temporaryArrayWithSearchString: searchString fromArray: [self filteredThreads]];

	UTILRequireCondition(result && [result count], ErrFilterByFindOperation);

	filtered_ = [result mutableCopyWithZone : [self zone]];
	[self setFilteredThreads : filtered_];
	[filtered_ release];

	if ([result containsObject : @"SearchNotFound"]) {
		// �������ʂ��󂾂����ꍇ�ł��Aresult ���L���C�ɂ��Ă����K�v������B
		[result removeAllObjects];
		return NO;
	} else {
		[result removeAllObjects];	
		return YES;
	}
	
ErrFilterByFindOperation:
	return NO;
}

/*
- (BOOL) filterByFindOperation : (CMRSearchOptions *) operation
{
	id				result;
	NSMutableArray	*filtered_;
		
	[self setFilteredThreads : nil];
	//result = [self temporaryArrayWithFindOperation:operation fromArray:[self filteredThreads]];
	result = [self temporaryArrayWithSearchString: [operation findObject] fromArray: [self filteredThreads]];

	UTILRequireCondition(result && [result count], ErrFilterByFindOperation);
	if ([result isKindOfClass: [NSMutableArray class]]) {
		NSMutableArray *mutableResult;
		NSLog(@"tempAryWithSearchStr: fromAry: returns immutable array, so we must mutableCopy it");
		mutableResult = [result mutableCopyWithZone : [self zone]];
		[self setFilteredThreads: mutableResult];
		[mutableResult release];
	} else {
		[self setFilteredThreads: result];
	}

	if ([result containsObject : @"SearchNotFound"]) {
		// �������ʂ��󂾂����ꍇ�ł��Aresult ���L���C�ɂ��Ă����K�v������B
		[result removeAllObjects];
		return NO;
	} else {
		[result removeAllObjects];	
		return YES;
	}
	
ErrFilterByFindOperation:
	NSLog(@"Hoge");
	return NO;
}
*/

- (void) _filteredThreadsLock
{
	[_filteredThreadsLock lock];
}
- (void) _filteredThreadsUnlock
{
	[_filteredThreadsLock unlock];
}
@end

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
