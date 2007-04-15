//: CMRHistoryManager.m
/**
  * $Id: CMRHistoryManager.m,v 1.8 2007/04/15 13:49:38 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRHistoryManager.h"
#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import "BoardListItem.h"

// assume item is precious if visitedCount >= PreciousItemThreshold
#define PreciousItemThreshold 5

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

		NSData			*data;
		NSDictionary	*rep;			
		NSString *errorStr;

		data = [NSData dataWithContentsOfFile: filepath_];
		if (data) {
			rep = [NSPropertyListSerialization propertyListFromData: data
												   mutabilityOption: NSPropertyListImmutable
															 format: NULL
												   errorDescription: &errorStr];
			if (!rep) {
				NSLog(@"CMRHistoryManager failed to read History.plist with NSPropertyListSerialization");
				rep = [NSDictionary dictionaryWithContentsOfFile : filepath_];
			}
		} else {
			rep = [NSDictionary dictionaryWithContentsOfFile : filepath_];
		}
		[self loadDictionaryRepresentation: rep];

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
    [[NSNotificationCenter defaultCenter] removeObserver : self];
    [self clearHistoryItemsBacket];
	[super dealloc];
}

- (unsigned) historyItemLimitForType : (int) aType
{
	switch(aType) {
    case CMRHistoryBoardEntryType:
        return [CMRPref maxCountForBoardsHistory];
    case CMRHistoryThreadEntryType:
        return [CMRPref maxCountForThreadsHistory];
    default:
        UTILUnknownSwitchCase(aType);
        return 10;
    }
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
    }

	// sort by date
	newArray_ = [[itemArray_ sortedArrayUsingSelector : @selector(_compareByDate:)] mutableCopy];
    [itemArray_ removeAllObjects];
	[itemArray_ addObjectsFromArray : newArray_];	
	[newArray_ release];
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
#define kHistoryFileVersionNew		  2

static NSString *const stHistoryPropertyKey[] = 
{
    @"Board",
    @"Thread",
};

- (void) removeAllItems
{
    [self clearHistoryItemsBacket];
}

- (void) loadDictionaryRepresentation : (NSDictionary *) aDictionary
{
    NSDictionary    *dict_;
    int                fileVersion_;
    unsigned        i,j;
	unsigned		max;
    
    if (nil == aDictionary)
        return;
    
    fileVersion_ = [aDictionary integerForKey : kHistoryFileVersionKey];
	if (fileVersion_ == kHistoryFileVersionAllowed) {
		NSLog(@"Ignore Old Board History.");
		j = 1;
	} else if (fileVersion_ == kHistoryFileVersionNew) {
//		NSLog(@"No Problem");
		j = 0;
	} else {
        NSLog(@"History FileVersion(%d) was not supported!", fileVersion_);
        return;
    }
    [self clearHistoryItemsBacket];
    
    dict_ = [aDictionary dictionaryForKey : kHistoryItemEntriesKey];
    if (nil == dict_ || 0 == [dict_ count])
        return;
    
    for (i = j; i < kHistoryItemsBacketCount; i++) {
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
    [dict_ setInteger : kHistoryFileVersionNew
               forKey : kHistoryFileVersionKey];
    [dict_ setObject : [self historiesPropertyListRepresentation]
              forKey : kHistoryItemEntriesKey];
    
    return dict_;
}

- (NSData *) binaryRepresentation
{
	NSString *errorStr;
	return [NSPropertyListSerialization dataFromPropertyList: [self dictionaryRepresentation]
													  format: NSPropertyListBinaryFormat_v1_0
											errorDescription: &errorStr];
}

- (void) applicationWillTerminate : (NSNotification *) theNotification
{    
    UTILAssertNotificationName(
        theNotification,
        NSApplicationWillTerminateNotification);

	[[self binaryRepresentation] writeToFile: [[self class] defaultFilepath] atomically: YES];
}
@end

@implementation CMRHistoryManager(NSMenuDelegate)
- (void) boardHistoryMenuNeedsUpdate: (NSMenu *) menu
{
	unsigned n = [menu numberOfItems];
	if (n > 0) {
		int i;
		for (i=n-1;i>=0;i--) {
			[menu removeItemAtIndex: i];
		}
	}

	NSArray	*historyItemsArray = [self historyItemArrayForType: CMRHistoryBoardEntryType];
	if (!historyItemsArray || [historyItemsArray count] == 0) {
		[menu addItemWithTitle: NSLocalizedString(@"No Board History", @"") action: NULL keyEquivalent: @""];
		return;
	} else {
		NSEnumerator *iter = [historyItemsArray reverseObjectEnumerator];
		CMRHistoryItem *eachItem;
		NSMenuItem *menuItem;
		NSString *title_;
		BoardListItem *item_;

		while (eachItem = [iter nextObject]) {
			title_ = [eachItem title];
			if (title_ == nil) continue;

			menuItem = [[NSMenuItem alloc] initWithTitle: title_ action: @selector(showBoardFromHistoryMenu:) keyEquivalent: @""];
			item_ = (BoardListItem *)[eachItem representedObject];

			[menuItem setTarget: [NSApp delegate]];
			[menuItem setImage: [item_ icon]];
			[menuItem setRepresentedObject: item_];

			[menu insertItem: menuItem atIndex: 0];
			[menuItem release];
		}
	}
}

- (void) menuNeedsUpdate: (NSMenu *) menu
{
	if ([menu delegate] != self) return;
	if ([menu supermenu] != [NSApp mainMenu]) {
		[self boardHistoryMenuNeedsUpdate: menu];
		return;
	}
	if ([menu numberOfItems] > 6/*4*/) {
		int i;
		for (i = [menu numberOfItems] - 2; i > 4/*2*/; i--) {
			[menu removeItemAtIndex: i];
		}
	}

	NSArray	*historyItemsArray = [self historyItemArrayForType: CMRHistoryThreadEntryType];
	if (!historyItemsArray || [historyItemsArray count] == 0) {
		return;
	} else {
		NSEnumerator *iter = [historyItemsArray reverseObjectEnumerator];
		CMRHistoryItem *eachItem;
		NSMenuItem *menuItem;
		NSString *title_;
		NSString *shortTitle_;

		[menu insertItem: [NSMenuItem separatorItem] atIndex: 5/*3*/];

		while (eachItem = [iter nextObject]) {
			title_ = [eachItem title];
			if (title_ == nil) title_ = @"";
			shortTitle_ = [title_ stringWithTruncatingForMenuItemOfWidth: 320.0 indent: NO activeItem: YES];

			menuItem = [[NSMenuItem alloc] initWithTitle: shortTitle_ action: @selector(showThreadFromHistoryMenu:) keyEquivalent: @""];

			if (NO == [shortTitle_ isEqualToString: title_]) {
				[menuItem setToolTip: title_];
			}
			[menuItem setTarget: nil];
			[menuItem setRepresentedObject: [eachItem representedObject]];

			[menu insertItem: menuItem atIndex: 5/*3*/];
			[menuItem release];
		}
	}
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

#pragma mark CMRPropertyListCoding

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
    
    return [instance_ autorelease];
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

#pragma mark NSCoding

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

#pragma mark NSObject

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
