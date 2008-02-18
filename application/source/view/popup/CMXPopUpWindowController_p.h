//
//  CMXPopUpWindowController_p.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/23.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMXPopUpWindowController.h"

#import "CocoMonar_Prefix.h"
#import <SGAppKit/SGAppKit.h>

#import "CMRPopUpTemplateKeys.h"
#import "CMXPopUpWindowManager.h"
#import "CMRThreadView.h"

#define DEFAULT_CONTENT_RECT		NSMakeRect(20.0f, 20.0f, 200.0f, 200.0f)
#define DEFAULT_CONTENT_WIDTH		200.0f
#define TITLEBAR_HEIGHT			16.0


@interface CMXPopUpWindowController(Private)
- (void)setScrollView:(NSScrollView *)aScrollView;
- (void)setTextView:(NSTextView *)aTextView;
- (void)setTextStorage:(NSTextStorage *)aTextStorage;
- (void)setTitlebar:(BSPopUpTitlebar *)aTitlebar;

- (void)restoreLockedPopUp:(BOOL)shouldPoof;
- (void)restoreLockedPopUp;
- (void)setupLockedPopUp;
@end


@interface CMXPopUpWindowController(ViewInitializer)
- (void)createUIComponents;
- (void)createPopUpWindow;
- (void)createScrollViewWithTitlebar;
- (void)createHTMLTextView;
- (void)updateLinkTextAttributes;
- (void)updateAntiAlias;
@end


@interface CMXPopUpWindowController(Resizing)
- (NSSize)maxSize;
- (NSRect)constrainWindowFrame:(NSRect)windowFrame;
- (void)sizeToFit;
@end
