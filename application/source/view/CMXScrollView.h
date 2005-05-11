//: CMXScrollView.h
/**
  * $Id: CMXScrollView.h,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


/* accessory view alignment */
enum {
	CMXScrollViewHorizontalRight = 0,
	CMXScrollViewHorizontalLeft,
	CMXScrollViewVerticalTop,
	CMXScrollViewVerticalBottom,
	
	_CMXScrollViewAlignmentLast
};

@interface CMXScrollView : NSScrollView
{
	NSMutableArray		*_accessoryViews;
	NSView				*_cornerHandleView;
}
// Accessory Views
- (void) addAccessoryView : (NSView *) anAccessory
				alignment : (int     ) anAlignment;
- (void) addHorizontalAccessoryView : (NSView *) anAccessory;


// Corner View
- (NSView *) cornerHandleView;
- (void) setCornerHandleView : (NSView *) aCornerHandleView;
@end
