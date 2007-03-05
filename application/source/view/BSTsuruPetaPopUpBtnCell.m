//
//  BSTsuruPetaPopUpBtnCell.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/06/23.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSTsuruPetaPopUpBtnCell.h"


@implementation BSTsuruPetaPopUpBtnCell
- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView *) controlView
{
	float	inset_x, height_, adjusted_Y_Origin;
	NSRect	adjustedFrame;

	inset_x = NSMinX(cellFrame) +2.0;
	adjusted_Y_Origin = cellFrame.origin.y+2.0;
	height_ = cellFrame.size.height;

	adjustedFrame = NSMakeRect(cellFrame.origin.x, adjusted_Y_Origin, cellFrame.size.width-5.0, height_);

	[super drawWithFrame: adjustedFrame inView: controlView];

	[[NSColor gridColor] set];
	NSRectFill(NSMakeRect(inset_x, adjusted_Y_Origin, 1.0, height_));
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(inset_x+1.0, adjusted_Y_Origin+1.0, 1.0, height_-1.0));
}
@end
