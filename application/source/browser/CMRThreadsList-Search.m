//:CMRThreadsList-Search.m
/**
  *
  * スレッドの検索をサポート
  *
  * @version 1.0.0d2 (01/12/23  11:32:58 AM)
  *
  */

#import "CMRThreadsList_p.h"
/*
typedef enum _ThreadsListSearchMask{
	ThreadsListTitleSeach = 1,			//タイトルで検索
	ThreadsListPathSearch = 1 << 1,		//パス文字列で検索　
} ThreadsListSearchMask;
*/
/**
  * [関数]_seachByLogFilePath
  * 
  * スレッド探索でパスが完全に一致する場合はYESを返す。
  * contextにはパス文字列を渡すこと。
  * 
  * @param    thread    条件をテストするスレッド。
  * @param    context   パス文字列
  */
static BOOL _seachByLogFilePath(NSDictionary *thread, void *context)
{
	NSString *path_;		//条件となるパス文字列
	NSString *target_;		//テストするパス文字列
	
	path_ = (NSString *)context;
	NSCAssert(
		(path_ == nil || [path_ respondsToSelector : @selector(isSameAsString:)]),
		@"_seachByLogFilePath  context must be NSString!");
	
	target_ = [CMRThreadAttributes pathFromDictionary : thread];
	UTILCAssertNotNil(target_);
	
	if(target_ == nil && path_ == nil) return YES;
	if(target_ == nil || path_ == nil) return NO;
	
	return [path_ isSameAsString : target_];
}

/**
  * [関数 : _func4type]
  * ThreadsListSearchTypeに対応する検索用関数を返す。
  */
static TLSearchFunction _func4type(ThreadsListSearchType type){
	switch(type){
	case ThreadsListTitleSeach:
		return _seachByLogFilePath;
		break;
	case ThreadsListPathSearch:
		return _seachByLogFilePath;
		break;
	default:
		return _seachByLogFilePath;
		break;
	}
	return _seachByLogFilePath;
}


@implementation CMRThreadsList(SearchThreads)
/**
  * ログファイルの保存場所が指定されたパスの
  * スレッドへの参照を返す。
  * 見つからなければ、nilを返す。
  * 
  * @param    filepath  ログファイルの保存場所
  * @return             スレッド
  */
- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath
{
	id thread_;					//スレッド情報を検索
	
	// 既にログを取得していれば、辞書に格納している。
	// ログが存在しない場合はNSNullを格納している。
	thread_ = [[self threadsInfo] objectForKey : filepath];
	if(thread_ != nil && (NO == [thread_ isEqual : [NSNull null]]))
		return thread_;
	
	// ログがなければ、一覧から検索。
	thread_ = [self seachThreadByPath : filepath inArray : [self threads]];
	
	return thread_;
}

/**
  * ログファイルの保存場所が指定されたパスの
  * スレッドへの参照を返す。
  * 見つからなければ、nilを返す。
  * 
  * @param    filepath  ログファイルの保存場所
  * @return             スレッド
  */
- (NSMutableDictionary *) seachThreadByPath : (NSString *) filepath
									inArray : (NSArray  *) array
{
	NSArray *matched_;		//見つかったスレッド
	
	matched_ = [self _seachThreads : ThreadsListPathSearch
						   inArray : array
						   context : filepath];
	//見つからなければ、nilを返す。
	if([matched_ count] == 0) return nil;
	
	//パス文字列の一致するスレッドはひとつしかない。
	NSAssert(
		([matched_ count] == 1),
		@"duplicated threadsList.");
	
	return [matched_ objectAtIndex : 0];
}

/**
  * 保持しているスレッド一覧を探索し、条件にマッチしたスレッドを
  * 格納する一時的な配列オブジェクトを新たに作って返す。
  * 条件のテストには、checkerで指定された関数を使う。この関数は
  * 引数を２つとり、結果としてBOOL値を返す関数でなくてはならない。
  * 第1引数にスレッドの辞書が渡され、第2引数にはcontextが渡される。
  * 
  * （関数例）BOOL mtCheck(NSDictionary *thread, void *context);
  * 
  * また、条件にマッチするスレッドがひとつもない場合は空の配列を返す。
  * 
  * @param    checker  条件をテストする関数
  * @param    context  関数に渡す情報
  * @return            条件にマッチしたスレッド
  */
- (NSArray *) seachThreadsUsingFunction : (TLSearchFunction)checker 
                                context : (void  *) context
{
	//保持しているスレッド一覧から探索する。
	
	return [self _seachThreadsUsingFunction : checker
							        inArray : [self threads]
							        context : context];
}

//-------------------------------------------------------------------
//-------------------------------------------------------------------
//-------------------------------------------------------------------
/**
  * 指定したスレッド一覧から探索。
  * 
  * @see seachThreadsUsingFunction:context:
  *
  * @param    type     検索条件の種類
  * @param    array    探索対象となる配列オブジェクト
  * @param    context  関数に渡す情報
  * @return            条件にマッチしたスレッド
  */

- (NSArray *) _seachThreads : (ThreadsListSearchType) type
			        inArray : (NSArray *) array
			        context : (void    *) context
{
	return [self _seachThreadsUsingFunction : _func4type(type)
							        inArray : array
							        context : context];
}

/**
  * 指定したスレッド一覧から探索。
  * 
  * @see seachThreadsUsingFunction:context:
  *
  * @param    checker  条件をテストする関数
  * @param    array    探索対象となる配列オブジェクト
  * @param    context  関数に渡す情報
  * @return            条件にマッチしたスレッド
  */

- (NSArray *) _seachThreadsUsingFunction : (TLSearchFunction)checker 
							     inArray : (NSArray *) array
							     context : (void *) context
{
	NSMutableArray *result_;		//条件にマッチしたスレッド
	NSEnumerator   *iter_;			//スレッドを順次探索
	NSDictionary   *thread_;		//テスト中のスレッド
	
	result_ = [NSMutableArray array];
	if(nil == array || NULL == checker) return result_;

	iter_ = [array objectEnumerator];
	
	// 各スレッドを順次探索し、checker関数がYESを返した
	// スレッドについては可変配列に追加していく。
	while(thread_ = [iter_ nextObject]){
		if(checker(thread_, context)){
			[result_ addObject : thread_];
		}
	}
	
	return result_;
}
@end
