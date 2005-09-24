//
//  SmartBoardList.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/18.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SmartBoardList.h"

#import "BoardListItem.h"
#import "AppDefaults.h"

@interface SmartBoardList (Test)
-(void)createTestTree;
@end

@implementation SmartBoardList

- (id) initWithContentsOfFile : (NSString *)path
{
	if (self = [super init]) {
//		topLevelItem = [[BoardListItem alloc] initWithFolderName:@"Top"];
		
		[self createTestTree];
	}
	
	return self;
}

- (void) dealloc
{
	[topLevelItem release];
	
	[super dealloc];
}

@end

@implementation SmartBoardList (Test)
- (id) URLForBoardName : (id) name
{
//	NSLog(@"CHECKKING ME! %s : %d", __FILE__, __LINE__);
	return nil;
}
- (id) itemForName : (id) name
{
	NSLog(@"CHECKKING ME! %s : %d", __FILE__, __LINE__);
	return nil;
}
- (NSString *) userBoardListPath
{
	NSString	*filepath_;
	
	filepath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
	return [filepath_ stringByAppendingPathComponent : CMRUserBoardFile];
}
- (NSString *) defaultBoardListPath
{
	NSString	*filepath_;
	
	filepath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
	return [filepath_ stringByAppendingPathComponent : CMRDefaultBoardFile];
}

-(void)createTestTree
{
	id favorites;
	
//	topLevelItem = [[BoardListItem alloc] initWithContentsOfFile:[self defaultBoardListPath]];
	topLevelItem = [[BoardListItem alloc] initWithContentsOfFile:[self userBoardListPath]];
	
	favorites = [[BoardListItem alloc] initForFavorites];
	if( favorites && [topLevelItem isMutable] ) {
		[topLevelItem insertItem:favorites atIndex:0];
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
	
	if(cell_ != nil && [cell_ isKindOfClass : [NSBrowserCell class]]){
		[cell_ setImage : anImage];
	}
}


- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	id result = nil;
	
	if(nil == item ) {
		result = [topLevelItem itemAtIndex:index];
	}
	
	if( [item hasChildren] ) {
		result = [item itemAtIndex:index];
	}
	
	return result;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	BOOL result = NO;
	
	if(nil == item) {
		result = YES;
	}
	
	if( [item hasChildren] ) {
		result = YES;
	}
	
	return result;
}
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	int result = 0;
	
	if(nil == item) {
		result = [topLevelItem numberOfItem];
	}
	
	if([item hasChildren] ) {
		result = [item numberOfItem];
	}
	
	return result;
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	id result = nil;
	
	if( [BoardPlistNameKey isEqualTo : [tableColumn identifier]] ) {
        NSImage                   *image_;
        NSMutableAttributedString *tmp;
        
        image_ = [item icon];
        NSDictionary *tmpAttrDict = [NSDictionary dictionaryWithObjectsAndKeys :
			[CMRPref boardListFont], NSFontAttributeName,
			[CMRPref boardListTextColor], NSForegroundColorAttributeName,
			NULL];
		tmp = [[[NSMutableAttributedString alloc] initWithString : @"StringGoesHere" attributes : tmpAttrDict] autorelease];
        
        [self outlineView:outlineView setDataCellImage:image_
			  tableColumn:tableColumn forItem:item];
        
        [tmp replaceCharactersInRange:[tmp range] withString:[item name]];
        result = tmp;
	}
	
	return result;
}
	
/* optional methods
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
*/
- (id)outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object
{
	return object;
}
- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
	return item;
}


@end