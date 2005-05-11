//: SGBackgroundSurfaceView_p.h
/**
  * $Id: SGBackgroundSurfaceView_p.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBackgroundSurfaceView.h"

#import "SGAppKitFrameworkDefines.h"
#import <SGAppKit/NSImage-SGExtensions.h>





@interface SGBackgroundSurfaceView(SurfaceImage)
+ (NSImage *) leftSurfaceImage;
+ (NSImage *) middleSurfaceImage;
+ (NSImage *) rightSurfaceImage;
- (NSImage *) compositedSurfaceImage;
@end