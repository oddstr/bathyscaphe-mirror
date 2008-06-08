//
//  CMRTextColumnCell.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/04/29.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRTextColumnCell.h"
#import <SGFoundation/SGFoundation.h>


@implementation CMRTextColumnCell
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
/*	
	// 一時凍結
	NSSize contentSize = [self cellSize];
	cellFrame.origin.y += (cellFrame.size.height - contentSize.height) / 2.0;
	cellFrame.size.height = contentSize.height;
*/
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}
@end


@implementation CMRRightAlignedTextColumnCell
static id rightParagraphStyle(void)
{
	static id pstyle = nil;
	if (!pstyle) {
		pstyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[pstyle setAlignment:NSRightTextAlignment];
	}
	return pstyle;
}

- (NSAttributedString *)attributedStringValue
{
	NSMutableAttributedString		*as;

	as = SGTemporaryAttributedString();
	[as setAttributedString:[super attributedStringValue]];
	[as addAttribute:NSParagraphStyleAttributeName value:rightParagraphStyle()];
	return as;
}
@end


@implementation BSIkioiCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect newFrame = NSInsetRect(cellFrame, 2.0, 2.0);
    [super drawWithFrame:newFrame inView:controlView];
}
@end
