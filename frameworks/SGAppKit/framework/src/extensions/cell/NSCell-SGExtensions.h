//: NSCell-SGExtensions.h
/**
  * $Id: NSCell-SGExtensions.h,v 1.2 2007/02/08 00:20:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSCell.h>

@interface NSCell(SGExtensions)
- (void) setAttributesFromCell : (NSCell *) aCell;
@end
