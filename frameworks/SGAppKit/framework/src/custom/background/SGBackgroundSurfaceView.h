//: SGBackgroundSurfaceView.h
/**
  * $Id: SGBackgroundSurfaceView.h,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSView.h>


@interface SGBackgroundSurfaceView : NSView
{
	BOOL	m_showsFirstResponder;
	BOOL	m_keyboardFocusRingFlag;
	NSImage	*m_background;
	id		m_delegate;
}
@end



@interface SGBackgroundSurfaceView(Attributes)
- (id) delegate;
- (void) setDelegate : (id) aDelegate;
- (BOOL) showsFirstResponder;
- (void) setShowsFirstResponder : (BOOL) flag;
- (void) setNeedsUpdateKeyboardFocusRing : (BOOL) flag;
@end



@interface NSObject(SGBackgroundSurfaceViewDelegate)
- (BOOL) backgroundViewShowsKeyboardFocusRing : (SGBackgroundSurfaceView *) aView;
@end