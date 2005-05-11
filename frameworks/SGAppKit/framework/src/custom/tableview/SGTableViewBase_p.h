//: SGTableViewBase_p.h
/**
  * $Id: SGTableViewBase_p.h,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGTableViewBase.h"
#import "UTILKit.h"
#import <SGAppKit/NSColor-SGExtensions.h>


#define kVerticalGridLineWidth		0.2f



@interface NSTableView (StripedColorDrawing)
- (void) synchronizeAllTableColumnAttributes;
- (void) synchronizeTableColumnAttributes : (NSTableColumn *) tableColumn;
@end
