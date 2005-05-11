//: NSMatrix-SGExtensions.h
/**
  * $Id: NSMatrix-SGExtensions.h,v 1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


@interface NSMatrix(FindingCellExtension)
- (NSCell *) cellAtPoint : (NSPoint) aPoint;
- (NSRect) cellFrameOfCell : (NSCell *) cell;
@end
