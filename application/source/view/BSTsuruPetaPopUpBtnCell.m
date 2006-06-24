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
	float	inset_x, inset_y;
	NSRect	adjustedFrame;

	inset_x = NSMinX(cellFrame) +3.0;
	inset_y = cellFrame.size.height-1.0;
	adjustedFrame = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y-1.0, cellFrame.size.width-2.0, cellFrame.size.height-1.0);

	[super drawWithFrame: adjustedFrame inView: controlView];

	[[NSColor gridColor] set];
	NSRectFill(NSMakeRect(inset_x, cellFrame.origin.y, 1.0, inset_y));
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(inset_x+1.0, cellFrame.origin.y+1.0, 1.0, inset_y));
}
@end
