//
//  $Id: BSTsuruPetaView.m,v 1.4 2007/12/11 17:09:37 tsawada2 Exp $
//  BathyScaphe -> SGAppKit
//
//  Created by Tsutomu Sawada on 06/06/22.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSTsuruPetaView.h"
//#import <SGAppKit/NSImage-SGExtensions.h>
#import <SGAppKit/NSBezierPath_AMShading.h>

//static NSString *const imgName = @"Spacer";

@implementation BSTsuruPetaView
//static NSImage	*bgPattern;
//static NSRect	bgPtnRect;
static NSColor	*foo;
static NSColor	*bar;
static NSColor	*hoge;

+ (void) initialize
{
	if (self == [BSTsuruPetaView class]) {
//		NSSize	size_;

//		bgPattern = [NSImage imageNamed: imgName loadFromBundle: [NSBundle bundleForClass: self]];
//		size_ = [bgPattern size];
		
//		bgPtnRect = NSMakeRect(0, 0, size_.width, size_.height);
		foo = [[NSColor colorWithCalibratedRed:0.953 green:0.953 blue:0.953 alpha:1.0] retain];
		bar = [[NSColor colorWithCalibratedRed:0.988 green:0.988 blue:0.988 alpha:1.0] retain];
		hoge = [[NSColor colorWithCalibratedRed:0.902 green:0.902 blue:0.902 alpha:1.0] retain];
	}
}

- (void) drawRect: (NSRect) rect
{
	NSRect topRect, bottomRect;
	rect.size.height -= 1.0;
	NSDivideRect(rect, &bottomRect, &topRect, 12.0, NSMinYEdge);
	[[NSColor gridColor] set];
	NSRectFill(NSMakeRect(rect.origin.x, rect.origin.y+rect.size.height, rect.size.width, 1.0));
	[hoge set];
	NSRectFill(bottomRect);
//	[bgPattern setFlipped: [self isFlipped]];
//	[bgPattern drawInRect: rect fromRect: bgPtnRect operation: NSCompositeCopy fraction: 1.0];
	[[NSBezierPath bezierPathWithRect:topRect] linearGradientFillWithStartColor:foo endColor:bar];
}

- (BOOL) isOpaque
{
	return YES; // note that by default NSView returns "NO".
}
@end
