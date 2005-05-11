/**
  * $Id: BoardList-OVDataSource.m,v 1.1.1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * BoardList-OVDataSource.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "BoardList.h"
#import "CMXPreferences.h"
#import "CMRFavoritesManager.h"
#import "CMRThreadsList.h"
#import "CMXTemplateResources.h"
#import "CMRBBSListTemplateKeys.h"

#import <Cocoa/Cocoa.h>
#import "CocoMonar_Prefix.h"



@implementation BoardList(NSOutlineViewDataSource)
- (int)      outlineView : (NSOutlineView *) outlineView
  numberOfChildrenOfItem : (id             ) item
{
	if(nil == item) return [[self boardItems] count];
	return [[item objectForKey : BoardPlistContentsKey] count];
}

- (BOOL) outlineView : (NSOutlineView *) outlineView
    isItemExpandable : (id             ) item
{
	return ([item objectForKey : BoardPlistContentsKey] != nil);
}
- (id) outlineView : (NSOutlineView *) outlineView
             child : (int            ) index
            ofItem : (id             ) item
{
	NSArray *children_;
	
	children_ = (nil == item)
			  ? [self boardItems]
			  : [item objectForKey : BoardPlistContentsKey];
	return (index < [children_ count])
		 ? [children_ objectAtIndex : index]
		 : nil;
}

static NSImage *imageForType(BoardListItemType type)
{
	NSString	*imageName_ = nil;
	
	switch(type){
	case BoardListUnknownItem:
		imageName_ = nil;
		break;
	case BoardListFavoritesItem:
		imageName_ = kFavoritesImageName;
		break;
	case BoardListCategoryItem:
		imageName_ = kCategoryImageName;
		break;
	case BoardListBoardItem:
		imageName_ = kDefaultBBSImageName;
		break;
	default:
		imageName_ = nil;
		break;
	}
	return [NSImage imageAppNamed : imageName_];
}

static NSMutableAttributedString *textForType(BoardListItemType type)
{
	NSString	*key_ = nil;
	
	switch(type){
	case BoardListFavoritesItem:
		key_ = kBBSListFavoritesTextKey;
		break;
	case BoardListCategoryItem:
		key_ = kBBSListCategoryTextKey;
		break;
	case BoardListBoardItem:
		key_ = kBBSListDefaultTextKey;
		break;
	default:
		key_ = kBBSListDefaultTextKey;
		break;
	}
	return CMXTemplateResource(key_, nil);
}

- (void) outlineView : (NSOutlineView *) outlineView
    setDataCellImage : (NSImage       *) anImage
         tableColumn : (NSTableColumn *) tableColumn
			 forItem : (id             ) item
{
	id		cell_;
	int		rowIndex_;
	
	rowIndex_ = [outlineView rowForItem : item];
	cell_ = [tableColumn dataCellForRow : rowIndex_];
	
	if(cell_ != nil && [cell_ isKindOfClass : [NSBrowserCell class]]){
		[cell_ setImage : anImage];
	}
}
- (id)          outlineView : (NSOutlineView *) outlineView
  objectValueForTableColumn : (NSTableColumn *) tableColumn
                     byItem : (id             ) item
{
    NSString *identifier_;
    id        object_;
    
    UTILAssertKindOfClass(item, NSDictionary);
    
    identifier_ = [tableColumn identifier];
    object_ = [item objectForKey : [tableColumn identifier]];
    if (nil == object_)
        object_ = @"";
    
    if ([identifier_ isEqualToString : BoardPlistNameKey]){
        BoardListItemType         type_;
        NSImage                   *image_;
        NSMutableAttributedString *tmp;
        
        type_ = [[self class] typeForItem : item];
        image_ = imageForType(type_);
        tmp = textForType(type_);
        
        [self outlineView:outlineView setDataCellImage:image_
                        tableColumn:tableColumn forItem:item];
        
        [tmp replaceCharactersInRange:[tmp range] withString:object_];
        return tmp;
    }
    
    return object_;
}

- (id)        outlineView : (NSOutlineView *) outlineView
  itemForPersistentObject : (id             ) object
{
	return object;
}
- (id)        outlineView : (NSOutlineView *) outlineView
  persistentObjectForItem : (id             ) item
{
	return item;
}
- (BOOL) outlineView : (NSOutlineView *) outlineView
          writeItems : (NSArray       *) items
        toPasteboard : (NSPasteboard  *) pboard
{
	NSArray			*types_;
	NSDictionary	*board_;
	NSString		*path_;
	NSURL			*url_;
	if([items containsObject : [FavoritesList favoritesItem]])
		return NO;
	
	types_ = [NSArray arrayWithObjects : CMRBBSListItemsPboardType,
										 NSURLPboardType,
										 NSStringPboardType,
										 nil];
	[pboard declareTypes : types_ 
				   owner : NSApp];
	[pboard setPropertyList : [items description] 
					forType : CMRBBSListItemsPboardType];
	
	board_ = [items lastObject];
	path_ = [board_ objectForKey : BoardPlistURLKey];
	UTILRequireCondition(path_ != nil, not_writtable);
	url_ = [NSURL URLWithString : path_];
	UTILRequireCondition(url_ != nil, not_writtable);
	
	[url_ writeToPasteboard : pboard];
	[pboard setString : [url_ absoluteString] 
			  forType : NSStringPboardType];
	
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
	NSMutableArray	*target_;
	
	NSEnumerator	*iter_;
	NSDictionary	*dropped_;
	
	pboard_ = [info draggingPasteboard];
	type_ = [pboard_ availableTypeFromArray : 
				[NSArray arrayWithObjects : CMRBBSListItemsPboardType, nil]];
	if(NO == [CMRBBSListItemsPboardType isEqualToString : type_])
		return NO;
	
	items_ = [pboard_ propertyListForType : CMRBBSListItemsPboardType];
	items_ = [items_ propertyList];
	
	target_ = (nil == item) ? [self boardItems]
							: [item objectForKey : BoardPlistContentsKey];
	if(nil == target_)
		return NO;
	
	iter_ = [items_ reverseObjectEnumerator];
	while(dropped_ = [iter_ nextObject]){
		unsigned int	found_;
		NSString		*name_;
		
		if([[self class] isFavorites : dropped_]) continue;
		if((found_ = [target_ indexOfObject : dropped_]) != NSNotFound){
			if(found_ < index){
				index -= 1;
			}
		}
		name_ = [dropped_ objectForKey : BoardPlistNameKey];
		[self removeItemWithName : name_];
		if(index < 0 || index >= [target_ count])
			[target_ addObject : dropped_];
		else
			[target_ insertObject : dropped_ atIndex : index];
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
	if(item != nil && index < 0 &&  NO == [[self class] isCategory : item]){
		return NSDragOperationNone;
	}
	return NSDragOperationMove;
	
}
@end



@implementation BoardList(OutlineViewDataSource)
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



@implementation BoardList(SGOutlineViewDataSource)
- (NSString *) outlineView : (NSOutlineView *) outlineView
			toolTipForItem : (id			 ) item
{
	if(NO == [item respondsToSelector : @selector(objectForKey:)]) return nil;
	if([[self class] isCategory : item]) return nil;
	if([[self class] isFavorites : item]) return nil;
	
	return [item objectForKey : BoardPlistURLKey];
}
@end



@implementation BoardList(NSDraggingSource)
- (unsigned int) draggingSourceOperationMaskForLocal : (BOOL) localFlag
{
	if(localFlag)
		return (NSDragOperationCopy | NSDragOperationGeneric | NSDragOperationMove);
	
	return NSDragOperationGeneric;
}
@end



@implementation FavoritesList

+ (NSMutableDictionary *) favoritesItem
{
	static NSMutableDictionary *favorites_;
	if(nil == favorites_){
		favorites_ = [[NSMutableDictionary alloc] initWithObjectsAndKeys : 
						CMXFavoritesDirectoryName,	BoardPlistNameKey,
						@"",							BoardPlistURLKey,
						nil];
	}
	return favorites_;
}
- (int)      outlineView : (NSOutlineView *) outlineView
  numberOfChildrenOfItem : (id             ) item
{
	if(nil == item) return [[self boardItems] count] +1;
	return [[item objectForKey : BoardPlistContentsKey] count];
}

- (id) outlineView : (NSOutlineView *) outlineView
             child : (int            ) index
            ofItem : (id             ) item
{
	NSArray *children_;
	int      atIndex_;
	
	atIndex_ = index;
	if(nil == item){
		if(0 == atIndex_){
			return [[self class] favoritesItem];
		}
		atIndex_ -= 1;
	}
	
	children_ = (nil == item)
			  ? [self boardItems]
			  : [item objectForKey : BoardPlistContentsKey];
	return (atIndex_ < [children_ count])
		 ? [children_ objectAtIndex : atIndex_]
		 : nil;
}

- (NSDragOperation) outlineView : (NSOutlineView     *) outlineView
                   validateDrop : (id <NSDraggingInfo>) info
                   proposedItem : (id                 ) item
             proposedChildIndex : (int                ) index;
{
	NSPasteboard *pboard_;
	NSString     *availableType_;
	
	pboard_ = [info draggingPasteboard];
	availableType_ =
		[pboard_ availableTypeFromArray : 
			[NSArray arrayWithObjects : NSFilenamesPboardType, 
										nil]];
	
	if([availableType_ isEqualToString : NSFilenamesPboardType]){
		[outlineView setDropItem : [[self class] favoritesItem]
				  dropChildIndex : NSOutlineViewDropOnItemIndex];

		return NSDragOperationLink;
	}
	
	return [super outlineView : outlineView
				 validateDrop : info
				 proposedItem : item
		   proposedChildIndex : index];
}

- (BOOL) outlineView : (NSOutlineView     *) outlineView
          acceptDrop : (id <NSDraggingInfo>) info
                item : (id                 ) item
          childIndex : (int                ) index
{
	int				index_;
	NSPasteboard	*pboard_;
	NSString		*availableType_;
	
	pboard_ = [info draggingPasteboard];
	if(nil == pboard_) return NO;
	
	availableType_ =
		[pboard_ availableTypeFromArray : 
			[NSArray arrayWithObjects : NSFilenamesPboardType, 
										nil]];
	
	if([availableType_ isEqualToString : NSFilenamesPboardType]){
		NSArray			*filenames_;
		NSEnumerator	*iter_;
		NSString		*path_;
		
		
		if([[self class] favoritesItem] != item){
			return NO;
		}

		
		filenames_ = [pboard_ propertyListForType : NSFilenamesPboardType];
		iter_ = [filenames_ objectEnumerator];
		while(path_ = [iter_ nextObject]){
			BOOL			result_;
			
			result_ = 
				[[CMRFavoritesManager defaultManager] addFavoriteWithFilePath : path_];
			if(NO == result_)
				return NO;
		}
		return YES;
	}
	
	index_ = index;
	if(nil == item){
		index_ -= 1;
		if(index_ < 0) index_ = -1;
	}
	return [super outlineView : outlineView
				   acceptDrop : info
				         item : item
				   childIndex : index_];
}

- (NSDictionary *) itemForAttribute : (id               ) attribute
					   attributeKey : (NSString        *) key
                          seachMask : (BoardListItemType) mask
					  containsArray : (NSMutableArray **) container
					        atIndex : (unsigned int    *) index
{
	if([key isEqualToString : BoardPlistURLKey] && attribute != nil){
		if(NO == [attribute isKindOfClass : [NSString class]])
			return nil;
		if(0 == [(NSString*)attribute length])
			return [[self class] favoritesItem];
	}
	return [super itemForAttribute : attribute
					  attributeKey : key
                         seachMask : mask
					 containsArray : container
					       atIndex : index];
}

@end

