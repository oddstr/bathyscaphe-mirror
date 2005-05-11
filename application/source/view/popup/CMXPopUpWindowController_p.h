//: CMXPopUpWindowController_p.h
/**
  * $Id: CMXPopUpWindowController_p.h,v 1.1 2005/05/11 17:51:09 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMXPopUpWindowController.h"
#import "CocoMonar_Prefix.h"
#import "CMRThreadView.h"
#import <SGAppKit/SGAppKit.h>

#define DEFAULT_CONTENT_RECT		NSMakeRect(20.0f, 20.0f, 200.0f, 200.0f)
#define DEFAULT_CONTENT_WIDTH		200.0f




@interface CMXPopUpWindowController(Private)
- (void) setScrollView : (NSScrollView *) aScrollView;
- (void) setTextView : (NSTextView *) aTextView;
- (void) setTextStorage : (NSTextStorage *) aTextStorage;
@end



@interface CMXPopUpWindowController(ViewInitializer)
- (void) createUIComponents;
- (void) createHelpWindow;
- (void) createScrollView;
- (void) createHTMLTextView;
@end



@interface CMXPopUpWindowController(Resizing)
- (NSSize) maxSize;

- (NSRect) constrainWindowFrame : (NSRect) windowFrame;
- (void) sizeToFit;
@end
