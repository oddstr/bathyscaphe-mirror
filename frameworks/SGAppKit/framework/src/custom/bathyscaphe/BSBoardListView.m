//
//  $Id: BSBoardListView.m,v 1.2 2006/06/25 17:06:42 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/20.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSBoardListView.h"
#import <SGAppKit/NSImage-SGExtensions.h>

static NSString	*const bgImage_focused	= @"boardListSelBgFocused";
static NSString *const bgImage_normal	= @"boardListSelBg";

@implementation BSBoardListView
static NSImage *imgNormal;
static NSImage *imgFocused;
static NSRect	imgRectNormal;
static NSRect	imgRectFocused;

- (int) semiSelectedRow
{
	return _semiSelectedRow;
}

- (NSRect) semiSelectedRowRect
{
	return _semiSelectedRowRect;
}

+ (NSImage *) imageNormal
{
	return imgNormal;
}

+ (NSImage *) imageFocused
{
	return imgFocused;
}

+ (void) initialize
{
	if (self == [BSBoardListView class]) {
		imgNormal = [NSImage imageAppNamed: bgImage_normal];
		imgFocused = [NSImage imageAppNamed: bgImage_focused];
		
		[imgNormal setFlipped: YES];
		[imgFocused setFlipped: YES];

		NSSize	tmp_ = [imgNormal size];
		imgRectNormal = NSMakeRect(0, 0, tmp_.width, tmp_.height);

		NSSize	tmp2_ = [imgFocused size];
		imgRectFocused = NSMakeRect(0, 0, tmp2_.width, tmp2_.height);

	}
}

- (void) awakeFromNib
{
	_semiSelectedRow = -1;
	_semiSelectedRowRect = NSZeroRect;
}

#pragma mark Custom highlight drawing

- (void) highlightSelectionInClipRect : (NSRect) clipRect
{
	NSImage	*image_;
	NSRect	rowRect;
	NSRect	sourceRect;

	if (([[self window] firstResponder] == self) && [[self window] isKeyWindow]) {
		image_ = [[self class] imageFocused];
		sourceRect = imgRectFocused;
	} else {
		image_ = [[self class] imageNormal];
		sourceRect = imgRectNormal;
	}

	// cf. <http://www.cocoadev.com/index.pl?NSIndexSet>
	{
		NSIndexSet *selected = [self selectedRowIndexes];
		int size = [selected lastIndex]+1;

		unsigned int arrayElement;
		NSRange e = NSMakeRange(0, size);

		[self lockFocus];
		while ([selected getIndexes:&arrayElement maxCount:1 inIndexRange:&e] > 0)
		{
			rowRect = [self rectOfRow : arrayElement];
			[image_ drawInRect : rowRect fromRect : sourceRect operation : NSCompositeCopy fraction : 1.0];
		}
		[self unlockFocus];
	}
}

#pragma mark Contextual menu handling
- (void) cleanUpSemiHighlightBorder : (NSNotification *) theNotification
{
	// erase the border
	[self setNeedsDisplayInRect: _semiSelectedRowRect];
	[[NSNotificationCenter defaultCenter] removeObserver : self];	
	_semiSelectedRowRect = NSZeroRect;
}

- (NSMenu *) menuForEvent : (NSEvent *) theEvent
{
	int row = [self rowAtPoint : [self convertPoint : [theEvent locationInWindow] fromView : nil]];

	if(![self isRowSelected : row]) {
		_semiSelectedRowRect = [self rectOfRow : row];
		// draw the border
		[self lockFocus];
		NSFrameRectWithWidth(_semiSelectedRowRect, 2.0);
		[self unlockFocus];
		[self displayIfNeededInRect: _semiSelectedRowRect];

		// This Notification is available in Mac OS X 10.3 and later.
 		[[NSNotificationCenter defaultCenter] addObserver : self
												 selector : @selector(cleanUpSemiHighlightBorder:)
													 name : NSMenuDidEndTrackingNotification
												   object : nil];
	}

	if(row >= 0) {
		_semiSelectedRow = row;
		return [self menu];
	} else {
		return nil;
	}
}
@end
