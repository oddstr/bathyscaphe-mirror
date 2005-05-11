//: CMXPopUpWindowController.h
/**
  * $Id: CMXPopUpWindowController.h,v 1.1.1.1 2005/05/11 17:51:09 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CMXPopUpOwner.h"



@interface CMXPopUpWindowController : NSWindowController
{
	@private
	
	NSScrollView		*_scrollView;
	NSTextView			*_textView;
	NSTextStorage		*_textStorage;
	
	id		_object;
	BOOL	_closable;
}
+ (float) popUpTrackingInsetWidth;

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
- (void) setBackgroundColor : (NSColor *) color;
- (NSColor *) backgroundColor;
- (void) setIsSeeThrough : (BOOL) flag;
- (BOOL) isSeeThrough;

- (BOOL) autohidesScrollers;
- (BOOL) hasVerticalScroller;
- (BOOL) verticalScrollerIsSmall;
@end
