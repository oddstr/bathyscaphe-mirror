//:CMRThreadsUpdateListTask.m
/**
  *
  * @see CMRThreadAttributes.h
  * @see CMRThreadsList.h
  * @see CMRThreadLayout.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/19  2:59:02 AM)
  *
  */
#import "CMRThreadsUpdateListTask_p.h"
#import "CMRFavoritesManager.h"

//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
NSString *const CMRThreadsUpdateListTaskDidFinishNotification = @"CMRThreadsUpdateListTaskDidFinishNotification";



/**
  * [関数]setAttributesFromDictionary
  *
  * 辞書からスレッドの情報を収集して追加。
  * 
  * @param    dict     辞書
  * @param    thread   スレッドの情報を格納する辞書
  * @return            収集した情報
  */
static void setAttributesFromDictionary(
                    NSDictionary        *dict,
                    NSMutableDictionary    *thread)
{
	static NSString * keys[] = {
						nil,
						nil,
						nil,
						nil,
						nil,
						nil,
						nil };

	if (keys[0] == nil) {
		keys[0] = CMRThreadCreatedDateKey;
		keys[1] = CMRThreadModifiedDateKey;
		keys[2] = CMRThreadLastLoadedNumberKey;
		keys[3] = CMRThreadStatusKey;
		keys[4] = ThreadPlistBoardNameKey;
		keys[5] = ThreadPlistIdentifierKey;
		keys[6] = nil;
	}
    NSString **p;
    
    for (p = keys; *p != nil; p++) {
        [thread setNoneNil : [dict objectForKey : *p]
                    forKey : *p];
    }
}
/**
  * [関数]collectAttributesFromPath
  *
  * 辞書からスレッドの情報を収集して追加。
  * 
  * @param    path     ログファイルのパス
  * @param    thread   スレッドの情報を格納する辞書
  * @return            収集した情報
  */
static void collectAttributesFromPath(NSString *path, NSMutableDictionary *thread)
{
    NSDictionary *fileContents_;
    
    UTILDebugWrite(@"Collect Attributes From Log File");
    
    // ログファイルから各種情報を取得
    fileContents_ = 
        [CMRThreadsList attributesForThreadsListWithContentsOfFile : path];
    
    if (nil != fileContents_)
        setAttributesFromDictionary(fileContents_, thread);
    
    [thread setObject : path
               forKey : CMRThreadLogFilepathKey];
}

static void constructAttributesByAppendingCachedInfo(
                    NSMutableDictionary *thread,
                    NSMutableDictionary *cachedInfoTbl,
                    BOOL                 isUpdated)
{
    NSString *path_;
    id        cache;
    NSNumber *count_;
    NSNumber *status_;
    unsigned s;
    
    struct {
        unsigned char cacheIsNull  :1;
        unsigned char reserved     :7;
    } flags;
    
    
    path_ = [CMRThreadAttributes pathFromDictionary : thread];
    UTILCAssertNotNil(path_);
    
    cache = [cachedInfoTbl objectForKey : path_];
    flags.cacheIsNull = [cache isEqual : [NSNull null]];
    if (isUpdated && cache != nil && !flags.cacheIsNull) {
        // 更新したとき、更新前の情報が存在した。
        // 更新前の情報を引き継ぐ。
        setAttributesFromDictionary(cache, thread);
    }
    
    count_  = [thread objectForKey : CMRThreadLastLoadedNumberKey];
    status_ = [thread objectForKey : CMRThreadStatusKey];
    s = [status_ unsignedIntValue];
    if (nil == status_ || nil == count_) {
        if (status_ == nil || !(s & ThreadNoCacheStatus)) {
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath : path_]) {
                collectAttributesFromPath(path_, thread);
                count_ = [thread objectForKey : CMRThreadLastLoadedNumberKey];
                s = ThreadLogCachedStatus;
                goto RECACHE;
            }
        }
        [thread removeObjectForKey : CMRThreadLastLoadedNumberKey];
        count_ = nil;
        s = ThreadNoCacheStatus;
    }
RECACHE:
    
    // ステータスを再検討。
    // 差分を計算し、設定。
    if (count_ != nil) {
        NSNumber    *newcount_;
        newcount_ = [thread objectForKey : CMRThreadNumberOfMessagesKey];
        
        // サーバ上のレス数の方が多ければ、
        if (newcount_ != nil && 
           NSOrderedDescending == [newcount_ compare : count_]) {
            s = ThreadUpdatedStatus;
        }
    }
    // 新規スレッドかどうを判定する。
    // すでに一覧に含まれているスレッドには
    // ログが存在しなくてもNSNullが設定されている。
    if (isUpdated && nil == cache) s = ThreadNewCreatedStatus;
    
    if (nil == status_ || [status_ unsignedIntValue] != s) {
        // ステータスを設定
        [thread setObject : [NSNumber numberWithUnsignedInt : s]
                   forKey : CMRThreadStatusKey];
    }
    
    // スレッド情報を更新する。
    // ログの存在しないスレッドにはNSNullを設定
    if (s & ThreadNoCacheStatus) {
        if (cache == nil) {
            [cachedInfoTbl setObject:[NSNull null] forKey:path_];
        }
	} else if (isUpdated && (s == ThreadUpdatedStatus)) {
		// お気に入りに含まれていないか探す
		// 新着ありの既得スレのみについて調べれば良い。
		// さらに subject.txt を取ってきて更新した場合のみ調べれば良い。
		int	favidx_;
		favidx_ = [[[CMRFavoritesManager defaultManager] favoritesItemsIndex] indexOfObject : path_];
		if (favidx_ != NSNotFound) {
			// お気に入りのデータを更新
			[[[CMRFavoritesManager defaultManager] favoritesItemsArray]
								replaceObjectAtIndex : favidx_
										  withObject : thread];
		}

        [cachedInfoTbl setObject:thread forKey:path_];

    } else {
        [cachedInfoTbl setObject:thread forKey:path_];
    }
}


@implementation CMRThreadsUpdateListTask
+ (id) taskWithLoadedList : (NSMutableArray      *) loadedList
              pathMapping : (NSMutableDictionary *) table
                   update : (BOOL                 ) isUpdated
{
    return [[[self alloc] initWithLoadedList : loadedList
                      pathMapping : table
                           update : isUpdated] autorelease];
}
- (id) initWithLoadedList : (NSMutableArray      *) loadedList
              pathMapping : (NSMutableDictionary *) table
                   update : (BOOL                 ) isUpdated
{
    UTILAssertNotNilArgument(table, @"table");
    if (self = [super init]) {
        
        [self setIsUpdate : isUpdated];
        [self setPathMappingTbl : table];
        [self setProgress : 0];
        [self setThreadsArray : loadedList];
    }
    return self;
}
- (void) dealloc
{
    [_boardName release];
    [_threadsArray release];
    [_pathMappingTbl release];
    [super dealloc];
}


- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
    NSDictionary    *userInfo_;
    NSMutableArray  *threadsArray_;
    
    threadsArray_ = [self threadsArray];
    UTILAssertNotNil(threadsArray_);
    
    [self addParameterForThreadsList : threadsArray_
                            fromInfo : _pathMappingTbl
                              update : _isUpdate];
    userInfo_ = [NSDictionary dictionaryWithObjectsAndKeys :
                    threadsArray_,   kCMRUserInfoThreadsArrayKey, 
                    _pathMappingTbl, kCMRUserInfoThreadsDictKey,
                    [NSNumber numberWithBool : _isUpdate],
                    kCMRUserInfoIsUpdatedKey,
                    nil];
    
    [CMRMainMessenger postNotificationName : CMRThreadsUpdateListTaskDidFinishNotification
                                    object : self
                                  userInfo : userInfo_];
    
}



- (NSString *) boardName
{
    return _boardName;
}
- (void) setBoardName : (NSString *) aBoardName
{
    id        tmp;
    
    tmp = _boardName;
    _boardName = [aBoardName retain];
    [tmp release];
}


// CMRTask:
- (NSString *) title
{
    NSString        *format_;
    NSString        *name_;
    
    name_ = [self boardName];
    format_ = [self localizedString : @"Converting List Title"];
    
    return [NSString stringWithFormat : 
                        format_ ? format_ : @"%@",
                        name_ ? name_ : @""];
}
- (NSString *) messageInProgress
{
    NSString        *format_;
    NSString        *title_;
    
    title_ = [self title];
    format_ = [self localizedString : @"Converting List Message"];
    
    return [NSString stringWithFormat : 
                        format_ ? format_ : @"%@",
                        title_ ? title_ : @""];
}
- (double) amount
{
    if ([self progress] <= 0)
        return -1;
    
    return [self progress];
}
@end



@implementation CMRThreadsUpdateListTask(Private)
- (void) addParameterForThreadsList : (NSArray             *) loadedList
                           fromInfo : (NSMutableDictionary *) threadsInfo
                             update : (BOOL                 ) isUpdated
{
    NSEnumerator        *iter;
    NSMutableDictionary *thread_;
    
    unsigned nEnded_ = 0;
    unsigned nElem_  = [loadedList count];

    UTILAssertNotNilArgument(loadedList, @"Threads List Array");
    UTILAssertNotNilArgument(threadsInfo, @"Threads Info Dictionary");

    iter = [loadedList objectEnumerator];
    while (thread_ = [iter nextObject]) {
        UTILAssertKindOfClass(thread_, NSMutableDictionary);
        
        constructAttributesByAppendingCachedInfo(thread_, threadsInfo, isUpdated);

        nEnded_++;
        [self setProgress : (((double)nEnded_ / (double)nElem_) * 100)];
    }
}



- (NSMutableArray *) threadsArray
{
    return _threadsArray;
}
- (NSMutableDictionary *) pathMappingTbl
{
    return _pathMappingTbl;
}
- (BOOL) isUpdate
{
    return _isUpdate;
}
- (void) setThreadsArray : (NSMutableArray *) aThreadsArray
{
    id        tmp;
    
    tmp = _threadsArray;
    _threadsArray = [aThreadsArray retain];
    [tmp release];
}
- (void) setPathMappingTbl : (NSMutableDictionary *) aPathMappingTbl
{
    id        tmp;
    
    tmp = _pathMappingTbl;
    _pathMappingTbl = [aPathMappingTbl retain];
    [tmp release];
}
- (void) setIsUpdate : (BOOL) anIsUpdate
{
    _isUpdate = anIsUpdate;
}

- (unsigned) progress
{
    return _progress;
}
- (void) setProgress : (unsigned) newValue
{
    _progress = newValue;
}
@end
