//: SGOutlineView_p.h
/**
  * $Id: SGOutlineView_p.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGOutlineView.h"

#import "UTILKit.h"
#import "SGTableViewBase_p.h"


@interface SGOutlineView(DrowingStripes)
- (void) fillWithStripedColorInRow : (int) rowIndex;
- (void) drawEmptyRows;
@end



@interface SGOutlineView(StripedLayoutSupport)
- (BOOL) shouldFillStripedAtRow : (int) rowIndex;
- (unsigned) numberOfEmptyRows;
- (int) numberOfRowsInVisibleRectIgnoreDataSource;
- (NSRect) visibleRectOfColumn : (int) columnIndex;
- (NSRect) rectOfRowIgnoreDataSource : (int) rowIndex;
@end



@interface SGOutlineView(VerticalGrid)
- (void) drawVerticalGridInClipRect : (NSRect) aRect;
- (void) strokeVerticalGridLineFromPoint : (NSPoint) p1 
								 toPoint : (NSPoint) p2;
@end
