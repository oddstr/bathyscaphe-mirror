//:CMRThreadsListReadFileTask.m
/**
  *
  * @see CMRThreadLayout.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/19  10:53:12 AM)
  *
  */
#import "CMRThreadsListReadFileTask_p.h"
#import "CMRDocumentFileManager.h"
#import "CMRThreadsList.h"
#import "CMRFavoritesManager.h"
#import "AppDefaults.h"

@implementation CMRThreadsListReadFileTask(Private)
- (NSString *) threadsListPath
{
	return _threadsListPath;
}
- (void) setThreadsListPath : (NSString *) aThreadsListPath
{
	id		tmp;
	
	tmp = _threadsListPath;
	_threadsListPath = [aThreadsListPath retain];
	[tmp release];
}
- (unsigned) readingProgress
{
	return _readingProgress;
}
- (void) setReadingProgress : (unsigned) aReadingProgress
{
	_readingProgress = aReadingProgress;
}


- (NSMutableArray *) convertThreadsList : (NSArray  *) loadedList
{
	NSMutableArray		*newList_;
	NSEnumerator		*iter_;
	id					item_;
	
	unsigned			subjectIndex_;
	unsigned			nElements_;
	
	if(nil == loadedList) return nil;
		
	subjectIndex_ = 0;
	nElements_ = [loadedList count];
	
	newList_ = [NSMutableArray arrayWithCapacity : nElements_];
	iter_ = [loadedList objectEnumerator];
	
	while(item_ = [iter_ nextObject]){
		NSMutableDictionary	*thread_;
		unsigned			amount_;
		
		UTILAssertKindOfClass(item_, NSDictionary);
		thread_ = [self mutableDictionaryConvertFrom : item_
										subjectIndex : subjectIndex_ +1];
		
		[newList_ addObject : thread_];
		[thread_ release];
		
		subjectIndex_++;
		amount_ = ((double)subjectIndex_ / (double)nElements_) * 100;
		[self setReadingProgress : amount_];
	}
	return newList_;
}
- (NSMutableDictionary *) mutableDictionaryConvertFrom : (NSDictionary *) dict
										  subjectIndex : (unsigned int  ) index
{
	NSMutableDictionary	*thread_;
	NSNumber			*count_;
	
	thread_ = [dict mutableCopyWithZone : [dict zone]];
	count_ = [thread_ objectForKey : CMRThreadLastLoadedNumberKey];
	
	//サーバー上のレス数
	if(nil == [thread_ objectForKey : CMRThreadNumberOfMessagesKey]){
		[thread_ setNoneNil : count_
					 forKey : CMRThreadNumberOfMessagesKey];
	}
	
	// スレッド番号がなければ、
	// 指定されたインデックスをエントリ
	if(nil == [thread_ objectForKey : CMRThreadSubjectIndexKey]){
		[thread_ setObject : [NSNumber numberWithUnsignedInt : index]
					forKey : CMRThreadSubjectIndexKey];
	}
	// 板名
	if(nil == [thread_ objectForKey : ThreadPlistBoardNameKey]){
		[thread_ setNoneNil : [self boardName]
					 forKey : ThreadPlistBoardNameKey];
	}
	return thread_;
}
@end



@implementation CMRThreadsListReadFileTask
+ (id) taskWithThreadsListPath : (NSString            *) path
			       pathMapping : (NSMutableDictionary *) table
{
	return [[[self alloc] initWithThreadsListPath : path
									  pathMapping : table] autorelease];

}
- (id) initWithThreadsListPath : (NSString            *) path
			       pathMapping : (NSMutableDictionary *) table
{
	self = [super initWithLoadedList : nil
						 pathMapping : table
							  update : NO];
	if(nil == self) return nil;
	
	[self setThreadsListPath : path];
	
	return self;
}

- (void) dealloc
{
	[_threadsListPath release];
	[super dealloc];
}


- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	NSArray				*list_;
	NSMutableArray		*converted_;
	NSString			*bName_;
	
	bName_ = [self boardName];

	if ([bName_ isEqualToString : CMXFavoritesDirectoryName]) {
		list_ = [[CMRFavoritesManager defaultManager] favoritesItemsArray];
	} else {
		list_ = [NSArray arrayWithContentsOfFile : [self threadsListPath]];
	}
	
	if(nil == list_) {
		SGFileRef			*folder;
		folder = [[CMRDocumentFileManager defaultManager] ensureDirectoryExistsWithBoardName : bName_];
		UTILAssertNotNil(folder);

		list_ = [CMRThreadsList threadsListTemplateWithPath : [folder filepath]];
	}
	
	converted_ = [self convertThreadsList : list_];
	if(nil == list_ || nil == converted_){
		NSLog(
			@"*** WARNING ***\n"
			@"  Can't %@ ThreadsList.plist At %@", 
			(nil == list_) ? @"load/create" : @"convert",
			[self threadsListPath]);
		return;
	}
	// --------- Start Update ---------
	[super setThreadsArray : converted_];
	[super doExecuteWithLayout : layout];
}

- (double) amount
{
	double amount_;
	
	amount_ = [super amount];
	if(amount_ <= 0)
		amount_ = 0;

	amount_ = ([self readingProgress] + amount_) / 2;
	
	if(amount_ <= 0)
		return -1;
	
	return amount_;
}
@end
