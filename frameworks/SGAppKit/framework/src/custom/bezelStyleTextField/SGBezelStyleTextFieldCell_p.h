//: SGBezelStyleTextFieldCell_p.h
/**
  * $Id: SGBezelStyleTextFieldCell_p.h,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBezelStyleTextFieldCell.h"

#import "SGAppKitFrameworkDefines.h"
#import <SGAppKit/NSImage-SGExtensions.h>


#define kLeftSurfaceImageName		@"RoundedTextFieldSurfaceLeft"
#define kMiddleSurfaceImageName		@"RoundedTextFieldSurfaceMiddle"
#define kRightSurfaceImageName		@"RoundedTextFieldSurfaceRight"



@interface SGBezelStyleTextFieldCell(SurfaceImage)
+ (NSImage *) leftSurfaceImage;
+ (NSImage *) middleSurfaceImage;
+ (NSImage *) rightSurfaceImage;
- (NSImage *) compositedSurfaceImageForView : (NSView *) controlView;

- (NSRect) rectExpandSpacing : (NSRect) rect;
- (NSRect) rectInsetSpacing : (NSRect) rect;
@end