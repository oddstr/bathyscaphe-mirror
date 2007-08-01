//: CMXPopUpWindowController.h
/**
  * $Id: CMXPopUpWindowController.h,v 1.5 2007/08/01 12:29:06 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CMXPopUpOwner.h"

@class BSThreadViewTheme, BSPopUpTitlebar;

@interface CMXPopUpWindowController : NSWindowController
{
	@private
	
	NSScrollView		*_scrollView;
	NSTextView			*_textView;
	NSTextStorage		*_textStorage;
	BSPopUpTitlebar		*m_titlebar;
	id		_object;
	BOOL	m_closable;
	
	BOOL	bs_usesSmallScroller;
	BOOL	bs_shouldAntialias;
	BOOL	bs_linkTextHasUnderline;
	BSThreadViewTheme *m_theme;
}
+ (float) popUpTrackingInsetWidth;

- (void) changeContextColorIfNeeded;

- (NSScrollView *) scrollView;
- (NSTextView *) textView;
- (NSTextStorage *) textStorage;
- (BSPopUpTitlebar *)titlebar;

- (BOOL) canPopUpWindow;
- (BOOL) mouseInWindowFrameInset : (float) anInset;

- (void) showPopUpWindowWithContext : (NSAttributedString *) context
                              owner : (id<CMXPopUpOwner>   ) owner
                       locationHint : (NSPoint             ) point;
- (void) performClose;

- (id) object;
- (void) setObject : (id) anObject;

- (BOOL) isClosable;
- (void) setClosable:(BOOL)closable;

// textView delegate
- (id<CMXPopUpOwner>) owner;
- (void) setOwner : (id<CMXPopUpOwner>) anOwner;
- (NSWindow *) ownerWindow;
@end


@interface CMXPopUpWindowController(Accessor)
- (void)updateBGColor;

- (BOOL)usesSmallScroller;
- (void)setUsesSmallScroller:(BOOL)TorF;
- (BOOL)shouldAntialias;
- (void)setShouldAntialias: (BOOL) TorF;
- (BOOL)linkTextHasUnderline;
- (void)setLinkTextHasUnderline:(BOOL)TorF;
- (BSThreadViewTheme *)theme;
- (void)setTheme:(BSThreadViewTheme *)aTheme;
@end
