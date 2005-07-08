//: CMRHistoryManager.h
/**
  * $Id: CMRHistoryManager.h,v 1.2 2005/07/08 20:56:24 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import "CocoMonar_Prefix.h"
#import "CMRHistoryObject.h"



enum {
	CMRHistoryBoardEntryType = 0,
	CMRHistoryThreadEntryType,
	//CMRHistorySearchListOptionEntryType, // deprecated in BathyScaphe 1.0.2
	
	CMRHistoryNumberOfEntryType
};



//
// ツールバーに使用するためにNSCodingが必要
//
@interface CMRHistoryItem : SGBaseObject<CMRPropertyListCoding, NSCoding>
{
	@private
	int						_type;
	unsigned				_visitedCount;
	NSString				*_title;
	NSDate					*_date;
	id<CMRHistoryObject>	_representedObject;
}
- (id) initWithTitle : (NSString *) aTitle
				type : (int       ) aType;

- (int) type;
- (void) setType : (int) aType;
- (NSString *) title;
- (void) setTitle : (NSString *) aTitle;
- (NSDate *) historyDate;
- (void) setHistoryDate : (NSDate *) aDate;
- (unsigned) visitedCount;
- (void) setVisitedCount : (unsigned) aVisitedCount;

- (id<CMRHistoryObject>) representedObject;
- (BOOL) hasRepresentedObject : (id) anObject;
- (void) setRepresentedObject : (id<CMRHistoryObject>) aRepresentedObject;

- (void) incrementVisitedCount;

- (NSComparisonResult) _compareByDate : (CMRHistoryItem *) anObject;
@end


@class CMRHistoryManager;
@protocol CMRHistoryClient<NSObject>
- (void) historyManager : (CMRHistoryManager *) aManager
	  insertHistoryItem : (CMRHistoryItem    *) anItem
				atIndex : (unsigned int       ) anIndex;
- (void) historyManager : (CMRHistoryManager *) aManager
	  removeHistoryItem : (CMRHistoryItem    *) anItem
				atIndex : (unsigned int       ) anIndex;
- (void) historyManager : (CMRHistoryManager *) aManager
	  changeHistoryItem : (CMRHistoryItem    *) anItem
				atIndex : (unsigned int       ) anIndex;
@end



typedef struct CMRHistoryClientEntry CMRHistoryClientEntry;

@interface CMRHistoryManager : NSObject
{
	@private
	id						*_backets;
	CMRHistoryClientEntry	*_clients;
}
+ (CMRHistoryManager *) defaultManager;

// retain/releaseはしない
- (void) addClient : (id<CMRHistoryClient>) aClient;
- (void) removeClient : (id<CMRHistoryClient>) aClient;

- (void) loadDictionaryRepresentation : (NSDictionary *) aDictionary;
- (NSDictionary *) dictionaryRepresentation;
- (void) removeAllItems;

- (NSArray *) historyItemArrayForType : (int) aType;

- (void) addItem : (CMRHistoryItem *) anItem;
- (CMRHistoryItem *) addItemWithTitle : (NSString *) aTitle
								 type : (int       ) aType
							   object : (id        ) aRepresentedObject;

- (void) removeItemForType : (int     ) aType
				   atIndex : (unsigned) anIndex;
@end
