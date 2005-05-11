/**
 * $Id: BoardList.m,v 1.1.1.1 2005/05/11 17:51:03 tsawada2 Exp $
 * 
 * BoardList.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "BoardList.h"
#import "BoardManager.h"
#import "CocoMonar_Prefix.h"


static BoardListItemType _dictionary_type(NSDictionary *item);
static NSDictionary *_searchItemInArray(NSMutableArray   *items,
										id                attribute,
										NSString         *key,
										BoardListItemType mask,
										NSMutableArray  **container,
										unsigned int     *index);



@implementation BoardList
- (void) registerFileManager : (NSString *) filepath
{
    SGFileLocation *f;
    
    f = [SGFileLocation fileLocationAtPath : filepath];
    if (nil == f) return;
    
   [[CMRFileManager defaultManager]
        addFileChangedObserver : self
        selector : @selector(didUpdateBoardFile:)
        location : f];
}
- (void) didUpdateBoardFile : (NSNotification *) aNotification
{
    SGFileRef *f;
    NSString  *name;
    
    id items = _boardItems;
    
    UTILAssertNotificationName(
		aNotification,
		CMRFileManagerDidUpdateFileNotification);
	UTILAssertNotificationObject(
		aNotification,
		[CMRFileManager defaultManager]);
    
    f = [[aNotification userInfo] objectForKey : kCMRChangedFileRef];
    name = [f filepath];
    name = [name lastPathComponent];
    
    if (NO == [name isEqualToString : _fileName]) {
        return;
    }
    
    [items retain];
    [self synchronizeWithFile : [f filepath]];
    [self postBoardListDidChangeNotification];
    [items autorelease];
    [self setIsEdited : NO];
}

- (id) initWithContentsOfFile : (NSString *) filepath
{
	if(self = [super init]){
		[self synchronizeWithFile : filepath];
        [self registerFileManager : filepath];
	}
	return self;
}
+ (NSString *) defaultBoardListPath
{
	return [[BoardManager defaultManager] defaultBoardListPath];
}
- (BOOL) writeToFile : (NSString *) filepath
          atomically : (BOOL      ) flag
{
	if(nil == [self boardItems]) return NO;
	
	return [[self boardItems] writeToFile : filepath
							   atomically : flag];
}
- (BOOL) synchronizeWithFile : (NSString *) filepath
{
	NSMutableArray	*list_;
	
    [_fileName autorelease];
    _fileName = [[filepath lastPathComponent] retain];
	list_ = [NSMutableArray arrayWithContentsOfFile : filepath];
    if (list_ != nil) {
        
	    [self setBoardItems : list_];
    }
	return (list_ != nil);
}


- (void) dealloc
{
	[_fileName release];
	[_boardItems release];
	[super dealloc];
}
- (BOOL) isEdited
{
	return _isEdited;
}
- (void) setIsEdited : (BOOL) flag
{
	_isEdited = flag;
}
- (NSMutableArray *) boardItems
{
	if(nil == _boardItems)
		_boardItems = [[NSMutableArray alloc] init];
	
	return _boardItems;
}
- (void) setBoardItems : (NSMutableArray *) aBoardItems
{
	id		tmp;
	
	tmp = _boardItems;
	_boardItems = [aBoardItems retain];
	[tmp autorelease];
}

- (void) postBoardListDidChangeNotification
{
	[self setIsEdited : YES];
	[[NSNotificationCenter defaultCenter]
			postNotificationName : CMRBBSListDidChangeNotification
					      object : self];
}
+ (BoardListItemType) typeForItem : (NSDictionary *) item
{
	return _dictionary_type(item);
}
+ (BOOL) isBoard : (NSDictionary *) item
{
	return (BoardListBoardItem == _dictionary_type(item));
}

+ (BOOL) isCategory : (NSDictionary *) item
{
	return (BoardListCategoryItem == _dictionary_type(item));
}

+ (BOOL) isFavorites : (NSDictionary *) item
{
	return (BoardListFavoritesItem == _dictionary_type(item));
}
- (BOOL) addItem : (NSDictionary   *) item
     afterObject : (NSDictionary   *) target
{
	NSString       *name_;
	NSDictionary   *item_;
	NSMutableArray *container_;
	unsigned int    index_;
	
	name_ = [item objectForKey : BoardPlistNameKey];
	if(nil == name_) return NO;
	
	if([self containsItemWithName : name_])
		return NO;
	
	item_ = [self itemForAttribute : [target objectForKey : BoardPlistNameKey]
					  attributeKey : BoardPlistNameKey
					     seachMask : (BoardListBoardItem | BoardListCategoryItem)
				     containsArray : &container_
					       atIndex : &index_];
	index_++;
	if(nil == item_){
		[[self boardItems] addObject : item];
	}else if(index_ == [container_ count]){
		[container_ addObject : item];
	}else{
		[container_ insertObject : item atIndex : index_];
	}
	[self postBoardListDidChangeNotification];
	return YES;
}

- (void) item : (NSMutableDictionary *) item
      setName : (NSString     *) name
       setURL : (NSString     *) url
{
	if(nil == item) return;
	if(nil == name && nil == url) return;
	
	if(name != nil){
		[item setObject : name
				 forKey : BoardPlistNameKey];
	}
	if(url != nil){
		[item setObject : url
				 forKey : BoardPlistURLKey];
	}
	[self postBoardListDidChangeNotification];
}
- (BOOL) containsItemWithName : (NSString     *) name
{
	NSDictionary *item_;

	item_ = [self itemForAttribute : name
					  attributeKey : BoardPlistNameKey
					     seachMask : (BoardListBoardItem | BoardListCategoryItem)
				     containsArray : NULL
					       atIndex : NULL];
	return (item_ != nil);
}

- (void) updateURL : (NSURL    *) anURL
      forBoardName : (NSString *) aName
{
	id item_;
	NSMutableArray *container_;
	unsigned int    index_;
	
	item_ = [self itemForAttribute : aName
					  attributeKey : BoardPlistNameKey
					     seachMask : BoardListBoardItem
				     containsArray : &container_
					       atIndex : &index_];
    if (nil == item_) {
        return;
    }
    
    item_ = [[item_ mutableCopy] autorelease];
    [container_ replaceObjectAtIndex:index_ withObject:item_];
    
    [self item:item_ setName:aName setURL:[anURL absoluteString]];
}
- (void) removeItemWithName : (NSString *) name
{
	NSDictionary   *item_;
	NSMutableArray *container_;
	unsigned int    index_;
	
	item_ = [self itemForAttribute : name
					  attributeKey : BoardPlistNameKey
					     seachMask : (BoardListBoardItem | BoardListCategoryItem)
				     containsArray : &container_
					       atIndex : &index_];
	if(item_ != nil){
		[container_ removeObjectAtIndex : index_];
	}
	[self postBoardListDidChangeNotification];
}

- (NSURL *) URLForBoardName : (NSString *) boardName
{
	NSDictionary *item_;
	NSString     *absolutepath_;
	item_ = [self itemForAttribute : boardName
			          attributeKey : BoardPlistNameKey
			             seachMask : BoardListBoardItem
		             containsArray : NULL
			               atIndex : NULL];
	
	if(nil == item_) return nil;
	absolutepath_ = [item_ objectForKey : BoardPlistURLKey];
	if(nil == absolutepath_) return nil;
	return [NSURL URLWithString : absolutepath_];
}

- (NSString *) boardNameForURL : (NSURL *) theURL
{
	NSDictionary *item_;

	item_ = [self itemForURL : theURL];
	if(nil == item_) return nil;
	return [item_ objectForKey : BoardPlistNameKey];
}


- (void) moveItem:(NSDictionary *)item direction:(int)direction
{
	NSString       *url_;
	NSString       *name_;
	NSDictionary   *item_;
	NSMutableArray *container_;
	unsigned int    index_;
	unsigned int    insert_index_ = NSNotFound;

	url_ = [item objectForKey : BoardPlistURLKey];
	name_ = [item objectForKey : BoardPlistNameKey];
	if( NULL != url_) {
                 item_ = [self itemForAttribute : url_
                         attributeKey : BoardPlistURLKey
                         seachMask : BoardListBoardItem
                         containsArray : &container_
                         atIndex : &index_];
         } else if ( NULL != name_ ) {
                 item_ = [self itemForAttribute : name_
                         attributeKey : BoardPlistNameKey
                         seachMask : (BoardListBoardItem | 
BoardListCategoryItem)
                         containsArray : &container_
                         atIndex : &index_];
         } else {
                 return;
         }
	
	if ( [item_ isEqual: [FavoritesList favoritesItem]] ) {
		return;
	}

         switch ( direction ) {
         case 0:
             if ( index_ == 0 ) {
                 return;
             }
             insert_index_ = index_ - 1;
             break;
         case 1:
             if ( index_ == [container_ count] - 1 ) {
                 return;
             }
             insert_index_ = index_ + 1;
             break;
         }
		 if(NSNotFound == insert_index_)
			return;
		
         [item retain];
         [container_ removeObjectAtIndex:index_];
         [container_ insertObject:item atIndex:insert_index_];
         [item release];
	[self postBoardListDidChangeNotification];
}
- (NSDictionary *) itemForName : (NSString *) name
{
	NSDictionary *item_;
	
	if(nil == name) return nil;
	if([CMXFavoritesDirectoryName isSameAsString : name])
		return [[self class] favoritesItem];
	
	item_ = [self itemForAttribute : name
			          attributeKey : BoardPlistNameKey
			             seachMask : (BoardListBoardItem | BoardListCategoryItem)
		             containsArray : NULL
			               atIndex : NULL];
		
	return item_;
}

- (NSDictionary *) itemForURL : (NSURL *) url
{
	NSDictionary *item_;
	NSString     *abstr_;
	
	abstr_ = (url != nil) ? [url absoluteString]
						  : @"";
						  
	item_ = [self itemForAttribute : abstr_
					  attributeKey : BoardPlistURLKey
					     seachMask : BoardListBoardItem
				     containsArray : NULL
					       atIndex : NULL];
	return item_;
}
- (NSDictionary *) itemForAttribute : (id               ) attribute
					   attributeKey : (NSString        *) key
                          seachMask : (BoardListItemType) mask
					  containsArray : (NSMutableArray **) container
					        atIndex : (unsigned int    *) index
{
	return _searchItemInArray([self boardItems],
							  attribute,
							  key,
							  mask,
							  container,
							  index);
}
@end



static BoardListItemType _dictionary_type(NSDictionary *item)
{
	if(nil == item) return BoardListUnknownItem;
	if(nil == [item objectForKey : BoardPlistNameKey])
		 return BoardListUnknownItem;
	
	if([item objectForKey : BoardPlistContentsKey] != nil)
		return BoardListCategoryItem;
	
	if([item objectForKey : BoardPlistURLKey] != nil){
		NSString *name_;
		
		name_ = [item objectForKey : BoardPlistNameKey];
		if([CMXFavoritesDirectoryName isSameAsString : name_])
			return BoardListFavoritesItem;
		
		return BoardListBoardItem;
	}
	return BoardListUnknownItem;
}


static NSDictionary *_searchItemInArray(NSMutableArray   *items,
										id                attribute,
										NSString         *key,
										BoardListItemType mask,
										NSMutableArray  **container,
										unsigned int     *index)
{
	unsigned int    index_;
	unsigned int    count_;
	
	if(container != NULL) *container = nil;
	if(index != NULL) *index = NSNotFound;

	if(nil == items || 0 == (count_ = [items count])){
		return nil;
	}
	
	for(index_ = 0; index_< count_; index_++){
		id entry_;
		id attr_;
		
		BoardListItemType type_;
		
		entry_ = [items objectAtIndex : index_];
		type_  = _dictionary_type(entry_);
		NSCAssert2(
			[entry_ isKindOfClass : [NSDictionary class]],
			@"Unknown format board.plist All Member must be <%@> but was <%@>",
			NSStringFromClass([NSDictionary class]),
			NSStringFromClass([entry_ class]));
		
		attr_ = [entry_ objectForKey : key];
		if(nil != attr_ && (mask & type_) && [attr_ isEqual : attribute]){
			if(container != NULL) *container = items;
			if(index != NULL) *index = index_;
			return entry_;
		}
		if(BoardListCategoryItem == type_){
			NSDictionary *found_;
			
			found_ = 
			  _searchItemInArray([entry_ objectForKey : BoardPlistContentsKey],
								 attribute,
								 key,
								 mask,
								 container,
								 index);
			if(found_ != nil) return found_;
		}
	}
	return nil;
}
