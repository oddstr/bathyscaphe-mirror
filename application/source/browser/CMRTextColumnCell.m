/**
  * $Id: CMRTextColumnCell.m,v 1.4 2007/02/21 10:50:53 tsawada2 Exp $
  * 
  * CMRTextColumnCell.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRTextColumnCell.h"
#import <SGFoundation/SGFoundation.h>


@implementation CMRTextColumnCell
- (void) drawInteriorWithFrame: (NSRect) cellFrame inView: (NSView *) controlView
{
    NSSize contentSize = [self cellSize];
    cellFrame.origin.y += (cellFrame.size.height - contentSize.height) / 2.0;
    cellFrame.size.height = contentSize.height;

    [super drawInteriorWithFrame: cellFrame inView: controlView];
}
@end

@implementation CMRRightAlignedTextColumnCell
static id rightParagraphStyle(void)
{
	static id pstyle = nil;
	if(nil == pstyle){
		pstyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[pstyle setAlignment : NSRightTextAlignment];
	}
	return pstyle;
}

- (NSAttributedString *) attributedStringValue
{
	NSMutableAttributedString		*as;

	as = SGTemporaryAttributedString();
	[as setAttributedString : [super attributedStringValue]];
	[as addAttribute: NSParagraphStyleAttributeName value: rightParagraphStyle()];
	return as;
}
@end
