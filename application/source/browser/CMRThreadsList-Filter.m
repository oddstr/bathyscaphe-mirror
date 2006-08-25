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
	
	// 指定されたログファイルを持つスレッドがフィルター後の
	// 配列に含まれていなければ追加。
	index_ = [[self filteredThreads] indexOfObject : matched_];
	if(NSNotFound == index_){
		NSString *sortKey_;
		
		[[self filteredThreads] addObject : matched_];
		//ソートし直す
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
  * スレッド一覧を（すべて・既得・未取得）などで分類
  * しなおす。statusにはThreadStatusをビットORした値を
  * 渡す。
  * 
  * @param    status  分類するステータス
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
  * ステータスでソート済みの配列オブジェクトから
  * 指定されたステータスの配列を返す。
  * 
  * @param    status  ステータス
  * @param    array   ステータスでソート済みの配列
  * @param    aRange  見つかった範囲
  *                   (見つからなければlocation == NSNotFound)
  * @return           指定されたステータスの配列
  */
- (NSArray *) _arrayWithStatus : (ThreadStatus    ) status
               fromSortedArray : (NSMutableArray *) array
			     subarrayRange : (NSRangePointer  ) aRange
{
	int firstIndex_, lastIndex_;
	int i, cnt;
	NSRange rng_;		//指定されたステータスをエントリに持つ範囲
	
	//配列は既にソートされているので、
	//前後から指定されたステータスをエントリに持つ
	//辞書のインデックスを求め、それで切り出す。
	rng_ = NSMakeRange(NSNotFound, 0);
	
	firstIndex_ = NSNotFound;  //要素が0だったりする場合もある。
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
				//最初のインデックスを記録
				firstIndex_ = i;
				break;
			}
		}
		//見つからなかった
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
	//見つかった範囲を決定
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
	//配列が空、つまり検索結果が「見つかりません」だったときは特別な配列を作って返す。
	//詳細は CMRThreadsList.m の filteredThreads メソッド辺りのコメントを参照。
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
		2004-12-05 tsawada2 チラシの裏
		_filteredThreadsをnilにすることで、-filteredThreads:で「全スレッドをステータスでフィルタしたもの」が返ってくる。
		(see CMRThreadsList.m)
		もしnilにしないと、-filteredThreads:で「全スレッドを直前の検索結果でフィルタしたもの」が返ってきてしまうため、
		検索結果を表示した状態で別の語句で検索をやり直すときに不都合である。
	*/
	[self setFilteredThreads : nil];

	result = [self temporaryArrayWithSearchString: searchString fromArray: [self filteredThreads]];

	UTILRequireCondition(result && [result count], ErrFilterByFindOperation);

	filtered_ = [result mutableCopyWithZone : [self zone]];
	[self setFilteredThreads : filtered_];
	[filtered_ release];

	if ([result containsObject : @"SearchNotFound"]) {
		// 検索結果が空だった場合でも、result をキレイにしておく必要がある。
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
		// 検索結果が空だった場合でも、result をキレイにしておく必要がある。
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
	
	// 既にログを取得していれば、辞書に格納している。
	// ログが存在しない場合はNSNullを格納している。
	thread_ = [[self threadsInfo] objectForKey : filepath];
	if(thread_ != nil && (NO == [thread_ isEqual : [NSNull null]]))
		return thread_;

	// ログがなければ、一覧から検索。
	thread_ = [self seachThreadByPath : filepath inArray : [self threads]];
	return thread_;
}

- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath
									inArray : (NSArray  *) array
{
	NSArray *matched_;
	
	matched_ = [self _searchThreadsInArray : array context : filepath];
	if([matched_ count] == 0) return nil;
	
	//パス文字列の一致するスレッドはひとつしかない。
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
