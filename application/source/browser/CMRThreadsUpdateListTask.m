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
////////////////////// [ �萔��}�N���u�� ] //////////////////////////
//////////////////////////////////////////////////////////////////////
NSString *const CMRThreadsUpdateListTaskDidFinishNotification = @"CMRThreadsUpdateListTaskDidFinishNotification";



/**
  * [�֐�]setAttributesFromDictionary
  *
  * ��������X���b�h�̏������W���Ēǉ��B
  * 
  * @param    dict     ����
  * @param    thread   �X���b�h�̏����i�[���鎫��
  * @return            ���W�������
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
  * [�֐�]collectAttributesFromPath
  *
  * ��������X���b�h�̏������W���Ēǉ��B
  * 
  * @param    path     ���O�t�@�C���̃p�X
  * @param    thread   �X���b�h�̏����i�[���鎫��
  * @return            ���W�������
  */
static void collectAttributesFromPath(NSString *path, NSMutableDictionary *thread)
{
    NSDictionary *fileContents_;
    
    UTILDebugWrite(@"Collect Attributes From Log File");
    
    // ���O�t�@�C������e������擾
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
        // �X�V�����Ƃ��A�X�V�O�̏�񂪑��݂����B
        // �X�V�O�̏��������p���B
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
    
    // �X�e�[�^�X���Č����B
    // �������v�Z���A�ݒ�B
    if (count_ != nil) {
        NSNumber    *newcount_;
        newcount_ = [thread objectForKey : CMRThreadNumberOfMessagesKey];
        
        // �T�[�o��̃��X���̕���������΁A
        if (newcount_ != nil && 
           NSOrderedDescending == [newcount_ compare : count_]) {
            s = ThreadUpdatedStatus;
        }
    }
    // �V�K�X���b�h���ǂ��𔻒肷��B
    // ���łɈꗗ�Ɋ܂܂�Ă���X���b�h�ɂ�
    // ���O�����݂��Ȃ��Ă�NSNull���ݒ肳��Ă���B
    if (isUpdated && nil == cache) s = ThreadNewCreatedStatus;
    
    if (nil == status_ || [status_ unsignedIntValue] != s) {
        // �X�e�[�^�X��ݒ�
        [thread setObject : [NSNumber numberWithUnsignedInt : s]
                   forKey : CMRThreadStatusKey];
    }
    
    // �X���b�h�����X�V����B
    // ���O�̑��݂��Ȃ��X���b�h�ɂ�NSNull��ݒ�
    if (s & ThreadNoCacheStatus) {
        if (cache == nil) {
            [cachedInfoTbl setObject:[NSNull null] forKey:path_];
        }
	} else if (isUpdated && (s == ThreadUpdatedStatus)) {
		// ���C�ɓ���Ɋ܂܂�Ă��Ȃ����T��
		// �V������̊����X���݂̂ɂ��Ē��ׂ�Ηǂ��B
		// ����� subject.txt ������Ă��čX�V�����ꍇ�̂ݒ��ׂ�Ηǂ��B
		int	favidx_;
		favidx_ = [[[CMRFavoritesManager defaultManager] favoritesItemsIndex] indexOfObject : path_];
		if (favidx_ != NSNotFound) {
			// ���C�ɓ���̃f�[�^���X�V
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
