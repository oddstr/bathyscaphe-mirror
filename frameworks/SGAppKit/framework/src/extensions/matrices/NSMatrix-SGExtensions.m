//: NSMatrix-SGExtensions.m
/**
  * $Id: NSMatrix-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSMatrix-SGExtensions_p.h"


@implementation NSMatrix(FindingCellExtension)
- (NSCell *) cellAtPoint : (NSPoint) aPoint
{
	int		rowIndex_;
	int		columnIndex_;
	
	if(NO == [self getRow:&rowIndex_ column:&columnIndex_ forPoint:aPoint])
		return nil;
	
	return [self cellAtRow:rowIndex_ column:columnIndex_];
}
- (NSRect) cellFrameOfCell : (NSCell *) cell
{
	int		rowIndex_;
	int		columnIndex_;
	
	if(NO == [self getRow:&rowIndex_ column:&columnIndex_ ofCell:cell])
		return NSZeroRect;
	
	return [self cellFrameAtRow:rowIndex_ column:columnIndex_];
}
@end
