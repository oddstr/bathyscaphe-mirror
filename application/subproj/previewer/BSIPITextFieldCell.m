//
//  BSIPITextFieldCell.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/10.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSIPITextFieldCell.h"


@implementation BSIPITextFieldCell
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect newRect = NSInsetRect(cellFrame, 0, 10.0);
	[super drawInteriorWithFrame:newRect inView:controlView];
}
@end
