//: NSScrollView-SGExtensions.h
/**
  * $Id: NSScrollView-SGExtensions.h,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSScrollView.h>


@interface NSScrollView(SGExtensions)
- (NSSize) contentSizeForFrameSize : (NSSize) aFrameSize;
- (NSSize) frameSizeForContentSize : (NSSize) contentSize;
@end
