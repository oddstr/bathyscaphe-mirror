//: CMXPopUpWindowController.h
/**
  * $Id: CMXPopUpWindowController.h,v 1.4 2007/07/21 19:32:55 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CMXPopUpOwner.h"

@class BSThreadViewTheme;

@interface CMXPopUpWindowController : NSWindowController
{
	@private
	
	NSScrollView		*_scrollView;
	NSTextView			*_textView;
	NSTextStorage		*_textStorage;
	
	id		_object;
	BOOL	_closable;
	
//	BOOL	bs_usesAlternateTextColor;
//	NSColor *bs_alternateTextColor;
	BOOL	bs_usesSmallScroller;
	BOOL	bs_shouldAntialias;
	BOOL	bs_linkTextHasUnderline;
	BSThreadViewTheme *m_theme;
	NSTimer *m_timer;
}
+ (float) popUpTrackingInsetWidth;

- (void) changeContextColorIfNeeded;

- (NSScrollView *) scrollView;
- (NSTextView *) textView;
- (NSTextStorage *) textStorage;

- (BOOL) canPopUpWindow;
- (BOOL) mouseInWindowFrameInset : (float) anInset;

- (void) showPopUpWindowWithContext : (NSAttributedString *) context
                              owner : (id<CMXPopUpOwner>   ) owner
                       locationHint : (NSPoint             ) point;
- (void) performClose;

- (id) object;
- (void) setObject : (id) anObject;

- (BOOL) isClosable;
- (void) setIsClosable : (BOOL) TorF;

// textView delegate
- (id<CMXPopUpOwner>) owner;
- (void) setOwner : (id<CMXPopUpOwner>) anOwner;
- (NSWindow *) ownerWindow;
@end



@interface CMXPopUpWindowController(Accessor)
/*- (void) setBackgroundColor : (NSColor *) color;
- (NSColor *) backgroundColor;
- (void) setAlphaValue : (float) floatValue;
- (float) alphaValue;
- (BOOL) usesAlternateTextColor;
- (void) setUsesAlternateTextColor: (BOOL) TorF;
- (NSColor *) alternateTextColor;
- (void) setAlternateTextColor: (NSColor *) aColor;*/
- (BOOL) usesSmallScroller;
- (void) setUsesSmallScroller: (BOOL) TorF;
- (BOOL) shouldAntialias;
- (void) setShouldAntialias: (BOOL) TorF;
- (BOOL) linkTextHasUnderline;
- (void) setLinkTextHasUnderline: (BOOL) TorF;
- (BSThreadViewTheme *)theme;
- (void) setTheme:(BSThreadViewTheme *)aTheme;
@end
