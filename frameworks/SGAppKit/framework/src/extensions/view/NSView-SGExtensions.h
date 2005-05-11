//: NSView-SGExtensions.h
/**
  * $Id: NSView-SGExtensions.h,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSClipView.h>
#import <AppKit/NSView.h>

@interface NSView(SGExtensions)
- (NSClipView *) enclosingClipView;
- (void) animationScrollPoint : (NSPoint       ) aPoint
                 animateValue : (float         ) animateValue
                     interval : (NSTimeInterval) timeInterval;
@end



@interface NSView(WorkingWithSubviews)
- (NSView *) subviewAtIndex : (unsigned) anIndex;
- (NSView *) firstSubview;
- (NSView *) secondSubview;
- (NSView *) lastSubview;
@end



@interface NSView(SGExtension_PrintingOperation)
- (NSImage *) PDFGraphicsImage;
- (NSImage *) PDFGraphicsImageInsideRect : (NSRect) rect;
@end