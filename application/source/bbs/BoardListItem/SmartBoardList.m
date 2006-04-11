//
//  SmartBoardList.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/18.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SmartBoardList.h"

#import "BoardManager.h"
#import "AppDefaults.h"

@interface SmartBoardList (Test)
@end

@implementation SmartBoardList

- (id) initWithContentsOfFile : (NSString *) path
{
	if (self = [super init]) {
		
		topLevelItem = [[BoardListItem alloc] initWithContentsOfFile : path];
		
		if (![path isEqualTo : [[BoardManager defaultManager] defaultBoardListPath]]) {
			id favorites;
			
			favorites = [BoardListItem favoritesItem];
			if (favorites && [topLevelItem isMutable]) {
				[topLevelItem insertItem : favorites atIndex : 0];
			}
		}
		isEdited = NO;
	}
	
	return self;
}

- (void) dealloc
{
	[topLevelItem release];
	
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
// ê‚ëŒïœçXïsâ¬
- (NSArray *) boardItems
{
	return [topLevelItem items];
}
- (void) postBoardListDidChangeNotification
{
	[self setIsEdited : YES];
	[[NSNotificationCenter defaultCenter]
			postNotificationName : CMRBBSListDidChangeNotification
					      object : self];
}

- (id) itemForName : (id) name
{
	return [topLevelItem itemForRepresentName : name deepSearch : YES];
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

@end

@implementation SmartBoardList (Test)

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
- (void) outlineView : (NSOutlineView *) outlineView
    setDataCellImage : (NSImage       *) anImage
         tableColumn : (NSTableColumn *) tableColumn
			 forItem : (id             ) item
{
	id		cell_;
	int		rowIndex_;
	
	rowIndex_ = [outlineView rowForItem : item];
	cell_ = [tableColumn dataCellForRow : rowIndex_];
	
	if (cell_ != nil && [cell_ isKindOfClass : [NSBrowserCell class]]) {
		[cell_ setImage : anImage];
	}
}


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
static NSMutableAttributedString *makeAttrStrFromStr (NSString *source)
{
	NSMutableParagraphStyle *style_;
	style_ = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style_ setParagraphSpacingBefore : ( ([CMRPref boardListRowHeight] - [[CMRPref boardListFont] defaultLineHeightForFont]) / 2) ];
	
	NSDictionary *tmpAttrDict = [NSDictionary dictionaryWithObjectsAndKeys :
		[CMRPref boardListFont], NSFontAttributeName,
		[CMRPref boardListTextColor], NSForegroundColorAttributeName,
		style_, NSParagraphStyleAttributeName,
		NULL];
	
	[style_ release];
	
	return [[[NSMutableAttributedString alloc] initWithString : source attributes : tmpAttrDict] autorelease];
}
- (id) outlineView : (NSOutlineView *) outlineView
objectValueForTableColumn : (NSTableColumn *) tableColumn
		   byItem : (id) item
{
	id result = nil;
	
	if ([BoardPlistNameKey isEqualTo : [tableColumn identifier]]) {
        id obj = [item representName];
		
		
        result = makeAttrStrFromStr( obj );
	}
	
	return result;
}
	
/* optional methods
- (void) outlineView : (NSOutlineView *) outlineView setObjectValue : (id) object forTableColumn : (NSTableColumn *) tableColumn byItem : (id) item;
*/
- (id) outlineView : (NSOutlineView *) outlineView itemForPersistentObject : (id) object
{
	return [self itemForName : object];
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
	
	types_ = [NSArray arrayWithObjects : CMRBBSListItemsPboardType,
		NSURLPboardType,
		NSStringPboardType,
		nil];
	[pboard declareTypes : types_ 
				   owner : NSApp];
	[pboard setPropertyList : [items description] 
					forType : CMRBBSListItemsPboardType];
	
	board_ = [items lastObject];
	if ([board_ hasURL]) {
		url_ = [board_ url];
		UTILRequireCondition(url_ != nil, not_writtable);
	
		[url_ writeToPasteboard : pboard];
		[pboard setString : [url_ absoluteString] 
				  forType : NSStringPboardType];
	}
	
	return YES;
	
not_writtable:
		return YES;
}
- (BOOL) outlineView : (NSOutlineView     *) outlineView
          acceptDrop : (id <NSDraggingInfo>) info
                item : (id                 ) item
          childIndex : (int                ) index
{
	NSPasteboard	*pboard_;
	NSString		*type_;
	id				items_;
	BoardListItem	*target_;
	
	NSEnumerator	*iter_;
	BoardListItem	*dropped_;
	
	pboard_ = [info draggingPasteboard];
	type_ = [pboard_ availableTypeFromArray : 
		[NSArray arrayWithObjects : CMRBBSListItemsPboardType, nil]];
	if(NO == [CMRBBSListItemsPboardType isEqualToString : type_])
		return NO;
	
	items_ = [pboard_ propertyListForType : CMRBBSListItemsPboardType];
	items_ = [items_ propertyList];
	
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
		/* TODO SmartBoardListItem ÇÃéûÇÃèàóù */
		if(parent_ && [parent_ isMutable]) {
			[parent_ removeItem : original_];
		} else if(parent_) { /* êeÇ™Ç†Ç¡ÇƒäéÇ¬immutable */
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
- (NSDragOperation) outlineView : (NSOutlineView     *) outlineView
                   validateDrop : (id <NSDraggingInfo>) info
                   proposedItem : (id                 ) item
             proposedChildIndex : (int                ) index;
{
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
