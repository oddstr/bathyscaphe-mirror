//: CMRHistoryManager.m
/**
  * $Id: CMRHistoryManager.m,v 1.2 2005/05/12 15:20:25 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRHistoryManager.h"
#import "CocoMonar_Prefix.h"
#import "CMXTemplateResources.h"



// Property List
#define kHistoryBoardLimitKey         @"History - Limit(Board)"
#define kHistoryThreadLimitKey        @"History - Limit(Thread)"
#define kHistorySearchListLimitKey    @"History - Limit(SearchList)"

// see historyItemLimitForType:
#define DEFAULT_LIMIT_ITEMS 10

// assume item is precious if visitedCount >= PreciousItemThreshold
#define PreciousItemThreshold 5

enum {
    CMRHistoryManagerClientPerformAdd,
    CMRHistoryManagerClientPerformRemove,
    CMRHistoryManagerClientPerformChange
};
struct CMRHistoryClientEntry{
    id<CMRHistoryClient>  client;
    CMRHistoryClientEntry *next;  /* list */
};

static const unsigned kHistoryItemsBacketCount = CMRHistoryNumberOfEntryType;

#pragma mark -

@implementation CMRHistoryManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

+ (NSString *) defaultFilepath
{
    return [[CMRFileManager defaultManager]
                 supportFilepathWithName : CMRHistoryFile
                        resolvingFileRef : NULL];
}
- (id) init
{
    if (self = [super init]) {
        NSString        *filepath_;
        
        filepath_ = [[self class] defaultFilepath];
        UTILAssertNotNil(filepath_);
        [self loadDictionaryRepresentation : 
            [NSDictionary dictionaryWithContentsOfFile : filepath_]];

        [[NSNotificationCenter defaultCenter]
                 addObserver : self
                    selector : @selector(applicationWillTerminate:)
                        name : NSApplicationWillTerminateNotification
                      object : NSApp];
    }
    return self;
}

- (void) clearHistoryItemsBacket
{
    if (_backets != NULL) {
        unsigned    i, cnt;
        
        cnt = kHistoryItemsBacketCount;
        for (i = 0; i < cnt; i++) {
            [_backets[i] release];
        }
        free(_backets);
    }
    _backets = NULL;
}

- (id *) historyItemsBacket
{
    if (NULL == _backets) {
        size_t    size = (kHistoryItemsBacketCount * sizeof(id));
        
        _backets = malloc(size);
        if (NULL == _backets) {
            [NSException raise:NSGenericException
                        format:@"%@ malloc()",
                                UTIL_HANDLE_FAILURE_IN_METHOD];
        }
        nsr_bzero(_backets, size);
    }
    return _backets;
}

- (void) dealloc
{
    CMRHistoryClientEntry    *next;
    
    [[NSNotificationCenter defaultCenter] removeObserver : self];
    
    for (; _clients != NULL; _clients = next) {
        next = _clients->next;
        free(_clients);
    }
    next = NULL;
    
    [self clearHistoryItemsBacket];
	[super dealloc];
}

#pragma mark -

static CMRHistoryClientEntry *lookupHistoryEntry(CMRHistoryClientEntry *inList, id<CMRHistoryClient> aClient)
{
    CMRHistoryClientEntry    *p;
    
    for (p = inList; p != NULL; p = p->next)
        if ([p->client isEqual : aClient])
            return p;
    
    return NULL;
}

- (void) addClient : (id<CMRHistoryClient>) aClient
{
    CMRHistoryClientEntry    *newp;
    
    if (nil == aClient)
        return;
    if (lookupHistoryEntry(_clients, aClient) != NULL)
        return;
    
    newp = malloc(sizeof(CMRHistoryClientEntry));
    if (NULL == newp) {
        [NSException raise:NSGenericException
                    format:@"malloc()"];
    }
    
    newp->client = aClient;
    newp->next = _clients;
    _clients = newp;
}

- (void) removeClient : (id<CMRHistoryClient>) aClient
{
    CMRHistoryClientEntry    *p, *prev = NULL;
    
    for (p = _clients; p != NULL; p = p->next) {
        if ([p->client isEqual : aClient]) {
            if (NULL == prev)
                _clients = p->next;
            else
                prev->next = p->next;
            
            free(p);
            return;
        }
        prev = p;
    }
}

- (void) makeClientsPerform : (int             ) performType
                historyItem : (CMRHistoryItem *) anItem
                    atIndex : (unsigned        ) anIndex
{
    CMRHistoryClientEntry    *p;
    
    for (p = _clients; p != NULL; p = p->next) {
        id<CMRHistoryClient> object_;
        
        object_ = p->client;
        UTILAssertConformsTo(object_, @protocol(CMRHistoryClient));
        
        switch(performType) {
        case CMRHistoryManagerClientPerformAdd:
            [object_ historyManager:self insertHistoryItem:anItem atIndex:anIndex];
            break;
        case CMRHistoryManagerClientPerformRemove:
            [object_ historyManager:self removeHistoryItem:anItem atIndex:anIndex];
            break;
        case CMRHistoryManagerClientPerformChange:
            [object_ historyManager:self changeHistoryItem:anItem atIndex:anIndex];
            break;
        default:
            UTILUnknownSwitchCase(performType);
            break;
        }
    }
}

- (unsigned) historyItemLimitForType : (int) aType
{
    NSString    *key_ = nil;
    id            n;
    
    switch(aType) {
    case CMRHistoryBoardEntryType:
        key_ = kHistoryBoardLimitKey;
        break;
    case CMRHistoryThreadEntryType:
        key_ = kHistoryThreadLimitKey;
        break;
    case CMRHistorySearchListOptionEntryType:
        key_ = kHistorySearchListLimitKey;
        break;
    default:
        UTILUnknownSwitchCase(aType);
        break;
    }
    
    n = SGTemplateResource(key_);
    if (nil == n) {
        return DEFAULT_LIMIT_ITEMS;
    }
    
    return [n unsignedIntValue];
}

- (NSMutableArray *) mutableHistoryItemArrayForType : (int) aType
{
    id        *backets_;
    
    if (aType >= CMRHistoryNumberOfEntryType || aType < 0) {
        [NSException raise:NSRangeException 
                    format:@"%@ Attempt to index(%d) bounds(%u)",
                            UTIL_HANDLE_FAILURE_IN_METHOD,
                            aType,
                            CMRHistoryNumberOfEntryType];
    }
    backets_ = [self historyItemsBacket];
    if (NULL == backets_[aType]) {
        backets_[aType] = [[NSMutableArray alloc] init];
    }
    
    return backets_[aType];
}

- (NSArray *) historyItemArrayForType : (int) aType
{
    return [self mutableHistoryItemArrayForType : aType];
}

- (void) removeItemForType : (int     ) aType
                   atIndex : (unsigned) anIndex
{
    NSMutableArray    *itemArray_;
    CMRHistoryItem    *item_;
    
    itemArray_ = [self mutableHistoryItemArrayForType : aType];
    if (anIndex >= [itemArray_ count])
        return;
    
    item_ = [[itemArray_ objectAtIndex : anIndex] retain];
    [itemArray_ removeObjectAtIndex : anIndex];
    
    [self makeClientsPerform:CMRHistoryManagerClientPerformRemove historyItem:item_ atIndex:anIndex];
    [item_ autorelease];
}

- (int) indexOfOldestItemForType : (int) aType
{
    NSArray *itemArray = [self mutableHistoryItemArrayForType : aType];
    int i, cnt = [itemArray count];
    CMRHistoryItem *oldest = nil;
    int oldestIndex = -1;

    for (i = 0; i < cnt; i++) {
        CMRHistoryItem *item = [itemArray objectAtIndex : i];
        
        if (nil == oldest || NSOrderedDescending == [[oldest historyDate] compare : [item historyDate]]) 
        {
            oldest = item;
            oldestIndex = i;
        }
    }
    return oldestIndex;
}

- (void) addItem : (CMRHistoryItem *) anItem
{
    int					performType_;
    CMRHistoryItem		*item_ = anItem;
    NSMutableArray		*itemArray_;
	NSMutableArray		*newArray_;
    
    unsigned		index_;
    unsigned		limit_;
    
    UTILAssertNotNilArgument(anItem, @"Item");
    
    limit_ = [self historyItemLimitForType : [anItem type]];
    itemArray_ = [self mutableHistoryItemArrayForType : [anItem type]];
    if ((index_ = [itemArray_ indexOfObject : anItem]) != NSNotFound) {
        // Update
        item_ = [itemArray_ objectAtIndex : index_];
        		
        [item_ setTitle : [anItem title]];
        [item_ setRepresentedObject : [anItem representedObject]];
        [item_ setHistoryDate : [NSDate date]];
        
        [item_ incrementVisitedCount];
        /*if ([item_ visitedCount] == PreciousItemThreshold) {
            // An item should become a precious item.
            
        }*/
		
		[itemArray_ exchangeObjectAtIndex: index_ withObjectAtIndex: 0];

        performType_ = CMRHistoryManagerClientPerformChange;
		
    } else {
        if (limit_ == [itemArray_ count]) { // Check limit
            int idx;
            
            idx = [self indexOfOldestItemForType : [anItem type]];
            UTILDebugWrite1(@"Oldest Item is %@.", 
                [itemArray_ objectAtIndex : idx]);
            [self removeItemForType:[anItem type] atIndex:idx];
        }
        
        // New Entry
        [itemArray_ insertObject : anItem atIndex : 0];
        performType_ = CMRHistoryManagerClientPerformAdd;
        index_ = 0; //[itemArray_ count] -1;
    }

	// sort by date
	newArray_ = [[itemArray_ sortedArrayUsingSelector : @selector(_compareByDate:)] mutableCopy];
    [itemArray_ removeAllObjects];
	[itemArray_ addObjectsFromArray : newArray_];
	
	[newArray_ release];
	
    [self makeClientsPerform:performType_ historyItem:item_ atIndex:index_];
}

- (CMRHistoryItem *) addItemWithTitle : (NSString *) aTitle
                                 type : (int       ) aType
                               object : (id        ) aRepresentedObject
{
    CMRHistoryItem    *item_;
    
    item_ = [[CMRHistoryItem alloc] initWithTitle:aTitle type:aType];
    [item_ setRepresentedObject : aRepresentedObject];
    
    [self addItem : item_];
    return [item_ autorelease];
}

#pragma mark -

#define kHistoryItemEntriesKey        @"HistoryDates"
#define kHistoryFileVersionKey        @"HistoryFileVersion"
#define kHistoryFileVersionAllowed    1

static NSString *const stHistoryPropertyKey[] = 
{
    @"Board",
    @"Thread",
    @"SearchListOption"
};

- (void) removeAllItems
{
    [self clearHistoryItemsBacket];
}

- (void) loadDictionaryRepresentation : (NSDictionary *) aDictionary
{
    NSDictionary    *dict_;
    int                fileVersion_;
    unsigned        i;
    
    if (nil == aDictionary)
        return;
    
    fileVersion_ = [aDictionary integerForKey : kHistoryFileVersionKey];
    if (fileVersion_ != kHistoryFileVersionAllowed) {
        NSLog(@"History FileVersion(%d) was not supported!", fileVersion_);
        return;
    }
    [self clearHistoryItemsBacket];
    
    dict_ = [aDictionary dictionaryForKey : kHistoryItemEntriesKey];
    if (nil == dict_ || 0 == [dict_ count])
        return;
    
    for (i = 0; i < kHistoryItemsBacketCount; i++) {
        NSString        *key_;
        NSArray            *itemArray_;
        NSEnumerator    *iter_;
        id                entry_;
        
        key_ = stHistoryPropertyKey[i];
        itemArray_ = [dict_ arrayForKey : key_];
        if (nil == itemArray_ || 0 == [itemArray_ count])
            continue;
        
        iter_ = [itemArray_ objectEnumerator];
        while (entry_ = [iter_ nextObject]) {
            CMRHistoryItem    *historyItem_;
            
            historyItem_ = [CMRHistoryItem objectWithPropertyListRepresentation : entry_];
            if (nil == historyItem_)
                continue;
            
            [self addItem : historyItem_];
        }
    }
}

- (id) genHistoriesPropertyListRepresentation : (NSArray *) aHistories
{
    NSMutableArray    *historyArray_;
    NSEnumerator    *iter_;
    CMRHistoryItem    *item_;
    
    historyArray_ = [NSMutableArray array];
    iter_ = [aHistories objectEnumerator];
    while (item_ = [iter_ nextObject]) {
        id        obj_;
        
        obj_ = [item_ propertyListRepresentation];
        [historyArray_ addObject : obj_];
    }
    
    return historyArray_;
}

- (NSDictionary *) historiesPropertyListRepresentation
{
    NSMutableDictionary        *dict_;
    
    dict_ = [NSMutableDictionary dictionary];
    if (_backets != NULL) {
        unsigned    i, cnt;
        
        cnt = kHistoryItemsBacketCount;
        for (i = 0; i < cnt; i++) {
            id        obj_;
            
            obj_ = [self genHistoriesPropertyListRepresentation : _backets[i]];
            [dict_ setObject:obj_ forKey:stHistoryPropertyKey[i]];
        }
    }
    return dict_;
}

- (NSDictionary *) dictionaryRepresentation
{
    NSMutableDictionary        *dict_;
    
    dict_ = [NSMutableDictionary dictionary];
    [dict_ setInteger : kHistoryFileVersionAllowed
               forKey : kHistoryFileVersionKey];
    [dict_ setObject : [self historiesPropertyListRepresentation]
              forKey : kHistoryItemEntriesKey];
    
    return dict_;
}

- (void) applicationWillTerminate : (NSNotification *) theNotification
{
    NSDictionary    *dictionaryRepresentation_;
    
    UTILAssertNotificationName(
        theNotification,
        NSApplicationWillTerminateNotification);
    
    dictionaryRepresentation_ = [self dictionaryRepresentation];
    [dictionaryRepresentation_ writeToFile : [[self class] defaultFilepath]
                                atomically : YES];
}
@end

#pragma mark -

@implementation CMRHistoryItem
- (id) init
{
    if (self = [super init]) {
        [self setHistoryDate : [NSDate date]];
        [self setType : -1];
        [self setVisitedCount : 1];
    }
    return self;
}

- (id) initWithTitle : (NSString *) aTitle
                type : (int       ) aType
{
    if (self = [self init]) {
        [self setTitle : aTitle];
        [self setType : aType];
    }
    return self;
}

- (void) dealloc
{
    [_date release];
    [_title release];
    [_representedObject release];
    [super dealloc];
}

- (int) type
{
    return _type;
}

- (void) setType : (int) aType
{
    _type = aType;
}

- (NSString *) title
{
    return _title;
}

- (NSDate *) historyDate
{
    return _date;
}

- (id<CMRHistoryObject>) representedObject
{
    return _representedObject;
}

- (unsigned) visitedCount
{
    return _visitedCount;
}

- (void) setTitle : (NSString *) aTitle
{
    id        tmp;
    
    tmp = _title;
    _title = [aTitle retain];
    [tmp release];
}

- (void) setHistoryDate : (NSDate *) aDate
{
    id        tmp;
    
    tmp = _date;
    _date = [aDate retain];
    [tmp release];
}

- (void) setRepresentedObject : (id<CMRHistoryObject>) aRepresentedObject
{
    id        tmp;
    
    UTILAssertConformsTo(
        aRepresentedObject,
        @protocol(CMRPropertyListCoding));
        
    tmp = _representedObject;
    _representedObject = [aRepresentedObject retain];
    [tmp release];
}

- (void) setVisitedCount : (unsigned) aVisitedCount
{
    _visitedCount = aVisitedCount;
}

- (void) incrementVisitedCount
{
    _visitedCount++;
}

- (BOOL) hasRepresentedObject : (id) anObject
{
    id        obj;
    
    if (NO == [anObject conformsToProtocol : @protocol(CMRHistoryObject)])
        return NO;
    
    obj = [self representedObject];
    return (obj == anObject) ? YES : [obj isHistoryEqual : anObject];
}

- (NSComparisonResult) _compareByDate : (CMRHistoryItem *) anObject;
{
	NSDate	*date1, *date2;
	
	date1 = [self historyDate];
	date2 = [anObject historyDate];
	
	return [date2 compare : date1];
}

#pragma mark -

// CMRPropertyListCoding
#define kRepresentationTitleKey				@"Title"
#define kRepresentationDateKey				@"HistoryDate"
#define kRepresentationObjectKey			@"RepresentedObject"
#define kRepresentationClassKey				@"RepresentedClass"
#define kRepresentationTypeKey				@"HistoryType"
#define kRepresentationVisitedCountKey		@"VisitedCount"

+ (id) objectWithPropertyListRepresentation : (id) rep
{
    id            title_;
    NSDate        *date_;
    id            object_;
    int            type_;
    unsigned    count_;
    
    NSString    *className_;
    Class        class_;
    
    id            instance_;
    
    if (nil == rep || NO == [rep isKindOfClass : [NSDictionary class]])
        return nil;
    
    title_ = [rep objectForKey : kRepresentationTitleKey];
    date_ = [rep objectForKey : kRepresentationDateKey];
    UTILAssertKindOfClass(date_, NSDate);
    
    className_ = [rep stringForKey : kRepresentationClassKey];
    UTILAssertNotNil(className_);
    class_ = NSClassFromString(className_);
    UTILAssertNotNil(class_);
    
    object_ = [rep objectForKey : kRepresentationObjectKey];
    UTILAssertNotNil(object_);
    object_ = [class_ objectWithPropertyListRepresentation : object_];
    UTILAssertNotNil(object_);
    
    type_ = [rep integerForKey : kRepresentationTypeKey];
    count_ = [rep unsignedIntForKey : kRepresentationVisitedCountKey];
    
    instance_ = [[self alloc] initWithTitle : title_
                                       type : type_];
    
    [instance_ setRepresentedObject : object_];
    [instance_ setHistoryDate : date_];
    [instance_ setVisitedCount : count_];
    
    return instance_;
}

- (id) propertyListRepresentation
{
    NSMutableDictionary        *dict;
    
    dict = [NSMutableDictionary dictionary];
    
    [dict setNoneNil:[self title] forKey:kRepresentationTitleKey];
    [dict setNoneNil:[self historyDate] forKey:kRepresentationDateKey];
    [dict setNoneNil : NSStringFromClass([[self representedObject] class])
              forKey : kRepresentationClassKey];
    [dict setNoneNil : [[self representedObject] propertyListRepresentation] 
              forKey : kRepresentationObjectKey];
    [dict setNoneNil : [NSNumber numberWithInt : [self type]]
              forKey : kRepresentationTypeKey];
    [dict setNoneNil : [NSNumber numberWithUnsignedInt : [self visitedCount]]
              forKey : kRepresentationVisitedCountKey];
    
    return dict;
}

#pragma mark -

// ----------------------------------------
// NSCoding
// ----------------------------------------
- (id) initWithCoder : (NSCoder *) coder
{
    id        tmp;
    
    UTILMethodLog;

    if ([coder supportsKeyedCoding]) {
        
        tmp = [coder decodeObjectForKey:kRepresentationTitleKey];
        [self setTitle : tmp];

        tmp = [coder decodeObjectForKey:kRepresentationDateKey];
        [self setHistoryDate : tmp];

        tmp = [coder decodeObjectForKey:kRepresentationObjectKey];
        [self setRepresentedObject : tmp];
        
        _type = [coder decodeInt32ForKey:kRepresentationTypeKey];
        _type = [coder decodeInt32ForKey:kRepresentationVisitedCountKey];
        
    } else {
        tmp = [coder decodeObject];
        if ([[NSNull null] isEqual : tmp]) tmp = nil;
        [self setTitle : tmp];
        
        tmp = [coder decodeObject];
        if ([[NSNull null] isEqual : tmp]) tmp = nil;
        [self setHistoryDate : tmp];

        tmp = [coder decodeObject];
        if ([[NSNull null] isEqual : tmp]) tmp = nil;
        [self setRepresentedObject : tmp];

        [coder decodeValueOfObjCType:@encode(int) at:&_type];
        [coder decodeValueOfObjCType:@encode(unsigned int) at:&_visitedCount];
    }
    return self;
}

- (void) encodeWithCoder : (NSCoder *) encoder
{
    id        tmp;
    
    UTILMethodLog;
    
    if ([encoder supportsKeyedCoding]) {
        tmp = [self title];
        if (tmp != nil)
            [encoder encodeObject:tmp forKey:kRepresentationTitleKey];
        
        tmp = [self historyDate];
        if (tmp != nil)
            [encoder encodeObject:tmp forKey:kRepresentationDateKey];
        
        tmp = [self representedObject];
        if (tmp != nil)
            [encoder encodeObject:tmp forKey:kRepresentationObjectKey];
        
        [encoder encodeInt32:[self type] forKey:kRepresentationTypeKey];
        [encoder encodeInt32:[self type] forKey:kRepresentationVisitedCountKey];
    } else {
        tmp = [self title];
        if (nil == tmp) tmp = [NSNull null];
        [encoder encodeObject:tmp];

        tmp = [self historyDate];
        if (nil == tmp) tmp = [NSNull null];
        [encoder encodeObject:tmp];

        tmp = [self representedObject];
        if (nil == tmp) tmp = [NSNull null];
        [encoder encodeObject:tmp];

        [encoder encodeValueOfObjCType:@encode(int) at:&_type];
        [encoder encodeValueOfObjCType:@encode(unsigned int) at:&_visitedCount];
    }
}

#pragma mark -

// ----------------------------------------
// NSObject
// ----------------------------------------
- (NSString *) description
{
    return [NSString stringWithFormat :
                @"<%@ %p> title=%@ type=%d visited=%u date=%@ object=%@",
                [self className],
                self,
                [self title],
                [self type],
                [self visitedCount],
                [self historyDate],
                [self representedObject]];
}

- (BOOL) isEqual : (id) other
{
    id                obj1, obj2;
    BOOL            result = NO;
    CMRHistoryItem    *item_ = other;
    
    if (item_ == self) return YES;
    if (nil == item_) return NO;
    
    if (NO == [item_ isKindOfClass : [self class]])
        return [super isEqual : item_];
    
    result = ([self type] == [item_ type]);
    if (NO == result) return NO;
    
    obj1 = [self representedObject];
    obj2 = [item_ representedObject];
    result = (obj1 == obj2) ? YES : [obj1 isHistoryEqual : obj2];
    
    return result;
}
@end