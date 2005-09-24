//
//  BSBoardListView.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/20.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSBoardListView.h"

static NSString	*const bgImage_focused	= @"boardListSelBgFocused";
static NSString *const bgImage_normal	= @"boardListSelBg";

@implementation BSBoardListView
#pragma mark Custom highlight drawing 
- (void) highlightSelectionInClipRect : (NSRect) clipRect
{
	NSImage	*image_;
	NSRect	rowRect;
	float	imgWidth, imgHeight;

	if (([[self window] firstResponder] == self) && [[self window] isKeyWindow])
		image_ = [NSImage imageAppNamed : bgImage_focused];
	else
		image_ = [NSImage imageAppNamed : bgImage_normal];

	rowRect	= [self rectOfRow : [self selectedRow]];

	imgWidth	= [image_ size].width;
	imgHeight	= [image_ size].height;

	[image_ setFlipped : [self isFlipped]];

	[self lockFocus];
	[image_ drawInRect : rowRect fromRect : NSMakeRect(0, 0, imgWidth, imgHeight) operation : NSCompositeCopy fraction : 1.0];
	[self unlockFocus];
}

#pragma mark Contextual menu handling
- (NSMenu *) menuForEvent : (NSEvent *) theEvent
{
	int row = [self rowAtPoint : [self convertPoint : [theEvent locationInWindow] fromView : nil]];

	if(![self isRowSelected : row]) [self selectRow : row byExtendingSelection : NO];
	if(row >= 0) {
		return [self menu];
	} else {
		return nil;
	}
}
@end
