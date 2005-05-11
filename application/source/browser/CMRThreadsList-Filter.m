/**
  * $Id: CMRThreadsList-Filter.m,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadsList-Filter.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
#import "CMRNoNameManager.h"
#import "CMRSearchOptions.h"
#import "JStringAdditions.h"



@implementation CMRThreadsList(Filter)
- (void) filterByStatus : (int       ) status
		displayWithPath : (NSString *) filepath
{
	NSDictionary		*matched_;
	unsigned int		index_;
	
	[self filterByStatus : status];
	
	matched_ = [self seachThreadByPath : filepath];
	if(nil == matched_) return;
	
	// �w�肳�ꂽ���O�t�@�C�������X���b�h���t�B���^�[���
	// �z��Ɋ܂܂�Ă��Ȃ���Βǉ��B
	index_ = [[self filteredThreads] indexOfObject : matched_];
	if(NSNotFound == index_){
		NSString *sortKey_;
		
		[[self filteredThreads] addObject : matched_];
		//�\�[�g������
		sortKey_ = [[CMRNoNameManager defaultManager] sortColumnForBoard : [self BBSSignature]];
		[self _sortArrayByKey:sortKey_ array:[self filteredThreads]];
	}
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
							   ThreadNewCreatedStatus};
	int					i, cnt;
	NSMutableArray		*sorted_;
	NSMutableArray		*filtered_ = [NSMutableArray array];
	NSString			*sortKey_  = [[CMRNoNameManager defaultManager] sortColumnForBoard : [self BBSSignature]];
	
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
//------- Filter(search) --------------------------------------------
//-------------------------------------------------------------------
- (id) temporaryArrayWithFindOperation : (CMRSearchOptions *) operation
							 fromArray : (NSArray       *) array
{
	NSMutableArray			*foundArray_;
	NSEnumerator			*iter_;
	id						thread_;
	NSString				*searchString_;
	unsigned int			options_;
	CMRSearchMask			searchOption_;
	BOOL					isZenHankakuInsensitive_;
	id						userInfo_;
	NSCharacterSet			*ignoreSet_ = nil;
	BOOL					ignoreSpecificCharacters_;
	
	foundArray_ = SGTemporaryArray();
	
	searchString_ = [operation findObject];
	UTILRequireCondition(array && operation, ErrSearch);
	UTILRequireCondition(
		searchString_ && 
		[searchString_ isKindOfClass : [NSString class]] &&
		NO == [searchString_ isEmpty],
		ErrSearch);
	
	iter_ = [array objectEnumerator];
	
	searchOption_ = 0;
	userInfo_ = [operation userInfo];
	if(userInfo_ && [userInfo_ respondsToSelector : @selector(unsignedIntValue)])
		searchOption_ = [userInfo_ unsignedIntValue];
	
	
	options_ = [operation findOption];
	if(searchOption_ & CMRSearchOptionCaseInsensitive){
		options_ = options_ | NSCaseInsensitiveSearch;
	}
	isZenHankakuInsensitive_ = 
		(searchOption_ & CMRSearchOptionZenHankakuInsensitive);
	ignoreSpecificCharacters_ = (searchOption_ & CMRSearchOptionIgnoreSpecified);
	
	
	if(ignoreSpecificCharacters_){
		if(nil == ignoreSet_){
			NSString		*igchars_;
			
			igchars_ = [CMRPref ignoreTitleCharacters];
			ignoreSet_ = [NSCharacterSet 
							characterSetWithCharactersInString : igchars_];
		}
		
		// ���������񂩂疳�����镶���͎�菜���B
		searchString_ = 
			[searchString_ stringByDeleteCharactersInSet : ignoreSet_];
		UTILRequireCondition(NO == [searchString_ isEmpty], ErrSearch);
	}
	
	while(thread_ = [iter_ nextObject]){
		NSString	*title_;
		NSRange		include_;
		NSRange		searchRng_;
		
		UTILAssertKindOfClass(thread_, NSDictionary);
		title_ = [thread_ objectForKey : CMRThreadTitleKey];
		UTILAssertNotNil(title_);
		
		
		if(ignoreSpecificCharacters_)
			title_ = [title_ stringByDeleteCharactersInSet : ignoreSet_];
		
		searchRng_ = NSMakeRange(0, [title_ length]);
		include_ = [title_ rangeOfString : searchString_ 
						   options : options_
							 range : searchRng_
			 HanZenKakuInsensitive : isZenHankakuInsensitive_];
		
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
- (BOOL) filterByFindOperation : (CMRSearchOptions *) operation
{
	id				result;
	NSMutableArray	*filtered_;
		
	[self setFilteredThreads : nil];
	/*
		2004-12-05 tsawada2 �`���V�̗�
		_filteredThreads��nil�ɂ��邱�ƂŁA-filteredThreads:�Łu�S�X���b�h���X�e�[�^�X�Ńt�B���^�������́v���Ԃ��Ă���B
		(see CMRThreadsList.m)
		����nil�ɂ��Ȃ��ƁA-filteredThreads:�Łu�S�X���b�h�𒼑O�̌������ʂŃt�B���^�������́v���Ԃ��Ă��Ă��܂����߁A
		�������ʂ�\��������Ԃŕʂ̌��Ō�������蒼���Ƃ��ɕs�s���ł���B
	*/
	result = [self temporaryArrayWithFindOperation:operation fromArray:[self filteredThreads]];
	//NSLog(@"%d",[result count]);
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


- (void) _filteredThreadsLock
{
	[_filteredThreadsLock lock];
}
- (void) _filteredThreadsUnlock
{
	[_filteredThreadsLock unlock];
}
@end
