//
//  SmartBoardList.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/18.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SmartBoardList.h"
#import <CocoMonar/CMRPropertyKeys.h>
#import "CMRFavoritesManager.h"
#import "CMRThreadSignature.h"
#import "BoardManager.h"
#import "AppDefaults.h"

@class BSBoardListView;

@interface SmartBoardList(Private)
- (void) registerFileManager : (NSString *) filepath;
- (BOOL) synchronizeWithFile:(NSString *)filepath;
- (void)registerNotification;
- (void)unregisterNotification;
@end

@implementation SmartBoardList(Private)
- (void) registerFileManager : (NSString *) filepath
{
    SGFileLocation *f;
	
	if(!listFilePath || ![listFilePath isEqualTo:filepath]) {
		
		f = [SGFileLocation fileLocationAtPath : filepath];
		if (nil == f) return;
		
		[[CMRFileManager defaultManager]
        addFileChangedObserver : self
					  selector : @selector(didUpdateBoardFile:)
					  location : f];
		
		id t = listFilePath;
		listFilePath = [filepath copy];
		[t release];
	}
}
- (BOOL) synchronizeWithFile:(NSString *)filepath
{
	id items;
	
	if(!filepath) return NO;
	
	items = [[BoardListItem alloc] initWithContentsOfFile : filepath];
	if(!items) {
		return NO;
	}
	
	if (![filepath isEqualTo : [[BoardManager defaultManager] defaultBoardListPath]]) {
		id favorites;
		
		favorites = [BoardListItem favoritesItem];
		if (favorites && [items isMutable]) {
			[items insertItem : favorites atIndex : 0];
		}
	}
	
	id temp = topLevelItem;
	topLevelItem = items;
	[temp release];
	
	[self setIsEdited:NO];
	
	return YES;
}

- (void)registerNotification
{
	id nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(updateItem:)
			   name:BoardListItemUpdateThreadsNotification
			 object:nil];
}

- (void)unregisterNotification
{
	id nc = [NSNotificationCenter defaultCenter];
	
	[nc removeObserver:self];
}
@end

@implementation SmartBoardList
- (id)init
{
	if(self = [super init]) {
		topLevelItem = [[BoardListItem alloc] initWithFolderName:@"Top"];
	}
	
	return self;
}
- (id) initWithContentsOfFile : (NSString *) path
{
	if (self = [super init]) {
		
		[self synchronizeWithFile: path];
		[self registerFileManager:path];
		isEdited = NO;
		[self registerNotification];
	}
	
	return self;
}

- (void) dealloc
{
	[self unregisterNotification];
	[topLevelItem release];
	[listFilePath release];
	
	[super dealloc];
}

- (NSString *) defaultBoardListPath
{
	return [[BoardManager defaultManager] defaultBoardListPath];
}

- (BOOL) writeToFile : (NSString *) filepath
		  atomically : (BOOL      ) flag
{
	id list = [topLevelItem plist];
	if (nil == list) return NO;
	
	return [list writeToFile : filepath
				  atomically : flag];
}

- (BOOL) isEdited
{
//	NSLog (@"Board.plist content --> \n%@", topLevelItem ) ;
	return isEdited;
}
- (void) setIsEdited : (BOOL) flag
{
	isEdited = flag;
}
// 絶対変更不可
- (NSArray *) boardItems
{
	return [topLevelItem items];
}
- (void) postBoardListDidChangeNotificationBoardEdited:(BOOL)flag
{
	[self setIsEdited : flag];
	[[NSNotificationCenter defaultCenter]
			postNotificationName : CMRBBSListDidChangeNotification
					      object : self];
}
- (void) postBoardListDidChangeNotification
{
	[self postBoardListDidChangeNotificationBoardEdited : YES];
}

- (BOOL) containsItemWithName: (NSString     *) name
					   ofType: (BoardListItemType) aType
{
	if([name isEqualToString: CMXFavoritesDirectoryName]) return YES;
	
	id item = [topLevelItem itemForRepresentName: name ofType: aType deepSearch: YES];
	
	return item != nil;
}

- (id) itemForName : (id) name
{
	return [topLevelItem itemForRepresentName: name deepSearch : YES];
}

- (id) itemWithNameHavingPrefix : (id) prefix // tsawada2 2007-02-10 added, For Type-To-Select search.
{
	return [topLevelItem itemWithRepresentNameHavingPrefix: prefix deepSearch: YES];
}

- (id) itemForName : (id) name ofType: (BoardListItemType) aType
{
	return [topLevelItem itemForRepresentName: name ofType:aType deepSearch : YES];
}

- (void) item : (id) item
      setName : (NSString     *) name
       setURL : (NSString     *) url
{
	[self setName:name toItem:item];
	[self setURL:url toItem:item];
}
- (void) setName : (NSString *) name toItem : (id) item
{
	[item setRepresentName : name];
	[self postBoardListDidChangeNotification];
}
- (void) setURL : (NSString *) urlString toItem : (id) item
{
	if ([item hasURL]) {
		[item setURLString : urlString];
		[self postBoardListDidChangeNotification];
	}
}
- (NSURL *) URLForBoardName : (id) name
{
	id item = [topLevelItem itemForName : name deepSearch : YES];
	
	if (item && [item hasURL]) {		
		return [item url];
	}
	
	return nil;
}
+ (BoardListItemType) typeForItem : (id) item
{
	return [BoardListItem typeForItem : item];
}
+ (BOOL) isBoard : (id) item
{
	return [BoardListItem isBoardItem : item];
}
+ (BOOL) isCategory : (id) item
{
	return [BoardListItem isFolderItem : item];
}
+ (BOOL) isFavorites : (id) item
{
	return [BoardListItem isFavoriteItem : item];
}

- (BOOL) addItem : (id) item
     afterObject : (id) target
{
	UTILAssertKindOfClass(item, BoardListItem);
	if(target) {
		UTILAssertKindOfClass(target, BoardListItem);
	}
	
	int type;
	if( BoardListCategoryItem == [(BoardListItem *)item type]) {
		type = BoardListCategoryItem;
	} else {
		type = BoardListBoardItem | BoardListSmartBoardItem;
	}
	if ([topLevelItem itemForRepresentName : [item name] ofType : type deepSearch : YES]) return NO;
	
	if (!target) {
		[topLevelItem addItem : item];
		[self postBoardListDidChangeNotification];
		return YES;
	}
	
	NS_DURING
		[topLevelItem insertItem : item afterItem : target deepSearch : YES];
	NS_HANDLER
		if (![NSRangeException isEqualTo : [localException name]]) {
			[localException raise];
		}
		NS_VALUERETURN (NO, BOOL) ;
	NS_ENDHANDLER
	
	[self postBoardListDidChangeNotification];
	
	return YES;
}
- (void) removeItem : (id) item
{
	[topLevelItem removeItem : item deepSearch : YES];
	[self postBoardListDidChangeNotification];
}

- (void)updateItem:(id)notification
{
	[self postBoardListDidChangeNotification];
}

- (void) didUpdateBoardFile:(NSNotification *) aNotification
{
    SGFileRef *f;
    NSString  *name;
	
    UTILAssertNotificationName(
							   aNotification,
							   CMRFileManagerDidUpdateFileNotification);
	UTILAssertNotificationObject(
								 aNotification,
								 [CMRFileManager defaultManager]);
    
    f = [[aNotification userInfo] objectForKey: kCMRChangedFileRef];
	name = [f filepath];
    name = [name lastPathComponent];
    
    if (NO == [name isEqualToString : [listFilePath lastPathComponent]]) {
        return;
    }
    
    [self synchronizeWithFile: [f filepath]];
	[self postBoardListDidChangeNotificationBoardEdited: NO];
}
@end

@implementation SmartBoardList (OutlineViewDelegate)
- (void) outlineView : (NSOutlineView *) olv
	willDisplayCell : (NSCell *) cell
	 forTableColumn : (NSTableColumn *) tableColumn
			   item : (id) item
{
	if ([[tableColumn identifier] isEqualToString : BoardPlistNameKey]) {
		[cell setImage : [item icon]];
	}
}
@end

@implementation SmartBoardList (OutlineViewDataSorce)
- (id) outlineView : (NSOutlineView *) outlineView child : (int) index ofItem : (id) item
{
	id result = nil;
	
	if (nil == item ) {
		result = [topLevelItem itemAtIndex : index];
	} else if ([item hasChildren]) {
		result = [item itemAtIndex : index];
	}
	
	return result;
}
- (BOOL) outlineView : (NSOutlineView *) outlineView isItemExpandable : (id) item
{
	BOOL result = NO;
	
	if (nil == item) {
		result = YES;
	} else if ([item hasChildren]) {
		result = YES;
	}
	
	return result;
}
- (int) outlineView : (NSOutlineView *) outlineView numberOfChildrenOfItem : (id) item
{
	int result = 0;
	
	if (nil == item) {
		result = [topLevelItem numberOfItem];
	} else if ([item hasChildren]) {
		result = [item numberOfItem];
	}
	
	return result;
}

// 掲示板リストだけでなく、「掲示板の追加」シートでも呼び出される
- (id) outlineView: (NSOutlineView *) outlineView objectValueForTableColumn: (NSTableColumn *) tableColumn byItem: (id) item
{
	if ([BoardPlistNameKey isEqualTo : [tableColumn identifier]]) {
        id obj = [item representName];
		if (!obj) {
			UTILDebugWrite(@"can not get represent name.");
			return nil;
		}
		if ([outlineView isKindOfClass: [BSBoardListView class]]) {
			NSAttributedString *string = [[NSAttributedString alloc] initWithString: obj attributes: [CMRPref boardListTextAttributes]];
			return [string autorelease];
		} else { // 「掲示板の追加」シートでは attributed string ではなくただの string で返す
			return obj;
		}
	} else if ([BoardPlistURLKey isEqualToString: [tableColumn identifier]] && [item hasURL]) { // URL カラムは「掲示板の追加」シートのみ
		return [[item url] absoluteString];
	} else {
		return nil;
	}
}
	
- (id) outlineView : (NSOutlineView *) outlineView itemForPersistentObject : (id) object
{
	return [topLevelItem itemForRepresentName: object deepSearch:YES];
}
- (id) outlineView : (NSOutlineView *) outlineView persistentObjectForItem : (id) item
{
	return [item representName];
}
- (BOOL) outlineView : (NSOutlineView *) outlineView
          writeItems : (NSArray       *) items
        toPasteboard : (NSPasteboard  *) pboard
{
	NSArray			*types_;
	BoardListItem	*board_;
	NSURL			*url_;
	
	if ([items containsObject : [BoardListItem favoritesItem]]) return NO;
	
	types_ = [NSArray arrayWithObject: CMRBBSListItemsPboardType];
	[pboard declareTypes : types_ owner : NSApp];
	[pboard setPropertyList : [items description] 
					forType : CMRBBSListItemsPboardType];
	
	board_ = [items lastObject];
	if ([board_ hasURL]) {
		[pboard addTypes: [NSArray arrayWithObjects: NSURLPboardType, NSStringPboardType, nil] owner: NSApp];
		url_ = [board_ url];
		UTILRequireCondition(url_ != nil, not_writtable);
	
		[url_ writeToPasteboard : pboard];
		[pboard setString : [url_ absoluteString] 
				  forType : NSStringPboardType];
	}
	
	return YES;

not_writtable:
	return NO;
}
- (BOOL) outlineView: (NSOutlineView *) outlineView handleDroppedThreads: (id) propertyListObject item: (id) item childIndex: (int) index
{
	if (item != [BoardListItem favoritesItem]) {
		return NO;
	}

	id<CMRPropertyListCoding>	plist_;
	CMRThreadSignature		*signature_;
	NSEnumerator			*iter_;
	CMRFavoritesManager		*fm_ = [CMRFavoritesManager defaultManager];
	BOOL					result_ = NO;

	iter_ = [propertyListObject objectEnumerator];
	while (plist_ = [iter_ nextObject]) {
		signature_ = [CMRThreadSignature objectWithPropertyListRepresentation: plist_];
		if ([fm_ addFavoriteWithSignature : signature_] && NO == result_) {
			result_ = YES;
		}
	}
	return result_;
}

- (BOOL) outlineView: (NSOutlineView *) outlineView handleDroppedBoards: (id) propertyListObject item: (id) item childIndex: (int) index
{
	id	items_;
	BoardListItem	*target_;
	
	NSEnumerator	*iter_;
	BoardListItem	*dropped_;

	items_ = [propertyListObject propertyList];
	
	target_ = (nil == item) ? topLevelItem : item;
	if(nil == target_)
		return NO;
	if(![target_ isMutable]) return NO;
	
	iter_ = [items_ reverseObjectEnumerator];
	while(dropped_ = [iter_ nextObject]){
		unsigned int	found_;
		NSString		*name_;
		BoardListItem	*original_;
		BoardListItem	*parent_;
		
		dropped_ = [BoardListItem baordListItemFromPlist : dropped_];
		if(!dropped_) continue;
		if([BoardListItem isFavoriteItem : dropped_]) continue;
		
		if((found_ = [target_ indexOfItem : dropped_]) != NSNotFound) {
			if(found_ < index){
				index -= 1;
			}
		}
		
		name_ = [dropped_ name];
		original_ = [topLevelItem itemForName : name_ ofType : [dropped_ type] deepSearch : YES];
		parent_ = [topLevelItem parentForItem : original_];
		/* TODO SmartBoardListItem の時の処理 */
		if(parent_ && [parent_ isMutable]) {
			[parent_ removeItem : original_];
		} else if(parent_) { /* 親があって且つimmutable */
			continue;
		}
		if(index < 0 || index >= [target_ numberOfItem]) {
			[target_ addItem : dropped_];
		} else {
			[target_ insertItem : dropped_ atIndex : index];
		}
	}
	[self postBoardListDidChangeNotification];
	
	[outlineView reloadData];
	return YES;
}

- (BOOL) outlineView : (NSOutlineView     *) outlineView
          acceptDrop : (id <NSDraggingInfo>) info
                item : (id                 ) item
          childIndex : (int                ) index
{
	NSPasteboard	*pboard_;
	NSString		*type_;
	
	pboard_ = [info draggingPasteboard];
	type_ = [pboard_ availableTypeFromArray: [NSArray arrayWithObjects: CMRBBSListItemsPboardType, BSThreadItemsPboardType, nil]];

	if ([type_ isEqualToString: CMRBBSListItemsPboardType]) {
		return [self outlineView: outlineView
			 handleDroppedBoards: [pboard_ propertyListForType: CMRBBSListItemsPboardType]
							item: item
					  childIndex: index];
	} else if ([type_ isEqualToString: BSThreadItemsPboardType]) {
		return [self outlineView: outlineView
			handleDroppedThreads: [pboard_ propertyListForType: BSThreadItemsPboardType]
							item: item
					  childIndex: index];
	} else {
		return NO;
	}
}
- (NSDragOperation) outlineView : (NSOutlineView     *) outlineView
                   validateDrop : (id <NSDraggingInfo>) info
                   proposedItem : (id                 ) item
             proposedChildIndex : (int                ) index;
{
	NSPasteboard *pboard_ = [info draggingPasteboard];

	if ([pboard_ availableTypeFromArray: [NSArray arrayWithObjects: BSThreadItemsPboardType, nil]] != nil) {
		NSArray			*threadSignatures_;
		NSEnumerator	*iter_;
		id<CMRPropertyListCoding>	plistRep_;
		CMRFavoritesManager	*fM = [CMRFavoritesManager defaultManager];
		CMRThreadSignature	*signature_;

		threadSignatures_ = [pboard_ propertyListForType: BSThreadItemsPboardType];
		iter_ = [threadSignatures_ objectEnumerator];
		while (plistRep_ = [iter_ nextObject]) {
			signature_ = [CMRThreadSignature objectWithPropertyListRepresentation: plistRep_];
			if (NO == [fM favoriteItemExistsOfThreadSignature: signature_]) {
				[outlineView setDropItem: [BoardListItem favoritesItem] dropChildIndex: NSOutlineViewDropOnItemIndex];
				return NSDragOperationCopy;
			}
		}
		return NSDragOperationNone;
	}

	if (index == 0) return NSDragOperationNone; // 「お気に入り」の上に他のリスト項目をドロップさせない
	if(item != nil && index < 0 &&  NO == [BoardListItem isFolderItem : item]){
		return NSDragOperationNone;
	}
	return NSDragOperationMove;
	
}
- (BOOL) outlineView : (NSOutlineView *) outlineView
             addItem : (id             ) item
           afterItem : (id             ) pointingItem
{
	if([self addItem : item afterObject : pointingItem]){
		[outlineView reloadData];
		return YES;
	}
	return NO;
}
@end

@implementation SmartBoardList (NSDraggingSource)
- (unsigned int) draggingSourceOperationMaskForLocal : (BOOL) localFlag
{
	if(localFlag)
		return (NSDragOperationCopy | NSDragOperationGeneric | NSDragOperationMove);
	
	return NSDragOperationGeneric;
}
@end
