/**
  * $Id: SGHTMLView.h,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * SGHTMLView.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>



@interface SGHTMLView : NSTextView
{
	@private
	NSMutableArray			*_userDataArray;
	NSMutableDictionary		*_trackingRectTags;
	NSTrackingRectTag		_visibleRectTag;
}

- (BOOL) mouseClicked : (NSEvent *) theEvent
			  atIndex : (unsigned ) charIndex;
@end



@interface NSObject(SGHTMLViewDelegate)
- (NSArray *) HTMLViewFilteringLinkSchemes : (SGHTMLView *) aView;

- (void) HTMLView : (SGHTMLView *) aView
	 mouseEntered : (NSEvent	*) anEvent;
- (void) HTMLView : (SGHTMLView *) aView
	  mouseExited : (NSEvent	*) anEvent;

- (void)	HTMLView : (SGHTMLView *) aView
  mouseEnteredInLink : (id       ) aLink
	   inTrackingRect : (NSRect   ) aRect
			withEvent : (NSEvent	*) anEvent;
- (void)	 HTMLView : (SGHTMLView *) aView
  mouseExitedFromLink : (id			 ) aLink
	   inTrackingRect : (NSRect		 ) aRect
			withEvent : (NSEvent	*) anEvent;

- (BOOL) HTMLView : (SGHTMLView *) aView
	 mouseClicked : (NSEvent    *) theEvent
	      atIndex : (unsigned    ) charIndex;

// continuous mouseDown
- (BOOL)				 HTMLView : (SGHTMLView *) aView 
  shouldHandleContinuousMouseDown : (NSEvent	*) theEvent;
- (BOOL)	 HTMLView : (SGHTMLView *) aView 
  continuousMouseDown : (NSEvent	*) theEvent;
@end



// Notification
extern NSString *const SGHTMLViewMouseEnteredNotification;
extern NSString *const SGHTMLViewMouseExitedNotification;
