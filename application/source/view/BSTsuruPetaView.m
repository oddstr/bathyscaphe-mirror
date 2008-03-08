//
//  BSTsuruPetaView.m
//  BathyScaphe (SGAppKit)
//
//  Created by Tsutomu Sawada on 06/06/22.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSTsuruPetaView.h"
#import <SGAppKit/NSBezierPath_AMShading.h>

@implementation BSTsuruPetaView
static NSColor	*upperStartColor;
static NSColor	*upperEndColor;
static NSColor	*bottomColor;

+ (void)initialize
{
	if (self == [BSTsuruPetaView class]) {
		upperStartColor = [[NSColor colorWithCalibratedRed:0.953 green:0.953 blue:0.953 alpha:1.0] retain];
		upperEndColor = [[NSColor colorWithCalibratedRed:0.988 green:0.988 blue:0.988 alpha:1.0] retain];
		bottomColor = [[NSColor colorWithCalibratedRed:0.902 green:0.902 blue:0.902 alpha:1.0] retain];
	}
}

- (void)drawRect:(NSRect)rect
{
	NSRect topRect, bottomRect;

	rect.size.height -= 1.0;
	NSDivideRect(rect, &bottomRect, &topRect, 12.0, NSMinYEdge);
	// 上ボーダー線の描画
	[[NSColor gridColor] set];
	NSRectFill(NSMakeRect(rect.origin.x, rect.origin.y+rect.size.height, rect.size.width, 1.0));
	// 下半分の塗り
	[bottomColor set];
	NSRectFill(bottomRect);
	// 上半分の塗り
	[[NSBezierPath bezierPathWithRect:topRect] linearGradientFillWithStartColor:upperStartColor endColor:upperEndColor];
}

- (BOOL)isOpaque
{
	return YES; // note that by default NSView returns "NO".
}
@end
