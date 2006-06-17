//
//  $Id: BSBoardListView.m,v 1.1 2006/06/17 07:37:54 tsawada2 Exp $
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
static NSRect	imgRectNormal;
static NSRect	imgRectFocused;

- (int) semiSelectedRow
{
	return _semiSelectedRow;
}

- (NSImage *) imageNormal
{
	return _imageNormal;
}

- (void) setImageNormal : (NSImage *) anImage
{
	[anImage retain];
	[_imageNormal release];
	_imageNormal = anImage;
	
	NSSize	tmp_ = [_imageNormal size];
	imgRectNormal = NSMakeRect(0, 0, tmp_.width, tmp_.height);

	[_imageNormal setFlipped : [self isFlipped]];
}

- (NSImage *) imageFocused
{
	return _imageFocused;
}

- (void) setImageFocused : (NSImage *) anImage
{
	[anImage retain];
	[_imageFocused release];
	_imageFocused = anImage;
	
	NSSize	tmp_ = [_imageFocused size];
	imgRectFocused = NSMakeRect(0, 0, tmp_.width, tmp_.height);

	[_imageFocused setFlipped : [self isFlipped]];
}

- (void) awakeFromNib
{
	_semiSelectedRow = -1;
	[self setImageNormal : [NSImage imageAppNamed : bgImage_normal]];
	[self setImageFocused : [NSImage imageAppNamed : bgImage_focused]];
}

- (void) dealloc
{
	[_imageNormal release];
	[_imageFocused release];
	[super dealloc];
}

#pragma mark Custom highlight drawing

- (void) highlightSelectionInClipRect : (NSRect) clipRect
{
	NSImage	*image_;
	NSRect	rowRect;
	NSRect	sourceRect;

	if (([[self window] firstResponder] == self) && [[self window] isKeyWindow]) {
		image_ = [self imageFocused];
		sourceRect = imgRectFocused;
	} else {
		image_ = [self imageNormal];
		sourceRect = imgRectNormal;
	}

	// 参考：<http://www.cocoadev.com/index.pl?NSIndexSet>
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
	[self setNeedsDisplay : YES]; // あまりスマートではないが、丸ごと描画し直す＝描いた枠を消す
	[[NSNotificationCenter defaultCenter] removeObserver : self];	
}

- (NSMenu *) menuForEvent : (NSEvent *) theEvent
{
	int row = [self rowAtPoint : [self convertPoint : [theEvent locationInWindow] fromView : nil]];

	if(![self isRowSelected : row]) {
		NSRect	tmpRect;
		tmpRect = [self rectOfRow : row];
		[self lockFocus];
		NSFrameRectWithWidth(tmpRect, 2.0); // 枠を描く
		[self unlockFocus];
		[self displayIfNeeded];

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
