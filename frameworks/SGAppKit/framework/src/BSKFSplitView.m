/**
  * $Id: BSKFSplitView.m,v 1.3 2007/01/07 17:04:24 masakih Exp $
  * 
  * BathyScaphe
  *
  * Copyright 2005-2006 BathyScaphe Project.
  * All rights reserved.
  */
#import "BSKFSplitView.h"
#import "NSImage-SGExtensions.h"

@implementation BSKFSplitView
static NSRect	bSRect;
static NSRect	bSDimRect;
static NSRect	bSVerRect;
static NSRect	bSDimVerRect;

#pragma mark Private Accessors
- (NSImage *) splitterBg
{
	if (_splitterBg == nil) {
		_splitterBg = [[NSImage imageNamed : @"browserSplitter"
						    loadFromBundle : [NSBundle bundleForClass : [self class]]] retain];

		bSRect = NSMakeRect(0, 0, 1.0, 10.0);
		[_splitterBg setFlipped : [self isFlipped]];
	}
	return _splitterBg;
}

- (NSImage *) splitterDimple
{
	if (_splitterDimple == nil) {
		_splitterDimple = [[NSImage imageNamed : @"browserSplitterDimple"
							    loadFromBundle : [NSBundle bundleForClass : [self class]]] retain];
		bSDimRect = NSMakeRect(0,0,8.0,10.0);
		[_splitterDimple setFlipped : [self isFlipped]];
	}
	return _splitterDimple;
}

- (NSImage *) splitterBgVertical
{
	if (_splitterBgVertical == nil) {
		_splitterBgVertical = [[NSImage imageNamed : @"browserSplitterVertical"
								    loadFromBundle : [NSBundle bundleForClass : [self class]]] retain];
		bSVerRect = NSMakeRect(0,0,10.0,1.0);
		[_splitterBgVertical setFlipped : [self isFlipped]];
	}
	return _splitterBgVertical;
}

- (NSImage *) splitterDimpleVertical
{
	if (_splitterDimpleVertical == nil) {
		_splitterDimpleVertical = [[NSImage imageNamed : @"browserSplitterDimpleVertical"
									    loadFromBundle : [NSBundle bundleForClass : [self class]]] retain];
		bSDimVerRect = NSMakeRect(0,0,10.0,8.0);
		[_splitterDimpleVertical setFlipped : [self isFlipped]];
	}
	return _splitterDimpleVertical;
}


#pragma mark Override

- (void) kfSetupResizeCursors
{
	// Mac OS X 10.3 以降なので、より適切なカーソルを使用することができる。
    if (kfIsVerticalResizeCursor == nil)
    {
        kfIsVerticalResizeCursor = [[NSCursor resizeLeftRightCursor] retain];
    }
    if (kfNotIsVerticalResizeCursor == nil)
    {
        kfNotIsVerticalResizeCursor = [[NSCursor resizeUpDownCursor] retain];
    }
}

- (float) dividerThickness
{
	return 10.0;
}

- (void) drawDividerInRect : (NSRect) aRect
{
	if (![self isVertical]) {
		float dX;
		[[self splitterBg] drawInRect: aRect fromRect: bSRect operation: NSCompositeCopy fraction: 1.0];
		
		dX = floor((NSWidth(aRect) - 8.0) * 0.5);
		[[self splitterDimple] drawInRect: NSMakeRect(aRect.origin.x+dX, aRect.origin.y, 8.0, 10.0)
								 fromRect: bSDimRect
								operation: NSCompositeCopy
								 fraction: 1.0];
	} else {
		float dY;
		[[self splitterBgVertical] drawInRect: aRect fromRect: bSVerRect operation: NSCompositeCopy fraction: 1.0];

		dY = floor((NSHeight(aRect) - 8.0) * 0.5);
		[[self splitterDimpleVertical] drawInRect: NSMakeRect(aRect.origin.x, aRect.origin.y+dY, 10.0, 8.0)
										 fromRect: bSDimVerRect
										operation: NSCompositeCopy
										 fraction: 1.0];
	}
}

- (void) dealloc
{
	[_splitterBg release];
	[_splitterDimple release];
	[_splitterBgVertical release];
	[_splitterDimpleVertical release];
	
	[super dealloc];
}
@end
