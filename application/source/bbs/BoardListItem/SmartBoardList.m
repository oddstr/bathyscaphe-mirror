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
			
			favorites = [[[BoardListItem alloc] initForFavorites] autorelease];
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
// 絶対変更不可
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
+ (/*BoardListItemType*/ int) typeForItem : (id) item
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


// 名前が同じものは全く受け付けない。TODO 要変更
- (BOOL) addItem : (id) item
     afterObject : (id) target
{
	// 名前が同じものは全く受け付けない。TODO 要変更
	if ([topLevelItem itemForRepresentName : [item name] deepSearch : YES]) return NO;
	
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
@implementation NSNumber (Test)
- (unsigned) length
{
	NSLog (@"OIHDSFKJDLKFJSHDKHFKSDHFKEF") ;
	return 0;
}
- (NSRange) rangeOfString : (id) str options : (int) opt
{
	NSLog (@"OIHDSFKJDLKFJSHDKHFKSDHFKEF") ;
	return NSMakeRange (NSNotFound, 0) ;
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
	}
	
	if ([item hasChildren]) {
		result = [item itemAtIndex : index];
	}
	
	return result;
}
- (BOOL) outlineView : (NSOutlineView *) outlineView isItemExpandable : (id) item
{
	BOOL result = NO;
	
	if (nil == item) {
		result = YES;
	}
	
	if ([item hasChildren]) {
		result = YES;
	}
	
	return result;
}
- (int) outlineView : (NSOutlineView *) outlineView numberOfChildrenOfItem : (id) item
{
	int result = 0;
	
	if (nil == item) {
		result = [topLevelItem numberOfItem];
	}
	
	if ([item hasChildren]) {
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
		
		
        result = makeAttrStrFromStr ( obj ) ;
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


@end
