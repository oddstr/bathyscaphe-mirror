//: NSTableView+CMXBrowser.m
/**
  * $Id: NSTableView+CMXBrowser.m,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSTableView+CMXBrowser.h"
#import "CMXComponents_p.h"


/*!
 * @define      kColumnAscendingIndicatorImage
 * @discussion  ヘッダのハイライト表示
 */
#define kColumnAscendingIndicatorImage		@"Ascending"
#define kColumnDescendingIndicatorImage		@"Descending"


/*!
 * @define      kDefaultRowHeight
 * @discussion  デフォルトの項目高さ
 */
#define kDefaultRowHeight			17.0f



@implementation NSTableView(CMXBrowser)
+ (NSImage *) headerSortImage : (BOOL) acsending
{
	return (acsending) 
				? [self headerSortImage]
				: [self headerReverseSortImage];
}
+ (NSImage *) headerSortImage
{
	// [NSTableView _defaultTableHeaderSortImage]
	return [NSImage imageAppNamed : kColumnAscendingIndicatorImage];
}
+ (NSImage *) headerReverseSortImage
{
	// [NSTableView _defaultTableHeaderReverseSortImage]
	return [NSImage imageAppNamed : kColumnDescendingIndicatorImage];
}

- (void) removeAllColumns
{
	NSEnumerator	*iter_;
	NSTableColumn	*column_;
	
	iter_ = [[self tableColumns] objectEnumerator];
	while(column_ = [iter_ nextObject]){
		UTILAssertKindOfClass(column_, NSTableColumn);
		
		[self removeTableColumn : column_];
	}
}
- (id) objectValueForTableColumn : (NSTableColumn *) aColumn
						   atRow : (int            ) rowIndex
{
	id		ds = [self dataSource];
	
	if(nil == aColumn) return nil;
	return [ds tableView:self objectValueForTableColumn:aColumn row:rowIndex];
}

- (void) setRowHeightColumnDataCellToFit
{
	NSEnumerator	*iter_;
	NSTableColumn	*column_;
	id				dataCell_  = nil;
	float			rowHeight_ = 0;
	
	if(0 == [self numberOfRows]){
		[self setRowHeight : kDefaultRowHeight];
		return;
	}
	
	iter_ = [[self tableColumns] objectEnumerator];
	while(column_ = [iter_ nextObject]){
		id		objectValue_;
		NSSize	cellSize_;
		
		dataCell_ = [column_ dataCellForRow : 0];
		if(nil == dataCell_) continue;
		
		objectValue_ = [self objectValueForTableColumn:column_ atRow:0];
		[dataCell_ setObjectValue : objectValue_];
		
		cellSize_ = [dataCell_ cellSize];
		if(cellSize_.height > rowHeight_)
			rowHeight_ = cellSize_.height;
		
		[dataCell_ setObjectValue : nil];
	}
	
	[self setRowHeight : rowHeight_];
}


- (BOOL) drawsBackground
{
	return (NO == [[self backgroundColor] isEqual : [NSColor whiteColor]]);
}
- (void) setDrawsBackground : (BOOL) flag
{
	if(NO == flag)
		[self setBackgroundColor : [NSColor whiteColor]];
}
@end




@implementation NSOutlineView(CMXBrowser)
- (void) removeAllColumns
{
	NSEnumerator	*iter_;
	NSTableColumn	*column_;
	NSTableColumn	*outlineTableColumn_;
	
	outlineTableColumn_ = [self outlineTableColumn];
	iter_ = [[self tableColumns] objectEnumerator];
	while(column_ = [iter_ nextObject]){
		UTILAssertKindOfClass(column_, NSTableColumn);
		
		if([outlineTableColumn_ isEqual : column_])
			[self setOutlineTableColumn : nil];
		else
			[self removeTableColumn : column_];
	}
}
- (id) objectValueForTableColumn : (NSTableColumn *) aColumn
						   atRow : (int            ) rowIndex
{
	id		ds = [self dataSource];
	id		item_ = [self itemAtRow : rowIndex];
	
	if(nil == aColumn) return nil;
	if(nil == item_) return nil;
	
	return [ds outlineView:self objectValueForTableColumn:aColumn byItem:item_];
}
@end
