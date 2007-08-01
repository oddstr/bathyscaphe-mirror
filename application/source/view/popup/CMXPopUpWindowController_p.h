//: CMXPopUpWindowController_p.h
/**
  * $Id: CMXPopUpWindowController_p.h,v 1.3 2007/08/01 12:29:06 tsawada2 Exp $
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
#define TITLEBAR_HEIGHT			16.0



@interface CMXPopUpWindowController(Private)
- (void) setScrollView : (NSScrollView *) aScrollView;
- (void) setTextView : (NSTextView *) aTextView;
- (void) setTextStorage : (NSTextStorage *) aTextStorage;
- (void) setTitlebar:(BSPopUpTitlebar *)aTitlebar;

- (void)restoreLockedPopUp;
- (void)setupLockedPopUp;
@end



@interface CMXPopUpWindowController(ViewInitializer)
- (void) createUIComponents;
- (void) createPopUpWindow;
- (void) createScrollViewWithTitlebar;
- (void) createHTMLTextView;
- (void) updateLinkTextAttributes;
- (void) updateAntiAlias;

@end



@interface CMXPopUpWindowController(Resizing)
- (NSSize) maxSize;
- (NSRect) constrainWindowFrame : (NSRect) windowFrame;
- (void) sizeToFit;
@end
