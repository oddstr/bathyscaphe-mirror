//: SGTableView.m
/**
  * $Id: SGTableView-Drawing.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGTableView_p.h"



@implementation SGTableView(DrowingStripes)
- (void) fillWithStripedColorInRow : (int) rowIndex
{
	if([self shouldFillStripedAtRow : rowIndex]){
		NSRect		rectOfRow_;
		rectOfRow_ = [self rectOfRowIgnoreDataSource : rowIndex];
	
		[[self stripedColor] set];
		NSRectFill(rectOfRow_);
	}
}

- (void) drawEmptyRows
{
	unsigned		nempty_;
	
	nempty_ = [self numberOfEmptyRows];
	if(nempty_ > 0){
		int		i, max;
		
		i = [self numberOfRows];
		max = nempty_ + i;
		for(; i < max; i++){
			NSRect		rectOfRow_;
			
			rectOfRow_ = [self rectOfRowIgnoreDataSource : i];
			
			[self drawRow:i clipRect:rectOfRow_];
			
			// 上書きしてしまったグリッドを
			// 再描画する。
			if([self drawsGrid] && [self shouldFillStripedAtRow : i])
				[self drawVerticalGridInClipRect : rectOfRow_];
		}
	}
}
@end



@implementation SGTableView(StripedLayoutSupport)
- (BOOL) shouldFillStripedAtRow : (int) rowIndex
{
	return (rowIndex % 2 && rowIndex != [self selectedRow]);
}
- (int) numberOfRowsInVisibleRectIgnoreDataSource
{
	return (NSHeight([self visibleRect]) / [self rowHeight]);
}
- (unsigned) numberOfEmptyRows
{
	int		nrows_;
	int		nmax_;
	
	nrows_ = [self numberOfRows];
	nmax_ = [self numberOfRowsInVisibleRectIgnoreDataSource];
	
	if(nrows_ < nmax_)
		return (nmax_ - nrows_);
	
	return 0;
}
- (NSRect) visibleRectOfColumn : (int) columnIndex
{
	NSRect			rectOfColumn_;
	
	rectOfColumn_ = [self rectOfColumn : columnIndex];
	rectOfColumn_ = NSIntersectionRect([self visibleRect], rectOfColumn_);
	
	return rectOfColumn_;
}
- (NSRect) rectOfRowIgnoreDataSource : (int) rowIndex
{
	NSRect		rect_;
	NSSize		intercellSpacing_;
	
	if(rowIndex < [self numberOfRows])
		return [super rectOfRow : rowIndex];
	
	intercellSpacing_ = [self intercellSpacing];
	rect_ = [self visibleRect];
	rect_.size.height = ([self rowHeight] + intercellSpacing_.height);
	rect_.origin.y = rect_.size.height * rowIndex;
	
	return rect_;
}
@end



@implementation SGTableView(VerticalGrid)
- (void) strokeVerticalGridLineFromPoint : (NSPoint) p1 
								 toPoint : (NSPoint) p2
{
	NSBezierPath	*bezierPath_;
	
	bezierPath_ = [NSBezierPath bezierPath];
	[bezierPath_ setLineWidth : VGLID_LINE_WIDTH];
	
	// アンチエイリアスを
	// 避けるためにずらす。
	p1.x -= 0.5;
	p2.x -= 0.5;
	
	[bezierPath_ moveToPoint : p1];
	[bezierPath_ lineToPoint : p2];
	
	[[self gridColor] set];
	[bezierPath_ stroke];
}
- (void) drawVerticalGridInClipRect : (NSRect) aRect
{
	int		i, cnt;
	
	// 可視領域内のカラムの右端にグリッドを描画
	// 領域右端カラムはグリッドを描画する必要がない。
	cnt = ([self numberOfColumns] -1);
	for(i = 0; i < cnt; i++){
		NSRect			rectOfColumn_;
		NSPoint			p1, p2;
		
		rectOfColumn_ = [self visibleRectOfColumn : i];
		rectOfColumn_ = NSIntersectionRect(aRect, rectOfColumn_);
		
		if(NSEqualRects(NSZeroRect, rectOfColumn_))
			continue;
		
		
		p1 = NSMakePoint(NSMaxX(rectOfColumn_), 
						 NSMinY(rectOfColumn_));
		p2 = NSMakePoint(p1.x,
						 NSMaxY(rectOfColumn_));
		[self strokeVerticalGridLineFromPoint:p1 toPoint:p2];
	}
}
@end
