//
//  CMXPopUpWindowController.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/23.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@class BSThreadViewTheme, BSPopUpTitlebar;

@interface CMXPopUpWindowController : NSWindowController
{
	@private
	NSScrollView		*_scrollView;
	NSTextView			*_textView;
	NSTextStorage		*_textStorage;
	BSPopUpTitlebar		*m_titlebar;
	id					_object;
	BSThreadViewTheme	*m_theme;

	BOOL	m_closable;	
	BOOL	bs_usesSmallScroller;
	BOOL	bs_shouldAntialias;
	BOOL	bs_linkTextHasUnderline;
}

+ (float)popUpTrackingInsetWidth;
+ (float)popUpMaxWidthRate;

- (NSScrollView *)scrollView;
- (NSTextView *)textView;
- (NSTextStorage *)textStorage;
- (BSPopUpTitlebar *)titlebar;

- (BOOL)canPopUpWindow;
- (BOOL)mouseInWindowFrameInset:(float)anInset;

- (void)showPopUpWindowWithContext:(NSAttributedString *)context owner:(id)owner locationHint:(NSPoint)point;
- (void)performClose;

- (id)object;
- (void)setObject : (id)anObject;

- (BOOL)isClosable;
- (void)setClosable:(BOOL)closable;

// textView delegate
- (id)owner;
- (void)setOwner:(id)anOwner;
- (NSWindow *)ownerWindow;
@end


@interface CMXPopUpWindowController(Accessor)
- (void)updateBGColor;

- (BOOL)usesSmallScroller;
- (void)setUsesSmallScroller:(BOOL)TorF;
- (BOOL)shouldAntialias;
- (void)setShouldAntialias:(BOOL)TorF;
- (BOOL)linkTextHasUnderline;
- (void)setLinkTextHasUnderline:(BOOL)TorF;
- (BSThreadViewTheme *)theme;
- (void)setTheme:(BSThreadViewTheme *)aTheme;
@end
