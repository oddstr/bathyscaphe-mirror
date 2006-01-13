/**
  * $Id: CMRSplitView.m,v 1.4 2006/01/13 23:47:59 tsawada2 Exp $
  * 
  * CMRSplitView.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRSplitView.h"

@implementation CMRSplitView
static NSRect	bSRect;
static NSRect	bSDimRect;
static NSRect	bSVerRect;
static NSRect	bSDimVerRect;

#pragma mark Private Accessors
- (NSImage *) splitterBg
{
	if (_splitterBg == nil) {
		_splitterBg = [NSImage imageNamed : @"browserSplitter"];
		bSRect = NSMakeRect(0, 0, 1.0, 10.0);
		[_splitterBg setFlipped : [self isFlipped]];
	}
	return _splitterBg;
}

- (NSImage *) splitterDimple
{
	if (_splitterDimple == nil) {
		_splitterDimple = [NSImage imageNamed : @"browserSplitterDimple"];
		bSDimRect = NSMakeRect(0,0,8.0,10.0);
		[_splitterDimple setFlipped : [self isFlipped]];
	}
	return _splitterDimple;
}

- (NSImage *) splitterBgVertical
{
	if (_splitterBgVertical == nil) {
		_splitterBgVertical = [NSImage imageNamed : @"browserSplitterVertical"];
		bSVerRect = NSMakeRect(0,0,10.0,1.0);
		[_splitterBgVertical setFlipped : [self isFlipped]];
	}
	return _splitterBgVertical;
}

- (NSImage *) splitterDimpleVertical
{
	if (_splitterDimpleVertical == nil) {
		_splitterDimpleVertical = [NSImage imageNamed : @"browserSplitterDimpleVertical"];
		bSDimVerRect = NSMakeRect(0,0,10.0,8.0);
		[_splitterDimpleVertical setFlipped : [self isFlipped]];
	}
	return _splitterDimpleVertical;
}


#pragma mark Override

- (void) kfSetupResizeCursors
{
	// Mac OS X 10.3 �ȍ~�Ȃ̂ŁA���K�؂ȃJ�[�\�����g�p���邱�Ƃ��ł���B
    if (kfIsVerticalResizeCursor == nil)
    {
        kfIsVerticalResizeCursor = [[NSCursor resizeLeftRightCursor] retain];
    }
    if (kfNotIsVerticalResizeCursor == nil)
    {
        kfNotIsVerticalResizeCursor = [[NSCursor resizeUpDownCursor] retain];
    }
}

- (float)dividerThickness
{
	return 8.0;
}

- (void) drawDividerInRect : (NSRect) aRect
{
	if (![self isVertical]) {
		float dX;
		[[self splitterBg] drawInRect : NSInsetRect(aRect, 0, -1.0) fromRect : bSRect
							operation : NSCompositeCopy fraction : 1.0];
		
		dX = (NSWidth(aRect) - 8.0) * 0.5;
		[[self splitterDimple] drawInRect : NSInsetRect(aRect, dX, -1.0) fromRect : bSDimRect
							operation : NSCompositeCopy fraction : 1.0];
	} else {
		float dY;
		[[self splitterBgVertical] drawInRect : NSInsetRect(aRect, -1.0, 0) fromRect : bSVerRect 
									operation : NSCompositeCopy fraction : 1.0];
		dY = (NSHeight(aRect) - 10.0) * 0.5;
		[[self splitterDimpleVertical] drawInRect : NSInsetRect(aRect, -1.0, dY) fromRect : bSDimVerRect
										operation : NSCompositeCopy fraction : 1.0];
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
