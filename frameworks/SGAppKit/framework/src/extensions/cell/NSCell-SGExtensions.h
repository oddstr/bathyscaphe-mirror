//: NSCell-SGExtensions.h
/**
  * $Id: NSCell-SGExtensions.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSCell.h>



/**
  *
  * @see SGBezelStyleTextField.h
  * @see SGBezelStyleTextFieldCell.h
  *
  */

#if MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_2

typedef enum {
	NSTextFieldSquareBezel  = 0,
	NSTextFieldRoundedBezel = 1
} NSTextFieldBezelStyle;

#endif



@interface NSCell(SGExtensions)
- (void) setAttributesFromCell : (NSCell *) aCell;
@end
